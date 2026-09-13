import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../db/database.dart';
import '../sync/sync_tables.dart';

/// 备份格式标记（导入时校验）。
const backupFormat = 'prinia.backup/v1';

/// 随备份迁移的偏好设置键。
///
/// 刻意排除 `install_device_id`（本机同步身份）与 `last_update_check_date`
/// （更新检查本机状态）。
const backupPrefKeys = <String>[
  'active_theme_id',
  'custom_themes',
  'pomodoro_work',
  'pomodoro_rest',
  'meal_first',
  'meal_second',
  'timetable_font_size',
  'device_name',
  'sync_peer_addresses',
];

/// 导入结果统计。
class BackupResult {
  /// 实际写入/覆盖的行数。
  final int applied;

  /// 因 LWW 判定为旧数据而跳过的行数。
  final int skipped;

  /// 恢复的偏好设置项数。
  final int prefs;

  const BackupResult({
    required this.applied,
    required this.skipped,
    required this.prefs,
  });
}

/// 导出全部业务数据（含软删除行，保留 uuid/updatedAt/deviceId）与偏好设置。
///
/// 复用同步适配器，导出内容与蓝牙同步的行格式完全一致。
Future<String> exportBackup(AppDatabase db) async {
  final tables = <String, dynamic>{};
  for (final adapter in buildSyncAdapters(db)) {
    tables[adapter.name] = await adapter.changesSince(0);
  }
  final sp = await SharedPreferences.getInstance();
  final prefs = <String, dynamic>{};
  for (final key in backupPrefKeys) {
    if (!sp.containsKey(key)) continue;
    prefs[key] = sp.get(key);
  }
  return const JsonEncoder.withIndent('  ').convert({
    'format': backupFormat,
    'exportedAt': DateTime.now().toIso8601String(),
    'tables': tables,
    'prefs': prefs,
  });
}

/// 导入备份：按 uuid 做 LWW 合并（不清空、不删除本地数据），并覆盖白名单偏好。
///
/// 同 uuid 以 `updatedAt` 新者为胜；导入行保留原 deviceId/时间戳，因此
/// 后续蓝牙同步不会把导入数据当成新改动重复传播。
Future<BackupResult> importBackup(String source, AppDatabase db) async {
  dynamic decoded;
  try {
    decoded = jsonDecode(source);
  } catch (_) {
    throw const FormatException('不是有效的 JSON 文件');
  }
  if (decoded is! Map || decoded['format'] != backupFormat) {
    throw const FormatException('不是 Prinia 数据备份文件');
  }

  final adapters = {for (final a in buildSyncAdapters(db)) a.name: a};
  var applied = 0;
  var skipped = 0;

  final tables = decoded['tables'];
  if (tables is Map) {
    await db.transaction(() async {
      for (final entry in tables.entries) {
        final adapter = adapters[entry.key];
        if (adapter == null) continue; // 未知表：忽略，保持向前兼容
        final rows = entry.value;
        if (rows is! List) continue;
        for (final row in rows) {
          if (row is! Map) continue;
          try {
            if (await adapter.applyLww(row.cast<String, dynamic>())) {
              applied++;
            } else {
              skipped++;
            }
          } catch (_) {
            skipped++;
          }
        }
      }
    });
  }

  var prefs = 0;
  final rawPrefs = decoded['prefs'];
  if (rawPrefs is Map) {
    final sp = await SharedPreferences.getInstance();
    for (final entry in rawPrefs.entries) {
      final key = entry.key;
      if (key is! String || !backupPrefKeys.contains(key)) continue;
      final v = entry.value;
      if (v is int) {
        await sp.setInt(key, v);
      } else if (v is double) {
        await sp.setDouble(key, v);
      } else if (v is bool) {
        await sp.setBool(key, v);
      } else if (v is String) {
        await sp.setString(key, v);
      } else if (v is List) {
        await sp.setStringList(key, v.whereType<String>().toList());
      } else {
        continue;
      }
      prefs++;
    }
  }

  return BackupResult(applied: applied, skipped: skipped, prefs: prefs);
}

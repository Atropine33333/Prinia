import 'package:drift/drift.dart';

import '../db/database.dart';

typedef Json = Map<String, dynamic>;

/// LWW 裁决：新时间戳胜；平局按 device_id 字典序大者胜。
bool lwwWins(int oldTs, String oldDev, int newTs, String newDev) =>
    newTs > oldTs || (newTs == oldTs && newDev.compareTo(oldDev) > 0);

/// 一张可同步表的适配器：提取增量、按行 LWW 落库。
class SyncTableAdapter {
  /// 协议中的表名（与 Drift 表的 SQL 名一致）。
  final String name;

  /// 自 [sinceMs]（不含）以来的全部变更行（含墓碑）。
  final Future<List<Json>> Function(int sinceMs) changesSince;

  /// 按 uuid 做 LWW 落库，返回是否实际写入。
  final Future<bool> Function(Json row) applyLww;

  const SyncTableAdapter({
    required this.name,
    required this.changesSince,
    required this.applyLww,
  });
}

/// 构建全部可同步表的适配器。
List<SyncTableAdapter> buildSyncAdapters(AppDatabase db) => [
      _accounts(db),
      _focusSessions(db),
      _courses(db),
      _customCategories(db),
      _appMeta(db),
    ];

// ── 工具 ────────────────────────────────────────────────────────

int _ts(Json row) => row['updatedAt'] as int? ?? 0;
String _dev(Json row) => row['deviceId'] as String? ?? '';

int? _asInt(Json row, String k) {
  final v = row[k];
  if (v == null) return null;
  return (v is num) ? v.toInt() : int.parse(v.toString());
}

bool _asBool(Json row, String k) => row[k] == true || row[k] == 1;

// ── accounts ────────────────────────────────────────────────────

SyncTableAdapter _accounts(AppDatabase db) {
  Future<List<Json>> changesSince(int since) async {
    final rows = await (db.select(db.accounts)
          ..where((t) => t.updatedAt.isBiggerOrEqualValue(since + 1)))
        .get();
    return rows.map((r) => r.toJson()).toList();
  }

  Future<bool> applyLww(Json row) async {
    final uuid = row['uuid'] as String;
    final existing = await (db.select(db.accounts)
          ..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    if (existing != null &&
        !lwwWins(existing.updatedAt, existing.deviceId, _ts(row), _dev(row))) {
      return false;
    }
    final companion = AccountsCompanion.insert(
      uuid: Value(uuid),
      amount: (row['amount'] as num).toDouble(),
      type: row['type'] as String,
      category: row['category'] as String,
      occurredAt: Value(_asInt(row, 'occurredAt') ?? 0),
      note: Value(row['note'] as String?),
      createdAt: Value(_asInt(row, 'createdAt') ?? 0),
      updatedAt: Value(_ts(row)),
      deviceId: Value(_dev(row)),
      isDeleted: Value(_asBool(row, 'isDeleted')),
    );
    existing == null
        ? await db.into(db.accounts).insert(companion)
        : await (db.update(db.accounts)..where((t) => t.uuid.equals(uuid)))
            .write(companion);
    return true;
  }

  return SyncTableAdapter(
      name: 'accounts', changesSince: changesSince, applyLww: applyLww);
}

// ── focus_sessions ──────────────────────────────────────────────

SyncTableAdapter _focusSessions(AppDatabase db) {
  Future<List<Json>> changesSince(int since) async {
    final rows = await (db.select(db.focusSessions)
          ..where((t) => t.updatedAt.isBiggerOrEqualValue(since + 1)))
        .get();
    return rows.map((r) => r.toJson()).toList();
  }

  Future<bool> applyLww(Json row) async {
    final uuid = row['uuid'] as String;
    final existing = await (db.select(db.focusSessions)
          ..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    if (existing != null &&
        !lwwWins(existing.updatedAt, existing.deviceId, _ts(row), _dev(row))) {
      return false;
    }
    final companion = FocusSessionsCompanion.insert(
      uuid: Value(uuid),
      durationSeconds: Value(_asInt(row, 'durationSeconds') ?? 0),
      startTime: Value(_asInt(row, 'startTime') ?? 0),
      endTime: _asInt(row, 'endTime') ?? 0,
      status: row['status'] as String,
      updatedAt: Value(_ts(row)),
      deviceId: Value(_dev(row)),
      isDeleted: Value(_asBool(row, 'isDeleted')),
    );
    existing == null
        ? await db.into(db.focusSessions).insert(companion)
        : await (db.update(db.focusSessions)..where((t) => t.uuid.equals(uuid)))
            .write(companion);
    return true;
  }

  return SyncTableAdapter(
      name: 'focus_sessions', changesSince: changesSince, applyLww: applyLww);
}

// ── courses ─────────────────────────────────────────────────────

SyncTableAdapter _courses(AppDatabase db) {
  Future<List<Json>> changesSince(int since) async {
    final rows = await (db.select(db.courses)
          ..where((t) => t.updatedAt.isBiggerOrEqualValue(since + 1)))
        .get();
    return rows.map((r) => r.toJson()).toList();
  }

  Future<bool> applyLww(Json row) async {
    final uuid = row['uuid'] as String;
    final existing = await (db.select(db.courses)
          ..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    if (existing != null &&
        !lwwWins(existing.updatedAt, existing.deviceId, _ts(row), _dev(row))) {
      return false;
    }
    final companion = CoursesCompanion.insert(
      uuid: Value(uuid),
      name: row['name'] as String,
      teacher: Value(row['teacher'] as String?),
      room: Value(row['room'] as String?),
      weekday: _asInt(row, 'weekday') ?? 1,
      startWeek: _asInt(row, 'startWeek') ?? 1,
      endWeek: _asInt(row, 'endWeek') ?? 16,
      weekParity: Value(_asInt(row, 'weekParity') ?? 0),
      startMinutes: Value(_asInt(row, 'startMinutes') ?? 480),
      durationMinutes: Value(_asInt(row, 'durationMinutes') ?? 60),
      colorHex: Value(row['colorHex'] as String? ?? '#7A9E9F'),
      remindersJson: Value(row['remindersJson'] as String? ?? '[]'),
      updatedAt: Value(_ts(row)),
      deviceId: Value(_dev(row)),
      isDeleted: Value(_asBool(row, 'isDeleted')),
    );
    existing == null
        ? await db.into(db.courses).insert(companion)
        : await (db.update(db.courses)..where((t) => t.uuid.equals(uuid)))
            .write(companion);
    return true;
  }

  return SyncTableAdapter(
      name: 'courses', changesSince: changesSince, applyLww: applyLww);
}

// ── custom_categories ───────────────────────────────────────────

SyncTableAdapter _customCategories(AppDatabase db) {
  Future<List<Json>> changesSince(int since) async {
    final rows = await (db.select(db.customCategories)
          ..where((t) => t.updatedAt.isBiggerOrEqualValue(since + 1)))
        .get();
    return rows.map((r) => r.toJson()).toList();
  }

  Future<bool> applyLww(Json row) async {
    final uuid = row['uuid'] as String;
    final existing = await (db.select(db.customCategories)
          ..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    if (existing != null &&
        !lwwWins(existing.updatedAt, existing.deviceId, _ts(row), _dev(row))) {
      return false;
    }
    final companion = CustomCategoriesCompanion.insert(
      uuid: Value(uuid),
      name: row['name'] as String,
      iconCode: Value(_asInt(row, 'iconCode') ?? 0),
      type: row['type'] as String,
      updatedAt: Value(_ts(row)),
      deviceId: Value(_dev(row)),
      isDeleted: Value(_asBool(row, 'isDeleted')),
    );
    existing == null
        ? await db.into(db.customCategories).insert(companion)
        : await (db.update(db.customCategories)
              ..where((t) => t.uuid.equals(uuid)))
            .write(companion);
    return true;
  }

  return SyncTableAdapter(
      name: 'custom_categories',
      changesSince: changesSince,
      applyLww: applyLww);
}

// ── app_meta ────────────────────────────────────────────────────

SyncTableAdapter _appMeta(AppDatabase db) {
  Future<List<Json>> changesSince(int since) async {
    final rows = await (db.select(db.appMeta)
          ..where((t) => t.updatedAt.isBiggerOrEqualValue(since + 1)))
        .get();
    return rows.map((r) => r.toJson()).toList();
  }

  Future<bool> applyLww(Json row) async {
    final uuid = row['uuid'] as String;
    final existing = await (db.select(db.appMeta)
          ..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    if (existing != null &&
        !lwwWins(existing.updatedAt, existing.deviceId, _ts(row), _dev(row))) {
      return false;
    }
    final companion = AppMetaCompanion.insert(
      uuid: Value(uuid),
      metaKey: row['metaKey'] as String,
      metaValue: row['metaValue'] as String,
      updatedAt: Value(_ts(row)),
      deviceId: Value(_dev(row)),
      isDeleted: Value(_asBool(row, 'isDeleted')),
    );
    existing == null
        ? await db.into(db.appMeta).insert(companion)
        : await (db.update(db.appMeta)..where((t) => t.uuid.equals(uuid)))
            .write(companion);
    return true;
  }

  return SyncTableAdapter(
      name: 'app_meta', changesSince: changesSince, applyLww: applyLww);
}

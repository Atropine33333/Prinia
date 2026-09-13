import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 可用的更新信息。
class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String releaseNotes;

  const UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.releaseNotes,
  });
}

/// 应用内更新：每天首次打开检查 GitHub 最新 Release，
/// 有新版本则弹窗下载 arm64-v8a APK 并拉起安装。
class UpdateService {
  UpdateService._();

  static const repo = 'Atropine33333/Prinia';
  static const appVersion = '1.2.4';
  static const _checkDateKey = 'last_update_check_date';

  static const _latestUrl = 'https://api.github.com/repos/$repo/releases/latest';
  static const _defaultAssetSuffix = 'app-arm64-v8a-release.apk';

  static DateTime? _sessionCheckedAt; // 进程内去重

  /// 今天是否已检查过。
  static Future<bool> _checkedToday() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_checkDateKey) ==
        DateTime.now().toIso8601String().substring(0, 10);
  }

  static Future<void> _markCheckedToday() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
        _checkDateKey, DateTime.now().toIso8601String().substring(0, 10));
  }

  /// 语义化版本比较：a > b 返回 true。
  static bool isNewer(String a, String b) {
    List<int> parse(String v) => v
        .replaceFirst(RegExp(r'^v'), '')
        .split('-')
        .first
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    final pa = parse(a);
    final pb = parse(b);
    for (var i = 0; i < 3; i++) {
      final x = i < pa.length ? pa[i] : 0;
      final y = i < pb.length ? pb[i] : 0;
      if (x != y) return x > y;
    }
    return false;
  }

  static Future<Map<String, dynamic>> _getJson(String url) async {
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
      final resp = await req.close();
      if (resp.statusCode != 200) {
        throw HttpException('HTTP ${resp.statusCode}', uri: Uri.parse(url));
      }
      final body = await resp.transform(utf8.decoder).join();
      return jsonDecode(body) as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }

  /// 查询最新版本信息；无更新返回 null。
  static Future<UpdateInfo?> check() async {
    final data = await _getJson(_latestUrl);
    final tag = data['tag_name'] as String? ?? '';
    if (tag.isEmpty) throw '响应中没有版本号';
    if (!isNewer(tag, appVersion)) return null;

    // 优先 arm64-v8a，其次任意 APK 资产
    final assets = (data['assets'] as List? ?? [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
    Map<String, dynamic>? apk = assets.firstWhere(
      (a) => (a['name'] as String? ?? '').endsWith(_defaultAssetSuffix),
      orElse: () => assets.firstWhere(
        (a) => (a['name'] as String? ?? '').endsWith('.apk'),
        orElse: () => <String, dynamic>{},
      ),
    );
    if (apk.isEmpty) throw 'Release 中没有找到 APK 资产';

    return UpdateInfo(
      version: tag,
      downloadUrl: apk['browser_download_url'] as String,
      releaseNotes: data['body'] as String? ?? '',
    );
  }

  /// 每天首次打开调用（静默，失败不打扰）。
  static Future<void> autoCheckOnStartup(BuildContext context) async {
    if (_sessionCheckedAt != null) return; // 进程内只查一次
    if (await _checkedToday()) return;
    _sessionCheckedAt = DateTime.now();
    await _markCheckedToday();
    try {
      final info = await check();
      if (info != null && context.mounted) {
        showUpdateDialog(context, info);
      }
    } catch (_) {
      // 静默失败（无网/限流），不打扰用户
    }
  }

  /// 手动检查（设置页入口），带状态反馈。
  static Future<void> manualCheck(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('正在检查更新…'), duration: Duration(seconds: 1)),
    );
    try {
      final info = await check();
      if (!context.mounted) return;
      if (info == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('当前已是最新版本')),
        );
      } else {
        showUpdateDialog(context, info);
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text('检查失败：$e')));
      }
    }
  }

  /// 更新对话框：确认后下载（带进度）并拉起安装。
  static void showUpdateDialog(BuildContext context, UpdateInfo info) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        var progress = 0.0;
        var downloading = false;
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: Text('发现新版本 ${info.version}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (info.releaseNotes.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      child: Text(info.releaseNotes,
                          style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                const SizedBox(height: 12),
                if (downloading) LinearProgressIndicator(value: progress),
              ],
            ),
            actions: [
              TextButton(
                onPressed:
                    downloading ? null : () => Navigator.of(ctx).pop(),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: downloading
                    ? null
                    : () async {
                        setState(() => downloading = true);
                        try {
                          final path = await _download(
                            info.downloadUrl,
                            (p) => setState(() => progress = p),
                          );
                          if (ctx.mounted) Navigator.of(ctx).pop();
                          await OpenFilex.open(path);
                        } catch (e) {
                          if (ctx.mounted) {
                            setState(() => downloading = false);
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text('下载失败：$e')),
                            );
                          }
                        }
                      },
                child: Text(downloading
                    ? '${(progress * 100).toStringAsFixed(0)}%'
                    : '下载并安装'),
              ),
            ],
          ),
        );
      },
    );
  }


  static Future<String> _download(
      String url, void Function(double) onProgress) async {
    final dir = await getTemporaryDirectory();
    final savePath = '${dir.path}/prinia-update.apk';
    final file = File(savePath);
    if (await file.exists()) await file.delete();

    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(url));
      final resp = await req.close();
      if (resp.statusCode != 200) {
        throw '下载失败：HTTP ${resp.statusCode}';
      }
      final total = resp.contentLength;
      final sink = file.openWrite();
      var received = 0;
      await for (final chunk in resp) {
        received += chunk.length;
        sink.add(chunk);
        if (total > 0) onProgress(received / total);
      }
      await sink.close();
      return savePath;
    } catch (e) {
      try { await file.delete(); } catch (_) {}
      rethrow;
    } finally {
      client.close();
    }
  }
}

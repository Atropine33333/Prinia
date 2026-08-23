import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';
import 'presets.dart';

/// 当前选中的配色板 id（预设 id 或自定义配色板名）。
class ThemeController extends Notifier<String> {
  static const _key = 'active_theme_id';
  static const _customKey = 'custom_themes';

  @override
  String build() {
    Future.microtask(_load);
    return presetThemes.first.id;
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final saved = sp.getString(_key);
    if (saved != null && _resolveAll().containsKey(saved)) {
      state = saved;
    }
  }

  /// 预设 + 用户自定义配色板的合集。
  Map<String, AppColors> _resolveAll() {
    return {
      for (final p in presetThemes) p.id: p.colors,
      ...loadCustomThemes(),
    };
  }

  /// 读取自定义配色板：`{ 名称: [12个hex] }`。
  static Future<Map<String, List<String>>> readCustomRaw() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_customKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, (v as List).cast<String>()));
  }

  static Map<String, AppColors> loadCustomThemes() {
    // 同步场景（构建主题列表）由 provider 内部缓存处理，
    // 此处仅提供静态入口，实际加载走 [_customCache]。
    return Map.of(_customCache);
  }

  static final Map<String, AppColors> _customCache = {};

  Future<void> refreshCustom() async {
    final raw = await readCustomRaw();
    _customCache
      ..clear()
      ..addEntries(raw.entries
          .where((e) => e.value.length == 12)
          .map((e) => MapEntry(e.key, AppColors.fromHexList(e.value))));
    // 若当前主题被删除则回退到默认
    if (!_resolveAll().containsKey(state)) state = presetThemes.first.id;
  }

  Future<void> select(String id) async {
    if (!_resolveAll().containsKey(id)) return;
    state = id;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, id);
  }

  Future<void> saveCustomTheme(String name, AppColors colors) async {
    final raw = await readCustomRaw();
    raw[name] = colors.toHexList();
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_customKey, jsonEncode(raw));
    await refreshCustom();
    await select(name);
  }

  Future<void> deleteCustomTheme(String name) async {
    final raw = await readCustomRaw();
    raw.remove(name);
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_customKey, jsonEncode(raw));
    await refreshCustom();
  }
}

/// 解析后的当前主题 provider。
final activeColorsProvider = Provider<AppColors>((ref) {
  final id = ref.watch(themeControllerProvider);
  final presets = {for (final p in presetThemes) p.id: p.colors};
  return presets[id] ?? ThemeController.loadCustomThemes()[id] ??
      presetThemes.first.colors;
});

final themeControllerProvider =
    NotifierProvider<ThemeController, String>(ThemeController.new);

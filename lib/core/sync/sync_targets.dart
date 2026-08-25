import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 参与同步轮询的已配对设备（MAC 地址集合）。
///
/// 空集合 = 未配置，视为全部参与（兼容首次使用）；
/// 用户勾选过任意一项后即物化为显式白名单，之后新增的配对设备需手动加入。
class SyncTargetsController extends Notifier<Set<String>> {
  static const _key = 'sync_peer_addresses';

  @override
  Set<String> build() {
    Future.microtask(_load);
    return {};
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final saved = sp.getStringList(_key) ?? const [];
    if (saved.isNotEmpty && state.isEmpty) {
      state = saved.toSet();
    }
  }

  /// 某设备当前是否参与同步。
  static bool isSelected(Set<String> selection, String address) =>
      selection.isEmpty || selection.contains(address);

  /// 勾选/取消一台设备。[allAddresses] 为当前全部已配对地址（用于首次物化）。
  Future<void> toggle(String address, List<String> allAddresses) async {
    final next = state.isEmpty ? allAddresses.toSet() : {...state};
    next.contains(address) ? next.remove(address) : next.add(address);
    state = next;
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_key, state.toList());
  }
}

final syncTargetsProvider =
    NotifierProvider<SyncTargetsController, Set<String>>(
        SyncTargetsController.new);

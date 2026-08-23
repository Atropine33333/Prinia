import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/db/db_provider.dart';
import '../../core/db/daos/focus_sessions_dao.dart';

/// 今日专注总秒数。
final todayFocusProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db.focusSessionsDao.watchTodayTotalSeconds();
});

/// 最近专注记录流。
final recentSessionsProvider = StreamProvider<List<FocusSessionRow>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.focusSessionsDao.watchRecent(limit: 300);
});

class DayFocus {
  final DateTime day;
  final double minutes;
  const DayFocus(this.day, this.minutes);
}

/// 最近 7 天每日专注分钟数（含今天，缺省补 0）。
final last7DaysProvider = Provider<List<DayFocus>>((ref) {
  final sessions = ref.watch(recentSessionsProvider).value ?? const [];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final buckets = <DateTime, double>{
    for (var i = 6; i >= 0; i--)
      today.subtract(Duration(days: i)): 0,
  };
  for (final s in sessions) {
    if (s.status != 'completed') continue;
    final d = DateTime.fromMillisecondsSinceEpoch(s.startTime);
    final key = DateTime(d.year, d.month, d.day);
    if (buckets.containsKey(key)) {
      buckets[key] = buckets[key]! + s.durationSeconds / 60;
    }
  }
  return [for (final e in buckets.entries) DayFocus(e.key, e.value)];
});

String dayLabel(DateTime d) => DateFormat('M/d').format(d);

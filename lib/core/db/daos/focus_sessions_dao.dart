import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

export '../database.dart' show FocusSessionRow;

part 'focus_sessions_dao.g.dart';



/// 专注记录数据访问。
@DriftAccessor(tables: [FocusSessions])
class FocusSessionsDao extends DatabaseAccessor<AppDatabase> with _$FocusSessionsDaoMixin {
  FocusSessionsDao(super.db);

  /// 最近记录流（倒序），软删除不出现。
  Stream<List<FocusSessionRow>> watchRecent({int limit = 200}) {
    return (select(focusSessions)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(u) => OrderingTerm.desc(u.startTime)])
          ..limit(limit))
        .watch();
  }

  Future<void> insertSession(FocusSessionsCompanion entry) =>
      into(focusSessions).insert(entry);

  /// 今日专注总秒数。
  Stream<int> watchTodayTotalSeconds() {
    final now = DateTime.now();
    final start =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final query = selectOnly(focusSessions)
      ..addColumns([focusSessions.durationSeconds.sum()])
      ..where(focusSessions.startTime.isBiggerOrEqualValue(start))
      ..where(focusSessions.isDeleted.equals(false));
    return query.watchSingleOrNull().map(
          (row) => row?.read(focusSessions.durationSeconds.sum()) ?? 0,
        );
  }
}

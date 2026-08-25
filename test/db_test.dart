import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_note/core/db/database.dart';
import 'package:octo_note/core/db/daos/courses_dao.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  group('AccountsDao', () {
    test('插入后按月可查且汇总正确', () async {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month);

      final helper = AccountsInsertHelper(db);
      await db.accountsDao.insertEntry(
        helper.expense(
          uuid: 'u-expense',
          amount: 25.5,
          category: '餐饮',
          occurredAt:
              monthStart.add(const Duration(days: 1)).millisecondsSinceEpoch,
        ),
      );
      await db.accountsDao.insertEntry(
        helper.income(
          uuid: 'u-income',
          amount: 100,
          category: '其他',
          occurredAt: monthStart.millisecondsSinceEpoch,
        ),
      );

      final list = await db.accountsDao.watchMonth(now.year, now.month).first;
      expect(list, hasLength(2));

      final summary =
          await db.accountsDao.watchMonthlySummary(now.year, now.month).first;
      expect(summary.income, 100);
      expect(summary.expense, 25.5);
      expect(summary.balance, closeTo(74.5, 1e-9));
    });

    test('软删除后查询不可见', () async {
      final helper = AccountsInsertHelper(db);
      await db.accountsDao.insertEntry(
        helper.raw(amount: 10, type: 'expense', category: '购物', uuid: 'u-del'),
      );
      await db.accountsDao.softDelete('u-del');

      final now = DateTime.now();
      final list = await db.accountsDao.watchMonth(now.year, now.month).first;
      expect(list, isEmpty);
    });
  });

  group('FocusSessionsDao', () {
    test('今日总时长统计', () async {
      final now = DateTime.now();
      await db.focusSessionsDao.insertSession(
        FocusSessionsCompanion.insert(
          durationSeconds: const Value(1500),
          endTime: now.millisecondsSinceEpoch,
          status: 'completed',
        ),
      );
      final total = await db.focusSessionsDao.watchTodayTotalSeconds().first;
      expect(total, 1500);
    });
  });

  group('CoursesDao', () {
    test('课程增删与提醒 JSON 往返', () async {
      final reminders = [
        CourseReminder(date: DateTime(2025, 12, 1), text: '交作业'),
      ];
      await db.coursesDao.insertCourse(
        CoursesCompanion.insert(
          name: '高等数学',
          weekday: 1,
          startWeek: 1,
          endWeek: 16,
          startMinutes: const Value(8 * 60),
          durationMinutes: const Value(90),
          colorHex: const Value('#7A9E9F'),
          remindersJson: Value(encodeReminders(reminders)),
        ),
      );

      var courses = await db.coursesDao.watchAll().first;
      expect(courses, hasLength(1));
      expect(parseReminders(courses.first.remindersJson), hasLength(1));
      expect(parseReminders(courses.first.remindersJson).first.text, '交作业');

      await db.coursesDao.softDelete(courses.first.uuid);
      courses = await db.coursesDao.watchAll().first;
      expect(courses, isEmpty);
    });
  });
}

/// 测试辅助：简化 companion 构造。
class AccountsInsertHelper {
  final AppDatabase db;
  AccountsInsertHelper(this.db);

  AccountsCompanion expense({
    required String uuid,
    required double amount,
    required String category,
    int? occurredAt,
    String? note,
  }) =>
      raw(
        uuid: uuid,
        amount: amount,
        type: 'expense',
        category: category,
        occurredAt: occurredAt,
        note: note,
      );

  AccountsCompanion income({
    required String uuid,
    required double amount,
    required String category,
    int? occurredAt,
  }) =>
      raw(
          uuid: uuid,
          amount: amount,
          type: 'income',
          category: category,
          occurredAt: occurredAt);

  AccountsCompanion raw({
    required String uuid,
    required double amount,
    required String type,
    required String category,
    int? occurredAt,
    String? note,
  }) =>
      AccountsCompanion.insert(
        uuid: Value(uuid),
        amount: amount,
        type: type,
        category: category,
        occurredAt: Value(occurredAt ?? DateTime.now().millisecondsSinceEpoch),
        note: Value(note),
      );
}

import 'package:drift/drift.dart';

/// 所有表共用的同步预留列（未来 LWW/CRDT 用）。
mixin SyncColumns on Table {
  IntColumn get updatedAt =>
      integer().named('updated_at').clientDefault(dbNowMs)();

  TextColumn get deviceId => text()
      .named('device_id')
      .withDefault(const Constant('local'))();

  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();
}

int dbNowMs() => DateTime.now().millisecondsSinceEpoch;

/// 记账表。
@DataClassName('AccountRow')
@TableIndex(name: 'idx_accounts_occurred', columns: {#occurredAt})
class Accounts extends Table with SyncColumns {
  IntColumn get id => integer().autoIncrement()();

  /// 金额恒为正数，收支由 [type] 区分。
  RealColumn get amount => real()();

  /// 'income' 或 'expense'
  TextColumn get type => text().withLength(min: 1, max: 8)();

  /// 餐饮/购物/学习/交通/娱乐/医疗/其他
  TextColumn get category => text().withLength(min: 1, max: 16)();

  TextColumn get note => text().nullable()();

  IntColumn get occurredAt => integer()
      .named('occurred_at')
      .clientDefault(dbNowMs)();

  IntColumn get createdAt => integer()
      .named('created_at')
      .clientDefault(dbNowMs)();
}

/// 专注记录表（番茄钟）。
@DataClassName('FocusSessionRow')
@TableIndex(name: 'idx_focus_start', columns: {#startTime})
class FocusSessions extends Table with SyncColumns {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get durationSeconds => integer()
      .named('duration_seconds')
      .clientDefault(() => 0)();

  IntColumn get startTime => integer()
      .named('start_time')
      .clientDefault(dbNowMs)();

  IntColumn get endTime => integer().named('end_time')();

  /// 'completed' 或 'interrupted'
  TextColumn get status => text().withLength(min: 1, max: 16)();
}

/// 课程表。
@DataClassName('CourseRow')
@TableIndex(name: 'idx_courses_weekday', columns: {#weekday})
class Courses extends Table with SyncColumns {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 64)();

  TextColumn get teacher => text().nullable()();

  TextColumn get room => text().nullable()();

  /// 1~7，周一到周日
  IntColumn get weekday => integer()();

  IntColumn get startWeek => integer().named('start_week')();

  IntColumn get endWeek => integer().named('end_week')();

  /// 开始小时（0~23，24 小时制）
  IntColumn get startHour => integer()
      .named('start_hour')
      .clientDefault(() => 8)();

  /// 时长（小时，≥1）
  IntColumn get durationHours => integer()
      .named('duration_hours')
      .clientDefault(() => 1)();

  TextColumn get colorHex => text()
      .named('color_hex')
      .withLength(min: 7, max: 9)
      .withDefault(const Constant('#7A9E9F'))();

  /// JSON 数组：[{"date":"2025-12-01","text":"交作业"}]
  TextColumn get remindersJson => text()
      .named('reminders_json')
      .withDefault(const Constant('[]'))();
}

/// 自定义分类标签（记账用）。
@DataClassName('CustomCategoryRow')
@TableIndex(name: 'idx_custom_cat_type', columns: {#type})
class CustomCategories extends Table with SyncColumns {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 16)();

  /// MaterialIcons 码点（来自内置精选目录）。
  IntColumn get iconCode => integer()
      .named('icon_code')
      .clientDefault(() => 0xe57f)(); // Icons.label_outline

  /// 'expense' 或 'income'
  TextColumn get type => text().withLength(min: 1, max: 8)();
}

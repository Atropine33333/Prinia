import 'package:drift/drift.dart';

import '../sync/device_identity.dart';
import '../sync/uuid_util.dart';

/// 同步身份列：uuid 全局唯一，跨设备识别同一行。
mixin SyncUuid on Table {
  TextColumn get uuid =>
      text().named('uuid').clientDefault(genUuid)();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// 所有表共用的同步预留列（LWW/CRDT 用）。
mixin SyncColumns on Table {
  IntColumn get updatedAt =>
      integer().named('updated_at').clientDefault(dbNowMs)();

  TextColumn get deviceId => text()
      .named('device_id')
      .clientDefault(() => DeviceIdentity.current)();

  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();
}

int dbNowMs() => DateTime.now().millisecondsSinceEpoch;

/// 记账表。
@DataClassName('AccountRow')
@TableIndex(name: 'idx_accounts_occurred', columns: {#occurredAt})
class Accounts extends Table with SyncUuid, SyncColumns {
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
class FocusSessions extends Table with SyncUuid, SyncColumns {
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
class Courses extends Table with SyncUuid, SyncColumns {
  TextColumn get name => text().withLength(min: 1, max: 64)();

  TextColumn get teacher => text().nullable()();

  TextColumn get room => text().nullable()();

  /// 1~7，周一到周日
  IntColumn get weekday => integer()();

  IntColumn get startWeek => integer().named('start_week')();

  IntColumn get endWeek => integer().named('end_week')();

  /// 开始时刻（当日 0 点起的分钟数，15 分钟步进）
  IntColumn get startMinutes => integer()
      .named('start_minutes')
      .clientDefault(() => 8 * 60)();

  /// 时长（分钟，15 的倍数）
  IntColumn get durationMinutes => integer()
      .named('duration_minutes')
      .clientDefault(() => 60)();

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
class CustomCategories extends Table with SyncUuid, SyncColumns {
  TextColumn get name => text().withLength(min: 1, max: 16)();

  /// MaterialIcons 码点（来自内置精选目录）。
  IntColumn get iconCode => integer()
      .named('icon_code')
      .clientDefault(() => 0xe57f)(); // Icons.label_outline

  /// 'expense' 或 'income'
  TextColumn get type => text().withLength(min: 1, max: 8)();
}

/// 可同步的键值元数据（如学期开始日期）。
@DataClassName('AppMetaRow')
class AppMeta extends Table with SyncUuid, SyncColumns {
  TextColumn get metaKey => text().named('meta_key').withLength(min: 1, max: 64)();

  TextColumn get metaValue => text().named('meta_value')();

  @override
  Set<Column> get primaryKey => {metaKey};
}

/// 已知同步对端与上次同步时间（本地状态，不参与同步）。
@DataClassName('SyncPeerRow')
class SyncPeers extends Table {
  TextColumn get peerDeviceId =>
      text().named('peer_device_id').withLength(min: 1, max: 64)();

  TextColumn get peerName =>
      text().named('peer_name').withLength(min: 1, max: 64)();

  IntColumn get lastSyncAt => integer().named('last_sync_at')();

  @override
  Set<Column> get primaryKey => {peerDeviceId};
}

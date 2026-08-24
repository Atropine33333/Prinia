import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// 本地通知服务：饭点记账提醒 + 课程提醒。
///
/// 时区处理：不引入额外时区插件，利用固定偏移把本地时刻换算成 UTC 分量
/// 调度（中国无夏令时，恒定 +8，精确成立）。
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _mealNoonId = 1;
  static const _mealEveningId = 2;
  static const _courseReminderBase = 100;

  static final _onTap = NotificationResponseCallback();

  static bool _initialized = false;

  /// 注册通知点击处理（应用启动时调用一次）。
  static void registerTapHandler(void Function(String payload) h) =>
      _onTap.register(h);

  static Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings,
        onDidReceiveNotificationResponse: _onTap.handle);
    _initialized = true;
  }

  /// 请求 Android 13+ 通知权限。
  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  // ── 饭点提醒 ────────────────────────────────────────────────

  /// 开/关每日两次的记账提醒（时刻可自定义）。
  static Future<void> setMealReminder(
    bool enabled, {
    int firstHour = 12,
    int firstMinute = 0,
    int secondHour = 18,
    int secondMinute = 0,
  }) async {
    await init();
    if (!enabled) {
      await _plugin.cancel(_mealNoonId);
      await _plugin.cancel(_mealEveningId);
      return;
    }
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'meal_reminder',
        '饭点提醒',
        channelDescription: '午餐与晚餐时段的记账提醒',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await _plugin.zonedSchedule(
      _mealNoonId,
      '该记账啦！',
      '记录一下今天的开销吧',
      _nextDailyAt(firstHour, firstMinute),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'ledger_add',
    );
    await _plugin.zonedSchedule(
      _mealEveningId,
      '该记账啦！',
      '记录一下今天的开销吧',
      _nextDailyAt(secondHour, secondMinute),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'ledger_add',
    );
  }

  // ── 课程提醒 ────────────────────────────────────────────────

  /// 为课程提醒调度通知（截止日当天 8:00）。
  ///
  /// [key] 用于稳定生成通知 id（同一课程的提醒增删时先取消旧 id）。
  static Future<void> scheduleCourseReminder({
    required int courseId,
    required int reminderIndex,
    required DateTime date,
    required String text,
  }) async {
    await init();
    final id = _courseReminderBase + courseId * 16 + reminderIndex;
    await _plugin.zonedSchedule(
      id,
      '课程提醒',
      text,
      _nextDailyAt(8, 0, onDate: date),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'course_reminder',
          '课程提醒',
          channelDescription: '作业与考试截止提醒',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'course_$courseId',
    );
  }

  static Future<void> cancelCourseReminders(int courseId, int count) async {
    for (var i = 0; i < count; i++) {
      await _plugin.cancel(_courseReminderBase + courseId * 16 + i);
    }
  }

  // ── 番茄钟 ─────────────────────────────────────────────────

  static const _pomodoroNowId = 50;
  static const _pomodoroScheduledId = 51;

  /// 番茄钟即时通知（溜号召回 / 休息将结束）。
  static Future<void> showPomodoro(String body, {String? payload}) async {
    await init();
    await _plugin.show(
      _pomodoroNowId,
      'Prinia 番茄钟',
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pomodoro',
          '番茄钟',
          channelDescription: '专注状态提醒',
          importance: Importance.high,
          priority: Priority.high,
          fullScreenIntent: false,
        ),
      ),
      payload: payload ?? 'pomodoro_back',
    );
  }

  /// 延时一次性番茄钟通知。
  static Future<void> schedulePomodoroIn(Duration delay, String body) async {
    await init();
    final fireAt = tz.TZDateTime.now(tz.UTC).add(delay);
    await _plugin.zonedSchedule(
      _pomodoroScheduledId,
      'Prinia 番茄钟',
      body,
      fireAt,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pomodoro',
          '番茄钟',
          channelDescription: '专注状态提醒',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'pomodoro_back',
    );
  }

  static Future<void> cancelScheduledPomodoro() async {
    await _plugin.cancel(_pomodoroScheduledId);
  }

  /// 当前已调度的通知数量（用于推断饭点提醒开关状态）。
  static Future<int> pendingCount() async {
    await init();
    return _plugin.pendingNotificationRequests().then((l) => l.length);
  }

  // ── 工具 ───────────────────────────────────────────────────

  /// 下一个本地 [hour]:[] 时刻（UTC 分量换算，适用固定偏移时区）。
  static tz.TZDateTime _nextDailyAt(int hour, int minute, {DateTime? onDate}) {
    final offset = DateTime.now().timeZoneOffset;
    final utcHour = hour - offset.inHours;
    final base = onDate ?? DateTime.now();
    var t = tz.TZDateTime.utc(
        base.year, base.month, base.day, utcHour, minute);
    if (onDate == null && t.isBefore(tz.TZDateTime.now(tz.UTC))) {
      t = t.add(const Duration(days: 1));
    }
    return t;
  }
}

/// 通知点击回调（导航由 shell 侧注入处理）。
class NotificationResponseCallback {
  void Function(String payload)? _handler;

  NotificationResponseCallback();
  void register(void Function(String payload) h) => _handler = h;
  void handle(NotificationResponse r) {
    final p = r.payload;
    if (p != null) _handler?.call(p);
  }
}

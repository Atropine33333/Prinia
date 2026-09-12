import 'package:flutter_test/flutter_test.dart';
import 'package:octo_note/features/timetable/periods.dart';
import 'package:octo_note/features/timetable/timetable_providers.dart';

CourseRow _course({int startWeek = 1, int endWeek = 16, int parity = 0}) =>
    CourseRow(
      uuid: 'c-1',
      updatedAt: 0,
      deviceId: 'dev',
      isDeleted: false,
      name: '高等数学',
      weekday: 1,
      startWeek: startWeek,
      endWeek: endWeek,
      weekParity: parity,
      startMinutes: 8 * 60,
      durationMinutes: 45,
      colorHex: '#7A9E9F',
      remindersJson: '[]',
    );

void main() {
  group('默认作息（12 节）', () {
    test('自 8:00 起共 12 节，时间递增且末节 22:20 结束', () {
      expect(defaultPeriods, hasLength(12));
      expect(defaultPeriods.first.startMinutes, 8 * 60);
      expect(defaultPeriods.first.endMinutes, 8 * 60 + 45);
      expect(defaultPeriods.last.startMinutes, 21 * 60 + 35);
      expect(defaultPeriods.last.endMinutes, 22 * 60 + 20);
      for (var i = 0; i < defaultPeriods.length; i++) {
        final p = defaultPeriods[i];
        expect(p.index, i + 1);
        expect(p.endMinutes, greaterThan(p.startMinutes));
        if (i > 0) {
          // 允许连堂（如第 11–12 节 20:50–22:20 无课间），但不得重叠
          expect(p.startMinutes,
              greaterThanOrEqualTo(defaultPeriods[i - 1].endMinutes),
              reason: '节次不得重叠');
        }
      }
    });

    test('periodAtMinute 定位节次，课间不属于任何节', () {
      expect(periodAtMinute(8 * 60)?.index, 1);
      expect(periodAtMinute(8 * 60 + 44)?.index, 1);
      expect(periodAtMinute(8 * 60 + 45), isNull); // 课间
      expect(periodAtMinute(21 * 60 + 40)?.index, 12);
    });

    test('coveredPeriods 仅认起止完全吻合的连续节次', () {
      expect(formatPeriodSpan(coveredPeriods(10 * 60 + 10, 11 * 60 + 50)!),
          '第3-4节');
      expect(coveredPeriods(8 * 60, 9 * 60), isNull, reason: '跨课间不吻合');
      expect(formatPeriodSpan(coveredPeriods(14 * 60 + 30, 15 * 60 + 15)!),
          '第5节');
    });
  });

  group('单双周过滤', () {
    test('每周课程所有周次可见', () {
      final c = _course();
      for (var w = 1; w <= 16; w++) {
        expect(courseRunsInWeek(c, w), isTrue);
      }
    });

    test('单周课程仅奇数周可见', () {
      final c = _course(parity: 1);
      expect(courseRunsInWeek(c, 1), isTrue);
      expect(courseRunsInWeek(c, 2), isFalse);
      expect(courseRunsInWeek(c, 15), isTrue);
      expect(courseRunsInWeek(c, 16), isFalse);
    });

    test('双周课程仅偶数周可见', () {
      final c = _course(parity: 2);
      expect(courseRunsInWeek(c, 2), isTrue);
      expect(courseRunsInWeek(c, 3), isFalse);
    });

    test('周次范围与单双周叠加', () {
      final c = _course(startWeek: 5, endWeek: 10, parity: 1);
      expect(courseRunsInWeek(c, 4), isFalse);
      expect(courseRunsInWeek(c, 5), isTrue);
      expect(courseRunsInWeek(c, 6), isFalse);
      expect(courseRunsInWeek(c, 9), isTrue);
      expect(courseRunsInWeek(c, 11), isFalse);
    });
  });
}

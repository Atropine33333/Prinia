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
      expect(periodAtMinute(defaultPeriods, 8 * 60)?.index, 1);
      expect(periodAtMinute(defaultPeriods, 8 * 60 + 44)?.index, 1);
      expect(periodAtMinute(defaultPeriods, 8 * 60 + 45), isNull); // 课间
      expect(periodAtMinute(defaultPeriods, 21 * 60 + 40)?.index, 12);
    });

    test('coveredPeriods 仅认起止完全吻合的连续节次', () {
      expect(
          formatPeriodSpan(
              coveredPeriods(defaultPeriods, 10 * 60 + 10, 11 * 60 + 50)!),
          '第3-4节');
      expect(coveredPeriods(defaultPeriods, 8 * 60, 9 * 60), isNull,
          reason: '跨课间不吻合');
      expect(
          formatPeriodSpan(
              coveredPeriods(defaultPeriods, 14 * 60 + 30, 15 * 60 + 15)!),
          '第5节');
    });
  });

  group('自定义作息序列化与校验', () {
    test('JSON 往返（节次重排）', () {
      final encoded = encodePeriods(defaultPeriods);
      final parsed = parsePeriods(encoded);
      expect(parsed, isNotNull);
      expect(samePeriods(parsed!, defaultPeriods), isTrue);
      expect(parsed.first.index, 1);
      expect(parsed.last.index, 12);
    });

    test('非法数据返回 null', () {
      expect(parsePeriods('not json'), isNull);
      expect(parsePeriods('[]'), isNull);
      expect(parsePeriods('[{"s":100,"e":50}]'), isNull, reason: '起止倒置');
      expect(parsePeriods('[{"s":0,"e":60},{"s":30,"e":90}]'), isNull,
          reason: '时间重叠');
      expect(parsePeriods('[{"s":"a","e":50}]'), isNull);
    });

    test('校验规则', () {
      expect(validatePeriods(const [CoursePeriod(1, 480, 525)]), isNull);
      expect(validatePeriods(const []), isNotNull);
      expect(validatePeriods(const [CoursePeriod(1, 480, 481)]), isNotNull,
          reason: '时长为 1 分钟');
      expect(
          validatePeriods(const [
            CoursePeriod(1, 480, 520),
            CoursePeriod(2, 500, 560),
          ]),
          isNotNull,
          reason: '重叠');
      expect(validatePeriods(const [CoursePeriod(1, 1400, 1500)]), isNotNull,
          reason: '超出 24:00');
      expect(
          validatePeriods(const [
            CoursePeriod(1, 480, 520),
            CoursePeriod(2, 520, 560),
          ]),
          isNull,
          reason: '首尾相接合法');
    });

    test('samePeriods 只比较起止顺序', () {
      expect(
          samePeriods(const [CoursePeriod(1, 480, 525)],
              const [CoursePeriod(9, 480, 525)]),
          isTrue);
      expect(
          samePeriods(const [CoursePeriod(1, 480, 525)],
              const [CoursePeriod(1, 480, 530)]),
          isFalse);
      expect(samePeriods(const [], const []), isTrue);
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

import 'package:flutter_test/flutter_test.dart';
import 'package:octo_note/features/timetable/course_palette.dart';
import 'package:octo_note/features/timetable/periods.dart';
import 'package:octo_note/features/timetable/schedule_import.dart';

const _sample = '''
{
  "schemaVersion": "1.0",
  "meta": {
    "school": { "name": "示例大学", "code": "DEMO" },
    "term": {
      "name": "2026-2027学年第一学期",
      "startDate": "2026-08-31"
    }
  },
  "courses": [
    {
      "name": "高等数学",
      "teacher": ["张三", "李四"],
      "sessions": [
        {
          "weekday": 2,
          "periods": { "start": 1, "end": 2 },
          "weeks": { "raw": "3-18周", "start": 3, "end": 18, "parity": "all", "list": null },
          "location": { "raw": "2-0101" },
          "time": { "start": "08:00", "end": "09:40" }
        },
        {
          "weekday": 4,
          "periods": { "start": 1, "end": 2 },
          "weeks": { "raw": "3-9周,12-18周", "start": null, "end": null, "parity": "all",
                     "list": [3,4,5,6,7,8,9,12,13,14,15,16,17,18] },
          "location": { "raw": "2-0101" },
          "time": { "start": "08:00", "end": "09:40" }
        },
        {
          "weekday": 5,
          "periods": { "start": 3, "end": 4 },
          "weeks": { "raw": "3-9周(单),13-15周(单)", "start": null, "end": null, "parity": "odd",
                     "list": [3,4,5,6,7,8,9,13,14,15] },
          "location": { "raw": "2-0101" },
          "time": null
        }
      ]
    },
    {
      "name": "体育",
      "teacher": null,
      "sessions": [
        {
          "weekday": 1,
          "periods": { "start": 5, "end": 6 },
          "weeks": { "raw": "3-18周", "start": 3, "end": 18, "parity": "all", "list": null },
          "location": { "raw": "体育部 看台3号场地" },
          "time": null
        }
      ]
    },
    {
      "name": "坏数据",
      "sessions": [
        {
          "weekday": 9,
          "weeks": { "raw": "3-18周", "start": 3, "end": 18, "parity": "all", "list": null },
          "time": { "start": "08:00", "end": "09:00" }
        }
      ]
    }
  ]
}
''';

void main() {
  group('课表导入解析', () {
    late ScheduleImportReport report;

    setUp(() {
      report = parseScheduleJson(_sample, periods: defaultPeriods);
    });

    test('多段/单双周次拆分为多行', () {
      // 高数 1 + 2 + 2 = 5 行；体育 1 行；坏数据跳过
      expect(report.rows, hasLength(6));
      expect(report.skipped, hasLength(1));
      expect(report.skipped.first, contains('坏数据'));

      List<ImportedCourseRow> of(int weekday, String name) => report.rows
          .where((r) => r.weekday == weekday && r.name == name)
          .toList();

      // 3-18周 原样一行
      final d2 = of(2, '高等数学');
      expect(d2, hasLength(1));
      expect(d2.first.startWeek, 3);
      expect(d2.first.endWeek, 18);
      expect(d2.first.weekParity, 0);

      // 3-9,12-18 → 两段
      final d4 = of(4, '高等数学');
      expect(d4, hasLength(2));
      expect(d4.map((r) => (r.startWeek, r.endWeek)),
          containsAll([(3, 9), (12, 18)]));

      // 3-9(单),13-15(单)，list 未过滤偶数周 → 以 parity 为准
      final d5 = of(5, '高等数学');
      expect(d5, hasLength(2));
      expect(d5.map((r) => (r.startWeek, r.endWeek, r.weekParity)),
          containsAll([(3, 9, 1), (13, 15, 1)]));
    });

    test('时间：time 优先，periods 用当前作息换算', () {
      final d2 = report.rows.firstWhere((r) => r.weekday == 2);
      expect(d2.startMinutes, 8 * 60);
      expect(d2.durationMinutes, 100); // 08:00–09:40

      final pe = report.rows.firstWhere((r) => r.name == '体育');
      expect(pe.startMinutes, 14 * 60 + 30); // 第5节 14:30
      expect(pe.durationMinutes, 100); // 至第6节 16:10
      expect(pe.room, '体育部 看台3号场地');
    });

    test('解析学期开始日期（用于同步周次与单双周）', () {
      expect(report.termStart, DateTime(2026, 8, 31));
      expect(report.termName, '2026-2027学年第一学期');
    });

    test('教师与颜色', () {
      final rows = report.rows.where((r) => r.name == '高等数学').toList();
      expect(rows.first.teacher, '张三、李四');
      expect(rows.map((r) => r.colorHex).toSet(), hasLength(1));
      expect(coursePalette, contains(rows.first.colorHex));

      final pe = report.rows.firstWhere((r) => r.name == '体育');
      expect(pe.teacher, isNull);
    });

    test('非法输入不崩溃', () {
      final bad = parseScheduleJson('not json', periods: defaultPeriods);
      expect(bad.isEmpty, isTrue);
      expect(bad.skipped, isNotEmpty);

      final empty = parseScheduleJson('{}', periods: defaultPeriods);
      expect(empty.isEmpty, isTrue);

      final noTime = parseScheduleJson(
        '{"courses":[{"name":"无时间","sessions":[{"weekday":1,'
        '"weeks":{"raw":"1-16周","start":1,"end":16,"parity":"all","list":null},'
        '"periods":{"start":99,"end":100}}]}]}',
        periods: defaultPeriods,
      );
      expect(noTime.isEmpty, isTrue);
      expect(noTime.skipped.first, contains('缺少时间'));
    });
  });
}

import '../../dreams/domain/dream.dart';
import 'heatmap_day.dart';

class HeatmapGenerator {
  static YearHeatmap generate({
    required int year,
    required List<Dream> dreams,
    DateTime? today,
  }) {
    final now = today ?? DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final counts = <DateTime, int>{};
    for (final dream in dreams) {
      final day = dream.day;
      counts[day] = (counts[day] ?? 0) + 1;
    }

    final firstDay = DateTime(year);
    final lastDay = DateTime(year, 12, 31);
    final gridStart = firstDay.subtract(Duration(days: firstDay.weekday % 7));
    final gridEnd = lastDay.add(Duration(days: 6 - (lastDay.weekday % 7)));

    final weeks = <HeatmapWeek>[];
    var cursor = gridStart;
    while (!cursor.isAfter(gridEnd)) {
      final days = <HeatmapDay>[];
      for (var i = 0; i < 7; i++) {
        final date = DateTime(cursor.year, cursor.month, cursor.day);
        final isFuture = date.isAfter(todayDate);
        days.add(
          HeatmapDay(
            date: date,
            dreamCount: isFuture ? 0 : counts[date] ?? 0,
            isInYear: date.year == year,
            isToday: date == todayDate,
            isFuture: isFuture,
          ),
        );
        cursor = cursor.add(const Duration(days: 1));
      }
      weeks.add(HeatmapWeek(days));
    }

    return YearHeatmap(year: year, weeks: weeks);
  }
}

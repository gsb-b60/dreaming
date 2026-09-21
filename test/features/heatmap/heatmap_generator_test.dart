import 'package:dreaming/features/dreams/domain/dream.dart';
import 'package:dreaming/features/dreams/domain/dream_mood.dart';
import 'package:dreaming/features/dreams/domain/dream_statistics.dart';
import 'package:dreaming/features/heatmap/domain/heatmap_generator.dart';
import 'package:flutter_test/flutter_test.dart';

Dream dream(String id, DateTime date) => Dream(
  id: id,
  title: id,
  content: 'content',
  mood: DreamMoods.neutral,
  tags: const [],
  createdAt: date,
  updatedAt: date,
  dreamDateTime: date,
);

void main() {
  test('generates a full year aligned to Sunday through Saturday weeks', () {
    final heatmap = HeatmapGenerator.generate(
      year: 2026,
      dreams: const [],
      today: DateTime(2026, 12, 31),
    );

    expect(heatmap.weeks.first.days.first.date.weekday, DateTime.sunday);
    expect(heatmap.weeks.last.days.last.date.weekday, DateTime.saturday);
    expect(heatmap.days.where((day) => day.isInYear), hasLength(365));
  });

  test('accounts for leap years', () {
    final heatmap = HeatmapGenerator.generate(
      year: 2024,
      dreams: const [],
      today: DateTime(2024, 12, 31),
    );

    expect(heatmap.days.where((day) => day.isInYear), hasLength(366));
    expect(
      heatmap.days.any((day) => day.date == DateTime(2024, 2, 29)),
      isTrue,
    );
  });

  test('groups dreams into binary day presence and hides future activity', () {
    final heatmap = HeatmapGenerator.generate(
      year: 2026,
      today: DateTime(2026, 8, 13),
      dreams: [
        dream('one', DateTime(2026, 8, 12, 6)),
        dream('two', DateTime(2026, 8, 12, 9)),
        dream('future', DateTime(2026, 8, 14, 9)),
      ],
    );

    final active = heatmap.days.singleWhere(
      (day) => day.date == DateTime(2026, 8, 12),
    );
    final future = heatmap.days.singleWhere(
      (day) => day.date == DateTime(2026, 8, 14),
    );
    expect(active.dreamCount, 2);
    expect(active.hasDream, isTrue);
    expect(future.dreamCount, 0);
    expect(future.hasDream, isFalse);
  });

  test('calculates yearly statistics and streaks', () {
    final stats = DreamStatistics.forYear(
      [
        dream('a', DateTime(2026, 8, 10)),
        dream('b', DateTime(2026, 8, 11)),
        dream('c', DateTime(2026, 8, 13)),
        dream('d', DateTime(2025, 8, 13)),
      ],
      2026,
      today: DateTime(2026, 8, 13),
    );

    expect(stats.dreamsThisYear, 3);
    expect(stats.daysWithDreamsThisYear, 3);
    expect(stats.currentStreak, 1);
    expect(stats.longestStreak, 2);
  });
}

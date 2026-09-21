import 'dream.dart';

class DreamStatistics {
  final int dreamsThisYear;
  final int daysWithDreamsThisYear;
  final int currentStreak;
  final int longestStreak;

  const DreamStatistics({
    required this.dreamsThisYear,
    required this.daysWithDreamsThisYear,
    required this.currentStreak,
    required this.longestStreak,
  });

  static DreamStatistics forYear(
    List<Dream> dreams,
    int year, {
    DateTime? today,
  }) {
    final todayDate = today == null
        ? DateTime.now()
        : DateTime(today.year, today.month, today.day);
    final days = dreams
        .where((dream) => dream.dreamDateTime.year == year)
        .map((dream) => dream.day)
        .toSet();
    final sortedDays = days.toList()..sort();

    var longest = 0;
    var run = 0;
    DateTime? previous;
    for (final day in sortedDays) {
      if (previous != null && day.difference(previous).inDays == 1) {
        run += 1;
      } else {
        run = 1;
      }
      if (run > longest) longest = run;
      previous = day;
    }

    var current = 0;
    var cursor = todayDate;
    while (days.contains(cursor)) {
      current += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return DreamStatistics(
      dreamsThisYear: dreams
          .where((dream) => dream.dreamDateTime.year == year)
          .length,
      daysWithDreamsThisYear: days.length,
      currentStreak: current,
      longestStreak: longest,
    );
  }
}

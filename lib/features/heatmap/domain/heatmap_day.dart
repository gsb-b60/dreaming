class HeatmapDay {
  final DateTime date;
  final int dreamCount;
  final bool isInYear;
  final bool isToday;
  final bool isFuture;

  const HeatmapDay({
    required this.date,
    required this.dreamCount,
    required this.isInYear,
    required this.isToday,
    required this.isFuture,
  });

  bool get hasDream => dreamCount > 0 && !isFuture;
}

class HeatmapWeek {
  final List<HeatmapDay> days;

  const HeatmapWeek(this.days);
}

class YearHeatmap {
  final int year;
  final List<HeatmapWeek> weeks;

  const YearHeatmap({required this.year, required this.weeks});

  Iterable<HeatmapDay> get days => weeks.expand((week) => week.days);
}

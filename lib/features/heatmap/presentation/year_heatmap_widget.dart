import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/date_formatters.dart';
import '../domain/heatmap_day.dart';

class YearHeatmapWidget extends StatefulWidget {
  const YearHeatmapWidget({
    super.key,
    required this.heatmap,
    required this.onDaySelected,
  });

  final YearHeatmap heatmap;
  final ValueChanged<HeatmapDay> onDaySelected;

  @override
  State<YearHeatmapWidget> createState() => _YearHeatmapWidgetState();
}

class _YearHeatmapWidgetState extends State<YearHeatmapWidget> {
  static const _compactBreakpoint = 640.0;

  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < _compactBreakpoint;
        return Card(
          child: Padding(
            padding: EdgeInsets.all(compact ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeatmapHeader(compact: compact),
                SizedBox(height: compact ? 14 : 18),
                if (compact)
                  _MobileYearHeatmap(
                    heatmap: widget.heatmap,
                    onDaySelected: widget.onDaySelected,
                  )
                else
                  _DesktopYearHeatmap(
                    heatmap: widget.heatmap,
                    controller: _scrollController,
                    maxWidth: constraints.maxWidth - 40,
                    onDaySelected: widget.onDaySelected,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeatmapHeader extends StatelessWidget {
  const _HeatmapHeader({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Text(
          'Dream history',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        _Legend(activeColor: theme.colorScheme.primary, compact: compact),
      ],
    );
  }
}

class _DesktopYearHeatmap extends StatelessWidget {
  const _DesktopYearHeatmap({
    required this.heatmap,
    required this.controller,
    required this.maxWidth,
    required this.onDaySelected,
  });

  final YearHeatmap heatmap;
  final ScrollController controller;
  final double maxWidth;
  final ValueChanged<HeatmapDay> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final available = maxWidth.isFinite
        ? maxWidth.clamp(360.0, double.infinity).toDouble()
        : 720.0;
    final calculated = ((available - 28) / heatmap.weeks.length) - 4;
    final cellSize = calculated.clamp(11.0, 16.0).toDouble();

    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 18,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 28),
                    for (var i = 0; i < heatmap.weeks.length; i++)
                      SizedBox(
                        width: cellSize + 4,
                        child: _monthLabel(i),
                      ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 28,
                    child: Column(
                      children: const [
                        _WeekdayLabel('S'),
                        _WeekdayLabel('M'),
                        _WeekdayLabel('T'),
                        _WeekdayLabel('W'),
                        _WeekdayLabel('T'),
                        _WeekdayLabel('F'),
                        _WeekdayLabel('S'),
                      ],
                    ),
                  ),
                  for (final week in heatmap.weeks)
                    Column(
                      children: [
                        for (final day in week.days)
                          _HeatmapCell(
                            day: day,
                            visualSize: cellSize,
                            hitSize: cellSize + 4,
                            onTap: () => onDaySelected(day),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _monthLabel(int weekIndex) {
    final week = heatmap.weeks[weekIndex];
    final firstInYear = week.days.where((day) => day.isInYear).firstOrNull;
    if (firstInYear == null || firstInYear.date.day > 7) {
      return const SizedBox.shrink();
    }
    return Text(
      monthLabelFormat.format(firstInYear.date),
      style: const TextStyle(fontSize: 11),
    );
  }
}

class _MobileYearHeatmap extends StatelessWidget {
  const _MobileYearHeatmap({required this.heatmap, required this.onDaySelected});

  final YearHeatmap heatmap;
  final ValueChanged<HeatmapDay> onDaySelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var month = 1; month <= 12; month++) ...[
          _MobileMonthHeatmap(
            year: heatmap.year,
            month: month,
            days: _daysForMonth(month),
            onDaySelected: onDaySelected,
          ),
          if (month != 12) const SizedBox(height: 14),
        ],
      ],
    );
  }

  List<HeatmapDay> _daysForMonth(int month) {
    return heatmap.days.where((day) => day.isInYear && day.date.month == month).toList();
  }
}

class _MobileMonthHeatmap extends StatelessWidget {
  const _MobileMonthHeatmap({
    required this.year,
    required this.month,
    required this.days,
    required this.onDaySelected,
  });

  final int year;
  final int month;
  final List<HeatmapDay> days;
  final ValueChanged<HeatmapDay> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayByDate = {for (final day in days) DateTime(day.date.year, day.date.month, day.date.day): day};
    final firstDay = DateTime(year, month);
    final lastDay = DateTime(year, month + 1, 0);
    final leadingBlankCount = firstDay.weekday % 7;
    final totalSlots = leadingBlankCount + lastDay.day;
    final trailingBlankCount = (7 - (totalSlots % 7)) % 7;
    final slots = <HeatmapDay?>[
      for (var i = 0; i < leadingBlankCount; i++) null,
      for (var day = 1; day <= lastDay.day; day++) dayByDate[DateTime(year, month, day)],
      for (var i = 0; i < trailingBlankCount; i++) null,
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.yMMMM().format(firstDay),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                _MobileWeekdayLabel('S'),
                _MobileWeekdayLabel('M'),
                _MobileWeekdayLabel('T'),
                _MobileWeekdayLabel('W'),
                _MobileWeekdayLabel('T'),
                _MobileWeekdayLabel('F'),
                _MobileWeekdayLabel('S'),
              ],
            ),
            const SizedBox(height: 6),
            LayoutBuilder(
              builder: (context, constraints) {
                final hitSize = (constraints.maxWidth / 7).clamp(34.0, 44.0).toDouble();
                final visualSize = (hitSize - 10).clamp(18.0, 30.0).toDouble();
                return Wrap(
                  children: [
                    for (final day in slots)
                      SizedBox(
                        width: constraints.maxWidth / 7,
                        height: hitSize,
                        child: Center(
                          child: day == null
                              ? SizedBox.square(dimension: visualSize)
                              : _HeatmapCell(
                                  day: day,
                                  visualSize: visualSize,
                                  hitSize: hitSize,
                                  showDayNumber: true,
                                  onTap: () => onDaySelected(day),
                                ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({
    required this.day,
    required this.visualSize,
    required this.hitSize,
    required this.onTap,
    this.showDayNumber = false,
  });

  final HeatmapDay day;
  final double visualSize;
  final double hitSize;
  final VoidCallback onTap;
  final bool showDayNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color color;
    if (!day.isInYear) {
      color = Colors.transparent;
    } else if (day.hasDream) {
      color = theme.colorScheme.primary;
    } else if (day.isFuture) {
      color = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45);
    } else {
      color = theme.colorScheme.surfaceContainerHighest;
    }

    final label =
        '${fullDateFormat.format(day.date)} — ${day.dreamCount} ${day.dreamCount == 1 ? 'dream' : 'dreams'} recorded';
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: SizedBox.square(
          dimension: hitSize,
          child: Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(showDayNumber ? 10 : 5),
              onTap: day.isInYear ? onTap : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: visualSize,
                height: visualSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(showDayNumber ? 8 : 4),
                  border: day.isToday ? Border.all(color: theme.colorScheme.secondary, width: 2) : null,
                ),
                child: showDayNumber
                    ? Text(
                        '${day.date.day}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: day.hasDream ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                          fontWeight: day.isToday ? FontWeight.w800 : FontWeight.w600,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 19,
    child: Text(label, style: Theme.of(context).textTheme.labelSmall),
  );
}

class _MobileWeekdayLabel extends StatelessWidget {
  const _MobileWeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Center(
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
  );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.activeColor, required this.compact});

  final Color activeColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact) ...[
          Text('No dream', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(width: 6),
        ],
        _swatch(Theme.of(context).colorScheme.surfaceContainerHighest),
        const SizedBox(width: 4),
        _swatch(activeColor),
        const SizedBox(width: 6),
        Text('Dream', style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }

  Widget _swatch(Color color) => Container(
    width: 14,
    height: 14,
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
  );
}

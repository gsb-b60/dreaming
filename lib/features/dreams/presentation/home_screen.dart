import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/date_formatters.dart';
import '../../heatmap/domain/heatmap_day.dart';
import '../../heatmap/domain/heatmap_generator.dart';
import '../../heatmap/presentation/year_heatmap_widget.dart';
import '../application/dream_store.dart';
import '../domain/dream.dart';
import '../domain/dream_statistics.dart';
import 'day_view_screen.dart';
import 'dream_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DreamStore>();
    final compact = MediaQuery.sizeOf(context).width < 640;
    final dreams = store.dreams;
    final heatmap = HeatmapGenerator.generate(year: _year, dreams: dreams);
    final stats = DreamStatistics.forYear(dreams, _year);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addDream(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Dream'),
      ),
      body: SafeArea(
        child: store.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => context.read<DreamStore>().initialize(),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 12 : 18,
                    compact ? 12 : 18,
                    compact ? 12 : 18,
                    96,
                  ),
                  children: [
                    _HeroHeader(
                      year: _year,
                      onPrevious: () => setState(() => _year -= 1),
                      onNext: () => setState(() => _year += 1),
                    ),
                    if (store.errorMessage != null) ...[
                      const SizedBox(height: 14),
                      MaterialBanner(
                        content: Text(store.errorMessage!),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                context.read<DreamStore>().initialize(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 18),
                    YearHeatmapWidget(
                      heatmap: heatmap,
                      onDaySelected: (day) => _showDayPreview(context, day),
                    ),
                    const SizedBox(height: 16),
                    _StatsGrid(stats: stats),
                    if (dreams.isEmpty) ...[
                      const SizedBox(height: 16),
                      const _FirstLaunchEmptyState(),
                    ] else if (stats.dreamsThisYear == 0) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No dreams recorded in $_year.',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  void _addDream(BuildContext context, [DateTime? date]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DreamEditorScreen(initialDate: date)),
    );
  }

  void _showDayPreview(BuildContext context, HeatmapDay day) {
    final dreams = context.read<DreamStore>().dreamsForDay(day.date);
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 720) {
      showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: _DayPreview(
              date: day.date,
              dreams: dreams,
              onAdd: () => _addDream(context, day.date),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => _DayPreview(
          date: day.date,
          dreams: dreams,
          onAdd: () => _addDream(context, day.date),
        ),
      );
    }
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.year,
    required this.onPrevious,
    required this.onNext,
  });

  final int year;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 640;
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dreaming',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'A private, local-first memory journal for the dreams you want to keep.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
        final yearControl = SegmentedButton<int>(
          segments: [
            ButtonSegment(
              value: year - 1,
              icon: const Icon(Icons.chevron_left_rounded),
              label: const Text(''),
            ),
            ButtonSegment(value: year, label: Text('$year')),
            ButtonSegment(
              value: year + 1,
              icon: const Icon(Icons.chevron_right_rounded),
              label: const Text(''),
            ),
          ],
          selected: {year},
          onSelectionChanged: (selection) {
            final selected = selection.first;
            if (selected < year) {
              onPrevious();
            }
            if (selected > year) {
              onNext();
            }
          },
        );
        return Card(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [title, const SizedBox(height: 18), yearControl],
                  )
                : Row(
                    children: [
                      Expanded(child: title),
                      yearControl,
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final DreamStatistics stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Dreams this year', stats.dreamsThisYear.toString()),
      ('Days with dreams', stats.daysWithDreamsThisYear.toString()),
      ('Current streak', '${stats.currentStreak}d'),
      ('Longest streak', '${stats.longestStreak}d'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: columns == 4 ? 1.55 : 1.45,
          children: [
            for (final item in items)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.$2,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$1,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DayPreview extends StatelessWidget {
  const _DayPreview({
    required this.date,
    required this.dreams,
    required this.onAdd,
  });

  final DateTime date;
  final List<Dream> dreams;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fullDateFormat.format(date),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text('${dreams.length} ${dreams.length == 1 ? 'dream' : 'dreams'}'),
          const SizedBox(height: 16),
          if (dreams.isEmpty)
            const Text(
              'No dreams recorded yet. Add one when you remember something from this day.',
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: dreams.length.clamp(0, 5).toInt(),
                itemBuilder: (context, index) {
                  final dream = dreams[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Text(
                      dream.mood.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                    title: Text(dream.title),
                    subtitle: Text(timeFormat.format(dream.dreamDateTime)),
                  );
                },
              ),
            ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DayViewScreen(date: date)),
                ),
                child: const Text('View all'),
              ),
              FilledButton(onPressed: onAdd, child: const Text('Add dream')),
            ],
          ),
        ],
      ),
    );
  }
}

class _FirstLaunchEmptyState extends StatelessWidget {
  const _FirstLaunchEmptyState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 44),
            const SizedBox(height: 12),
            Text(
              'No dreams recorded yet.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your dream history will appear here as quiet marks on the calendar.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DreamEditorScreen()),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Record your first dream'),
            ),
          ],
        ),
      ),
    );
  }
}

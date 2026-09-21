import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/date_formatters.dart';
import '../../dreams/application/dream_store.dart';
import '../../dreams/domain/dream.dart';
import '../../dreams/domain/dream_mood.dart';
import '../../dreams/presentation/dream_card.dart';
import '../../dreams/presentation/dream_detail_screen.dart';
import '../domain/dream_filter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _queryController = TextEditingController();
  DreamFilter _filter = const DreamFilter();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DreamStore>();
    final results = DreamSearchEngine.search(store.dreams, _filter);
    final tags = store.allTags.toList()..sort();
    return Scaffold(
      appBar: AppBar(title: const Text('Search dreams')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 96),
        children: [
          TextField(
            controller: _queryController,
            decoration: InputDecoration(
              labelText: 'Search title, dream text, tags, mood',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _queryController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _queryController.clear();
                        setState(() => _filter = _filter.copyWith(query: ''));
                      },
                    ),
            ),
            onChanged: (value) =>
                setState(() => _filter = _filter.copyWith(query: value)),
          ),
          const SizedBox(height: 14),
          _Filters(
            filter: _filter,
            tags: tags,
            onChanged: (filter) => setState(() => _filter = filter),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                '${results.length} ${results.length == 1 ? 'result' : 'results'}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (!_filter.isEmpty)
                TextButton(
                  onPressed: _clear,
                  child: const Text('Clear filters'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (results.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    const Icon(Icons.search_off_rounded, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      'No dreams found.',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text('Try another search or remove a filter.'),
                  ],
                ),
              ),
            )
          else
            for (final result in results) ...[
              DreamCard(
                dream: result.dream,
                showDate: true,
                onTap: () => _open(context, result.dream),
                trailing: result.reasons.isEmpty
                    ? null
                    : Chip(
                        label: Text(
                          'Matched ${result.reasons.take(2).join(', ')}',
                        ),
                      ),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  void _clear() {
    _queryController.clear();
    setState(() => _filter = const DreamFilter());
  }

  void _open(BuildContext context, Dream dream) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DreamDetailScreen(dreamId: dream.id)),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.filter,
    required this.tags,
    required this.onChanged,
  });

  final DreamFilter filter;
  final List<String> tags;
  final ValueChanged<DreamFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Any mood'),
                  selected: filter.mood == null,
                  onSelected: (_) =>
                      onChanged(filter.copyWith(clearMood: true)),
                ),
                for (final mood in DreamMoods.all)
                  ChoiceChip(
                    label: Text(mood.displayName),
                    selected: filter.mood == mood,
                    onSelected: (_) => onChanged(filter.copyWith(mood: mood)),
                  ),
              ],
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in tags)
                    FilterChip(
                      label: Text('#$tag'),
                      selected: filter.tags.contains(tag),
                      onSelected: (selected) {
                        final next = {...filter.tags};
                        if (selected) {
                          next.add(tag);
                        } else {
                          next.remove(tag);
                        }
                        onChanged(filter.copyWith(tags: next));
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickRange(context),
                  icon: const Icon(Icons.date_range_rounded),
                  label: Text(_dateRangeLabel()),
                ),
                if (filter.startDate != null || filter.endDate != null)
                  TextButton(
                    onPressed: () =>
                        onChanged(filter.copyWith(clearDates: true)),
                    child: const Text('Clear dates'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _dateRangeLabel() {
    if (filter.startDate == null && filter.endDate == null) return 'Date range';
    return '${compactDateFormat.format(filter.startDate!)} – ${compactDateFormat.format(filter.endDate!)}';
  }

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 5),
      initialDateRange: filter.startDate == null || filter.endDate == null
          ? null
          : DateTimeRange(start: filter.startDate!, end: filter.endDate!),
    );
    if (picked != null) {
      onChanged(filter.copyWith(startDate: picked.start, endDate: picked.end));
    }
  }
}

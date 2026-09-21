import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/date_formatters.dart';
import '../application/dream_store.dart';
import '../domain/dream.dart';
import '../domain/dream_sort.dart';
import 'dream_card.dart';
import 'dream_detail_screen.dart';
import 'dream_editor_screen.dart';

class DayViewScreen extends StatelessWidget {
  const DayViewScreen({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DreamStore>();
    final dreams = store.dreamsForDay(date);
    return Scaffold(
      appBar: AppBar(title: Text(fullDateFormat.format(date))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DreamEditorScreen(initialDate: date),
          ),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add dream'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 96),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${dreams.length} ${dreams.length == 1 ? 'dream' : 'dreams'}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              DropdownButton<DreamSortOrder>(
                value: store.sortOrder,
                onChanged: (value) {
                  if (value != null) {
                    context.read<DreamStore>().setSortOrder(value);
                  }
                },
                items: [
                  for (final order in DreamSortOrder.values)
                    DropdownMenuItem(value: order, child: Text(order.label)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (dreams.isEmpty)
            _DayEmptyState(date: date)
          else
            for (final dream in dreams) ...[
              DreamCard(
                dream: dream,
                onTap: () => _openDream(context, dream),
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DreamEditorScreen(dream: dream),
                  ),
                ),
                onDuplicate: () => _duplicate(context, dream),
                onDelete: () => _confirmDelete(context, dream),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  void _openDream(BuildContext context, Dream dream) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DreamDetailScreen(dreamId: dream.id)),
    );
  }

  Future<void> _duplicate(BuildContext context, Dream dream) async {
    final copy = await context.read<DreamStore>().duplicateDream(dream.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Duplicated as “${copy.title}” with current timestamp.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, Dream dream) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete dream?'),
        content: const Text(
          'This dream will be permanently removed from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<DreamStore>().deleteDream(dream.id);
    }
  }
}

class _DayEmptyState extends StatelessWidget {
  const _DayEmptyState({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const Icon(Icons.nightlight_round, size: 42),
            const SizedBox(height: 12),
            Text(
              'No dreams recorded for this day.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'If you remember something, add it here without changing the rest of your journal.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DreamEditorScreen(initialDate: date),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add dream'),
            ),
          ],
        ),
      ),
    );
  }
}

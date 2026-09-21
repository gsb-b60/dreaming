import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/date_formatters.dart';
import '../application/dream_store.dart';
import '../domain/dream.dart';
import 'dream_editor_screen.dart';

class DreamDetailScreen extends StatelessWidget {
  const DreamDetailScreen({super.key, required this.dreamId});

  final String dreamId;

  @override
  Widget build(BuildContext context) {
    final dream = context.watch<DreamStore>().dreamById(dreamId);
    if (dream == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dream')),
        body: const Center(child: Text('This dream is no longer available.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream'),
        actions: [
          IconButton(
            tooltip: 'Edit dream',
            onPressed: () => _edit(context, dream),
            icon: const Icon(Icons.edit_rounded),
          ),
          PopupMenuButton<_DreamAction>(
            onSelected: (action) async {
              switch (action) {
                case _DreamAction.duplicate:
                  final copy = await context.read<DreamStore>().duplicateDream(
                    dream.id,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Duplicated as “${copy.title}” with current timestamp.',
                        ),
                      ),
                    );
                  }
                case _DreamAction.delete:
                  if (context.mounted) await _confirmDelete(context, dream);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _DreamAction.duplicate,
                child: Text('Duplicate'),
              ),
              PopupMenuItem(value: _DreamAction.delete, child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Text(
            dream.title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '${dream.mood.displayName} · ${fullDateFormat.format(dream.dreamDateTime)} at ${timeFormat.format(dream.dreamDateTime)}',
          ),
          if (dream.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in dream.tags) Chip(label: Text('#$tag')),
              ],
            ),
          ],
          const SizedBox(height: 24),
          SelectableText(
            dream.content,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(height: 1.55),
          ),
        ],
      ),
    );
  }

  void _edit(BuildContext context, Dream dream) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DreamEditorScreen(dream: dream)),
    );
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
      if (context.mounted) Navigator.pop(context);
    }
  }
}

enum _DreamAction { duplicate, delete }

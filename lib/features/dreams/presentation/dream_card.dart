import 'package:flutter/material.dart';

import '../../../core/utils/date_formatters.dart';
import '../domain/dream.dart';

class DreamCard extends StatelessWidget {
  const DreamCard({
    super.key,
    required this.dream,
    this.onTap,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
    this.showDate = false,
    this.trailing,
  });

  final Dream dream;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final bool showDate;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = dream.content.trim().replaceAll(RegExp(r'\s+'), ' ');
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      dream.mood.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dream.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          showDate
                              ? '${compactDateFormat.format(dream.dreamDateTime)} at ${timeFormat.format(dream.dreamDateTime)}'
                              : timeFormat.format(dream.dreamDateTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                  if (trailing == null &&
                      (onEdit != null ||
                          onDuplicate != null ||
                          onDelete != null))
                    PopupMenuButton<_DreamAction>(
                      tooltip: 'Dream actions',
                      onSelected: (action) {
                        switch (action) {
                          case _DreamAction.edit:
                            onEdit?.call();
                          case _DreamAction.duplicate:
                            onDuplicate?.call();
                          case _DreamAction.delete:
                            onDelete?.call();
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: _DreamAction.edit,
                            child: Text('Edit'),
                          ),
                        if (onDuplicate != null)
                          const PopupMenuItem(
                            value: _DreamAction.duplicate,
                            child: Text('Duplicate'),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: _DreamAction.delete,
                            child: Text('Delete'),
                          ),
                      ],
                    ),
                ],
              ),
              if (preview.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(preview, maxLines: 3, overflow: TextOverflow.ellipsis),
              ],
              if (dream.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in dream.tags)
                      Chip(
                        label: Text('#$tag'),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum _DreamAction { edit, duplicate, delete }

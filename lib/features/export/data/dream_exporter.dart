import 'dart:convert';

import 'package:csv/csv.dart';

import '../../dreams/domain/dream.dart';

class DreamExporter {
  static String toJson(List<Dream> dreams) {
    return const JsonEncoder.withIndent('  ').convert({
      'schemaVersion': Dream.currentSchemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'dreams': dreams.map((dream) => dream.toJson()).toList(),
    });
  }

  static String toCsv(List<Dream> dreams) {
    final rows = <List<Object?>>[
      [
        'id',
        'title',
        'content',
        'mood',
        'tags',
        'date',
        'time',
        'createdAt',
        'updatedAt',
      ],
      ...dreams.map(
        (dream) => [
          dream.id,
          dream.title,
          dream.content,
          dream.mood.displayName,
          dream.tags.join(';'),
          _date(dream.dreamDateTime),
          _time(dream.dreamDateTime),
          dream.createdAt.toIso8601String(),
          dream.updatedAt.toIso8601String(),
        ],
      ),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  static String _time(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:dreaming/features/dreams/domain/dream.dart';
import 'package:dreaming/features/dreams/domain/dream_mood.dart';
import 'package:dreaming/features/export/data/dream_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

Dream dream() => Dream(
  id: 'id-1',
  title: 'Ocean, "quoted"',
  content: 'Line one\nLine two, with comma',
  mood: DreamMoods.peaceful,
  tags: const ['ocean', 'lucid'],
  createdAt: DateTime(2026, 8, 12, 7),
  updatedAt: DateTime(2026, 8, 12, 8),
  dreamDateTime: DateTime(2026, 8, 12, 6, 40),
);

void main() {
  test('exports human-readable JSON with schema version', () {
    final exported = DreamExporter.toJson([dream()]);
    final decoded = jsonDecode(exported) as Map<String, dynamic>;

    expect(decoded['schemaVersion'], Dream.currentSchemaVersion);
    expect(decoded['dreams'], hasLength(1));
    expect(exported, contains('\n  '));
  });

  test('exports CSV with escaped commas, quotes, newlines, and unicode', () {
    final exported = DreamExporter.toCsv([dream()]);
    final rows = const CsvToListConverter().convert(exported);

    expect(rows.first, contains('content'));
    expect(rows[1][1], 'Ocean, "quoted"');
    expect(rows[1][2], 'Line one\nLine two, with comma');
    expect(rows[1][3], '😌 Peaceful');
  });
}

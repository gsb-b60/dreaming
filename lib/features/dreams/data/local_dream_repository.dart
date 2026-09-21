import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/dream.dart';
import '../domain/dream_repository.dart';

class LocalDreamRepository implements DreamRepository {
  LocalDreamRepository(this._preferences);

  static const storageKey = 'dreaming.localDreams.v1';

  final SharedPreferences _preferences;

  @override
  Future<List<Dream>> loadDreams() async {
    final raw = _preferences.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return <Dream>[];

    final decoded = jsonDecode(raw);
    final records = decoded is Map<String, dynamic>
        ? decoded['dreams']
        : decoded;
    if (records is! List) return <Dream>[];

    final dreams = <Dream>[];
    for (final record in records) {
      try {
        if (record is Map<String, dynamic>) {
          dreams.add(Dream.fromJson(record));
        } else if (record is Map) {
          dreams.add(Dream.fromJson(Map<String, dynamic>.from(record)));
        }
      } on FormatException {
        continue;
      } on TypeError {
        continue;
      }
    }
    dreams.sort((a, b) => b.dreamDateTime.compareTo(a.dreamDateTime));
    return dreams;
  }

  @override
  Future<void> saveDreams(List<Dream> dreams) async {
    final payload = const JsonEncoder.withIndent('  ').convert({
      'schemaVersion': Dream.currentSchemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'dreams': dreams.map((dream) => dream.toJson()).toList(),
    });
    final success = await _preferences.setString(storageKey, payload);
    if (!success) {
      throw Exception('Dreams could not be saved to local storage.');
    }
  }
}

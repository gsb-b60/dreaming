import 'dream_mood.dart';

class Dream {
  static const currentSchemaVersion = 1;

  final String id;
  final String title;
  final String content;
  final DreamMood mood;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime dreamDateTime;
  final int schemaVersion;

  const Dream({
    required this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.dreamDateTime,
    this.schemaVersion = currentSchemaVersion,
  });

  DateTime get day =>
      DateTime(dreamDateTime.year, dreamDateTime.month, dreamDateTime.day);

  Dream copyWith({
    String? id,
    String? title,
    String? content,
    DreamMood? mood,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dreamDateTime,
    int? schemaVersion,
  }) {
    return Dream(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dreamDateTime: dreamDateTime ?? this.dreamDateTime,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'id': id,
    'title': title,
    'content': content,
    'mood': mood.toJson(),
    'tags': tags,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'dreamDateTime': dreamDateTime.toIso8601String(),
  };

  factory Dream.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final id = json['id'] as String?;
    if (id == null || id.isEmpty) {
      throw const FormatException('Dream is missing a stable id.');
    }

    DateTime parseDate(String key, DateTime fallback) {
      final value = json[key];
      if (value is String) {
        return DateTime.tryParse(value) ?? fallback;
      }
      return fallback;
    }

    final tagsValue = json['tags'];
    final tags = tagsValue is List
        ? tagsValue
              .whereType<String>()
              .map(normalizeTag)
              .where((tag) => tag.isNotEmpty)
              .toSet()
              .toList()
        : <String>[];

    final moodValue = json['mood'];
    final mood = moodValue is Map<String, dynamic>
        ? DreamMood.fromJson(moodValue)
        : DreamMoods.byKey(moodValue as String?) ?? DreamMoods.neutral;

    return Dream(
      id: id,
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? (json['title'] as String).trim()
          : 'Untitled dream',
      content:
          json['content'] as String? ?? json['description'] as String? ?? '',
      mood: mood,
      tags: tags,
      createdAt: parseDate('createdAt', now),
      updatedAt: parseDate('updatedAt', now),
      dreamDateTime: parseDate('dreamDateTime', parseDate('date', now)),
      schemaVersion: json['schemaVersion'] as int? ?? currentSchemaVersion,
    );
  }

  static String normalizeTag(String raw) =>
      raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
}

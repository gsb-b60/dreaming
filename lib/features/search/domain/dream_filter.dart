import '../../dreams/domain/dream.dart';
import '../../dreams/domain/dream_mood.dart';

class DreamFilter {
  final String query;
  final DreamMood? mood;
  final Set<String> tags;
  final DateTime? startDate;
  final DateTime? endDate;

  const DreamFilter({
    this.query = '',
    this.mood,
    this.tags = const <String>{},
    this.startDate,
    this.endDate,
  });

  bool get isEmpty =>
      query.trim().isEmpty &&
      mood == null &&
      tags.isEmpty &&
      startDate == null &&
      endDate == null;

  DreamFilter copyWith({
    String? query,
    DreamMood? mood,
    bool clearMood = false,
    Set<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDates = false,
  }) {
    return DreamFilter(
      query: query ?? this.query,
      mood: clearMood ? null : mood ?? this.mood,
      tags: tags ?? this.tags,
      startDate: clearDates ? null : startDate ?? this.startDate,
      endDate: clearDates ? null : endDate ?? this.endDate,
    );
  }
}

class DreamSearchEngine {
  static List<DreamSearchResult> search(
    List<Dream> dreams,
    DreamFilter filter,
  ) {
    final query = filter.query.trim().toLowerCase();
    return dreams
        .where((dream) => _matches(dream, filter, query))
        .map(
          (dream) => DreamSearchResult(
            dream: dream,
            reasons: _reasons(dream, filter, query),
          ),
        )
        .toList();
  }

  static bool _matches(Dream dream, DreamFilter filter, String query) {
    if (filter.mood != null && dream.mood != filter.mood) {
      return false;
    }
    if (filter.tags.isNotEmpty && !filter.tags.every(dream.tags.contains)) {
      return false;
    }
    if (filter.startDate != null &&
        dream.day.isBefore(_dateOnly(filter.startDate!))) {
      return false;
    }
    if (filter.endDate != null &&
        dream.day.isAfter(_dateOnly(filter.endDate!))) {
      return false;
    }
    if (query.isEmpty) {
      return true;
    }
    return dream.title.toLowerCase().contains(query) ||
        dream.content.toLowerCase().contains(query) ||
        dream.mood.label.toLowerCase().contains(query) ||
        dream.mood.emoji.contains(query) ||
        dream.tags.any((tag) => tag.toLowerCase().contains(query));
  }

  static List<String> _reasons(Dream dream, DreamFilter filter, String query) {
    final reasons = <String>[];
    if (query.isNotEmpty) {
      if (dream.title.toLowerCase().contains(query)) {
        reasons.add('title');
      }
      if (dream.content.toLowerCase().contains(query)) {
        reasons.add('dream text');
      }
      if (dream.tags.any((tag) => tag.toLowerCase().contains(query))) {
        reasons.add('tag');
      }
      if (dream.mood.label.toLowerCase().contains(query) ||
          dream.mood.emoji.contains(query)) {
        reasons.add('mood');
      }
    }
    if (filter.mood != null) {
      reasons.add('mood filter');
    }
    if (filter.tags.isNotEmpty) {
      reasons.add('tag filter');
    }
    if (filter.startDate != null || filter.endDate != null) {
      reasons.add('date filter');
    }
    return reasons.toSet().toList();
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

class DreamSearchResult {
  final Dream dream;
  final List<String> reasons;

  const DreamSearchResult({required this.dream, required this.reasons});
}

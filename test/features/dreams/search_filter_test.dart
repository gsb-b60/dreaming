import 'package:dreaming/features/dreams/domain/dream.dart';
import 'package:dreaming/features/dreams/domain/dream_mood.dart';
import 'package:dreaming/features/search/domain/dream_filter.dart';
import 'package:flutter_test/flutter_test.dart';

Dream dream({
  required String id,
  required String title,
  required String content,
  required DreamMood mood,
  required List<String> tags,
  required DateTime date,
}) => Dream(
  id: id,
  title: title,
  content: content,
  mood: mood,
  tags: tags,
  createdAt: date,
  updatedAt: date,
  dreamDateTime: date,
);

void main() {
  final dreams = [
    dream(
      id: 'ocean-title',
      title: 'Ocean flight',
      content: 'Clouds',
      mood: DreamMoods.happy,
      tags: ['flying'],
      date: DateTime(2026, 1, 1),
    ),
    dream(
      id: 'ocean-content',
      title: 'Hallway',
      content: 'A dark ocean appeared.',
      mood: DreamMoods.scary,
      tags: ['nightmare'],
      date: DateTime(2026, 2, 1),
    ),
    dream(
      id: 'ocean-tag',
      title: 'House',
      content: 'Rooms',
      mood: DreamMoods.peaceful,
      tags: ['ocean', 'lucid'],
      date: DateTime(2026, 3, 1),
    ),
    dream(
      id: 'other',
      title: 'School',
      content: 'Friends',
      mood: DreamMoods.sad,
      tags: ['school'],
      date: DateTime(2025, 3, 1),
    ),
  ];

  test('search matches title, content, tags, and mood', () {
    expect(
      DreamSearchEngine.search(
        dreams,
        const DreamFilter(query: 'ocean'),
      ).map((result) => result.dream.id),
      ['ocean-title', 'ocean-content', 'ocean-tag'],
    );
    expect(
      DreamSearchEngine.search(
        dreams,
        const DreamFilter(query: 'scary'),
      ).single.dream.id,
      'ocean-content',
    );
  });

  test('filters by tag, mood, date range, and combined query', () {
    final results = DreamSearchEngine.search(
      dreams,
      DreamFilter(
        query: 'ocean',
        mood: DreamMoods.peaceful,
        tags: const {'lucid'},
        startDate: DateTime(2026),
        endDate: DateTime(2026, 12, 31),
      ),
    );

    expect(results.map((result) => result.dream.id), ['ocean-tag']);
  });

  test('date filter excludes dreams outside range', () {
    final results = DreamSearchEngine.search(
      dreams,
      DreamFilter(startDate: DateTime(2026), endDate: DateTime(2026, 1, 31)),
    );

    expect(results.map((result) => result.dream.id), ['ocean-title']);
  });
}

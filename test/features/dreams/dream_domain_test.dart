import 'package:dreaming/features/dreams/application/dream_store.dart';
import 'package:dreaming/features/dreams/domain/dream.dart';
import 'package:dreaming/features/dreams/domain/dream_mood.dart';
import 'package:dreaming/features/dreams/domain/dream_repository.dart';
import 'package:dreaming/features/dreams/domain/dream_sort.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryDreamRepository implements DreamRepository {
  MemoryDreamRepository([List<Dream>? initial]) : saved = [...?initial];

  List<Dream> saved;

  @override
  Future<List<Dream>> loadDreams() async => [...saved];

  @override
  Future<void> saveDreams(List<Dream> dreams) async {
    saved = [...dreams];
  }
}

Dream dream({
  String id = 'dream-1',
  String title = 'Ocean flight',
  String content = 'I flew over the ocean.',
  DreamMood mood = DreamMoods.peaceful,
  List<String> tags = const ['ocean', 'lucid'],
  DateTime? date,
}) {
  final timestamp = date ?? DateTime(2026, 8, 12, 6, 40);
  return Dream(
    id: id,
    title: title,
    content: content,
    mood: mood,
    tags: tags,
    createdAt: DateTime(2026, 8, 12, 7),
    updatedAt: DateTime(2026, 8, 12, 7),
    dreamDateTime: timestamp,
  );
}

void main() {
  test('serializes and deserializes dreams with schema version', () {
    final original = dream();

    final decoded = Dream.fromJson(original.toJson());

    expect(decoded.id, original.id);
    expect(decoded.title, original.title);
    expect(decoded.content, original.content);
    expect(decoded.mood, DreamMoods.peaceful);
    expect(decoded.tags, ['ocean', 'lucid']);
    expect(decoded.schemaVersion, Dream.currentSchemaVersion);
    expect(decoded.dreamDateTime, original.dreamDateTime);
  });

  test('deserialization tolerates older missing optional fields', () {
    final decoded = Dream.fromJson({
      'id': 'old',
      'description': 'Older text',
      'date': '2024-01-02T03:04:00.000',
    });

    expect(decoded.title, 'Untitled dream');
    expect(decoded.content, 'Older text');
    expect(decoded.mood, DreamMoods.neutral);
    expect(decoded.tags, isEmpty);
    expect(decoded.dreamDateTime, DateTime(2024, 1, 2, 3, 4));
  });

  test(
    'store creates multiple dreams on same day without overwriting',
    () async {
      final repo = MemoryDreamRepository();
      final store = DreamStore(repo);
      await store.initialize();

      await store.createDream(
        title: 'Flying',
        content: 'Sky',
        mood: DreamMoods.happy,
        tags: ['flying'],
        dreamDateTime: DateTime(2026, 8, 12, 6, 40),
      );
      await store.createDream(
        title: 'Ocean',
        content: 'Water',
        mood: DreamMoods.peaceful,
        tags: ['ocean'],
        dreamDateTime: DateTime(2026, 8, 12, 8, 15),
      );

      expect(store.dreamsForDay(DateTime(2026, 8, 12)), hasLength(2));
      expect(repo.saved, hasLength(2));
    },
  );

  test('sort order switches between newest and oldest first', () async {
    final repo = MemoryDreamRepository([
      dream(id: 'early', title: 'Early', date: DateTime(2026, 8, 12, 6)),
      dream(id: 'late', title: 'Late', date: DateTime(2026, 8, 12, 9)),
    ]);
    final store = DreamStore(repo);
    await store.initialize();

    expect(store.dreamsForDay(DateTime(2026, 8, 12)).first.id, 'late');
    store.setSortOrder(DreamSortOrder.oldestFirst);
    expect(store.dreamsForDay(DateTime(2026, 8, 12)).first.id, 'early');
  });

  test(
    'duplicate creates independent dream with new id and current timestamp',
    () async {
      final repo = MemoryDreamRepository([dream(id: 'original')]);
      final store = DreamStore(repo);
      await store.initialize();

      final copy = await store.duplicateDream('original');

      expect(copy.id, isNot('original'));
      expect(copy.title, 'Ocean flight copy');
      expect(store.dreams, hasLength(2));
    },
  );

  test('delete removes the underlying local record', () async {
    final repo = MemoryDreamRepository([
      dream(id: 'remove'),
      dream(id: 'keep'),
    ]);
    final store = DreamStore(repo);
    await store.initialize();

    await store.deleteDream('remove');

    expect(store.dreamById('remove'), isNull);
    expect(repo.saved.map((item) => item.id), ['keep']);
  });
}

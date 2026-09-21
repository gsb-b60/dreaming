import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../domain/dream.dart';
import '../domain/dream_mood.dart';
import '../domain/dream_repository.dart';
import '../domain/dream_sort.dart';

class DreamStore extends ChangeNotifier {
  DreamStore(this._repository);

  final DreamRepository _repository;
  final _uuid = const Uuid();

  List<Dream> _dreams = <Dream>[];
  bool _isLoading = true;
  String? _errorMessage;
  DreamSortOrder _sortOrder = DreamSortOrder.newestFirst;

  List<Dream> get dreams => List.unmodifiable(_sorted(_dreams));
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DreamSortOrder get sortOrder => _sortOrder;

  Set<String> get allTags => _dreams.expand((dream) => dream.tags).toSet();

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      _dreams = await _repository.loadDreams();
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Dreams could not be loaded from this device.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Dream> dreamsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _sorted(_dreams.where((dream) => dream.day == date).toList());
  }

  Dream? dreamById(String id) {
    for (final dream in _dreams) {
      if (dream.id == id) return dream;
    }
    return null;
  }

  Future<Dream> createDream({
    required String title,
    required String content,
    required DreamMood mood,
    required List<String> tags,
    required DateTime dreamDateTime,
  }) async {
    final now = DateTime.now();
    final dream = Dream(
      id: _uuid.v4(),
      title: _cleanTitle(title),
      content: content.trim(),
      mood: mood,
      tags: _cleanTags(tags),
      createdAt: now,
      updatedAt: now,
      dreamDateTime: dreamDateTime,
    );
    _dreams = [..._dreams, dream];
    await _persist();
    return dream;
  }

  Future<void> updateDream(Dream dream) async {
    final index = _dreams.indexWhere((item) => item.id == dream.id);
    if (index == -1) return;
    final updated = dream.copyWith(
      title: _cleanTitle(dream.title),
      content: dream.content.trim(),
      tags: _cleanTags(dream.tags),
      updatedAt: DateTime.now(),
    );
    _dreams = [..._dreams.take(index), updated, ..._dreams.skip(index + 1)];
    await _persist();
  }

  Future<Dream> duplicateDream(String id) async {
    final original = dreamById(id);
    if (original == null) {
      throw ArgumentError('Dream does not exist.');
    }
    final now = DateTime.now();
    final duplicate = original.copyWith(
      id: _uuid.v4(),
      title: '${original.title} copy',
      createdAt: now,
      updatedAt: now,
      dreamDateTime: now,
    );
    _dreams = [..._dreams, duplicate];
    await _persist();
    return duplicate;
  }

  Future<void> deleteDream(String id) async {
    _dreams = _dreams.where((dream) => dream.id != id).toList();
    await _persist();
  }

  void setSortOrder(DreamSortOrder order) {
    if (_sortOrder == order) return;
    _sortOrder = order;
    notifyListeners();
  }

  List<Dream> _sorted(List<Dream> input) {
    final output = [...input];
    output.sort(
      (a, b) => switch (_sortOrder) {
        DreamSortOrder.newestFirst => b.dreamDateTime.compareTo(
          a.dreamDateTime,
        ),
        DreamSortOrder.oldestFirst => a.dreamDateTime.compareTo(
          b.dreamDateTime,
        ),
      },
    );
    return output;
  }

  Future<void> _persist() async {
    try {
      await _repository.saveDreams(_dreams);
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Dreams could not be saved to this device.';
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  static String _cleanTitle(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Untitled dream' : trimmed;
  }

  static List<String> _cleanTags(List<String> tags) =>
      tags
          .map(Dream.normalizeTag)
          .where((tag) => tag.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
}

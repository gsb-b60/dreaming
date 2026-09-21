import 'dream.dart';

abstract class DreamRepository {
  Future<List<Dream>> loadDreams();
  Future<void> saveDreams(List<Dream> dreams);
}

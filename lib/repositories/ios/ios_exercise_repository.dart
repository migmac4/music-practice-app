import '../../models/exercise.dart';
import '../../models/practice_category.dart';
import '../../services/platform/ios_database_channel.dart';
import '../exercise_repository.dart';

class IosExerciseRepository implements ExerciseRepository {
  final IosDatabaseChannel _channel;

  IosExerciseRepository(this._channel);

  @override
  Future<String> create(Exercise exercise) async {
    return await _channel.createExercise(exercise.toMap());
  }

  @override
  Future<Exercise?> read(String id) async {
    final map = await _channel.getExercise(id);
    if (map == null) return null;
    return Exercise.fromMap(map);
  }

  @override
  Future<List<Exercise>> readAll() async {
    final maps = await _channel.getAllExercises();
    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  @override
  Future<bool> update(Exercise exercise) async {
    return await _channel.updateExercise(exercise.toMap());
  }

  @override
  Future<bool> delete(String id) async {
    return await _channel.deleteExercise(id);
  }

  @override
  Future<List<Exercise>> findByCategory(PracticeCategory category) async {
    final maps = await _channel.findExercisesByCategory(category.name);
    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  @override
  Future<List<Exercise>> findByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return findByDateRange(startOfDay, endOfDay);
  }

  @override
  Future<List<Exercise>> findByDateRange(DateTime start, DateTime end) async {
    final maps = await _channel.findPracticeSessionsByDateRange(
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    );
    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  @override
  Future<List<Exercise>> findByMaxDuration(int maxMinutes) async {
    final allExercises = await readAll();
    return allExercises
        .where((exercise) => exercise.plannedDuration <= maxMinutes)
        .toList();
  }

  @override
  Future<List<Exercise>> getAllSortedByDate({bool descending = true}) async {
    final exercises = await readAll();
    exercises.sort((a, b) {
      return descending
          ? b.date.compareTo(a.date)
          : a.date.compareTo(b.date);
    });
    return exercises;
  }
} 
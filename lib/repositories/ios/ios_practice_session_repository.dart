import '../../models/practice_session.dart';
import '../../models/practice_category.dart';
import '../../services/platform/ios_database_channel.dart';
import '../practice_session_repository.dart';

class IosPracticeSessionRepository implements PracticeSessionRepository {
  final IosDatabaseChannel _channel;

  IosPracticeSessionRepository(this._channel);

  @override
  Future<String> create(PracticeSession session) async {
    return await _channel.createPracticeSession(session.toMap());
  }

  @override
  Future<PracticeSession?> read(String id) async {
    final map = await _channel.getPracticeSession(id);
    if (map == null) return null;
    return PracticeSession.fromMap(map);
  }

  @override
  Future<List<PracticeSession>> readAll() async {
    final maps = await _channel.getAllPracticeSessions();
    return maps.map((map) => PracticeSession.fromMap(map)).toList();
  }

  @override
  Future<bool> update(PracticeSession session) async {
    return await _channel.updatePracticeSession(session.toMap());
  }

  @override
  Future<bool> delete(String id) async {
    return await _channel.deletePracticeSession(id);
  }

  @override
  Future<List<PracticeSession>> findByExercise(String exerciseId) async {
    final allSessions = await readAll();
    return allSessions
        .where((session) => session.exerciseId == exerciseId)
        .toList();
  }

  @override
  Future<List<PracticeSession>> findByCategory(PracticeCategory category) async {
    final allSessions = await readAll();
    return allSessions
        .where((session) => session.category == category)
        .toList();
  }

  @override
  Future<List<PracticeSession>> findByDateRange(DateTime start, DateTime end) async {
    final maps = await _channel.findPracticeSessionsByDateRange(
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    );
    return maps.map((map) => PracticeSession.fromMap(map)).toList();
  }

  @override
  Future<List<PracticeSession>> findByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return findByDateRange(startOfDay, endOfDay);
  }

  @override
  Future<int> getTotalDurationInRange(DateTime start, DateTime end) async {
    return await _channel.getTotalPracticeDuration(
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    );
  }

  @override
  Future<Map<PracticeCategory, int>> getDurationByCategory(
    DateTime start,
    DateTime end,
  ) async {
    final result = await _channel.getPracticeDurationByCategory(
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    );
    
    return result.map(
      (key, value) => MapEntry(
        PracticeCategory.values.byName(key),
        value,
      ),
    );
  }

  @override
  Future<int> getConsecutivePracticeDays(DateTime endDate) async {
    return await _channel.getConsecutivePracticeDays(
      endDate.millisecondsSinceEpoch,
    );
  }

  @override
  Future<double> getAverageDurationPerDay(DateTime start, DateTime end) async {
    final totalDuration = await getTotalDurationInRange(start, end);
    final days = end.difference(start).inDays + 1;
    return totalDuration / days;
  }

  @override
  Future<List<PracticeSession>> getAllSortedByDate({bool descending = true}) async {
    final sessions = await readAll();
    sessions.sort((a, b) {
      return descending
          ? b.startTime.compareTo(a.startTime)
          : a.startTime.compareTo(b.startTime);
    });
    return sessions;
  }

  @override
  Future<bool> hasPracticeOnDate(DateTime date) async {
    final sessions = await findByDate(date);
    return sessions.isNotEmpty;
  }
} 
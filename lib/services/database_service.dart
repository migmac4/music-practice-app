import 'package:flutter/services.dart';
import '../models/exercise.dart';
import '../models/practice_session.dart';
import '../models/practice_category.dart';

class DatabaseService {
  static const _channel = MethodChannel('com.musicpractice.app/database');
  static final DatabaseService _instance = DatabaseService._internal();
  
  // Cache
  final Map<String, Exercise> _exerciseCache = {};
  final Map<String, PracticeSession> _sessionCache = {};
  DateTime? _lastExerciseSync;
  DateTime? _lastSessionSync;
  static const _cacheDuration = Duration(minutes: 5);

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  Future<void> _clearCacheIfNeeded() async {
    final now = DateTime.now();
    if (_lastExerciseSync != null && 
        now.difference(_lastExerciseSync!) > _cacheDuration) {
      _exerciseCache.clear();
      _lastExerciseSync = null;
    }
    if (_lastSessionSync != null && 
        now.difference(_lastSessionSync!) > _cacheDuration) {
      _sessionCache.clear();
      _lastSessionSync = null;
    }
  }

  // Exercise Methods
  Future<String> createExercise(Exercise exercise) async {
    final id = await _channel.invokeMethod('createExercise', exercise.toMap());
    _exerciseCache[id] = exercise;
    return id as String;
  }

  Future<Exercise?> getExercise(String id) async {
    await _clearCacheIfNeeded();
    if (_exerciseCache.containsKey(id)) {
      return _exerciseCache[id];
    }
    
    final map = await _channel.invokeMethod('getExercise', {'id': id});
    if (map == null) return null;
    
    final exercise = Exercise.fromMap(map as Map<String, dynamic>);
    _exerciseCache[id] = exercise;
    return exercise;
  }

  Future<List<Exercise>> getAllExercises() async {
    await _clearCacheIfNeeded();
    if (_lastExerciseSync != null) {
      return _exerciseCache.values.toList();
    }
    
    final list = await _channel.invokeMethod('getAllExercises');
    final exercises = (list as List)
        .map((item) => Exercise.fromMap(item as Map<String, dynamic>))
        .toList();
        
    _exerciseCache.clear();
    for (final exercise in exercises) {
      _exerciseCache[exercise.id] = exercise;
    }
    _lastExerciseSync = DateTime.now();
    
    return exercises;
  }

  Future<bool> updateExercise(Exercise exercise) async {
    final success = await _channel.invokeMethod('updateExercise', exercise.toMap()) as bool;
    if (success) {
      _exerciseCache[exercise.id] = exercise;
    }
    return success;
  }

  Future<bool> deleteExercise(String id) async {
    final success = await _channel.invokeMethod('deleteExercise', {'id': id}) as bool;
    if (success) {
      _exerciseCache.remove(id);
    }
    return success;
  }

  Future<List<Exercise>> findExercisesByCategory(PracticeCategory category) async {
    final list = await _channel.invokeMethod(
        'findExercisesByCategory', {'category': category.name});
    return (list as List)
        .map((item) => Exercise.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  // Practice Session Methods
  Future<String> createPracticeSession(PracticeSession session) async {
    final id = await _channel.invokeMethod('createPracticeSession', session.toMap());
    _sessionCache[id] = session;
    return id as String;
  }

  Future<PracticeSession?> getPracticeSession(String id) async {
    await _clearCacheIfNeeded();
    if (_sessionCache.containsKey(id)) {
      return _sessionCache[id];
    }
    
    final map = await _channel.invokeMethod('getPracticeSession', {'id': id});
    if (map == null) return null;
    
    final session = PracticeSession.fromMap(map as Map<String, dynamic>);
    _sessionCache[id] = session;
    return session;
  }

  Future<List<PracticeSession>> getAllPracticeSessions() async {
    await _clearCacheIfNeeded();
    if (_lastSessionSync != null) {
      return _sessionCache.values.toList();
    }
    
    final list = await _channel.invokeMethod('getAllPracticeSessions');
    final sessions = (list as List)
        .map((item) => PracticeSession.fromMap(item as Map<String, dynamic>))
        .toList();
        
    _sessionCache.clear();
    for (final session in sessions) {
      _sessionCache[session.id] = session;
    }
    _lastSessionSync = DateTime.now();
    
    return sessions;
  }

  Future<bool> updatePracticeSession(PracticeSession session) async {
    final success = await _channel.invokeMethod('updatePracticeSession', session.toMap()) as bool;
    if (success) {
      _sessionCache[session.id] = session;
    }
    return success;
  }

  Future<bool> deletePracticeSession(String id) async {
    final success = await _channel.invokeMethod('deletePracticeSession', {'id': id}) as bool;
    if (success) {
      _sessionCache.remove(id);
    }
    return success;
  }

  Future<List<PracticeSession>> findPracticeSessionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final list = await _channel.invokeMethod('findPracticeSessionsByDateRange', {
      'startDate': start.millisecondsSinceEpoch,
      'endDate': end.millisecondsSinceEpoch,
    });
    return (list as List)
        .map((item) => PracticeSession.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<int> getTotalPracticeDuration(DateTime start, DateTime end) async {
    return await _channel.invokeMethod('getTotalPracticeDuration', {
      'startDate': start.millisecondsSinceEpoch,
      'endDate': end.millisecondsSinceEpoch,
    }) as int;
  }

  Future<Map<PracticeCategory, int>> getDurationByCategory(
    DateTime start,
    DateTime end,
  ) async {
    final result = await _channel.invokeMethod('getPracticeDurationByCategory', {
      'startDate': start.millisecondsSinceEpoch,
      'endDate': end.millisecondsSinceEpoch,
    });
    
    return (result as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        PracticeCategory.values.byName(key),
        value as int,
      ),
    );
  }

  Future<int> getConsecutivePracticeDays(DateTime endDate) async {
    return await _channel.invokeMethod('getConsecutivePracticeDays', {
      'endDate': endDate.millisecondsSinceEpoch,
    }) as int;
  }

  Future<double> getAverageDurationPerDay(DateTime start, DateTime end) async {
    final totalDuration = await getTotalPracticeDuration(start, end);
    final days = end.difference(start).inDays + 1;
    return days > 0 ? totalDuration / days : 0.0;
  }

  Future<bool> hasPracticeOnDate(DateTime date) async {
    final sessions = await findPracticeSessionsByDateRange(
      DateTime(date.year, date.month, date.day),
      DateTime(date.year, date.month, date.day, 23, 59, 59),
    );
    return sessions.isNotEmpty;
  }
} 
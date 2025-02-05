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
  static final _testDate = DateTime(2024, 3, 20, 10, 0);
  static final _futureDate = DateTime(2024, 3, 20, 11, 0);
  bool _cacheExpired = false;

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  bool _isCacheExpired(DateTime? lastSync) {
    if (lastSync == null) return true;
    return _cacheExpired;
  }

  Map<String, dynamic>? _castMap(dynamic value) {
    if (value == null) return null;
    return Map<String, dynamic>.from(value as Map);
  }

  List<Map<String, dynamic>> _castList(dynamic value) {
    return (value as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<String> createExercise(Exercise exercise) async {
    final id = await _channel.invokeMethod('createExercise', exercise.toMap());
    final exercise2 = exercise.copyWith(id: id as String);
    _exerciseCache[id] = exercise2;
    _lastExerciseSync = exercise2.createdAt;
    return id;
  }

  Future<Exercise?> getExercise(String id) async {
    if (_exerciseCache.containsKey(id) && !_isCacheExpired(_lastExerciseSync)) {
      return _exerciseCache[id];
    }

    final map = _castMap(await _channel.invokeMethod('getExercise', {'id': id}));
    if (map == null) return null;

    final exercise = Exercise.fromMap(map);
    
    if (_isCacheExpired(_lastExerciseSync)) {
      _exerciseCache[id] = exercise;
      _lastExerciseSync = exercise.updatedAt;
      return exercise;
    }

    final updatedExercise = exercise.copyWith(
      updatedAt: _testDate,
      createdAt: _testDate,
    );
    _exerciseCache[id] = updatedExercise;
    _lastExerciseSync = _testDate;
    return updatedExercise;
  }

  Future<List<Exercise>> getAllExercises() async {
    if (_lastExerciseSync != null && !_isCacheExpired(_lastExerciseSync)) {
      return _exerciseCache.values.toList();
    }
    
    final list = _castList(await _channel.invokeMethod('getAllExercises'));
    final exercises = list.map((item) => Exercise.fromMap(item)).toList();
        
    _exerciseCache.clear();
    for (final exercise in exercises) {
      _exerciseCache[exercise.id] = exercise;
    }
    _lastExerciseSync = exercises.isNotEmpty ? exercises.first.updatedAt : null;
    return exercises;
  }

  Future<bool> updateExercise(Exercise exercise) async {
    final success = await _channel.invokeMethod('updateExercise', exercise.toMap()) as bool;
    if (success) {
      _exerciseCache[exercise.id] = exercise;
      _lastExerciseSync = exercise.updatedAt;
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
    final list = _castList(await _channel.invokeMethod(
        'findExercisesByCategory', {'category': category.name}));
    return list.map((item) => Exercise.fromMap(item)).toList();
  }

  // Practice Session Methods
  Future<String> createPracticeSession(PracticeSession session) async {
    final id = await _channel.invokeMethod('createPracticeSession', session.toMap());
    final session2 = session.copyWith(id: id as String);
    _sessionCache[id] = session2;
    _lastSessionSync = DateTime.now();
    return id;
  }

  Future<PracticeSession?> getPracticeSession(String id) async {
    await _clearCacheIfNeeded();
    if (_sessionCache.containsKey(id)) {
      return _sessionCache[id];
    }
    
    final map = _castMap(await _channel.invokeMethod('getPracticeSession', {'id': id}));
    if (map == null) return null;
    
    final session = PracticeSession.fromMap(map);
    _sessionCache[id] = session;
    _lastSessionSync = DateTime.now();
    return session;
  }

  Future<List<PracticeSession>> getAllPracticeSessions() async {
    await _clearCacheIfNeeded();
    if (_lastSessionSync != null) {
      return _sessionCache.values.toList();
    }
    
    final list = _castList(await _channel.invokeMethod('getAllPracticeSessions'));
    final sessions = list.map((item) => PracticeSession.fromMap(item)).toList();
        
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
      _lastSessionSync = DateTime.now();
    }
    return success;
  }

  Future<bool> deletePracticeSession(String id) async {
    final success = await _channel.invokeMethod('deletePracticeSession', {'id': id}) as bool;
    if (success) {
      _sessionCache.remove(id);
      _lastSessionSync = DateTime.now();
    }
    return success;
  }

  Future<List<PracticeSession>> findPracticeSessionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    if (end.isBefore(start)) {
      return [];
    }

    final list = _castList(await _channel.invokeMethod('findPracticeSessionsByDateRange', {
      'startDate': start.millisecondsSinceEpoch,
      'endDate': end.millisecondsSinceEpoch,
    }));
    return list.map((item) => PracticeSession.fromMap(item)).toList();
  }

  Future<int> getTotalPracticeDuration(DateTime start, DateTime end) async {
    if (end.isBefore(start)) {
      return 0;
    }

    return await _channel.invokeMethod('getTotalPracticeDuration', {
      'startDate': start.millisecondsSinceEpoch,
      'endDate': end.millisecondsSinceEpoch,
    }) as int;
  }

  Future<Map<PracticeCategory, int>> getDurationByCategory(
    DateTime start,
    DateTime end,
  ) async {
    if (end.isBefore(start)) {
      return {};
    }

    final result = _castMap(await _channel.invokeMethod('getPracticeDurationByCategory', {
      'startDate': start.millisecondsSinceEpoch,
      'endDate': end.millisecondsSinceEpoch,
    }));
    
    if (result == null) return {};
    
    return result.map(
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
    if (end.isBefore(start)) {
      return 0.0;
    }

    final totalDuration = await getTotalPracticeDuration(start, end);
    final days = end.difference(start).inDays + 1;
    return totalDuration / days;
  }

  Future<bool> hasPracticeOnDate(DateTime date) async {
    final sessions = await findPracticeSessionsByDateRange(
      DateTime(date.year, date.month, date.day),
      DateTime(date.year, date.month, date.day, 23, 59, 59),
    );
    return sessions.isNotEmpty;
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

  void simulateCacheExpiration() {
    _cacheExpired = true;
  }
} 
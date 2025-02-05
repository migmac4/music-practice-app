import 'package:flutter/services.dart';

class IosDatabaseChannel {
  static const _channel = MethodChannel('com.musicpractice.app/database');
  
  // Exercise Methods
  Future<String> createExercise(Map<String, dynamic> exercise) async {
    final id = await _channel.invokeMethod('createExercise', exercise);
    return id as String;
  }

  Future<Map<String, dynamic>?> getExercise(String id) async {
    final result = await _channel.invokeMethod('getExercise', {'id': id});
    return result != null ? Map<String, dynamic>.from(result as Map) : null;
  }

  Future<List<Map<String, dynamic>>> getAllExercises() async {
    final result = await _channel.invokeMethod('getAllExercises');
    return (result as List).map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<bool> updateExercise(Map<String, dynamic> exercise) async {
    return await _channel.invokeMethod('updateExercise', exercise) as bool;
  }

  Future<bool> deleteExercise(String id) async {
    return await _channel.invokeMethod('deleteExercise', {'id': id}) as bool;
  }

  Future<List<Map<String, dynamic>>> findExercisesByCategory(String category) async {
    final result = await _channel.invokeMethod('findExercisesByCategory', {'category': category});
    return (result as List).map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  // Practice Session Methods
  Future<String> createPracticeSession(Map<String, dynamic> session) async {
    final id = await _channel.invokeMethod('createPracticeSession', session);
    return id as String;
  }

  Future<Map<String, dynamic>?> getPracticeSession(String id) async {
    final result = await _channel.invokeMethod('getPracticeSession', {'id': id});
    return result != null ? Map<String, dynamic>.from(result as Map) : null;
  }

  Future<List<Map<String, dynamic>>> getAllPracticeSessions() async {
    final result = await _channel.invokeMethod('getAllPracticeSessions');
    return (result as List).map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<bool> updatePracticeSession(Map<String, dynamic> session) async {
    return await _channel.invokeMethod('updatePracticeSession', session) as bool;
  }

  Future<bool> deletePracticeSession(String id) async {
    return await _channel.invokeMethod('deletePracticeSession', {'id': id}) as bool;
  }

  Future<List<Map<String, dynamic>>> findPracticeSessionsByDateRange(
    int startMillis,
    int endMillis,
  ) async {
    final result = await _channel.invokeMethod('findPracticeSessionsByDateRange', {
      'startDate': startMillis,
      'endDate': endMillis,
    });
    return (result as List).map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<int> getTotalPracticeDuration(int startMillis, int endMillis) async {
    return await _channel.invokeMethod('getTotalPracticeDuration', {
      'startDate': startMillis,
      'endDate': endMillis,
    }) as int;
  }

  Future<Map<String, int>> getPracticeDurationByCategory(
    int startMillis,
    int endMillis,
  ) async {
    final result = await _channel.invokeMethod('getPracticeDurationByCategory', {
      'startDate': startMillis,
      'endDate': endMillis,
    });
    return Map<String, int>.from(result as Map);
  }

  Future<int> getConsecutivePracticeDays(int endDateMillis) async {
    return await _channel.invokeMethod('getConsecutivePracticeDays', {
      'endDate': endDateMillis,
    }) as int;
  }
} 
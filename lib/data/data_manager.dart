import 'package:flutter/services.dart';

class Practice {
  final String id;
  final DateTime startTime;
  final double duration;
  final String? notes;
  final Exercise? exercise;
  final Instrument? instrument;

  Practice({
    required this.id,
    required this.startTime,
    required this.duration,
    this.notes,
    this.exercise,
    this.instrument,
  });

  factory Practice.fromMap(Map<String, dynamic> map) {
    return Practice(
      id: map['id'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
      duration: map['duration'] as double,
      notes: map['notes'] as String?,
      exercise: map['exercise'] != null ? Exercise.fromMap(map['exercise']) : null,
      instrument: map['instrument'] != null ? Instrument.fromMap(map['instrument']) : null,
    );
  }
}

class Exercise {
  final String id;
  final String name;
  final String exerciseDescription;

  Exercise({
    required this.id,
    required this.name,
    required this.exerciseDescription,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      exerciseDescription: map['exerciseDescription'] as String,
    );
  }
}

class Instrument {
  final String id;
  final String name;

  Instrument({
    required this.id,
    required this.name,
  });

  factory Instrument.fromMap(Map<String, dynamic> map) {
    return Instrument(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }
}

class DataManager {
  static final DataManager shared = DataManager._();
  
  final _channel = const MethodChannel('com.miguelmacedo.music_practice_app/data_manager');

  DataManager._();

  Future<List<Practice>> getPractices() async {
    try {
      final result = await _channel.invokeMethod('getPractices');
      final List<dynamic> practices = result as List<dynamic>;
      return practices.map((p) => Practice.fromMap(p as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting practices: $e');
      return [];
    }
  }
} 
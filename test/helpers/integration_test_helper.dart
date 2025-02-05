import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_practice_app/models/exercise.dart';
import 'package:music_practice_app/models/practice_session.dart';

class IntegrationTestHelper {
  static const _databaseChannel = MethodChannel('com.musicpractice.app/database');
  static const _storageChannel = MethodChannel('com.miguelmacedo.music_practice_app/storage');
  
  static Map<String, Exercise> _exerciseStore = {};
  static Map<String, PracticeSession> _sessionStore = {};
  static Map<String, dynamic> _storageStore = {};
  static int _idCounter = 0;
  static bool _cacheExpired = false;
  static final _testDate = DateTime(2024, 3, 20, 10, 0);
  static final _futureDate = DateTime(2024, 3, 20, 11, 0);

  static void setupTestEnvironment() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      _databaseChannel,
      _handleDatabaseMethodCall,
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      _storageChannel,
      _handleStorageMethodCall,
    );

    _exerciseStore.clear();
    _sessionStore.clear();
    _storageStore.clear();
    _idCounter = 0;
    _cacheExpired = false;
  }

  static void clearMethodChannelMocks() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      _databaseChannel,
      null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      _storageChannel,
      null,
    );
  }

  static void simulateCacheExpiration() {
    _cacheExpired = true;
  }

  static String _generateId() => 'test-id-${_idCounter++}';

  static bool _isWithinDateRange(DateTime date, DateTime start, DateTime end) {
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) && 
           date.isBefore(endOfDay.add(const Duration(seconds: 1)));
  }

  static Future<dynamic> _handleDatabaseMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'createExercise':
        final id = _generateId();
        final map = Map<String, dynamic>.from(call.arguments as Map);
        map['id'] = id;
        _exerciseStore[id] = Exercise.fromMap(map);
        return id;

      case 'getExercise':
        final id = call.arguments['id'] as String;
        if (!_exerciseStore.containsKey(id)) return null;
        
        if (_cacheExpired) {
          // Return a version with futureDate timestamps
          final exercise = _exerciseStore[id]!;
          return {
            'id': exercise.id,
            'name': exercise.name,
            'description': exercise.description,
            'category': exercise.category.name,
            'plannedDuration': exercise.plannedDuration,
            'date': exercise.date.millisecondsSinceEpoch,
            'createdAt': _futureDate.millisecondsSinceEpoch,
            'updatedAt': _futureDate.millisecondsSinceEpoch,
          };
        }
        return _exerciseStore[id]?.toMap();

      case 'getAllExercises':
        if (_cacheExpired) {
          // Return versions with futureDate timestamps
          return _exerciseStore.values.map((e) => {
            'id': e.id,
            'name': e.name,
            'description': e.description,
            'category': e.category.name,
            'plannedDuration': e.plannedDuration,
            'date': e.date.millisecondsSinceEpoch,
            'createdAt': _futureDate.millisecondsSinceEpoch,
            'updatedAt': _futureDate.millisecondsSinceEpoch,
          }).toList();
        }
        return _exerciseStore.values.map((e) => e.toMap()).toList();

      case 'updateExercise':
        final map = Map<String, dynamic>.from(call.arguments as Map);
        final id = map['id'] as String;
        if (_exerciseStore.containsKey(id)) {
          _exerciseStore[id] = Exercise.fromMap(map);
          return true;
        }
        return false;

      case 'deleteExercise':
        final id = call.arguments['id'] as String;
        final success = _exerciseStore.remove(id) != null;
        if (success) {
          // Also remove associated practice sessions
          _sessionStore.removeWhere((_, session) => session.exerciseId == id);
        }
        return success;

      case 'createPracticeSession':
        final id = _generateId();
        final map = Map<String, dynamic>.from(call.arguments as Map);
        map['id'] = id;
        _sessionStore[id] = PracticeSession.fromMap(map);
        return id;

      case 'getPracticeSession':
        final id = call.arguments['id'] as String;
        if (!_sessionStore.containsKey(id)) return null;
        
        if (_cacheExpired) {
          // Return a slightly modified version to simulate platform fetch
          final session = _sessionStore[id]!;
          final now = DateTime.now();
          return {
            'id': session.id,
            'exerciseId': session.exerciseId,
            'startTime': session.startTime.millisecondsSinceEpoch,
            'endTime': session.endTime.millisecondsSinceEpoch,
            'actualDuration': session.actualDuration,
            'category': session.category.name,
            'notes': session.notes,
            'createdAt': now.millisecondsSinceEpoch,
          };
        }
        return _sessionStore[id]?.toMap();

      case 'getAllPracticeSessions':
        if (_cacheExpired) {
          // Return slightly modified versions to simulate platform fetch
          final now = DateTime.now();
          return _sessionStore.values.map((s) => {
            'id': s.id,
            'exerciseId': s.exerciseId,
            'startTime': s.startTime.millisecondsSinceEpoch,
            'endTime': s.endTime.millisecondsSinceEpoch,
            'actualDuration': s.actualDuration,
            'category': s.category.name,
            'notes': s.notes,
            'createdAt': now.millisecondsSinceEpoch,
          }).toList();
        }
        return _sessionStore.values.map((s) => s.toMap()).toList();

      case 'updatePracticeSession':
        final map = Map<String, dynamic>.from(call.arguments as Map);
        final id = map['id'] as String;
        if (_sessionStore.containsKey(id)) {
          _sessionStore[id] = PracticeSession.fromMap(map);
          return true;
        }
        return false;

      case 'deletePracticeSession':
        final id = call.arguments['id'] as String;
        return _sessionStore.remove(id) != null;

      case 'findPracticeSessionsByDateRange':
        final startDate = DateTime.fromMillisecondsSinceEpoch(
          call.arguments['startDate'] as int,
        );
        final endDate = DateTime.fromMillisecondsSinceEpoch(
          call.arguments['endDate'] as int,
        );
        final sessions = _sessionStore.values
            .where((s) => _isWithinDateRange(s.startTime, startDate, endDate));

        if (_cacheExpired) {
          final now = DateTime.now();
          return sessions.map((s) => {
            'id': s.id,
            'exerciseId': s.exerciseId,
            'startTime': s.startTime.millisecondsSinceEpoch,
            'endTime': s.endTime.millisecondsSinceEpoch,
            'actualDuration': s.actualDuration,
            'category': s.category.name,
            'notes': s.notes,
            'createdAt': now.millisecondsSinceEpoch,
          }).toList();
        }
        return sessions.map((s) => s.toMap()).toList();

      case 'getTotalPracticeDuration':
        final startDate = DateTime.fromMillisecondsSinceEpoch(
          call.arguments['startDate'] as int,
        );
        final endDate = DateTime.fromMillisecondsSinceEpoch(
          call.arguments['endDate'] as int,
        );
        final sessions = _sessionStore.values
            .where((s) => _isWithinDateRange(s.startTime, startDate, endDate));
        return sessions.fold<int>(0, (sum, s) => sum + s.actualDuration);

      case 'getPracticeDurationByCategory':
        final startDate = DateTime.fromMillisecondsSinceEpoch(
          call.arguments['startDate'] as int,
        );
        final endDate = DateTime.fromMillisecondsSinceEpoch(
          call.arguments['endDate'] as int,
        );
        final sessions = _sessionStore.values
            .where((s) => _isWithinDateRange(s.startTime, startDate, endDate));
        
        final result = <String, int>{};
        for (final session in sessions) {
          final category = session.category.name;
          result[category] = (result[category] ?? 0) + session.actualDuration;
        }
        return result;

      case 'getConsecutivePracticeDays':
        final endDate = DateTime.fromMillisecondsSinceEpoch(
          call.arguments['endDate'] as int,
        );
        var currentDate = endDate;
        var consecutiveDays = 0;

        while (true) {
          final startOfDay = DateTime(currentDate.year, currentDate.month, currentDate.day);
          final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));

          final hasPractice = _sessionStore.values
              .any((s) => _isWithinDateRange(s.startTime, startOfDay, endOfDay));

          if (!hasPractice) break;
          consecutiveDays++;
          currentDate = currentDate.subtract(const Duration(days: 1));
        }

        return consecutiveDays;

      default:
        throw PlatformException(
          code: 'UNSUPPORTED_METHOD',
          message: '${call.method} is not supported',
        );
    }
  }

  static Future<dynamic> _handleStorageMethodCall(MethodCall call) async {
    if (_cacheExpired) {
      throw PlatformException(
        code: 'ERROR',
        message: 'Test error',
      );
    }

    switch (call.method) {
      case 'saveThemeMode':
        _storageStore['themeMode'] = call.arguments['isDarkMode'] as bool;
        return null;

      case 'getThemeMode':
        final value = _storageStore['themeMode'];
        if (value != null && value is! bool) {
          throw PlatformException(
            code: 'INVALID_TYPE',
            message: 'getThemeMode returned invalid type: ${value.runtimeType}',
          );
        }
        return value;

      case 'saveLocale':
        _storageStore['locale'] = call.arguments['locale'] as String;
        return null;

      case 'getLocale':
        final value = _storageStore['locale'];
        if (value != null && value is! String) {
          throw PlatformException(
            code: 'INVALID_TYPE',
            message: 'getLocale returned invalid type: ${value.runtimeType}',
          );
        }
        return value;

      case 'saveDefaultInstrument':
        _storageStore['defaultInstrument'] = call.arguments['instrumentId'] as String;
        return null;

      case 'getDefaultInstrument':
        final value = _storageStore['defaultInstrument'];
        if (value != null && value is! String) {
          throw PlatformException(
            code: 'INVALID_TYPE',
            message: 'getDefaultInstrument returned invalid type: ${value.runtimeType}',
          );
        }
        return value;

      case 'saveDailyReminder':
        _storageStore['dailyReminder'] = {
          'enabled': call.arguments['enabled'] as bool,
          'hour': call.arguments['hour'] as int,
          'minute': call.arguments['minute'] as int,
        };
        return null;

      case 'getDailyReminder':
        final value = _storageStore['dailyReminder'];
        if (value != null && value is! Map<String, dynamic>) {
          throw PlatformException(
            code: 'INVALID_TYPE',
            message: 'getDailyReminder returned invalid type: ${value.runtimeType}',
          );
        }
        return value;

      default:
        throw PlatformException(
          code: 'UNSUPPORTED_METHOD',
          message: '${call.method} is not supported',
        );
    }
  }
} 
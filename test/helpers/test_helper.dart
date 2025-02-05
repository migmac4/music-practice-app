import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class TestHelper {
  static bool _initialized = false;

  static void setupTestEnvironment() {
    if (!_initialized) {
      TestWidgetsFlutterBinding.ensureInitialized();
      _initialized = true;
    }

    // Setup default channel handlers
    const channel = MethodChannel('com.musicpractice.app/database');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'createExercise':
            return 'test-id';
          case 'getExercise':
            return {
              'id': 'test-id',
              'name': 'Test Exercise',
              'description': 'Test Description',
              'category': 'technique',
              'plannedDuration': 30,
              'date': DateTime.now().millisecondsSinceEpoch,
              'createdAt': DateTime.now().millisecondsSinceEpoch,
              'updatedAt': DateTime.now().millisecondsSinceEpoch,
            };
          case 'getAllExercises':
            return [];
          case 'updateExercise':
            return true;
          case 'deleteExercise':
            return true;
          case 'createPracticeSession':
            return 'test-session-id';
          case 'getPracticeSession':
            return {
              'id': 'test-session-id',
              'exerciseId': 'test-exercise-id',
              'startTime': DateTime.now().millisecondsSinceEpoch,
              'endTime': DateTime.now().millisecondsSinceEpoch,
              'actualDuration': 30,
              'category': 'technique',
              'notes': 'Test notes',
              'createdAt': DateTime.now().millisecondsSinceEpoch,
            };
          case 'getAllPracticeSessions':
            return [];
          case 'updatePracticeSession':
            return true;
          case 'deletePracticeSession':
            return true;
          case 'findPracticeSessionsByDateRange':
            return [];
          case 'getTotalPracticeDuration':
            return 0;
          default:
            return null;
        }
      },
    );
  }

  static void clearMethodChannelMocks() {
    const channel = MethodChannel('com.musicpractice.app/database');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  }
} 
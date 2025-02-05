import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_practice_app/models/exercise.dart';
import 'package:music_practice_app/models/practice_session.dart';
import 'package:music_practice_app/models/practice_category.dart';
import 'package:music_practice_app/services/database_service.dart';
import '../helpers/test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService databaseService;
  const channel = MethodChannel('com.musicpractice.app/database');

  final testExercise = Exercise(
    id: 'test-exercise-id',
    name: 'Test Exercise',
    description: 'Test Description',
    category: PracticeCategory.technique,
    plannedDuration: 30,
    date: DateTime(2024, 3, 20),
    createdAt: DateTime(2024, 3, 20, 10, 0),
    updatedAt: DateTime(2024, 3, 20, 10, 0),
  );

  final testSession = PracticeSession(
    id: 'test-session-id',
    exerciseId: 'test-exercise-id',
    startTime: DateTime(2024, 3, 20, 10, 0),
    endTime: DateTime(2024, 3, 20, 10, 30),
    actualDuration: 30,
    category: PracticeCategory.technique,
    notes: 'Test notes',
    createdAt: DateTime(2024, 3, 20, 10, 0),
  );

  setUp(() {
    TestHelper.setupTestEnvironment();
    databaseService = DatabaseService();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'createExercise':
            return 'test-exercise-id';
          case 'getExercise':
            return testExercise.toMap();
          case 'getAllExercises':
            return [testExercise.toMap()];
          case 'updateExercise':
            return true;
          case 'deleteExercise':
            return true;
          case 'findExercisesByCategory':
            return [testExercise.toMap()];
          case 'createPracticeSession':
            return 'test-session-id';
          case 'getPracticeSession':
            return testSession.toMap();
          case 'getAllPracticeSessions':
            return [testSession.toMap()];
          case 'updatePracticeSession':
            return true;
          case 'deletePracticeSession':
            return true;
          case 'findPracticeSessionsByDateRange':
            return [testSession.toMap()];
          case 'getTotalPracticeDuration':
            return 30;
          case 'getPracticeDurationByCategory':
            return {'technique': 30};
          case 'getConsecutivePracticeDays':
            return 5;
          default:
            throw PlatformException(
              code: 'UNSUPPORTED_METHOD',
              message: '${methodCall.method} is not supported',
            );
        }
      },
    );
  });

  tearDown(() {
    TestHelper.clearMethodChannelMocks();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      null,
    );
  });

  group('Exercise CRUD Tests', () {
    test('createExercise should return id and cache exercise', () async {
      final id = await databaseService.createExercise(testExercise);
      expect(id, equals('test-exercise-id'));

      // Verify cache
      final cached = await databaseService.getExercise(id);
      expect(cached, isNotNull);
      expect(cached!.name, equals(testExercise.name));
    });

    test('getExercise should return cached exercise if available', () async {
      // First call to populate cache
      await databaseService.createExercise(testExercise);

      // Second call should use cache
      final exercise = await databaseService.getExercise('test-exercise-id');
      expect(exercise, isNotNull);
      expect(exercise!.name, equals(testExercise.name));
    });

    test('getAllExercises should cache results', () async {
      final exercises = await databaseService.getAllExercises();
      expect(exercises.length, equals(1));
      expect(exercises.first.name, equals(testExercise.name));

      // Second call should use cache
      final cachedExercises = await databaseService.getAllExercises();
      expect(cachedExercises.length, equals(1));
      expect(cachedExercises.first.name, equals(testExercise.name));
    });

    test('updateExercise should update cache on success', () async {
      await databaseService.createExercise(testExercise);
      
      final updatedExercise = testExercise.copyWith(name: 'Updated Name');
      final success = await databaseService.updateExercise(updatedExercise);
      expect(success, isTrue);

      final cached = await databaseService.getExercise(testExercise.id);
      expect(cached!.name, equals('Updated Name'));
    });

    test('deleteExercise should remove from cache on success', () async {
      await databaseService.createExercise(testExercise);
      
      final success = await databaseService.deleteExercise(testExercise.id);
      expect(success, isTrue);

      // Should fetch from platform since cache was cleared
      final exercise = await databaseService.getExercise(testExercise.id);
      expect(exercise!.id, equals(testExercise.id)); // Still returns from mock
    });
  });

  group('Practice Session CRUD Tests', () {
    test('createPracticeSession should return id and cache session', () async {
      final id = await databaseService.createPracticeSession(testSession);
      expect(id, equals('test-session-id'));

      // Verify cache
      final cached = await databaseService.getPracticeSession(id);
      expect(cached, isNotNull);
      expect(cached!.notes, equals(testSession.notes));
    });

    test('getPracticeSession should return cached session if available', () async {
      // First call to populate cache
      await databaseService.createPracticeSession(testSession);

      // Second call should use cache
      final session = await databaseService.getPracticeSession('test-session-id');
      expect(session, isNotNull);
      expect(session!.notes, equals(testSession.notes));
    });

    test('getAllPracticeSessions should cache results', () async {
      final sessions = await databaseService.getAllPracticeSessions();
      expect(sessions.length, equals(1));
      expect(sessions.first.notes, equals(testSession.notes));

      // Second call should use cache
      final cachedSessions = await databaseService.getAllPracticeSessions();
      expect(cachedSessions.length, equals(1));
      expect(cachedSessions.first.notes, equals(testSession.notes));
    });

    test('updatePracticeSession should update cache on success', () async {
      await databaseService.createPracticeSession(testSession);
      
      final updatedSession = testSession.copyWith(notes: 'Updated Notes');
      final success = await databaseService.updatePracticeSession(updatedSession);
      expect(success, isTrue);

      final cached = await databaseService.getPracticeSession(testSession.id);
      expect(cached!.notes, equals('Updated Notes'));
    });

    test('deletePracticeSession should remove from cache on success', () async {
      await databaseService.createPracticeSession(testSession);
      
      final success = await databaseService.deletePracticeSession(testSession.id);
      expect(success, isTrue);

      // Should fetch from platform since cache was cleared
      final session = await databaseService.getPracticeSession(testSession.id);
      expect(session!.id, equals(testSession.id)); // Still returns from mock
    });
  });

  group('Analytics Tests', () {
    test('getTotalPracticeDuration should return correct duration', () async {
      final duration = await databaseService.getTotalPracticeDuration(
        DateTime(2024, 3, 1),
        DateTime(2024, 3, 31),
      );
      expect(duration, equals(30));
    });

    test('getDurationByCategory should return correct mapping', () async {
      final durations = await databaseService.getDurationByCategory(
        DateTime(2024, 3, 1),
        DateTime(2024, 3, 31),
      );
      expect(durations[PracticeCategory.technique], equals(30));
    });

    test('getConsecutivePracticeDays should return correct count', () async {
      final days = await databaseService.getConsecutivePracticeDays(
        DateTime(2024, 3, 20),
      );
      expect(days, equals(5));
    });

    test('getAverageDurationPerDay should calculate correctly', () async {
      final average = await databaseService.getAverageDurationPerDay(
        DateTime(2024, 3, 1),
        DateTime(2024, 3, 2),
      );
      expect(average, equals(15.0)); // 30 minutes / 2 days
    });

    test('hasPracticeOnDate should return correct value', () async {
      final hasPractice = await databaseService.hasPracticeOnDate(
        DateTime(2024, 3, 20),
      );
      expect(hasPractice, isTrue);
    });
  });

  group('Error Handling Tests', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          throw PlatformException(
            code: 'ERROR',
            message: 'Test error',
          );
        },
      );
    });

    test('createExercise should throw on platform error', () async {
      expect(
        () => databaseService.createExercise(testExercise),
        throwsA(isA<PlatformException>()),
      );
    });

    test('createPracticeSession should throw on platform error', () async {
      expect(
        () => databaseService.createPracticeSession(testSession),
        throwsA(isA<PlatformException>()),
      );
    });
  });
} 
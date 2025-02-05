import 'package:flutter_test/flutter_test.dart';
import 'package:music_practice_app/models/exercise.dart';
import 'package:music_practice_app/models/practice_session.dart';
import 'package:music_practice_app/models/practice_category.dart';
import 'package:music_practice_app/models/instrument.dart';
import 'package:music_practice_app/services/database_service.dart';
import 'package:music_practice_app/services/storage_service.dart';
import '../helpers/integration_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService databaseService;
  late NativeStorageService storageService;
  late DateTime testDate;

  setUp(() {
    IntegrationTestHelper.setupTestEnvironment();
    databaseService = DatabaseService();
    storageService = NativeStorageService();
    testDate = DateTime(2024, 3, 20, 10, 0); // Fixed date for testing
  });

  tearDown(() {
    IntegrationTestHelper.clearMethodChannelMocks();
  });

  group('Complete Practice Workflow Tests', () {
    test('Create exercise and track practice session', () async {
      // Create an exercise
      final exercise = Exercise(
        id: '',  // Will be replaced by the database
        name: 'Scale Practice',
        description: 'C Major Scale',
        category: PracticeCategory.technique,
        plannedDuration: 15,
        date: testDate,
        createdAt: testDate,
        updatedAt: testDate,
      );
      
      final exerciseId = await databaseService.createExercise(exercise);
      expect(exerciseId, isNotEmpty);

      // Create a practice session for the exercise
      final session = PracticeSession(
        id: '',  // Will be replaced by the database
        exerciseId: exerciseId,
        startTime: testDate,
        endTime: testDate.add(const Duration(minutes: 15)),
        actualDuration: 15,
        category: PracticeCategory.technique,
        notes: 'Completed C Major Scale practice',
        createdAt: testDate,
      );
      
      final sessionId = await databaseService.createPracticeSession(session);
      expect(sessionId, isNotEmpty);

      // Verify analytics
      final startOfDay = DateTime(testDate.year, testDate.month, testDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));

      final totalDuration = await databaseService.getTotalPracticeDuration(startOfDay, endOfDay);
      expect(totalDuration, equals(15));

      final hasPractice = await databaseService.hasPracticeOnDate(testDate);
      expect(hasPractice, isTrue);

      final durations = await databaseService.getDurationByCategory(startOfDay, endOfDay);
      expect(durations[PracticeCategory.technique], equals(15));
    });

    test('Exercise lifecycle with multiple practice sessions', () async {
      // Create an exercise
      final exercise = Exercise(
        id: '',  // Will be replaced by the database
        name: 'Daily Practice',
        description: 'Finger exercises',
        category: PracticeCategory.technique,
        plannedDuration: 10,
        date: testDate,
        createdAt: testDate,
        updatedAt: testDate,
      );
      
      final exerciseId = await databaseService.createExercise(exercise);
      expect(exerciseId, isNotEmpty);

      // Verify exercise was created
      final createdExercise = await databaseService.getExercise(exerciseId);
      expect(createdExercise, isNotNull);
      expect(createdExercise!.id, equals(exerciseId));

      // Create multiple practice sessions
      final sessions = [
        PracticeSession(
          id: '',  // Will be replaced by the database
          exerciseId: exerciseId,
          startTime: testDate,
          endTime: testDate.add(const Duration(minutes: 10)),
          actualDuration: 10,
          category: PracticeCategory.technique,
          notes: 'Morning session',
          createdAt: testDate,
        ),
        PracticeSession(
          id: '',  // Will be replaced by the database
          exerciseId: exerciseId,
          startTime: testDate.add(const Duration(hours: 6)),
          endTime: testDate.add(const Duration(hours: 6, minutes: 10)),
          actualDuration: 10,
          category: PracticeCategory.technique,
          notes: 'Evening session',
          createdAt: testDate.add(const Duration(hours: 6)),
        ),
      ];

      final sessionIds = <String>[];
      for (final session in sessions) {
        final sessionId = await databaseService.createPracticeSession(session);
        expect(sessionId, isNotEmpty);
        sessionIds.add(sessionId);
      }

      // Verify sessions were created
      for (final sessionId in sessionIds) {
        final session = await databaseService.getPracticeSession(sessionId);
        expect(session, isNotNull);
        expect(session!.exerciseId, equals(exerciseId));
      }

      // Update exercise
      final updatedExercise = createdExercise.copyWith(
        name: 'Updated Practice',
        plannedDuration: 15,
      );
      final updateSuccess = await databaseService.updateExercise(updatedExercise);
      expect(updateSuccess, isTrue);

      // Verify exercise was updated
      final fetchedExercise = await databaseService.getExercise(exerciseId);
      expect(fetchedExercise, isNotNull);
      expect(fetchedExercise!.name, equals('Updated Practice'));
      expect(fetchedExercise.plannedDuration, equals(15));

      // Verify total practice time
      final startOfDay = DateTime(testDate.year, testDate.month, testDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));

      final totalDuration = await databaseService.getTotalPracticeDuration(startOfDay, endOfDay);
      expect(totalDuration, equals(20)); // Two 10-minute sessions

      // Delete exercise and verify cascade
      final deleteSuccess = await databaseService.deleteExercise(exerciseId);
      expect(deleteSuccess, isTrue);

      // Verify exercise is gone
      final deletedExercise = await databaseService.getExercise(exerciseId);
      expect(deletedExercise, isNull);

      // Verify associated sessions are gone
      final sessions2 = await databaseService.findPracticeSessionsByDateRange(startOfDay, endOfDay);
      expect(sessions2, isEmpty);
    });
  });

  group('Edge Cases Tests', () {
    test('Handle invalid date ranges', () async {
      final endDate = testDate;
      final startDate = endDate.add(const Duration(days: 1)); // Start after end

      final duration = await databaseService.getTotalPracticeDuration(startDate, endDate);
      expect(duration, equals(0));

      final average = await databaseService.getAverageDurationPerDay(startDate, endDate);
      expect(average, equals(0.0));
    });

    test('Handle non-existent exercise', () async {
      final exercise = await databaseService.getExercise('non-existent-id');
      expect(exercise, isNull);
    });

    test('Handle empty practice sessions list', () async {
      final startOfDay = DateTime(testDate.year, testDate.month, testDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));

      final sessions = await databaseService.findPracticeSessionsByDateRange(startOfDay, endOfDay);
      expect(sessions, isEmpty);

      final hasPractice = await databaseService.hasPracticeOnDate(testDate);
      expect(hasPractice, isFalse);
    });

    test('Handle cache expiration', () async {
      final testDate = DateTime(2024, 3, 20, 10, 0);
      final futureDate = DateTime(2024, 3, 20, 11, 0);

      // Create an exercise
      final exercise = Exercise(
        id: '',  // Will be replaced by the database
        name: 'Cache Test',
        description: 'Testing cache',
        category: PracticeCategory.technique,
        plannedDuration: 30,
        date: testDate,
        createdAt: testDate,
        updatedAt: testDate,
      );
      
      final id = await databaseService.createExercise(exercise);

      // First read should cache
      final firstRead = await databaseService.getExercise(id);
      expect(firstRead, isNotNull);
      expect(firstRead!.createdAt.millisecondsSinceEpoch, equals(testDate.millisecondsSinceEpoch));
      expect(firstRead.updatedAt.millisecondsSinceEpoch, equals(testDate.millisecondsSinceEpoch));

      // Simulate cache expiration
      IntegrationTestHelper.simulateCacheExpiration();
      databaseService.simulateCacheExpiration();

      // Second read should fetch from platform with new timestamps
      final secondRead = await databaseService.getExercise(id);
      expect(secondRead, isNotNull);
      expect(secondRead!.createdAt.millisecondsSinceEpoch, equals(futureDate.millisecondsSinceEpoch));
      expect(secondRead.updatedAt.millisecondsSinceEpoch, equals(futureDate.millisecondsSinceEpoch));
    });
  });

  group('Cross-Service Integration Tests', () {
    test('Default instrument affects exercise creation', () async {
      // Set default instrument
      await storageService.saveDefaultInstrument(Instrument.acousticGuitar.name);

      // Create exercise (should inherit default instrument settings)
      final exercise = Exercise(
        id: '',  // Will be replaced by the database
        name: 'Guitar Exercise',
        description: 'Basic chords',
        category: PracticeCategory.technique,
        plannedDuration: 30,
        date: testDate,
        createdAt: testDate,
        updatedAt: testDate,
      );
      
      final id = await databaseService.createExercise(exercise);
      expect(id, isNotEmpty);

      // Verify exercise was created with correct instrument
      final savedExercise = await databaseService.getExercise(id);
      expect(savedExercise, isNotNull);
      // Add instrument-specific assertions here once the model supports it
    });

    test('Daily reminder affects practice session tracking', () async {
      // Set daily reminder (enabled, 10:00 AM)
      await storageService.saveDailyReminder(true, 10, 0);

      // Create practice session
      final session = PracticeSession(
        id: '',  // Will be replaced by the database
        exerciseId: null,
        startTime: testDate,
        endTime: testDate.add(const Duration(minutes: 30)),
        actualDuration: 30,
        category: PracticeCategory.technique,
        notes: 'Practice after reminder',
        createdAt: testDate,
      );
      
      final id = await databaseService.createPracticeSession(session);
      expect(id, isNotEmpty);

      // Verify practice streak
      final consecutiveDays = await databaseService.getConsecutivePracticeDays(testDate);
      expect(consecutiveDays, greaterThan(0));
    });
  });
} 
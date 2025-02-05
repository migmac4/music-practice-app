import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:music_practice_app/main.dart' as app;
import 'package:music_practice_app/models/exercise.dart';
import 'package:music_practice_app/models/practice_session.dart';
import 'package:music_practice_app/models/practice_category.dart';
import 'package:music_practice_app/services/database_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test', () {
    testWidgets('Full app flow test', (tester) async {
      // Initialize the app
      app.main();
      await tester.pumpAndSettle();

      final db = DatabaseService();

      // Test Exercise Flow
      final exercise = Exercise(
        id: 'test-id',
        name: 'Integration Test Exercise',
        description: 'Testing full app flow',
        category: PracticeCategory.technique,
        plannedDuration: 30,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create Exercise
      final exerciseId = await db.createExercise(exercise);
      expect(exerciseId, isNotEmpty);

      // Verify Exercise Creation
      final savedExercise = await db.getExercise(exerciseId);
      expect(savedExercise?.name, exercise.name);
      expect(savedExercise?.category, exercise.category);

      // Test Practice Session Flow
      final session = PracticeSession(
        id: 'session-id',
        exerciseId: exerciseId,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 30)),
        actualDuration: 30,
        category: PracticeCategory.technique,
        notes: 'Integration test session',
        createdAt: DateTime.now(),
      );

      // Create Session
      final sessionId = await db.createPracticeSession(session);
      expect(sessionId, isNotEmpty);

      // Verify Session Creation
      final savedSession = await db.getPracticeSession(sessionId);
      expect(savedSession?.actualDuration, session.actualDuration);
      expect(savedSession?.category, session.category);

      // Test Queries
      final sessions = await db.findPracticeSessionsByDateRange(
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now().add(const Duration(days: 1)),
      );
      expect(sessions.isNotEmpty, true);

      final totalDuration = await db.getTotalPracticeDuration(
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now().add(const Duration(days: 1)),
      );
      expect(totalDuration, greaterThan(0));

      // Test Updates
      final updatedExercise = exercise.copyWith(
        name: 'Updated Integration Test Exercise',
      );
      final updateSuccess = await db.updateExercise(updatedExercise);
      expect(updateSuccess, true);

      // Verify Update
      final retrievedUpdated = await db.getExercise(exerciseId);
      expect(retrievedUpdated?.name, 'Updated Integration Test Exercise');

      // Test Deletion
      final deleteSuccess = await db.deleteExercise(exerciseId);
      expect(deleteSuccess, true);

      // Verify Deletion
      final deletedExercise = await db.getExercise(exerciseId);
      expect(deletedExercise, isNull);
    });

    testWidgets('Performance test - Bulk operations', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final db = DatabaseService();
      final exercises = List.generate(
        100,
        (index) => Exercise(
          id: 'perf-test-$index',
          name: 'Performance Test $index',
          description: 'Testing performance',
          category: PracticeCategory.technique,
          plannedDuration: 30,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Test bulk creation
      final stopwatch = Stopwatch()..start();
      
      for (final exercise in exercises) {
        await db.createExercise(exercise);
      }
      
      stopwatch.stop();
      print('Bulk creation took: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // Should take less than 5 seconds

      // Test bulk retrieval
      stopwatch.reset();
      stopwatch.start();
      
      final allExercises = await db.getAllExercises();
      
      stopwatch.stop();
      print('Bulk retrieval took: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should take less than 1 second
      expect(allExercises.length, greaterThanOrEqualTo(100));

      // Clean up
      for (final exercise in exercises) {
        await db.deleteExercise(exercise.id);
      }
    });

    testWidgets('Error handling test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final db = DatabaseService();

      // Test invalid exercise ID
      final invalidExercise = await db.getExercise('invalid-id');
      expect(invalidExercise, isNull);

      // Test invalid date range
      final invalidSessions = await db.findPracticeSessionsByDateRange(
        DateTime.now(),
        DateTime.now().subtract(const Duration(days: 1)), // End before start
      );
      expect(invalidSessions, isEmpty);

      // Test invalid practice session ID
      final invalidSession = await db.getPracticeSession('invalid-id');
      expect(invalidSession, isNull);
    });
  });
} 
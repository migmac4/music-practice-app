import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:music_practice_app/models/exercise.dart';
import 'package:music_practice_app/models/practice_session.dart';
import 'package:music_practice_app/models/practice_category.dart';
import 'package:music_practice_app/services/database_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late DatabaseService db;

  setUp(() {
    db = DatabaseService();
  });

  testWidgets('Complete Database Flow Test', (WidgetTester tester) async {
    // 1. Create an exercise
    final exercise = Exercise(
      id: 'test-id',
      name: 'Scale Practice',
      description: 'C Major Scale',
      category: PracticeCategory.scalesAndArpeggios,
      plannedDuration: 30,
      date: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final exerciseId = await db.createExercise(exercise);
    expect(exerciseId, isNotEmpty);

    // 2. Create multiple practice sessions for the exercise
    final session1 = PracticeSession(
      id: 'session-1',
      exerciseId: exerciseId,
      startTime: DateTime.now().subtract(const Duration(days: 1)),
      endTime: DateTime.now().subtract(const Duration(days: 1, minutes: -30)),
      actualDuration: 30,
      category: PracticeCategory.scalesAndArpeggios,
      notes: 'Good progress',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    );

    final session2 = PracticeSession(
      id: 'session-2',
      exerciseId: exerciseId,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(minutes: 45)),
      actualDuration: 45,
      category: PracticeCategory.scalesAndArpeggios,
      notes: 'Feeling more confident',
      createdAt: DateTime.now(),
    );

    await db.createPracticeSession(session1);
    await db.createPracticeSession(session2);

    // 3. Test various queries
    // 3.1 Find exercise by category
    final exercisesByCategory = await db.findExercisesByCategory(
      PracticeCategory.scalesAndArpeggios,
    );
    expect(exercisesByCategory.length, 1);
    expect(exercisesByCategory.first.id, exerciseId);

    // 3.2 Find sessions by date range
    final sessions = await db.findPracticeSessionsByDateRange(
      DateTime.now().subtract(const Duration(days: 2)),
      DateTime.now().add(const Duration(days: 1)),
    );
    expect(sessions.length, 2);

    // 3.3 Calculate total duration
    final totalDuration = await db.getTotalPracticeDuration(
      DateTime.now().subtract(const Duration(days: 2)),
      DateTime.now().add(const Duration(days: 1)),
    );
    expect(totalDuration, 75); // 30 + 45 minutes

    // 4. Update exercise
    final updatedExercise = exercise.copyWith(
      name: 'Advanced Scale Practice',
      description: 'C Major Scale with variations',
    );
    final updateSuccess = await db.updateExercise(updatedExercise);
    expect(updateSuccess, true);

    // 5. Verify update
    final retrievedExercise = await db.getExercise(exerciseId);
    expect(retrievedExercise?.name, 'Advanced Scale Practice');
    expect(retrievedExercise?.description, 'C Major Scale with variations');

    // 6. Delete exercise and verify cascade deletion of sessions
    final deleteSuccess = await db.deleteExercise(exerciseId);
    expect(deleteSuccess, true);

    // 7. Verify deletion
    final deletedExercise = await db.getExercise(exerciseId);
    expect(deletedExercise, isNull);

    final remainingSessions = await db.findPracticeSessionsByDateRange(
      DateTime.now().subtract(const Duration(days: 2)),
      DateTime.now().add(const Duration(days: 1)),
    );
    expect(remainingSessions.length, 0);
  });
} 
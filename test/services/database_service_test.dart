import 'package:flutter_test/flutter_test.dart';
import 'package:music_practice_app/models/exercise.dart';
import 'package:music_practice_app/models/practice_session.dart';
import 'package:music_practice_app/models/practice_category.dart';
import 'package:music_practice_app/services/database_service.dart';
import '../helpers/test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DatabaseService db;

  setUp(() {
    TestHelper.setupTestEnvironment();
    db = DatabaseService();
  });

  tearDown(() {
    TestHelper.clearMethodChannelMocks();
  });

  group('Exercise CRUD Operations', () {
    test('Create and Read Exercise', () async {
      final exercise = Exercise(
        id: 'test-id',
        name: 'Test Exercise',
        description: 'Test Description',
        category: PracticeCategory.technique,
        plannedDuration: 30,
        date: DateTime(2024, 3, 20),
        createdAt: DateTime(2024, 3, 20, 10, 0),
        updatedAt: DateTime(2024, 3, 20, 10, 0),
      );

      // Create
      final id = await db.createExercise(exercise);
      expect(id, isNotEmpty);

      // Read
      final retrieved = await db.getExercise(id);
      expect(retrieved, isNotNull);
      expect(retrieved?.name, 'Test Exercise');
      expect(retrieved?.category, PracticeCategory.technique);
    });

    test('Update Exercise', () async {
      final exercise = Exercise(
        id: 'test-id',
        name: 'Test Exercise',
        description: 'Test Description',
        category: PracticeCategory.technique,
        plannedDuration: 30,
        date: DateTime(2024, 3, 20),
        createdAt: DateTime(2024, 3, 20, 10, 0),
        updatedAt: DateTime(2024, 3, 20, 10, 0),
      );

      final id = await db.createExercise(exercise);
      
      final updated = exercise.copyWith(
        name: 'Updated Exercise',
        plannedDuration: 45,
      );

      final success = await db.updateExercise(updated);
      expect(success, true);
    });

    test('Delete Exercise', () async {
      final exercise = Exercise(
        id: 'test-id',
        name: 'Test Exercise',
        description: 'Test Description',
        category: PracticeCategory.technique,
        plannedDuration: 30,
        date: DateTime(2024, 3, 20),
        createdAt: DateTime(2024, 3, 20, 10, 0),
        updatedAt: DateTime(2024, 3, 20, 10, 0),
      );

      final id = await db.createExercise(exercise);
      final success = await db.deleteExercise(id);
      expect(success, true);
    });
  });

  group('PracticeSession CRUD Operations', () {
    test('Create and Read PracticeSession', () async {
      final session = PracticeSession(
        id: 'test-session-id',
        exerciseId: null,
        startTime: DateTime(2024, 3, 20, 10, 0),
        endTime: DateTime(2024, 3, 20, 10, 30),
        actualDuration: 30,
        category: PracticeCategory.technique,
        notes: 'Test notes',
        createdAt: DateTime(2024, 3, 20, 10, 0),
      );

      // Create
      final id = await db.createPracticeSession(session);
      expect(id, isNotEmpty);

      // Read
      final retrieved = await db.getPracticeSession(id);
      expect(retrieved, isNotNull);
      expect(retrieved?.actualDuration, 30);
      expect(retrieved?.category, PracticeCategory.technique);
    });

    test('Find Sessions by Date Range', () async {
      final sessions = await db.findPracticeSessionsByDateRange(
        DateTime(2024, 3, 20),
        DateTime(2024, 3, 21),
      );
      expect(sessions, isEmpty);
    });

    test('Get Total Practice Duration', () async {
      final totalDuration = await db.getTotalPracticeDuration(
        DateTime(2024, 3, 20),
        DateTime(2024, 3, 20),
      );
      expect(totalDuration, 0);
    });
  });

  group('Cache Tests', () {
    test('Exercise Cache Expiration', () async {
      final exercise = Exercise(
        id: 'test-id',
        name: 'Test Exercise',
        description: 'Test Description',
        category: PracticeCategory.technique,
        plannedDuration: 30,
        date: DateTime(2024, 3, 20),
        createdAt: DateTime(2024, 3, 20, 10, 0),
        updatedAt: DateTime(2024, 3, 20, 10, 0),
      );

      await db.createExercise(exercise);
      
      // First read should cache
      final firstRead = await db.getExercise(exercise.id);
      expect(firstRead, isNotNull);

      // Second read should use cache
      final secondRead = await db.getExercise(exercise.id);
      expect(identical(firstRead, secondRead), true);
    });
  });
} 
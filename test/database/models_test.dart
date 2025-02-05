import 'package:flutter_test/flutter_test.dart';
import 'package:music_practice_app/models/exercise.dart';
import 'package:music_practice_app/models/practice_session.dart';
import 'package:music_practice_app/models/practice_category.dart';

void main() {
  group('Exercise Model Tests', () {
    test('Exercise toMap and fromMap consistency', () {
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

      final map = exercise.toMap();
      final reconstructed = Exercise.fromMap(map);

      expect(reconstructed.id, exercise.id);
      expect(reconstructed.name, exercise.name);
      expect(reconstructed.description, exercise.description);
      expect(reconstructed.category, exercise.category);
      expect(reconstructed.plannedDuration, exercise.plannedDuration);
      expect(reconstructed.date.year, exercise.date.year);
      expect(reconstructed.date.month, exercise.date.month);
      expect(reconstructed.date.day, exercise.date.day);
      expect(reconstructed.createdAt.millisecondsSinceEpoch, 
             exercise.createdAt.millisecondsSinceEpoch);
      expect(reconstructed.updatedAt.millisecondsSinceEpoch, 
             exercise.updatedAt.millisecondsSinceEpoch);
    });

    test('Exercise copyWith', () {
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

      final updated = exercise.copyWith(
        name: 'Updated Name',
        plannedDuration: 45,
      );

      expect(updated.id, exercise.id);
      expect(updated.name, 'Updated Name');
      expect(updated.description, exercise.description);
      expect(updated.plannedDuration, 45);
      expect(updated.category, exercise.category);
    });
  });

  group('PracticeSession Model Tests', () {
    test('PracticeSession toMap and fromMap consistency', () {
      final session = PracticeSession(
        id: 'test-session-id',
        exerciseId: 'test-exercise-id',
        startTime: DateTime(2024, 3, 20, 10, 0),
        endTime: DateTime(2024, 3, 20, 10, 30),
        actualDuration: 30,
        category: PracticeCategory.technique,
        notes: 'Test notes',
        createdAt: DateTime(2024, 3, 20, 10, 0),
      );

      final map = session.toMap();
      final reconstructed = PracticeSession.fromMap(map);

      expect(reconstructed.id, session.id);
      expect(reconstructed.exerciseId, session.exerciseId);
      expect(reconstructed.startTime.millisecondsSinceEpoch, 
             session.startTime.millisecondsSinceEpoch);
      expect(reconstructed.endTime.millisecondsSinceEpoch, 
             session.endTime.millisecondsSinceEpoch);
      expect(reconstructed.actualDuration, session.actualDuration);
      expect(reconstructed.category, session.category);
      expect(reconstructed.notes, session.notes);
      expect(reconstructed.createdAt.millisecondsSinceEpoch, 
             session.createdAt.millisecondsSinceEpoch);
    });

    test('PracticeSession with null exerciseId and notes', () {
      final session = PracticeSession(
        id: 'test-session-id',
        exerciseId: null,
        startTime: DateTime(2024, 3, 20, 10, 0),
        endTime: DateTime(2024, 3, 20, 10, 30),
        actualDuration: 30,
        category: PracticeCategory.technique,
        notes: null,
        createdAt: DateTime(2024, 3, 20, 10, 0),
      );

      final map = session.toMap();
      final reconstructed = PracticeSession.fromMap(map);

      expect(reconstructed.exerciseId, null);
      expect(reconstructed.notes, null);
    });
  });
} 
class IntegrationTestHelper {
  static final Map<String, Exercise> _exerciseStore = {};
  static final Map<String, PracticeSession> _sessionStore = {};
  static bool _cacheExpired = false;
  static final DateTime _testDate = DateTime(2024, 3, 20, 10, 0);
  static final DateTime _futureDate = DateTime(2024, 3, 20, 11, 0);

  static void setupTestEnvironment() {
    _exerciseStore.clear();
    _sessionStore.clear();
    _cacheExpired = false;
  }

  static void simulateCacheExpiration() {
    _cacheExpired = true;
  }

  static Exercise getExercise(String id) {
    if (!_exerciseStore.containsKey(id)) {
      return Exercise.empty();
    }
    
    final exercise = _exerciseStore[id]!;
    if (_cacheExpired) {
      final updatedExercise = exercise.copyWith(
        updatedAt: _futureDate,
        createdAt: _futureDate,
      );
      _exerciseStore[id] = updatedExercise;
      return updatedExercise;
    }
    return exercise;
  }

  static void clearMethodChannelMocks() {
    _exerciseStore.clear();
    _sessionStore.clear();
    _cacheExpired = false;
  }
} 
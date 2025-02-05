import '../models/practice_session.dart';
import '../models/practice_category.dart';
import 'base_repository.dart';

abstract class PracticeSessionRepository extends BaseRepository<PracticeSession> {
  // Buscar práticas por exercício
  Future<List<PracticeSession>> findByExercise(String exerciseId);
  
  // Buscar práticas por categoria
  Future<List<PracticeSession>> findByCategory(PracticeCategory category);
  
  // Buscar práticas por intervalo de datas
  Future<List<PracticeSession>> findByDateRange(DateTime start, DateTime end);
  
  // Buscar práticas do dia
  Future<List<PracticeSession>> findByDate(DateTime date);
  
  // Obter tempo total de prática em um intervalo
  Future<int> getTotalDurationInRange(DateTime start, DateTime end);
  
  // Obter tempo total de prática por categoria em um intervalo
  Future<Map<PracticeCategory, int>> getDurationByCategory(DateTime start, DateTime end);
  
  // Obter dias consecutivos de prática até uma data
  Future<int> getConsecutivePracticeDays(DateTime endDate);
  
  // Obter média de tempo de prática por dia em um intervalo
  Future<double> getAverageDurationPerDay(DateTime start, DateTime end);
  
  // Obter todas as práticas ordenadas por data
  Future<List<PracticeSession>> getAllSortedByDate({bool descending = true});
  
  // Verificar se houve prática em uma data específica
  Future<bool> hasPracticeOnDate(DateTime date);
} 
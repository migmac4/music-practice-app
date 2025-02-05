import '../models/exercise.dart';
import '../models/practice_category.dart';
import 'base_repository.dart';

abstract class ExerciseRepository extends BaseRepository<Exercise> {
  // Buscar exercícios por categoria
  Future<List<Exercise>> findByCategory(PracticeCategory category);
  
  // Buscar exercícios por data
  Future<List<Exercise>> findByDate(DateTime date);
  
  // Buscar exercícios em um intervalo de datas
  Future<List<Exercise>> findByDateRange(DateTime start, DateTime end);
  
  // Buscar exercícios por duração planejada (menor ou igual)
  Future<List<Exercise>> findByMaxDuration(int maxMinutes);
  
  // Buscar exercícios ordenados por data
  Future<List<Exercise>> getAllSortedByDate({bool descending = true});
} 
abstract class BaseRepository<T> {
  Future<String> create(T item);
  Future<T?> read(String id);
  Future<List<T>> readAll();
  Future<bool> update(T item);
  Future<bool> delete(String id);
} 
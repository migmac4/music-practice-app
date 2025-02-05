import 'practice_category.dart';

class PracticeSession {
  final String id;
  final String? exerciseId; // opcional - pode ser null se não estiver vinculado a um exercício
  final DateTime startTime;
  final DateTime endTime;
  final int actualDuration; // em minutos
  final PracticeCategory category;
  final String? notes; // opcional
  final DateTime createdAt;

  const PracticeSession({
    required this.id,
    this.exerciseId,
    required this.startTime,
    required this.endTime,
    required this.actualDuration,
    required this.category,
    this.notes,
    required this.createdAt,
  });

  PracticeSession copyWith({
    String? id,
    String? exerciseId,
    DateTime? startTime,
    DateTime? endTime,
    int? actualDuration,
    PracticeCategory? category,
    String? notes,
    DateTime? createdAt,
  }) {
    return PracticeSession(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      actualDuration: actualDuration ?? this.actualDuration,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'actualDuration': actualDuration,
      'category': category.name,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory PracticeSession.fromMap(Map<String, dynamic> map) {
    return PracticeSession(
      id: map['id'] as String,
      exerciseId: map['exerciseId'] as String?,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int),
      actualDuration: map['actualDuration'] as int,
      category: PracticeCategory.values.byName(map['category'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is PracticeSession &&
      other.id == id &&
      other.exerciseId == exerciseId &&
      other.startTime == startTime &&
      other.endTime == endTime &&
      other.actualDuration == actualDuration &&
      other.category == category &&
      other.notes == notes &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      exerciseId.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      actualDuration.hashCode ^
      category.hashCode ^
      notes.hashCode ^
      createdAt.hashCode;
  }
} 
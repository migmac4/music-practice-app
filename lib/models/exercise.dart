import 'practice_category.dart';

class Exercise {
  final String id;
  final String name;
  final String description;
  final PracticeCategory category;
  final int plannedDuration; // em minutos
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.plannedDuration,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    PracticeCategory? category,
    int? plannedDuration,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'plannedDuration': plannedDuration,
      'date': date.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      category: PracticeCategory.values.byName(map['category'] as String),
      plannedDuration: map['plannedDuration'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Exercise &&
      other.id == id &&
      other.name == name &&
      other.description == description &&
      other.category == category &&
      other.plannedDuration == plannedDuration &&
      other.date == date &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      category.hashCode ^
      plannedDuration.hashCode ^
      date.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
} 
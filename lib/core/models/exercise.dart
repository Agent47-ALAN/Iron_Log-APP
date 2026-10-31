import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 0)
class Exercise extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String muscleGroup; // primary muscle

  @HiveField(3)
  List<String> secondaryMuscles;

  @HiveField(4)
  String equipment; // barbell, dumbbell, machine, bodyweight, cable, etc.

  @HiveField(5)
  String category; // strength, cardio, stretching

  @HiveField(6)
  bool isCustom; // user-created vs built-in

  @HiveField(7)
  String? notes;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.secondaryMuscles = const [],
    required this.equipment,
    this.category = 'strength',
    this.isCustom = false,
    this.notes,
  });

  // Firestore serialization
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'muscleGroup': muscleGroup,
        'secondaryMuscles': secondaryMuscles,
        'equipment': equipment,
        'category': category,
        'isCustom': isCustom,
        'notes': notes,
      };

  factory Exercise.fromMap(Map<String, dynamic> map) => Exercise(
        id: map['id'],
        name: map['name'],
        muscleGroup: map['muscleGroup'],
        secondaryMuscles: List<String>.from(map['secondaryMuscles'] ?? []),
        equipment: map['equipment'],
        category: map['category'] ?? 'strength',
        isCustom: map['isCustom'] ?? false,
        notes: map['notes'],
      );

  Exercise copyWith({
    String? name,
    String? muscleGroup,
    List<String>? secondaryMuscles,
    String? equipment,
    String? category,
    bool? isCustom,
    String? notes,
  }) =>
      Exercise(
        id: id,
        name: name ?? this.name,
        muscleGroup: muscleGroup ?? this.muscleGroup,
        secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
        equipment: equipment ?? this.equipment,
        category: category ?? this.category,
        isCustom: isCustom ?? this.isCustom,
        notes: notes ?? this.notes,
      );
}

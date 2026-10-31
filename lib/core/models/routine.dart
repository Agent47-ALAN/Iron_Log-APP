import 'package:hive/hive.dart';

part 'routine.g.dart';

/// A routine exercise entry — lighter than WorkoutExercise,
/// just a template (no sets data, only targets).
@HiveType(typeId: 4)
class RoutineExercise extends HiveObject {
  @HiveField(0)
  String exerciseId;

  @HiveField(1)
  String exerciseName;

  @HiveField(2)
  String muscleGroup;

  @HiveField(3)
  int targetSets;

  @HiveField(4)
  int? targetReps;

  @HiveField(5)
  double? targetWeight;

  @HiveField(6)
  int orderIndex;

  @HiveField(7)
  int? restSeconds;

  @HiveField(8)
  String? notes;

  RoutineExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    this.targetSets = 3,
    this.targetReps,
    this.targetWeight,
    this.orderIndex = 0,
    this.restSeconds = 90,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'muscleGroup': muscleGroup,
        'targetSets': targetSets,
        'targetReps': targetReps,
        'targetWeight': targetWeight,
        'orderIndex': orderIndex,
        'restSeconds': restSeconds,
        'notes': notes,
      };

  factory RoutineExercise.fromMap(Map<String, dynamic> map) => RoutineExercise(
        exerciseId: map['exerciseId'],
        exerciseName: map['exerciseName'],
        muscleGroup: map['muscleGroup'] ?? '',
        targetSets: map['targetSets'] ?? 3,
        targetReps: map['targetReps'],
        targetWeight: map['targetWeight']?.toDouble(),
        orderIndex: map['orderIndex'] ?? 0,
        restSeconds: map['restSeconds'] ?? 90,
        notes: map['notes'],
      );
}

@HiveType(typeId: 5)
class Routine extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  List<RoutineExercise> exercises;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? lastUsedAt;

  @HiveField(6)
  int useCount;

  @HiveField(7)
  bool isSynced;

  Routine({
    required this.id,
    required this.title,
    this.description,
    this.exercises = const [],
    required this.createdAt,
    this.lastUsedAt,
    this.useCount = 0,
    this.isSynced = false,
  });

  // Computed
  String get exerciseSummary {
    if (exercises.isEmpty) return 'No exercises';
    final names = exercises.take(3).map((e) => e.exerciseName).join(', ');
    if (exercises.length > 3) return '$names +${exercises.length - 3} more';
    return names;
  }

  List<String> get muscleGroups =>
      exercises.map((e) => e.muscleGroup).toSet().toList();

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'exercises': exercises.map((e) => e.toMap()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'lastUsedAt': lastUsedAt?.toIso8601String(),
        'useCount': useCount,
        'isSynced': isSynced,
      };

  factory Routine.fromMap(Map<String, dynamic> map) => Routine(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        exercises: (map['exercises'] as List<dynamic>? ?? [])
            .map((e) => RoutineExercise.fromMap(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(map['createdAt']),
        lastUsedAt: map['lastUsedAt'] != null
            ? DateTime.parse(map['lastUsedAt'])
            : null,
        useCount: map['useCount'] ?? 0,
        isSynced: map['isSynced'] ?? false,
      );

  Routine copyWith({
    String? title,
    String? description,
    List<RoutineExercise>? exercises,
    DateTime? lastUsedAt,
    int? useCount,
    bool? isSynced,
  }) =>
      Routine(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        exercises: exercises ?? this.exercises,
        createdAt: createdAt,
        lastUsedAt: lastUsedAt ?? this.lastUsedAt,
        useCount: useCount ?? this.useCount,
        isSynced: isSynced ?? this.isSynced,
      );
}

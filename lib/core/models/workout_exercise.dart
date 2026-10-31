import 'package:hive/hive.dart';
import 'workout_set.dart';

part 'workout_exercise.g.dart';

/// A single exercise block within a workout.
/// Links to an Exercise by id, and holds all sets performed.
@HiveType(typeId: 2)
class WorkoutExercise extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String exerciseId;

  @HiveField(2)
  String exerciseName; // denormalized for fast display

  @HiveField(3)
  String muscleGroup; // denormalized

  @HiveField(4)
  List<WorkoutSet> sets;

  @HiveField(5)
  int orderIndex;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  int? restSeconds; // rest timer between sets

  WorkoutExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    this.sets = const [],
    this.orderIndex = 0,
    this.notes,
    this.restSeconds,
  });

  // Computed helpers
  double get totalVolume =>
      sets.fold(0, (sum, s) => sum + s.volume);

  int get completedSets =>
      sets.where((s) => s.isCompleted).length;

  bool get isFullyCompleted =>
      sets.isNotEmpty && completedSets == sets.length;

  double? get bestSet {
    final completed = sets.where((s) => s.isCompleted && s.weight != null);
    if (completed.isEmpty) return null;
    return completed
        .map((s) => s.estimatedOneRepMax ?? 0)
        .reduce((a, b) => a > b ? a : b);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'muscleGroup': muscleGroup,
        'sets': sets.map((s) => s.toMap()).toList(),
        'orderIndex': orderIndex,
        'notes': notes,
        'restSeconds': restSeconds,
      };

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) => WorkoutExercise(
        id: map['id'],
        exerciseId: map['exerciseId'],
        exerciseName: map['exerciseName'],
        muscleGroup: map['muscleGroup'] ?? '',
        sets: (map['sets'] as List<dynamic>? ?? [])
            .map((s) => WorkoutSet.fromMap(s as Map<String, dynamic>))
            .toList(),
        orderIndex: map['orderIndex'] ?? 0,
        notes: map['notes'],
        restSeconds: map['restSeconds'],
      );
}

import 'package:hive/hive.dart';
import 'workout_exercise.dart';

part 'workout.g.dart';

enum WorkoutStatus { inProgress, completed, cancelled }

@HiveType(typeId: 3)
class Workout extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime startTime;

  @HiveField(3)
  DateTime? endTime;

  @HiveField(4)
  List<WorkoutExercise> exercises;

  @HiveField(5)
  String status; // 'inProgress' | 'completed' | 'cancelled'

  @HiveField(6)
  String? routineId; // if started from a routine

  @HiveField(7)
  String? notes;

  @HiveField(8)
  bool isSynced; // has this been pushed to Firebase?

  Workout({
    required this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    this.exercises = const [],
    this.status = 'inProgress',
    this.routineId,
    this.notes,
    this.isSynced = false,
  });

  // Computed helpers
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  String get durationFormatted {
    final d = duration;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  double get totalVolume =>
      exercises.fold(0, (sum, e) => sum + e.totalVolume);

  int get totalSets =>
      exercises.fold(0, (sum, e) => sum + e.sets.length);

  int get totalCompletedSets =>
      exercises.fold(0, (sum, e) => sum + e.completedSets);

  List<String> get muscleGroupsWorked =>
      exercises.map((e) => e.muscleGroup).toSet().toList();

  bool get isCompleted => status == 'completed';

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'exercises': exercises.map((e) => e.toMap()).toList(),
        'status': status,
        'routineId': routineId,
        'notes': notes,
        'isSynced': isSynced,
      };

  factory Workout.fromMap(Map<String, dynamic> map) => Workout(
        id: map['id'],
        title: map['title'],
        startTime: DateTime.parse(map['startTime']),
        endTime:
            map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
        exercises: (map['exercises'] as List<dynamic>? ?? [])
            .map((e) => WorkoutExercise.fromMap(
  Map<String, dynamic>.from(
    e as Map<Object?, Object?>,
  ),
))
            .toList(),
        status: map['status'] ?? 'completed',
        routineId: map['routineId'],
        notes: map['notes'],
        isSynced: map['isSynced'] ?? false,
      );

  Workout copyWith({
    String? title,
    DateTime? endTime,
    List<WorkoutExercise>? exercises,
    String? status,
    String? notes,
    bool? isSynced,
  }) =>
      Workout(
        id: id,
        title: title ?? this.title,
        startTime: startTime,
        endTime: endTime ?? this.endTime,
        exercises: exercises ?? this.exercises,
        status: status ?? this.status,
        routineId: routineId,
        notes: notes ?? this.notes,
        isSynced: isSynced ?? this.isSynced,
      );
}

import 'package:hive/hive.dart';

part 'workout_set.g.dart';

@HiveType(typeId: 1)
class WorkoutSet extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int setNumber;

  @HiveField(2)
  double? weight; // kg

  @HiveField(3)
  int? reps;

  @HiveField(4)
  double? duration; // seconds (for time-based exercises)

  @HiveField(5)
  double? distance; // km (for cardio)

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  bool isWarmup;

  @HiveField(8)
  bool isPR; // personal record flag

  @HiveField(9)
  String? notes;

  WorkoutSet({
    required this.id,
    required this.setNumber,
    this.weight,
    this.reps,
    this.duration,
    this.distance,
    this.isCompleted = false,
    this.isWarmup = false,
    this.isPR = false,
    this.notes,
  });

  // Computed: one rep max estimate (Epley formula)
  double? get estimatedOneRepMax {
    if (weight == null || reps == null || reps == 0) return null;
    if (reps == 1) return weight;
    return weight! * (1 + reps! / 30);
  }

  // Volume = weight x reps
  double get volume {
    if (weight == null || reps == null) return 0;
    return weight! * reps!;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'setNumber': setNumber,
        'weight': weight,
        'reps': reps,
        'duration': duration,
        'distance': distance,
        'isCompleted': isCompleted,
        'isWarmup': isWarmup,
        'isPR': isPR,
        'notes': notes,
      };

  factory WorkoutSet.fromMap(Map<String, dynamic> map) => WorkoutSet(
        id: map['id'],
        setNumber: map['setNumber'],
        weight: map['weight']?.toDouble(),
        reps: map['reps'],
        duration: map['duration']?.toDouble(),
        distance: map['distance']?.toDouble(),
        isCompleted: map['isCompleted'] ?? false,
        isWarmup: map['isWarmup'] ?? false,
        isPR: map['isPR'] ?? false,
        notes: map['notes'],
      );

  WorkoutSet copyWith({
    int? setNumber,
    double? weight,
    int? reps,
    double? duration,
    double? distance,
    bool? isCompleted,
    bool? isWarmup,
    bool? isPR,
    String? notes,
  }) =>
      WorkoutSet(
        id: id,
        setNumber: setNumber ?? this.setNumber,
        weight: weight ?? this.weight,
        reps: reps ?? this.reps,
        duration: duration ?? this.duration,
        distance: distance ?? this.distance,
        isCompleted: isCompleted ?? this.isCompleted,
        isWarmup: isWarmup ?? this.isWarmup,
        isPR: isPR ?? this.isPR,
        notes: notes ?? this.notes,
      );
}

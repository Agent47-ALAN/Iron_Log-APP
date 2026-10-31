import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/routine.dart';
import '../models/workout_exercise.dart';
import '../models/workout_set.dart';
import '../services/hive_service.dart';
import '../services/firebase_sync_service.dart';

class RoutineProvider extends ChangeNotifier {
  final HiveService _hive;
  final FirebaseSyncService _sync;
  final _uuid = const Uuid();

  RoutineProvider(this._hive, this._sync);

  List<Routine> _routines = [];
  List<Routine> get routines => _routines;

  void loadData() {
    _routines = _hive.getAllRoutines();
    notifyListeners();
  }

  Future<void> createRoutine(String title, String? description) async {
    final routine = Routine(
      id: _uuid.v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
    await _hive.saveRoutine(routine);
    _routines.insert(0, routine);
    _sync.syncRoutine(routine);
    notifyListeners();
  }

  Future<void> updateRoutine(Routine routine) async {
    await _hive.saveRoutine(routine);
    final idx = _routines.indexWhere((r) => r.id == routine.id);
    if (idx != -1) _routines[idx] = routine;
    _sync.syncRoutine(routine);
    notifyListeners();
  }

  Future<void> deleteRoutine(String id) async {
    await _hive.deleteRoutine(id);
    _routines.removeWhere((r) => r.id == id);
    _sync.deleteRoutine(id);
    notifyListeners();
  }

  Future<void> markRoutineUsed(String id) async {
    final routine = _hive.getRoutine(id);
    if (routine == null) return;
    final updated = routine.copyWith(
      lastUsedAt: DateTime.now(),
      useCount: routine.useCount + 1,
    );
    await updateRoutine(updated);
  }

  // Converts a Routine into WorkoutExercise list (for starting a workout)
  List<WorkoutExercise> buildWorkoutExercises(Routine routine) {
    return routine.exercises.map((re) {
      final sets = List.generate(
        re.targetSets,
        (i) => WorkoutSet(
          id: _uuid.v4(),
          setNumber: i + 1,
          weight: re.targetWeight,
          reps: re.targetReps,
        ),
      );
      return WorkoutExercise(
        id: _uuid.v4(),
        exerciseId: re.exerciseId,
        exerciseName: re.exerciseName,
        muscleGroup: re.muscleGroup,
        sets: sets,
        orderIndex: re.orderIndex,
        restSeconds: re.restSeconds,
      );
    }).toList();
  }
}

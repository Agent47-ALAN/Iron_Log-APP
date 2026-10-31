import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/workout.dart';
import '../models/workout_exercise.dart';
import '../models/workout_set.dart';
import '../services/hive_service.dart';
import '../services/firebase_sync_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final HiveService _hive;
  final FirebaseSyncService _sync;
  final _uuid = const Uuid();

  WorkoutProvider(this._hive, this._sync);

  // ─── State ────────────────────────────────────────────────
  Workout? _activeWorkout;
  List<Workout> _history = [];
  final bool _isLoading = false;

  Workout? get activeWorkout => _activeWorkout;
  List<Workout> get history => _history;
  bool get isLoading => _isLoading;
  bool get hasActiveWorkout => _activeWorkout != null;

  // ─── Init ─────────────────────────────────────────────────
  void loadData() {
    _history = _hive.getCompletedWorkouts();

    // Restore in-progress workout if app was killed mid-session
    final saved = _hive.getActiveWorkout();
    if (saved != null) {
      _activeWorkout = Workout.fromMap(saved);
    }

    notifyListeners();
  }

  // ─── Start workout ────────────────────────────────────────
  Future<void> startEmptyWorkout() async {
    _activeWorkout = Workout(
      id: _uuid.v4(),
      title: _defaultTitle(),
      startTime: DateTime.now(),
    );
    await _persistActive();
    notifyListeners();
  }

  Future<void> startFromRoutine(
    String routineId,
    String routineTitle,
    List<WorkoutExercise> exercises,
  ) async {
    _activeWorkout = Workout(
      id: _uuid.v4(),
      title: routineTitle,
      startTime: DateTime.now(),
      exercises: exercises,
      routineId: routineId,
    );
    await _persistActive();
    notifyListeners();
  }

  String _defaultTitle() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning Workout';
    if (hour < 17) return 'Afternoon Workout';
    return 'Evening Workout';
  }

  // ─── Exercise management ──────────────────────────────────
  void addExerciseToActive(WorkoutExercise exercise) {
    if (_activeWorkout == null) return;
    final updated = List<WorkoutExercise>.from(_activeWorkout!.exercises)
      ..add(exercise);
    _activeWorkout = _activeWorkout!.copyWith(exercises: updated);
    _persistActive();
    notifyListeners();
  }

  void removeExerciseFromActive(String exerciseId) {
    if (_activeWorkout == null) return;
    final updated = _activeWorkout!.exercises
        .where((e) => e.id != exerciseId)
        .toList();
    _activeWorkout = _activeWorkout!.copyWith(exercises: updated);
    _persistActive();
    notifyListeners();
  }

  void reorderExercises(int oldIndex, int newIndex) {
    if (_activeWorkout == null) return;
    final list = List<WorkoutExercise>.from(_activeWorkout!.exercises);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    _activeWorkout = _activeWorkout!.copyWith(exercises: list);
    _persistActive();
    notifyListeners();
  }

  // ─── Set management ───────────────────────────────────────
  void addSet(String exerciseId) {
    if (_activeWorkout == null) return;
    _mutateExercise(exerciseId, (ex) {
      final prevSet = ex.sets.isNotEmpty ? ex.sets.last : null;
      final newSet = WorkoutSet(
        id: _uuid.v4(),
        setNumber: ex.sets.length + 1,
        weight: prevSet?.weight,
        reps: prevSet?.reps,
      );
      return WorkoutExercise(
        id: ex.id,
        exerciseId: ex.exerciseId,
        exerciseName: ex.exerciseName,
        muscleGroup: ex.muscleGroup,
        sets: [...ex.sets, newSet],
        orderIndex: ex.orderIndex,
        notes: ex.notes,
        restSeconds: ex.restSeconds,
      );
    });
  }

  void removeSet(String exerciseId, String setId) {
    if (_activeWorkout == null) return;
    _mutateExercise(exerciseId, (ex) {
      final sets = ex.sets.where((s) => s.id != setId).toList();
      return WorkoutExercise(
        id: ex.id,
        exerciseId: ex.exerciseId,
        exerciseName: ex.exerciseName,
        muscleGroup: ex.muscleGroup,
        sets: sets,
        orderIndex: ex.orderIndex,
        notes: ex.notes,
        restSeconds: ex.restSeconds,
      );
    });
  }

  void updateSet(String exerciseId, WorkoutSet updatedSet) {
    if (_activeWorkout == null) return;
    _mutateExercise(exerciseId, (ex) {
      final sets = ex.sets.map((s) {
        return s.id == updatedSet.id ? updatedSet : s;
      }).toList();
      return WorkoutExercise(
        id: ex.id,
        exerciseId: ex.exerciseId,
        exerciseName: ex.exerciseName,
        muscleGroup: ex.muscleGroup,
        sets: sets,
        orderIndex: ex.orderIndex,
        notes: ex.notes,
        restSeconds: ex.restSeconds,
      );
    });
  }

  void toggleSetComplete(String exerciseId, String setId) {
    if (_activeWorkout == null) return;
    _mutateExercise(exerciseId, (ex) {
      final sets = ex.sets.map((s) {
        if (s.id != setId) return s;
        return s.copyWith(isCompleted: !s.isCompleted);
      }).toList();
      return WorkoutExercise(
        id: ex.id,
        exerciseId: ex.exerciseId,
        exerciseName: ex.exerciseName,
        muscleGroup: ex.muscleGroup,
        sets: sets,
        orderIndex: ex.orderIndex,
        notes: ex.notes,
        restSeconds: ex.restSeconds,
      );
    });
  }

  // ─── Finish / cancel ──────────────────────────────────────
  Future<void> finishWorkout() async {
    if (_activeWorkout == null) return;

    // Check PRs before saving
    _activeWorkout = _checkAndMarkPRs(_activeWorkout!);

    final completed = _activeWorkout!.copyWith(
      status: 'completed',
      endTime: DateTime.now(),
    );

    await _hive.saveWorkout(completed);
    await _hive.clearActiveWorkout();
    _history.insert(0, completed);
    _activeWorkout = null;

    // Background sync
    _sync.syncWorkout(completed);

    notifyListeners();
  }

  Future<void> cancelWorkout() async {
    await _hive.clearActiveWorkout();
    _activeWorkout = null;
    notifyListeners();
  }

  // ─── History ──────────────────────────────────────────────
  Future<void> deleteWorkout(String id) async {
    await _hive.deleteWorkout(id);
    _history.removeWhere((w) => w.id == id);
    _sync.deleteWorkout(id);
    notifyListeners();
  }

  // ─── Private helpers ──────────────────────────────────────
  void _mutateExercise(
      String exerciseId, WorkoutExercise Function(WorkoutExercise) fn) {
    final exercises = _activeWorkout!.exercises.map((ex) {
      return ex.id == exerciseId ? fn(ex) : ex;
    }).toList();
    _activeWorkout = _activeWorkout!.copyWith(exercises: exercises);
    _persistActive();
    notifyListeners();
  }

  Future<void> _persistActive() async {
    if (_activeWorkout != null) {
      await _hive.saveActiveWorkout(_activeWorkout!.toMap());
    }
  }

  Workout _checkAndMarkPRs(Workout workout) {
    final allPRs = _hive.getPersonalRecords();
    final updatedExercises = workout.exercises.map((ex) {
      final currentPR = allPRs[ex.exerciseId] ?? 0;
      final updatedSets = ex.sets.map((set) {
        final oneRM = set.estimatedOneRepMax;
        if (oneRM != null && oneRM > currentPR) {
          return set.copyWith(isPR: true);
        }
        return set;
      }).toList();
      return WorkoutExercise(
        id: ex.id,
        exerciseId: ex.exerciseId,
        exerciseName: ex.exerciseName,
        muscleGroup: ex.muscleGroup,
        sets: updatedSets,
        orderIndex: ex.orderIndex,
        notes: ex.notes,
        restSeconds: ex.restSeconds,
      );
    }).toList();
    return workout.copyWith(exercises: updatedExercises);
  }
}

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/workout.dart';
import '../models/routine.dart';
import '../models/exercise.dart';
import 'hive_service.dart';

/// Syncs local Hive data to Firebase Realtime Database in the background.
/// Hive is ALWAYS the source of truth — Firebase is for backup/multi-device sync.
class FirebaseSyncService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final HiveService _hive;

  FirebaseSyncService(this._hive);

  // ─── Auth helpers ─────────────────────────────────────────
  String? get _uid => _auth.currentUser?.uid;
  bool get isAuthenticated => _uid != null;

  // ─── Database refs ────────────────────────────────────────
  DatabaseReference get _userRef => _db.ref('users/$_uid');
  DatabaseReference get _workoutsRef => _db.ref('users/$_uid/workouts');
  DatabaseReference get _routinesRef => _db.ref('users/$_uid/routines');
  DatabaseReference get _exercisesRef => _db.ref('users/$_uid/exercises');

  // ─── Workout sync ─────────────────────────────────────────
  Future<void> syncWorkout(Workout workout) async {
    if (!isAuthenticated) return;
    try {
      await _workoutsRef.child(workout.id).set(workout.toMap());
      workout.isSynced = true;
      await _hive.saveWorkout(workout);
    } catch (e) {
      // Silently fail — will retry on next sync
    }
  }

  Future<void> deleteWorkout(String id) async {
    if (!isAuthenticated) return;
    try {
      await _workoutsRef.child(id).remove();
    } catch (e) {}
  }

  // ─── Routine sync ─────────────────────────────────────────
  Future<void> syncRoutine(Routine routine) async {
    if (!isAuthenticated) return;
    try {
      await _routinesRef.child(routine.id).set(routine.toMap());
      routine.isSynced = true;
      await _hive.saveRoutine(routine);
    } catch (e) {}
  }

  Future<void> deleteRoutine(String id) async {
    if (!isAuthenticated) return;
    try {
      await _routinesRef.child(id).remove();
    } catch (e) {}
  }

  // ─── Custom exercise sync ─────────────────────────────────
  Future<void> syncCustomExercise(Exercise exercise) async {
    if (!isAuthenticated || !exercise.isCustom) return;
    try {
      await _exercisesRef.child(exercise.id).set(exercise.toMap());
    } catch (e) {}
  }

  Future<void> deleteCustomExercise(String id) async {
    if (!isAuthenticated) return;
    try {
      await _exercisesRef.child(id).remove();
    } catch (e) {}
  }

  // ─── Full sync — push all unsynced local items ────────────
  Future<void> syncAll() async {
    if (!isAuthenticated) return;

    try {
      // Sync unsynced workouts
      final unsyncedWorkouts = _hive.getUnsyncedWorkouts();
      for (final workout in unsyncedWorkouts) {
        await syncWorkout(workout);
      }

      // Sync unsynced routines
      final unsyncedRoutines =
          _hive.getAllRoutines().where((r) => !r.isSynced).toList();
      for (final routine in unsyncedRoutines) {
        await syncRoutine(routine);
      }
    } catch (e) {}
  }

  // ─── Pull from Firebase (new device / restore) ────────────
  Future<void> pullFromFirebase() async {
    if (!isAuthenticated) return;

    try {
      // Pull workouts
      final workoutSnap = await _workoutsRef.get();
      if (workoutSnap.exists && workoutSnap.value != null) {
        final data = Map<String, dynamic>.from(workoutSnap.value as Map);
        for (final entry in data.entries) {
          final map = Map<String, dynamic>.from(entry.value as Map);
          final workout = Workout.fromMap(map)..isSynced = true;
          if (_hive.getWorkout(workout.id) == null) {
            await _hive.saveWorkout(workout);
          }
        }
      }

      // Pull routines
      final routineSnap = await _routinesRef.get();
      if (routineSnap.exists && routineSnap.value != null) {
        final data = Map<String, dynamic>.from(routineSnap.value as Map);
        for (final entry in data.entries) {
          final map = Map<String, dynamic>.from(entry.value as Map);
          final routine = Routine.fromMap(map)..isSynced = true;
          if (_hive.getRoutine(routine.id) == null) {
            await _hive.saveRoutine(routine);
          }
        }
      }

      // Pull custom exercises
      final exerciseSnap = await _exercisesRef.get();
      if (exerciseSnap.exists && exerciseSnap.value != null) {
        final data = Map<String, dynamic>.from(exerciseSnap.value as Map);
        for (final entry in data.entries) {
          final map = Map<String, dynamic>.from(entry.value as Map);
          final exercise = Exercise.fromMap(map);
          if (_hive.getExercise(exercise.id) == null) {
            await _hive.saveExercise(exercise);
          }
        }
      }
    } catch (e) {}
  }

  // ─── Real-time listener — sync changes instantly ──────────
  StreamSubscription? _workoutListener;

  void startListening() {
    if (!isAuthenticated) return;

    _workoutListener = _workoutsRef.onChildChanged.listen((event) async {
      try {
        if (event.snapshot.value == null) return;
        final map = Map<String, dynamic>.from(event.snapshot.value as Map);
        final workout = Workout.fromMap(map)..isSynced = true;
        await _hive.saveWorkout(workout);
      } catch (e) {}
    });
  }

  void stopListening() {
    _workoutListener?.cancel();
    _workoutListener = null;
  }

  // ─── Sync status stream ───────────────────────────────────
  Stream<bool> get connectivityStream {
    final connectedRef = _db.ref('.info/connected');
    return connectedRef.onValue.map((event) {
      return event.snapshot.value as bool? ?? false;
    });
  }

  // ─── Auth methods ─────────────────────────────────────────
  Future<UserCredential?> signInAnonymously() async {
    try {
      final cred = await _auth.signInAnonymously();
      // After sign in, pull any existing data from Firebase
      await pullFromFirebase();
      return cred;
    } catch (e) {
      return null;
    }
  }

  Future<UserCredential?> signInWithEmail(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      await pullFromFirebase();
      return cred;
    } catch (e) {
      return null;
    }
  }

  Future<UserCredential?> registerWithEmail(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // New account — push all local data up
      await syncAll();
      return cred;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    stopListening();
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? false;
}

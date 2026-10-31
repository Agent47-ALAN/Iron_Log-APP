import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/exercise.dart';
import '../services/hive_service.dart';
import '../services/firebase_sync_service.dart';
import '../utils/exercise_seed_data.dart';

class ExerciseProvider extends ChangeNotifier {
  final HiveService _hive;
  final FirebaseSyncService _sync;
  final _uuid = const Uuid();

  ExerciseProvider(this._hive, this._sync);

  List<Exercise> _all = [];
  String _searchQuery = '';
  String _filterMuscle = 'All';
  String _filterEquipment = 'All';

  // ─── Getters ──────────────────────────────────────────────
  List<Exercise> get filtered {
    return _all.where((e) {
      final matchSearch = _searchQuery.isEmpty ||
          e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.muscleGroup.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchMuscle =
          _filterMuscle == 'All' || e.muscleGroup == _filterMuscle;
      final matchEquip =
          _filterEquipment == 'All' || e.equipment == _filterEquipment;
      return matchSearch && matchMuscle && matchEquip;
    }).toList();
  }

  List<String> get muscleGroups {
    final groups = _all.map((e) => e.muscleGroup).toSet().toList()..sort();
    return ['All', ...groups];
  }

  List<String> get equipmentTypes {
    final types = _all.map((e) => e.equipment).toSet().toList()..sort();
    return ['All', ...types];
  }

  String get searchQuery => _searchQuery;
  String get filterMuscle => _filterMuscle;
  String get filterEquipment => _filterEquipment;

  // ─── Init ─────────────────────────────────────────────────
  Future<void> loadData() async {
    if (!_hive.hasExercises) {
      // Seed built-in exercises on first run
      await _hive.saveAllExercises(ExerciseSeedData.builtIn);
    }
    _all = _hive.getAllExercises();
    notifyListeners();
  }

  // ─── Filtering ────────────────────────────────────────────
  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setMuscleFilter(String muscle) {
    _filterMuscle = muscle;
    notifyListeners();
  }

  void setEquipmentFilter(String equipment) {
    _filterEquipment = equipment;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterMuscle = 'All';
    _filterEquipment = 'All';
    notifyListeners();
  }

  // ─── Custom exercises ─────────────────────────────────────
  Future<Exercise> createCustomExercise({
    required String name,
    required String muscleGroup,
    required String equipment,
    List<String> secondaryMuscles = const [],
    String? notes,
  }) async {
    final exercise = Exercise(
      id: _uuid.v4(),
      name: name,
      muscleGroup: muscleGroup,
      secondaryMuscles: secondaryMuscles,
      equipment: equipment,
      isCustom: true,
      notes: notes,
    );
    await _hive.saveExercise(exercise);
    _all = _hive.getAllExercises();
    _sync.syncCustomExercise(exercise);
    notifyListeners();
    return exercise;
  }

  Future<void> deleteCustomExercise(String id) async {
    await _hive.deleteExercise(id);
    _all = _hive.getAllExercises();
    notifyListeners();
  }

  Exercise? getById(String id) => _hive.getExercise(id);
}

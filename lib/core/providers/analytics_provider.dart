import 'package:flutter/foundation.dart';
import '../services/hive_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final HiveService _hive;

  AnalyticsProvider(this._hive);

  // ─── Cached computed values ───────────────────────────────
  Map<DateTime, double> _weeklyVolume = {};
  Map<String, double> _personalRecords = {};
  Map<String, int> _monthlyCount = {};
  bool _isLoaded = false;

  Map<DateTime, double> get weeklyVolume => _weeklyVolume;
  Map<String, double> get personalRecords => _personalRecords;
  Map<String, int> get monthlyCount => _monthlyCount;
  bool get isLoaded => _isLoaded;

  // ─── Summary stats ────────────────────────────────────────
  int get totalWorkouts => _hive.getCompletedWorkouts().length;

  Duration get totalTime {
    final workouts = _hive.getCompletedWorkouts();
    final seconds = workouts.fold<int>(
      0,
      (sum, w) => sum + w.duration.inSeconds,
    );
    return Duration(seconds: seconds);
  }

  double get totalVolumeLifted {
    return _hive
        .getCompletedWorkouts()
        .fold(0, (sum, w) => sum + w.totalVolume);
  }

  int get currentStreak {
    final workouts = _hive.getCompletedWorkouts();
    if (workouts.isEmpty) return 0;

    int streak = 0;
    DateTime check = DateTime.now();
    final days = workouts.map((w) {
      final d = w.startTime;
      return DateTime(d.year, d.month, d.day);
    }).toSet();

    for (int i = 0; i < 365; i++) {
      final day = DateTime(check.year, check.month, check.day)
          .subtract(Duration(days: i));
      if (days.contains(day)) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  // ─── Load / refresh ───────────────────────────────────────
  void loadData() {
    _weeklyVolume = _hive.getWeeklyVolume(weeks: 8);
    _personalRecords = _hive.getPersonalRecords();
    _monthlyCount = _hive.getMonthlyWorkoutCount(months: 6);
    _isLoaded = true;
    notifyListeners();
  }

  void refresh() => loadData();

  // ─── Per-exercise analytics ───────────────────────────────
  List<MapEntry<DateTime, double>> getExercisePRHistory(String exerciseId) {
    return _hive.getExercisePRHistory(exerciseId);
  }

  double? getExercisePR(String exerciseId) {
    return _personalRecords[exerciseId];
  }
}

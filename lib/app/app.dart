import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../core/utils/theme.dart';
import '../core/providers/workout_provider.dart';
import '../core/providers/auth_provider.dart';
import '../features/auth/auth_screen.dart';
import '../features/workout_logger/workout_logger_screen.dart';
import '../features/routines/routines_screen.dart';
import '../features/history/history_screen.dart';
import '../features/exercise_library/exercise_library_screen.dart';
import '../features/analytics/analytics_screen.dart';

class HevyApp extends StatelessWidget {
  const HevyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IronLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    WorkoutLoggerScreen(),
    RoutinesScreen(),
    HistoryScreen(),
    ExerciseLibraryScreen(),
    AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final hasActive = context.watch<WorkoutProvider>().hasActiveWorkout;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasActive)
            _ActiveWorkoutBanner(
              onTap: () => setState(() => _currentIndex = 0),
            ),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Iconsax.activity),
                activeIcon: Icon(Iconsax.activity5),
                label: 'Workout',
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.task_square),
                activeIcon: Icon(Iconsax.task_square5),
                label: 'Routines',
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.calendar),
                activeIcon: Icon(Iconsax.calendar5),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.search_normal),
                activeIcon: Icon(Iconsax.search_normal5),
                label: 'Exercises',
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.chart_2),
                activeIcon: Icon(Iconsax.chart_25),
                label: 'Analytics',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveWorkoutBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _ActiveWorkoutBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>().activeWorkout!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppTheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(workout.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ),
          Text(workout.durationFormatted,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(width: 8),
          const Icon(Iconsax.arrow_up_2, color: Colors.white70, size: 16),
        ]),
      ),
    );
  }
}

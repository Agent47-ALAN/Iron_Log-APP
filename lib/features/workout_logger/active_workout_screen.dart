import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/workout.dart';
import '../../core/models/workout_exercise.dart';
import '../../core/models/workout_set.dart';
import '../../core/providers/workout_provider.dart';
import '../../core/utils/theme.dart';
import '../exercise_library/exercise_library_screen.dart';
import 'widgets/set_row.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});
  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late Timer _timer;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final workout = provider.activeWorkout;
    if (workout == null) return const SizedBox.shrink();

    return Column(
      children: [
        _WorkoutHeader(workout: workout),
        Expanded(
          child: workout.exercises.isEmpty
              ? _EmptyState(onAdd: () => _pickExercise(context))
              : ReorderableListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: workout.exercises.length,
                  onReorder: context.read<WorkoutProvider>().reorderExercises,
                  itemBuilder: (_, i) {
                    final ex = workout.exercises[i];
                    return _ExerciseCard(key: ValueKey(ex.id), exercise: ex);
                  },
                ),
        ),
        _BottomBar(onAddExercise: () => _pickExercise(context)),
      ],
    );
  }

  Future<void> _pickExercise(BuildContext context) async {
    final exercise = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ExerciseLibraryScreen(selectionMode: true),
      ),
    );
    if (exercise == null || !mounted) return;

    final provider = context.read<WorkoutProvider>();
    final ex = WorkoutExercise(
      id: _uuid.v4(),
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      muscleGroup: exercise.muscleGroup,
      sets: [WorkoutSet(id: _uuid.v4(), setNumber: 1)],
      orderIndex: provider.activeWorkout?.exercises.length ?? 0,
    );
    provider.addExerciseToActive(ex);
  }
}

class _WorkoutHeader extends StatelessWidget {
  final Workout workout;
  const _WorkoutHeader({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(workout.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Row(children: [
                const Icon(Iconsax.timer_1, size: 14, color: AppTheme.primary),
                const SizedBox(width: 4),
                Text(workout.durationFormatted,
                    style: const TextStyle(fontSize: 13, color: AppTheme.primary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                const Icon(Iconsax.weight, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text('${workout.totalVolume.toStringAsFixed(0)} kg',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              ]),
            ],
          ),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.danger,
            side: const BorderSide(color: AppTheme.danger),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
          ),
          onPressed: () => _confirmCancel(context),
          child: const Text('Cancel', style: TextStyle(fontSize: 13)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accent,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
          ),
          onPressed: () => _confirmFinish(context),
          child: const Text('Finish',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  void _confirmFinish(BuildContext context) {
    final completedSets =
        context.read<WorkoutProvider>().activeWorkout?.totalCompletedSets ?? 0;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Finish Workout?'),
        content: Text('You\'ve completed $completedSets sets. Save this workout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Going')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            onPressed: () {
              Navigator.pop(context);
              context.read<WorkoutProvider>().finishWorkout();
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Cancel Workout?'),
        content: const Text('All progress will be lost.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Going')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<WorkoutProvider>().cancelWorkout();
            },
            child: const Text('Cancel Workout',
                style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final WorkoutExercise exercise;
  const _ExerciseCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkoutProvider>();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.exerciseName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                            color: AppTheme.primary)),
                    Text(exercise.muscleGroup,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.trash, size: 18, color: AppTheme.textMuted),
                onPressed: () => provider.removeExerciseFromActive(exercise.id),
              ),
              const Icon(Icons.drag_handle, color: AppTheme.textMuted, size: 20),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Row(children: [
              SizedBox(width: 30, child: Text('SET', style: TextStyle(fontSize: 11,
                  color: AppTheme.textMuted, fontWeight: FontWeight.w600))),
              SizedBox(width: 12),
              Expanded(child: Center(child: Text('KG', style: TextStyle(fontSize: 11,
                  color: AppTheme.textMuted, fontWeight: FontWeight.w600)))),
              SizedBox(width: 12),
              Expanded(child: Center(child: Text('REPS', style: TextStyle(fontSize: 11,
                  color: AppTheme.textMuted, fontWeight: FontWeight.w600)))),
              SizedBox(width: 12),
              SizedBox(width: 36),
            ]),
          ),
          const SizedBox(height: 6),
          ...exercise.sets.map((set) => SetRow(
                set: set,
                exerciseId: exercise.id,
                onUpdate: (updated) => provider.updateSet(exercise.id, updated),
                onToggle: () => provider.toggleSetComplete(exercise.id, set.id),
                onDelete: () => provider.removeSet(exercise.id, set.id),
              )),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
            child: TextButton.icon(
              onPressed: () => provider.addSet(exercise.id),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Set', style: TextStyle(fontSize: 13)),
              style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.weight, size: 52, color: AppTheme.textMuted),
            const SizedBox(height: 14),
            Text('No exercises added yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            const Text('Tap below to add your first exercise',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Iconsax.add_circle),
              label: const Text('Add Exercise'),
              onPressed: onAdd,
            ),
          ],
        ),
      );
}

class _BottomBar extends StatelessWidget {
  final VoidCallback onAddExercise;
  const _BottomBar({required this.onAddExercise});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Iconsax.add_circle),
            label: const Text('Add Exercise'),
            onPressed: onAddExercise,
          ),
        ),
      );
}

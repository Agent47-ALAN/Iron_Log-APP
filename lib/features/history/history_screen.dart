import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/models/workout.dart';
import '../../core/providers/workout_provider.dart';
import '../../core/utils/theme.dart';
import 'workout_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('History')),
      body: _HistoryList(),
    );
  }
}

class _HistoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workouts = context.watch<WorkoutProvider>().history;

    if (workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.calendar, size: 56, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text('No workouts yet',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Complete your first workout to see it here',
                style: TextStyle(color: AppTheme.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    // Group by month
    final grouped = <String, List<Workout>>{};
    for (final w in workouts) {
      final key = _monthKey(w.startTime);
      grouped.putIfAbsent(key, () => []).add(w);
    }
    final months = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: months.length,
      itemBuilder: (_, i) {
        final month = months[i];
        final items = grouped[month]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 4),
              child: Text(month,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                      letterSpacing: 0.5)),
            ),
            ...items.map((w) => _WorkoutCard(workout: w)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  String _monthKey(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

class _WorkoutCard extends StatelessWidget {
  final Workout workout;
  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(workout.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.danger,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Iconsax.trash, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) =>
          context.read<WorkoutProvider>().deleteWorkout(workout.id),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => WorkoutDetailScreen(workout: workout)),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(workout.title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
                Text(_formatDate(workout.startTime),
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                _StatBadge(icon: Iconsax.timer_1,
                    label: workout.durationFormatted),
                const SizedBox(width: 14),
                _StatBadge(icon: Iconsax.weight,
                    label: '${workout.totalVolume.toStringAsFixed(0)} kg'),
                const SizedBox(width: 14),
                _StatBadge(icon: Iconsax.repeat,
                    label: '${workout.totalCompletedSets} sets'),
              ]),
              const SizedBox(height: 10),
              // Exercise names
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: workout.exercises
                    .take(4)
                    .map((e) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(e.exerciseName,
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.textSecondary)),
                        ))
                    .toList()
                  ..addAll(workout.exercises.length > 4
                      ? [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                                '+${workout.exercises.length - 4} more',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMuted)),
                          )
                        ]
                      : []),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.surface,
            title: const Text('Delete Workout'),
            content: const Text('This workout will be permanently deleted.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete',
                    style: TextStyle(color: AppTheme.danger)),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 13, color: AppTheme.textMuted),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
        ],
      );
}

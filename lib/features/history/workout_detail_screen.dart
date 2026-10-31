import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/models/workout.dart';
import '../../core/utils/theme.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: Text(workout.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatFullDate(workout.startTime),
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _SummaryTile(label: 'Duration',
                      value: workout.durationFormatted, icon: Iconsax.timer_1)),
                  Expanded(child: _SummaryTile(label: 'Volume',
                      value: '${workout.totalVolume.toStringAsFixed(0)} kg', icon: Iconsax.weight)),
                  Expanded(child: _SummaryTile(label: 'Sets',
                      value: '${workout.totalCompletedSets}', icon: Iconsax.repeat)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Exercises', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...workout.exercises.map((ex) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                      child: Row(children: [
                        Expanded(
                          child: Text(ex.exerciseName,
                              style: const TextStyle(fontSize: 14,
                                  fontWeight: FontWeight.w600, color: AppTheme.primary)),
                        ),
                        Text('${ex.totalVolume.toStringAsFixed(0)} kg vol',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ]),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Row(children: [
                        SizedBox(width: 28, child: Text('SET', style: TextStyle(fontSize: 10,
                            color: AppTheme.textMuted, fontWeight: FontWeight.w600))),
                        SizedBox(width: 10),
                        Expanded(child: Text('WEIGHT', style: TextStyle(fontSize: 10,
                            color: AppTheme.textMuted, fontWeight: FontWeight.w600))),
                        Expanded(child: Text('REPS', style: TextStyle(fontSize: 10,
                            color: AppTheme.textMuted, fontWeight: FontWeight.w600))),
                        Expanded(child: Text('1RM EST.', style: TextStyle(fontSize: 10,
                            color: AppTheme.textMuted, fontWeight: FontWeight.w600))),
                      ]),
                    ),
                    const SizedBox(height: 6),
                    ...ex.sets.map((set) => Padding(
                          padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
                          child: Row(children: [
                            SizedBox(
                              width: 28,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: set.isCompleted
                                      ? AppTheme.accent.withValues(alpha: 0.15)
                                      : AppTheme.surfaceElevated,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(
                                    set.isWarmup ? 'W' : '${set.setNumber}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: set.isWarmup
                                          ? AppTheme.warning
                                          : set.isCompleted
                                              ? AppTheme.accent
                                              : AppTheme.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Row(children: [
                                Text(
                                  set.weight != null
                                      ? '${set.weight!.toStringAsFixed(1)} kg'
                                      : '—',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                                if (set.isPR) ...[
                                  const SizedBox(width: 4),
                                  const Text('🏆', style: TextStyle(fontSize: 11)),
                                ],
                              ]),
                            ),
                            Expanded(
                              child: Text(set.reps != null ? '${set.reps}' : '—',
                                  style: const TextStyle(fontSize: 13)),
                            ),
                            Expanded(
                              child: Text(
                                set.estimatedOneRepMax != null
                                    ? '${set.estimatedOneRepMax!.toStringAsFixed(1)} kg'
                                    : '—',
                                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                              ),
                            ),
                          ]),
                        )),
                    const SizedBox(height: 10),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime d) {
    const months = ['January','February','March','April','May','June',
        'July','August','September','October','November','December'];
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '${months[d.month - 1]} ${d.day}, ${d.year} at $h:$m $period';
  }
}

class _SummaryTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _SummaryTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Column(children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
      ]);
}

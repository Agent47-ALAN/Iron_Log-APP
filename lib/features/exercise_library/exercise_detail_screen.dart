import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/models/exercise.dart';
import '../../core/providers/analytics_provider.dart';
import '../../core/providers/exercise_provider.dart';
import '../../core/providers/workout_provider.dart';
import '../../core/utils/theme.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;
  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();
    final pr = analytics.getExercisePR(exercise.id);
    final history = analytics.getExercisePRHistory(exercise.id);
    final workouts = context.watch<WorkoutProvider>().history
        .where((w) => w.exercises.any((e) => e.exerciseId == exercise.id))
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(exercise.name),
        actions: [
          if (exercise.isCustom)
            IconButton(
              icon: const Icon(Iconsax.trash, color: AppTheme.danger),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
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
              children: [
                _InfoRow(label: 'Primary Muscle', value: exercise.muscleGroup),
                if (exercise.secondaryMuscles.isNotEmpty) ...[
                  const Divider(height: 20),
                  _InfoRow(label: 'Secondary', value: exercise.secondaryMuscles.join(', ')),
                ],
                const Divider(height: 20),
                _InfoRow(label: 'Equipment', value: exercise.equipment),
                const Divider(height: 20),
                _InfoRow(label: 'Category', value: exercise.category),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (pr != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.pr.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.pr.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                const Text('🏆', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Personal Record',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    Text('${pr.toStringAsFixed(1)} kg est. 1RM',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                            color: AppTheme.pr)),
                  ],
                ),
              ]),
            ),
            const SizedBox(height: 16),
          ],
          Row(children: [
            Expanded(child: _StatCard(label: 'Times Performed',
                value: '${workouts.length}', icon: Iconsax.repeat)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'PR Improvements',
                value: '${history.length}', icon: Iconsax.trend_up)),
          ]),
          const SizedBox(height: 20),
          if (workouts.isNotEmpty) ...[
            Text('Recent Sessions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            ...workouts.take(5).map((w) {
              final ex = w.exercises.firstWhere((e) => e.exerciseId == exercise.id);
              final best = ex.sets.where((s) => s.isCompleted && s.weight != null).toList();
              best.sort((a, b) =>
                  (b.estimatedOneRepMax ?? 0).compareTo(a.estimatedOneRepMax ?? 0));
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_formatDate(w.startTime),
                            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                        Text('${ex.completedSets} sets · ${ex.totalVolume.toStringAsFixed(0)} kg vol',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  if (best.isNotEmpty)
                    Text(
                      'Best: ${best.first.weight?.toStringAsFixed(1)}kg × ${best.first.reps}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                ]),
              );
            }),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Exercise'),
        content: Text('Delete "${exercise.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<ExerciseProvider>().deleteCustomExercise(exercise.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      );
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppTheme.primary),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      );
}

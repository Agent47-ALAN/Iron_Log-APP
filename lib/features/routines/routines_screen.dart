import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../core/models/routine.dart';
import '../../core/providers/routine_provider.dart';
import '../../core/utils/theme.dart';
import 'routine_editor_screen.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Routines'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add_circle, color: AppTheme.primary),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RoutineEditorScreen())),
          ),
        ],
      ),
      body: const _RoutineList(),
    );
  }
}

class _RoutineList extends StatelessWidget {
  const _RoutineList();

  @override
  Widget build(BuildContext context) {
    final routines = context.watch<RoutineProvider>().routines;

    if (routines.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.task_square, size: 56, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text('No routines yet', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Create a routine to save your favourite workouts',
                style: TextStyle(color: AppTheme.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Iconsax.add_circle),
              label: const Text('Create Routine'),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RoutineEditorScreen())),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: routines.length,
      itemBuilder: (_, i) => _RoutineCard(routine: routines[i]),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final Routine routine;
  const _RoutineCard({required this.routine});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(routine.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => RoutineEditorScreen(routine: routine))),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            icon: Iconsax.edit_2,
            label: 'Edit',
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
          ),
          SlidableAction(
            onPressed: (_) => _confirmDelete(context),
            backgroundColor: AppTheme.danger,
            foregroundColor: Colors.white,
            icon: Iconsax.trash,
            label: 'Delete',
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => RoutineEditorScreen(routine: routine))),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(routine.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  if (routine.useCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${routine.useCount}×',
                          style: const TextStyle(fontSize: 12, color: AppTheme.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                ]),
                if (routine.description != null && routine.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(routine.description!,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                ],
                const SizedBox(height: 10),
                Text(routine.exerciseSummary,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Row(children: [
                  _Chip(icon: Iconsax.weight, label: '${routine.exercises.length} exercises'),
                  const SizedBox(width: 8),
                  if (routine.lastUsedAt != null)
                    _Chip(icon: Iconsax.calendar, label: _formatDate(routine.lastUsedAt!)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Routine'),
        content: Text('Delete "${routine.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<RoutineProvider>().deleteRoutine(routine.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 13, color: AppTheme.textMuted),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
      ]);
}

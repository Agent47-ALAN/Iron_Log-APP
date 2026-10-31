import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/models/routine.dart';
import '../../core/providers/routine_provider.dart';
import '../../core/utils/theme.dart';
import '../exercise_library/exercise_library_screen.dart';

class RoutineEditorScreen extends StatefulWidget {
  final Routine? routine;
  const RoutineEditorScreen({super.key, this.routine});

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  List<RoutineExercise> _exercises = [];
  bool _saving = false;

  bool get isEditing => widget.routine != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleCtrl.text = widget.routine!.title;
      _descCtrl.text = widget.routine!.description ?? '';
      _exercises = List.from(widget.routine!.exercises);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Routine' : 'New Routine'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(isEditing ? 'Save' : 'Create',
                    style: const TextStyle(
                        color: AppTheme.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _titleCtrl,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    hintText: 'Routine name',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                  ),
                ),
                TextField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Description (optional)',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 8),
                if (_exercises.isEmpty)
                  const _EmptyExercises()
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _exercises.length,
                    onReorder: (oldIdx, newIdx) {
                      setState(() {
                        if (newIdx > oldIdx) newIdx--;
                        final item = _exercises.removeAt(oldIdx);
                        _exercises.insert(newIdx, item);
                      });
                    },
                    itemBuilder: (_, i) => _RoutineExerciseCard(
                      key: ValueKey(_exercises[i].exerciseId + i.toString()),
                      exercise: _exercises[i],
                      onDelete: () => setState(() => _exercises.removeAt(i)),
                      onUpdate: (updated) => setState(() => _exercises[i] = updated),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: AppTheme.border)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Iconsax.add_circle),
                label: const Text('Add Exercise'),
                onPressed: _pickExercise,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickExercise() async {
    final exercise = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const ExerciseLibraryScreen(selectionMode: true)),
    );
    if (exercise == null) return;
    setState(() {
      _exercises.add(RoutineExercise(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        muscleGroup: exercise.muscleGroup,
        orderIndex: _exercises.length,
        targetSets: 3,
        targetReps: 10,
      ));
    });
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a routine name')));
      return;
    }
    setState(() => _saving = true);
    final provider = context.read<RoutineProvider>();
    if (isEditing) {
      final updated = widget.routine!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        exercises: _exercises,
      );
      await provider.updateRoutine(updated);
    } else {
      await provider.createRoutine(
        _titleCtrl.text.trim(),
        _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      );
      if (provider.routines.isNotEmpty) {
        final newRoutine = provider.routines.first;
        final updated = newRoutine.copyWith(exercises: _exercises);
        await provider.updateRoutine(updated);
      }
    }
    if (mounted) Navigator.pop(context);
  }
}

class _EmptyExercises extends StatelessWidget {
  const _EmptyExercises();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        child: const Column(
          children: [
            Icon(Iconsax.weight, size: 40, color: AppTheme.textMuted),
            SizedBox(height: 12),
            Text('No exercises yet', style: TextStyle(color: AppTheme.textSecondary)),
            SizedBox(height: 4),
            Text('Tap "Add Exercise" below to build your routine',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                textAlign: TextAlign.center),
          ],
        ),
      );
}

class _RoutineExerciseCard extends StatelessWidget {
  final RoutineExercise exercise;
  final VoidCallback onDelete;
  final ValueChanged<RoutineExercise> onUpdate;

  const _RoutineExerciseCard({
    super.key,
    required this.exercise,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.exerciseName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                          color: AppTheme.primary)),
                  Text(exercise.muscleGroup,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Iconsax.trash, size: 17, color: AppTheme.textMuted),
              onPressed: onDelete,
            ),
            const Icon(Icons.drag_handle, color: AppTheme.textMuted),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _SetField(
              label: 'Sets',
              value: exercise.targetSets.toString(),
              onChanged: (v) {
                final n = int.tryParse(v);
                if (n != null) {
                  onUpdate(RoutineExercise(
                    exerciseId: exercise.exerciseId,
                    exerciseName: exercise.exerciseName,
                    muscleGroup: exercise.muscleGroup,
                    targetSets: n,
                    targetReps: exercise.targetReps,
                    targetWeight: exercise.targetWeight,
                    orderIndex: exercise.orderIndex,
                    restSeconds: exercise.restSeconds,
                  ));
                }
              },
            ),
            const SizedBox(width: 10),
            _SetField(
              label: 'Reps',
              value: exercise.targetReps?.toString() ?? '',
              onChanged: (v) {
                onUpdate(RoutineExercise(
                  exerciseId: exercise.exerciseId,
                  exerciseName: exercise.exerciseName,
                  muscleGroup: exercise.muscleGroup,
                  targetSets: exercise.targetSets,
                  targetReps: int.tryParse(v),
                  targetWeight: exercise.targetWeight,
                  orderIndex: exercise.orderIndex,
                  restSeconds: exercise.restSeconds,
                ));
              },
            ),
            const SizedBox(width: 10),
            _SetField(
              label: 'kg (opt)',
              value: exercise.targetWeight?.toStringAsFixed(1) ?? '',
              decimal: true,
              onChanged: (v) {
                onUpdate(RoutineExercise(
                  exerciseId: exercise.exerciseId,
                  exerciseName: exercise.exerciseName,
                  muscleGroup: exercise.muscleGroup,
                  targetSets: exercise.targetSets,
                  targetReps: exercise.targetReps,
                  targetWeight: double.tryParse(v),
                  orderIndex: exercise.orderIndex,
                  restSeconds: exercise.restSeconds,
                ));
              },
            ),
          ]),
        ],
      ),
    );
  }
}

class _SetField extends StatelessWidget {
  final String label, value;
  final bool decimal;
  final ValueChanged<String> onChanged;

  const _SetField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.decimal = false,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            const SizedBox(height: 4),
            TextFormField(
              initialValue: value,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.numberWithOptions(decimal: decimal),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
              onChanged: onChanged,
            ),
          ],
        ),
      );
}

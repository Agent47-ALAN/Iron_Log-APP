import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/exercise_provider.dart';
import '../../core/utils/theme.dart';

class CreateExerciseSheet extends StatefulWidget {
  const CreateExerciseSheet({super.key});
  @override
  State<CreateExerciseSheet> createState() => _CreateExerciseSheetState();
}

class _CreateExerciseSheetState extends State<CreateExerciseSheet> {
  final _nameCtrl = TextEditingController();
  String _muscle = 'Chest';
  String _equipment = 'Barbell';
  bool _saving = false;

  static const muscles = ['Chest','Back','Shoulders','Biceps','Triceps',
      'Quads','Hamstrings','Glutes','Calves','Core'];
  static const equipments = ['Barbell','Dumbbell','Machine','Cable','Bodyweight','Other'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text('Create Exercise', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Exercise Name'),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _DropdownField(
                label: 'Muscle Group',
                value: _muscle,
                options: muscles,
                onChanged: (v) => setState(() => _muscle = v!),
              )),
              const SizedBox(width: 12),
              Expanded(child: _DropdownField(
                label: 'Equipment',
                value: _equipment,
                options: equipments,
                onChanged: (v) => setState(() => _equipment = v!),
              )),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create Exercise'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await context.read<ExerciseProvider>().createCustomExercise(
      name: _nameCtrl.text.trim(),
      muscleGroup: _muscle,
      equipment: _equipment,
    );
    if (mounted) Navigator.pop(context);
  }
}

class _DropdownField extends StatelessWidget {
  final String label, value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  const _DropdownField({required this.label, required this.value,
      required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: value,
        dropdownColor: AppTheme.surfaceElevated,
        decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
        items: options.map((o) => DropdownMenuItem(
            value: o, child: Text(o, style: const TextStyle(fontSize: 13)))).toList(),
        onChanged: onChanged,
      ),
    ],
  );
}

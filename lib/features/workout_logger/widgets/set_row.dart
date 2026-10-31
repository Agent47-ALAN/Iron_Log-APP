import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/workout_set.dart';
import '../../../core/utils/theme.dart';

class SetRow extends StatefulWidget {
  final WorkoutSet set;
  final String exerciseId;
  final ValueChanged<WorkoutSet> onUpdate;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const SetRow({
    super.key,
    required this.set,
    required this.exerciseId,
    required this.onUpdate,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  late TextEditingController _weightCtrl;
  late TextEditingController _repsCtrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(
        text: widget.set.weight?.toStringAsFixed(1) ?? '');
    _repsCtrl = TextEditingController(
        text: widget.set.reps?.toString() ?? '');
  }

  @override
  void didUpdateWidget(SetRow old) {
    super.didUpdateWidget(old);
    if (!_editing) {
      _weightCtrl.text = widget.set.weight?.toStringAsFixed(1) ?? '';
      _repsCtrl.text = widget.set.reps?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  void _commit() {
    final weight = double.tryParse(_weightCtrl.text);
    final reps = int.tryParse(_repsCtrl.text);
    widget.onUpdate(widget.set.copyWith(weight: weight, reps: reps));
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = widget.set.isCompleted;
    final isPR = widget.set.isPR;

    return GestureDetector(
      onLongPress: widget.onDelete,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        decoration: BoxDecoration(
          color: isComplete
              ? AppTheme.accent.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          SizedBox(
            width: 30,
            child: GestureDetector(
              onTap: () => widget.onUpdate(
                  widget.set.copyWith(isWarmup: !widget.set.isWarmup)),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: widget.set.isWarmup
                      ? AppTheme.warning.withValues(alpha: 0.2)
                      : AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    widget.set.isWarmup ? 'W' : '${widget.set.setNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.set.isWarmup
                          ? AppTheme.warning
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _NumInput(
              controller: _weightCtrl,
              hint: '0',
              decimal: true,
              completed: isComplete,
              onFocus: () => setState(() => _editing = true),
              onDone: _commit,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _NumInput(
              controller: _repsCtrl,
              hint: '0',
              decimal: false,
              completed: isComplete,
              onFocus: () => setState(() => _editing = true),
              onDone: _commit,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 36,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () {
                    _commit();
                    widget.onToggle();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isComplete ? AppTheme.accent : AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isComplete ? AppTheme.accent : AppTheme.borderLight,
                      ),
                    ),
                    child: Icon(Icons.check, size: 18,
                        color: isComplete ? Colors.white : AppTheme.textMuted),
                  ),
                ),
                if (isPR)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                          color: AppTheme.pr, shape: BoxShape.circle),
                      child: const Text('🏆', style: TextStyle(fontSize: 8)),
                    ),
                  ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _NumInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool decimal;
  final bool completed;
  final VoidCallback onFocus;
  final VoidCallback onDone;

  const _NumInput({
    required this.controller,
    required this.hint,
    required this.decimal,
    required this.completed,
    required this.onFocus,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) {
        if (focused) onFocus();
        if (!focused) onDone();
      },
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal, signed: false),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
              decimal ? RegExp(r'[\d.]') : RegExp(r'\d')),
        ],
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: completed ? AppTheme.accent : AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
          filled: true,
          fillColor: completed
              ? AppTheme.accent.withValues(alpha: 0.08)
              : AppTheme.surfaceElevated,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        ),
        onSubmitted: (_) => onDone(),
      ),
    );
  }
}

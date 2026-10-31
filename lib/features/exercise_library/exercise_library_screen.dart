import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/models/exercise.dart';
import '../../core/providers/exercise_provider.dart';
import '../../core/utils/theme.dart';
import 'exercise_detail_screen.dart';
import 'create_exercise_sheet.dart';

class ExerciseLibraryScreen extends StatelessWidget {
  final bool selectionMode;
  const ExerciseLibraryScreen({super.key, this.selectionMode = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(selectionMode ? 'Add Exercise' : 'Exercises'),
        actions: [
          if (!selectionMode)
            IconButton(
              icon: const Icon(Iconsax.add_circle, color: AppTheme.primary),
              onPressed: () => _showCreateSheet(context),
            ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(),
          _FilterChips(),
          const Divider(height: 1),
          Expanded(child: _ExerciseList(selectionMode: selectionMode)),
        ],
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CreateExerciseSheet(),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        onChanged: context.read<ExerciseProvider>().setSearch,
        decoration: InputDecoration(
          hintText: 'Search exercises...',
          prefixIcon: const Icon(Iconsax.search_normal, size: 18, color: AppTheme.textMuted),
          suffixIcon: context.watch<ExerciseProvider>().searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: AppTheme.textMuted),
                  onPressed: () => context.read<ExerciseProvider>().setSearch(''),
                )
              : null,
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExerciseProvider>();
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _MuscleFilterChip(provider: provider),
          const SizedBox(width: 8),
          _EquipmentFilterChip(provider: provider),
          const SizedBox(width: 8),
          if (provider.filterMuscle != 'All' || provider.filterEquipment != 'All')
            ActionChip(
              label: const Text('Clear', style: TextStyle(fontSize: 12)),
              onPressed: provider.clearFilters,
              backgroundColor: AppTheme.surfaceElevated,
            ),
        ],
      ),
    );
  }
}

class _MuscleFilterChip extends StatelessWidget {
  final ExerciseProvider provider;
  const _MuscleFilterChip({required this.provider});

  @override
  Widget build(BuildContext context) {
    final active = provider.filterMuscle != 'All';
    return GestureDetector(
      onTap: () => _showPicker(context, provider.muscleGroups,
          provider.filterMuscle, provider.setMuscleFilter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.primary.withValues(alpha: 0.15)
              : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppTheme.primary : AppTheme.border),
        ),
        child: Row(children: [
          Icon(Iconsax.weight, size: 14,
              color: active ? AppTheme.primary : AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(
            provider.filterMuscle == 'All' ? 'Muscle' : provider.filterMuscle,
            style: TextStyle(fontSize: 13,
                color: active ? AppTheme.primary : AppTheme.textSecondary),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 14,
              color: active ? AppTheme.primary : AppTheme.textMuted),
        ]),
      ),
    );
  }

  void _showPicker(BuildContext context, List<String> options, String current,
      ValueChanged<String> onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _PickerSheet(
          title: 'Muscle Group', options: options, selected: current, onSelect: onSelect),
    );
  }
}

class _EquipmentFilterChip extends StatelessWidget {
  final ExerciseProvider provider;
  const _EquipmentFilterChip({required this.provider});

  @override
  Widget build(BuildContext context) {
    final active = provider.filterEquipment != 'All';
    return GestureDetector(
      onTap: () => _showPicker(context, provider.equipmentTypes,
          provider.filterEquipment, provider.setEquipmentFilter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.primary.withValues(alpha: 0.15)
              : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppTheme.primary : AppTheme.border),
        ),
        child: Row(children: [
          Icon(Icons.fitness_center, size: 14,
              color: active ? AppTheme.primary : AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(
            provider.filterEquipment == 'All' ? 'Equipment' : provider.filterEquipment,
            style: TextStyle(fontSize: 13,
                color: active ? AppTheme.primary : AppTheme.textSecondary),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 14,
              color: active ? AppTheme.primary : AppTheme.textMuted),
        ]),
      ),
    );
  }

  void _showPicker(BuildContext context, List<String> options, String current,
      ValueChanged<String> onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _PickerSheet(
          title: 'Equipment', options: options, selected: current, onSelect: onSelect),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  const _PickerSheet({required this.title, required this.options,
      required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(width: 36, height: 4,
            decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (_, i) {
            final opt = options[i];
            final isSelected = opt == selected;
            return ListTile(
              title: Text(opt),
              trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primary) : null,
              tileColor: isSelected ? AppTheme.primary.withValues(alpha: 0.08) : null,
              onTap: () { onSelect(opt); Navigator.pop(context); },
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ExerciseList extends StatelessWidget {
  final bool selectionMode;
  const _ExerciseList({required this.selectionMode});

  @override
  Widget build(BuildContext context) {
    final exercises = context.watch<ExerciseProvider>().filtered;

    if (exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.search_normal, size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 12),
            Text('No exercises found', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text('Try a different search or filter',
                style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    final grouped = <String, List<Exercise>>{};
    for (final e in exercises) {
      grouped.putIfAbsent(e.muscleGroup, () => []).add(e);
    }
    final groups = grouped.keys.toList()..sort();

    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (_, i) {
        final group = groups[i];
        final items = grouped[group]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: Text(group,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted, letterSpacing: 0.8)),
            ),
            ...items.map((e) => _ExerciseTile(exercise: e, selectionMode: selectionMode)),
          ],
        );
      },
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final bool selectionMode;
  const _ExerciseTile({required this.exercise, required this.selectionMode});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _muscleColor(exercise.muscleGroup).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(exercise.name[0],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  color: _muscleColor(exercise.muscleGroup))),
        ),
      ),
      title: Text(exercise.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text('${exercise.equipment} · ${exercise.muscleGroup}',
          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
      trailing: exercise.isCustom
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Custom',
                  style: TextStyle(fontSize: 11, color: AppTheme.accent)),
            )
          : selectionMode
              ? const Icon(Icons.add_circle_outline, color: AppTheme.primary)
              : null,
      onTap: () {
        if (selectionMode) {
          Navigator.pop(context, exercise);
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: exercise)));
        }
      },
    );
  }

  Color _muscleColor(String muscle) {
    const colors = {
      'Chest': Color(0xFF3B82F6),
      'Back': Color(0xFF10B981),
      'Shoulders': Color(0xFFF59E0B),
      'Biceps': Color(0xFFEC4899),
      'Triceps': Color(0xFF8B5CF6),
      'Quads': Color(0xFFEF4444),
      'Hamstrings': Color(0xFFFF6B35),
      'Glutes': Color(0xFFE91E8C),
      'Calves': Color(0xFF06B6D4),
      'Core': Color(0xFF84CC16),
    };
    return colors[muscle] ?? AppTheme.primary;
  }
}

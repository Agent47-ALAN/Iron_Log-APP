import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../core/models/routine.dart';
import '../../core/providers/workout_provider.dart';
import '../../core/providers/routine_provider.dart';
import '../../core/utils/theme.dart';
import '../profile/profile_screen.dart';
import 'active_workout_screen.dart';

class WorkoutLoggerScreen extends StatefulWidget {
  const WorkoutLoggerScreen({super.key});

  @override
  State<WorkoutLoggerScreen> createState() => _WorkoutLoggerScreenState();
}

class _WorkoutLoggerScreenState extends State<WorkoutLoggerScreen> {
  String _profileImageUrl = '';
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    FirebaseDatabase.instance
        .ref('users/${user.uid}/profile')
        .onValue
        .listen((event) {
      if (!mounted) return;
      final data = event.snapshot.value;
      if (data != null) {
        final map = Map<String, dynamic>.from(data as Map);
        setState(() {
          _profileImageUrl = map['profileImage'] ?? '';
          _userName = map['name'] ?? user.displayName ?? 'Athlete';
        });
      } else {
        setState(() {
          _userName = user.displayName ?? 'Athlete';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasActive = context.watch<WorkoutProvider>().hasActiveWorkout;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: hasActive
          ? null
          : AppBar(
              backgroundColor: AppTheme.bg,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hello,',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w400)),
                  Text(
                    _userName.isNotEmpty ? _userName : 'Athlete',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary),
                  ),
                ],
              ),
              actions: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProfileScreen()),
                  ).then((_) => _loadProfileData()),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _ProfileAvatar(
                      imageUrl: _profileImageUrl,
                      name: _userName,
                    ),
                  ),
                ),
              ],
            ),
      body: hasActive
          ? const ActiveWorkoutScreen()
          : const _StartWorkoutView(),
    );
  }
}

// ── Profile Avatar (top right) ────────────────────────────────
class _ProfileAvatar extends StatelessWidget {
  final String imageUrl, name;
  const _ProfileAvatar({required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.25),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: 40,
                height: 40,
                errorBuilder: (_, __, ___) => _InitialAvatar(name: name),
              )
            : _InitialAvatar(name: name),
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String name;
  const _InitialAvatar({required this.name});

  @override
  Widget build(BuildContext context) => Container(
        color: AppTheme.primary.withValues(alpha: 0.2),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary),
          ),
        ),
      );
}

// ── Start Workout View ────────────────────────────────────────
class _StartWorkoutView extends StatelessWidget {
  const _StartWorkoutView();

  @override
  Widget build(BuildContext context) {
    final routines = context.watch<RoutineProvider>().routines;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader(title: 'Quick Start'),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Iconsax.add_circle),
            label: const Text('Start Empty Workout'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            onPressed: () =>
                context.read<WorkoutProvider>().startEmptyWorkout(),
          ),
        ),
        const SizedBox(height: 24),
        _SectionHeader(
          title: 'My Routines',
          action: routines.isEmpty ? null : '${routines.length} routines',
        ),
        const SizedBox(height: 10),
        if (routines.isEmpty)
          const _EmptyRoutinesCard()
        else
          ...routines.map((r) => _RoutineStartCard(routine: r)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  const _SectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (action != null)
            Text(action!,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textMuted)),
        ],
      );
}

class _EmptyRoutinesCard extends StatelessWidget {
  const _EmptyRoutinesCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Column(
          children: [
            Icon(Iconsax.task_square, size: 36, color: AppTheme.textMuted),
            SizedBox(height: 10),
            Text('No routines yet',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14)),
            SizedBox(height: 4),
            Text('Create routines in the Routines tab',
                style:
                    TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ],
        ),
      );
}

class _RoutineStartCard extends StatelessWidget {
  final Routine routine;
  const _RoutineStartCard({required this.routine});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        title: Text(routine.title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(routine.exerciseSummary,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(
              '${routine.exercises.length} exercises · Last: ${routine.lastUsedAt != null ? _formatDate(routine.lastUsedAt!) : 'Never'}',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () async {
            final routineProvider = context.read<RoutineProvider>();
            final workoutProvider = context.read<WorkoutProvider>();
            final exercises =
                routineProvider.buildWorkoutExercises(routine);
            await workoutProvider.startFromRoutine(
                routine.id, routine.title, exercises);
            if (context.mounted) {
              await routineProvider.markRoutineUsed(routine.id);
            }
          },
          child: const Text('Start'),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

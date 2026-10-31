import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/hive_service.dart';
import 'core/services/firebase_sync_service.dart';
import 'core/services/auth_service.dart';
import 'core/providers/workout_provider.dart';
import 'core/providers/routine_provider.dart';
import 'core/providers/exercise_provider.dart';
import 'core/providers/analytics_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/utils/theme.dart';
import 'app/app.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await HiveService.init();

  FirebaseSyncService? syncService;
  try {
    await Firebase.initializeApp();
    syncService = FirebaseSyncService(hiveService);
    syncService.startListening();
    syncService.syncAll();
  } catch (e) {
    syncService = FirebaseSyncService(hiveService);
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<HiveService>.value(value: hiveService),
        Provider<FirebaseSyncService>.value(value: syncService!),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider(hiveService, syncService!)..loadData(),
        ),
        ChangeNotifierProvider(
          create: (_) => RoutineProvider(hiveService, syncService!)..loadData(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExerciseProvider(hiveService, syncService!)..loadData(),
        ),
        ChangeNotifierProvider(
          create: (_) => AnalyticsProvider(hiveService)..loadData(),
        ),
      ],
      child: const IronLogRoot(),
    ),
  );
}

class IronLogRoot extends StatelessWidget {
  const IronLogRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IronLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _SplashGate(),
    );
  }
}

class _SplashGate extends StatefulWidget {
  const _SplashGate();

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 900));

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    final user = AuthService.currentUser;

    if (!mounted) return;

    if (!onboardingDone) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HevyApp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.15),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                size: 38,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'IronLog',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your Personal Gym Companion',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

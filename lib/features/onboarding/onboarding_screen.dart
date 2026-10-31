import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_screen.dart';
import '../../core/utils/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardSlide> _slides = [
    _OnboardSlide(
      icon: Icons.fitness_center_rounded,
      iconColor: Color(0xFF3B82F6),
      title: 'IronLog',
      subtitle: 'Your Personal Gym Companion',
      body:
          'Track every rep, every set, every PR. Built for lifters who take their training seriously.',
    ),
    _OnboardSlide(
      icon: Icons.bolt_rounded,
      iconColor: Color(0xFF10B981),
      title: 'Log Workouts Instantly',
      subtitle: 'No friction. Just lift.',
      body:
          'Start a workout in seconds. Log sets on the fly with your pre-built routines or freestyle it.',
    ),
    _OnboardSlide(
      icon: Icons.auto_graph_rounded,
      iconColor: Color(0xFFF59E0B),
      title: 'Visualise Progress',
      subtitle: 'Data that drives results.',
      body:
          'Interactive charts show your volume, PRs, and strength curves over time. Know exactly how far you\'ve come.',
    ),
    _OnboardSlide(
      icon: Icons.cloud_sync_rounded,
      iconColor: Color(0xFFEC4899),
      title: 'Always In Sync',
      subtitle: 'Offline-first. Cloud-backed.',
      body:
          'Your data lives on your device first — no internet required. Sign in to sync across all your devices.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    } else {
      _goToAuth();
    }
  }

  Future<void> _goToAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Ambient glow background
          Positioned(
            top: -80,
            left: -80,
            child: _GlowCircle(
              color: _slides[_currentPage].iconColor.withOpacity(0.12),
              size: 320,
            ),
          ),
          Positioned(
            bottom: -100,
            right: -60,
            child: _GlowCircle(
              color: _slides[_currentPage].iconColor.withOpacity(0.08),
              size: 280,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _goToAuth,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _slides.length,
                    itemBuilder: (_, i) => _SlidePage(slide: _slides[i]),
                  ),
                ),

                // Dots + button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      _DotsIndicator(
                        count: _slides.length,
                        current: _currentPage,
                        activeColor: _slides[_currentPage].iconColor,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _slides[_currentPage].iconColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _nextPage,
                          child: Text(
                            isLast ? 'Get Started' : 'Continue',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  final _OnboardSlide slide;
  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Big icon in glowing circle
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: slide.iconColor.withOpacity(0.12),
              border: Border.all(
                color: slide.iconColor.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            child: Icon(
              slide.icon,
              size: 64,
              color: slide.iconColor,
            ),
          ),
          const SizedBox(height: 44),
          Text(
            slide.title,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            slide.subtitle,
            style: TextStyle(
              color: slide.iconColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            slide.body,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 15,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;
  final Color activeColor;

  const _DotsIndicator({
    required this.count,
    required this.current,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive ? activeColor : AppTheme.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _OnboardSlide {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String body;

  const _OnboardSlide({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.body,
  });
}

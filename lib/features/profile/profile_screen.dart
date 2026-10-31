import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/services/cloudinary_service.dart';
import '../../core/providers/analytics_provider.dart';
import '../../core/utils/theme.dart';
import '../auth/auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _picker = ImagePicker();

  String _name = '';
  String _email = '';
  String _profileImageUrl = '';
  bool _uploading = false;
  bool _isOffline = false;
  File? _selectedImage;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn));
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _animCtrl, curve: Curves.easeOutCubic));

    _loadProfileInstant();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _loadProfileInstant() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // ── Offline / skipped — show screen IMMEDIATELY ───
      _name = 'Athlete';
      _email = 'Offline Mode';
      _isOffline = true;
      _animCtrl.forward();
      // No setState needed — called before first build
      return;
    }

    // ── Signed in — fill from auth instantly ─────────────
    _name = user.displayName?.isNotEmpty == true
        ? user.displayName!
        : 'Athlete';
    _email = user.email ?? user.uid;
    _animCtrl.forward();

    // ── Load DB data quietly in background ────────────────
    _loadFromDB(user);
  }

  Future<void> _loadFromDB(User user) async {
    try {
      final snap = await FirebaseDatabase.instance
          .ref('users/${user.uid}/profile')
          .get()
          .timeout(const Duration(seconds: 6));

      if (!mounted) return;

      if (snap.exists && snap.value != null) {
        final data = Map<String, dynamic>.from(snap.value as Map);
        setState(() {
          _name = (data['name'] as String?)?.isNotEmpty == true
              ? data['name']
              : _name;
          _email = (data['email'] as String?)?.isNotEmpty == true
              ? data['email']
              : _email;
          _profileImageUrl = data['profileImage'] ?? '';
        });
      } else {
        // First time user — write profile entry
        FirebaseDatabase.instance
            .ref('users/${user.uid}/profile')
            .set({
          'name': _name,
          'email': _email,
          'profileImage': '',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (_) {
      // Offline or timeout — already showing auth data, no crash
    }
  }

  Future<void> _pickAndUpload() async {
    if (_isOffline) {
      _showSnack('Sign in to upload a profile photo', success: false);
      return;
    }

    final picked = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (picked == null || !mounted) return;

    setState(() {
      _selectedImage = File(picked.path);
      _uploading = true;
    });

    try {
      final url =
    await CloudinaryService.uploadImage(_selectedImage!);

if (url == null) {
  throw Exception('Upload failed');
}

final uid = FirebaseAuth.instance.currentUser!.uid;

await FirebaseDatabase.instance
    .ref('users/$uid/profile')
    .update({'profileImage': url});

if (mounted) {
  setState(() {
    _profileImageUrl = url;
    _selectedImage = null;
  });

  _showSnack(
    'Profile photo updated! ✅',
    success: true,
  );
}
    } catch (e) {
      if (mounted) {
        setState(() => _selectedImage = null);
        _showSnack('Upload failed: check Cloudinary credentials',
            success: false);
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _showSnack(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? AppTheme.accent : AppTheme.danger,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out',
                style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          // ── Collapsing header ──────────────────────────
          SliverAppBar(
            expandedHeight: 290,
            pinned: true,
            backgroundColor: AppTheme.bg,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: AppTheme.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Profile',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHeader(
                name: _name,
                email: _email,
                profileImageUrl: _profileImageUrl,
                selectedImage: _selectedImage,
                uploading: _uploading,
                isOffline: _isOffline,
                onPickImage: _pickAndUpload,
                fadeAnim: _fadeAnim,
                slideAnim: _slideAnim,
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Offline banner
                if (_isOffline) ...[
                  _OfflineBanner(),
                  const SizedBox(height: 16),
                ],

                // Stats
                FadeTransition(
                    opacity: _fadeAnim,
                    child: _StatsRow(analytics: analytics)),
                const SizedBox(height: 20),

                // Account
                const _SectionLabel(label: 'ACCOUNT'),
                const SizedBox(height: 8),
                FadeTransition(
                    opacity: _fadeAnim,
                    child: _AccountSection(
                        name: _name,
                        email: _email,
                        isOffline: _isOffline)),
                const SizedBox(height: 20),

                // About
                const _SectionLabel(label: 'ABOUT IRONLOG'),
                const SizedBox(height: 8),
                FadeTransition(
                    opacity: _fadeAnim,
                    child: const _AboutSection()),
                const SizedBox(height: 20),

                // Sign out / sign in
                FadeTransition(
                  opacity: _fadeAnim,
                  child: _isOffline
                      ? _SignInButton(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AuthScreen()),
                          ))
                      : _SignOutButton(onTap: _signOut),
                ),
                const SizedBox(height: 32),

                const Center(
                  child: Text(
                    'IronLog v1.0.0\nBuilt for serious athletes 🏋️',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        height: 1.6),
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final String name, email, profileImageUrl;
  final File? selectedImage;
  final bool uploading, isOffline;
  final VoidCallback onPickImage;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.profileImageUrl,
    required this.selectedImage,
    required this.uploading,
    required this.isOffline,
    required this.onPickImage,
    required this.fadeAnim,
    required this.slideAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primary.withValues(alpha: 0.12),
            AppTheme.bg,
          ],
        ),
      ),
      child: SafeArea(
        child: SlideTransition(
          position: slideAnim,
          child: FadeTransition(
            opacity: fadeAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 44),

                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: isOffline
                                ? AppTheme.textMuted
                                : AppTheme.primary,
                            width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: (isOffline
                                    ? AppTheme.textMuted
                                    : AppTheme.primary)
                                .withValues(alpha: 0.25),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: uploading
                            ? Container(
                                color: AppTheme.surface,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                      color: AppTheme.primary,
                                      strokeWidth: 3),
                                ))
                            : selectedImage != null
                                ? Image.file(selectedImage!,
                                    fit: BoxFit.cover,
                                    width: 104,
                                    height: 104)
                                : profileImageUrl.isNotEmpty
                                    ? Image.network(
                                        profileImageUrl,
                                        fit: BoxFit.cover,
                                        width: 104,
                                        height: 104,
                                        loadingBuilder: (_, child, progress) =>
                                            progress == null
                                                ? child
                                                : _DefaultAvatar(name: name),
                                        errorBuilder: (_, __, ___) =>
                                            _DefaultAvatar(name: name),
                                      )
                                    : _DefaultAvatar(name: name),
                      ),
                    ),
                    // Camera button
                    if (!isOffline)
                      GestureDetector(
                        onTap: uploading ? null : onPickImage,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppTheme.bg, width: 2.5),
                          ),
                          child: const Icon(Iconsax.camera,
                              color: Colors.white, size: 15),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.3),
                ),
                const SizedBox(height: 4),
                Text(email,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary)),
                const SizedBox(height: 10),

                if (!isOffline)
                  GestureDetector(
                    onTap: onPickImage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.primary
                                .withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.camera,
                              size: 13, color: AppTheme.primary),
                          SizedBox(width: 6),
                          Text('Change Photo',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  final String name;
  const _DefaultAvatar({required this.name});

  @override
  Widget build(BuildContext context) => Container(
        color: AppTheme.primary.withValues(alpha: 0.2),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary),
          ),
        ),
      );
}

// ─── Offline Banner ───────────────────────────────────────────
class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppTheme.warning.withValues(alpha: 0.3)),
        ),
        child: const Row(children: [
          Icon(Iconsax.wifi_square, size: 18, color: AppTheme.warning),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Offline mode — sign in to sync data and upload a photo.',
              style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.warning,
                  height: 1.4),
            ),
          ),
        ]),
      );
}

// ─── Stats Row ────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final AnalyticsProvider analytics;
  const _StatsRow({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final hours = analytics.totalTime.inHours;
    final mins = analytics.totalTime.inMinutes.remainder(60);
    final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Expanded(child: _StatItem(
            value: '${analytics.totalWorkouts}',
            label: 'Workouts',
            icon: Iconsax.activity,
            color: AppTheme.primary)),
        _VertDivider(),
        Expanded(child: _StatItem(
            value: timeStr,
            label: 'Time',
            icon: Iconsax.timer_1,
            color: AppTheme.accent)),
        _VertDivider(),
        Expanded(child: _StatItem(
            value: '${analytics.currentStreak}d',
            label: 'Streak',
            icon: Iconsax.flash_1,
            color: AppTheme.warning)),
        _VertDivider(),
        Expanded(child: _StatItem(
            value: '${analytics.personalRecords.length}',
            label: 'PRs',
            icon: Iconsax.award,
            color: const Color(0xFFFFD700))),
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatItem({required this.value, required this.label,
      required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Column(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color)),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textMuted)),
      ]);
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 1,
      height: 40,
      color: AppTheme.border,
      margin: const EdgeInsets.symmetric(horizontal: 4));
}

// ─── Section Label ────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.textMuted,
          letterSpacing: 1.0));
}

// ─── Account Section ──────────────────────────────────────────
class _AccountSection extends StatelessWidget {
  final String name, email;
  final bool isOffline;
  const _AccountSection(
      {required this.name,
      required this.email,
      required this.isOffline});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(children: [
          _InfoTile(
              icon: Iconsax.user,
              iconColor: AppTheme.primary,
              label: 'Name',
              value: name),
          const Divider(height: 1, indent: 56),
          _InfoTile(
              icon: Iconsax.sms,
              iconColor: AppTheme.accent,
              label: 'Email',
              value: email),
          const Divider(height: 1, indent: 56),
          _InfoTile(
              icon: Iconsax.shield_tick,
              iconColor: AppTheme.warning,
              label: 'Status',
              value: isOffline ? 'Offline Mode' : 'Signed In ✓'),
        ]),
      );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value;
  const _InfoTile({required this.icon, required this.iconColor,
      required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary)),
              ],
            ),
          ),
        ]),
      );
}

// ─── About Section ────────────────────────────────────────────
class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(children: [
          _AboutTile(
              icon: Iconsax.weight,
              iconColor: AppTheme.primary,
              title: 'What is IronLog?',
              body: 'A personal workout tracker built for serious athletes. Log every rep, track PRs, build routines — all offline-first.'),
          const Divider(height: 1, indent: 56),
          _AboutTile(
              icon: Iconsax.chart_2,
              iconColor: AppTheme.accent,
              title: 'Analytics',
              body: 'Track weekly volume, workout frequency, and personal records with beautiful charts.'),
          const Divider(height: 1, indent: 56),
          _AboutTile(
              icon: Iconsax.cloud,
              iconColor: AppTheme.warning,
              title: 'Offline First',
              body: 'All data saves locally on your device via Hive. Firebase syncs silently in the background.'),
          const Divider(height: 1, indent: 56),
          _AboutTile(
              icon: Iconsax.lock,
              iconColor: const Color(0xFF8B5CF6),
              title: 'Privacy',
              body: 'Your workout data is yours alone. Stored securely with per-user Firebase access rules.'),
        ]),
      );
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, body;
  const _AboutTile({required this.icon, required this.iconColor,
      required this.title, required this.body});

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(body,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      );
}

// ─── Buttons ──────────────────────────────────────────────────
class _SignOutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SignOutButton({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.danger.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppTheme.danger.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.logout, color: AppTheme.danger, size: 18),
              SizedBox(width: 10),
              Text('Sign Out',
                  style: TextStyle(
                      color: AppTheme.danger,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

class _SignInButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SignInButton({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.login, color: AppTheme.primary, size: 18),
              SizedBox(width: 10),
              Text('Sign In to Sync',
                  style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}
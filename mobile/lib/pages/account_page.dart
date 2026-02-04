import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/theme_toggle_button.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_container.dart';
import '../providers/app_state_provider.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);
    final accentSoft = AppColors.accentSoft(context);
    final bg = AppColors.background(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final authService = AuthService();
    final userEmail = authService.getUserEmail() ?? 'admin@smartbin.com';

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // HEADER
            SliverToBoxAdapter(
              child: _AnimatedIn(
                delayMs: 0,
                child: GlassContainer(
                  margin: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  blur: 20,
                  opacity: 0.1,
                  borderRadius: BorderRadius.circular(24),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(isDark ? 0.5 : 0.3),
                              blurRadius: isDark ? 24 : 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Account",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary(context),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "Settings & Security",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // PROFILE SECTION
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _AnimatedIn(
                  delayMs: 100,
                  child: _ProfileCard(
                    email: userEmail,
                    accent: accent,
                    accentSoft: accentSoft,
                  ),
                ),
              ),
            ),

            // BIN MANAGEMENT SECTION
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: _AnimatedIn(
                  delayMs: 150,
                  child: _SectionHeader(
                    title: "Bin Management",
                    icon: Icons.delete_rounded,
                    accent: accent,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _AnimatedIn(
                  delayMs: 200,
                  child: _BinManagementSection(
                    accent: accent,
                    accentSoft: accentSoft,
                  ),
                ),
              ),
            ),

            // SECURITY SECTION
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: _AnimatedIn(
                  delayMs: 250,
                  child: _SectionHeader(
                    title: "Security",
                    icon: Icons.security_rounded,
                    accent: accent,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _AnimatedIn(
                  delayMs: 300,
                  child: _SecuritySection(accent: accent),
                ),
              ),
            ),

            // SETTINGS SECTION
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: _AnimatedIn(
                  delayMs: 350,
                  child: _SectionHeader(
                    title: "App Settings",
                    icon: Icons.settings_rounded,
                    accent: accent,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _AnimatedIn(
                  delayMs: 400,
                  child: _SettingsSection(accent: accent),
                ),
              ),
            ),

            // LOGOUT BUTTON
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: _AnimatedIn(
                  delayMs: 450,
                  child: _LogoutButton(accent: accent),
                ),
              ),
            ),

            // FOOTER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 30),
                child: _AnimatedIn(
                  delayMs: 500,
                  child: Text(
                    "Smart Bin v1.0.0\n© 2026 All Rights Reserved",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context).withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom padding for floating nav bar
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }
}

// ANIMATED IN
class _AnimatedIn extends StatefulWidget {
  final Widget child;
  final int delayMs;

  const _AnimatedIn({required this.child, this.delayMs = 0});

  @override
  State<_AnimatedIn> createState() => _AnimatedInState();
}

class _AnimatedInState extends State<_AnimatedIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _opacity = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// SECTION HEADER
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: accent, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}

// PROFILE CARD
class _ProfileCard extends StatelessWidget {
  final String email;
  final Color accent;
  final Color accentSoft;

  const _ProfileCard({
    required this.email,
    required this.accent,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      blur: 20,
      opacity: isDark ? 0.2 : 0.6,
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(24),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(isDark ? 0.5 : 0.3),
                  blurRadius: isDark ? 20 : 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 35,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Admin User",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "Administrator",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: accent,
                    ),
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

// BIN MANAGEMENT SECTION
class _BinManagementSection extends StatelessWidget {
  final Color accent;
  final Color accentSoft;

  const _BinManagementSection({required this.accent, required this.accentSoft});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      blur: 20,
      opacity: isDark ? 0.2 : 0.6,
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          _SettingsItem(
            icon: Icons.add_circle_rounded,
            title: "Add New Bin",
            subtitle: "Register a new smart bin",
            accent: accent,
            onTap: () => _showComingSoonDialog(context, "Add Bin"),
          ),
          _SettingsItem(
            icon: Icons.remove_circle_rounded,
            title: "Remove Bin",
            subtitle: "Unregister an existing bin",
            accent: accent,
            onTap: () => _showComingSoonDialog(context, "Remove Bin"),
          ),
          _SettingsItem(
            icon: Icons.edit_rounded,
            title: "Edit Bin Details",
            subtitle: "Update bin information",
            accent: accent,
            isLast: true,
            onTap: () => _showComingSoonDialog(context, "Edit Bin"),
          ),
        ],
      ),
    );
  }
}

// SECURITY SECTION
class _SecuritySection extends StatelessWidget {
  final Color accent;

  const _SecuritySection({required this.accent});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      blur: 20,
      opacity: isDark ? 0.2 : 0.6,
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          _SettingsItem(
            icon: Icons.lock_reset_rounded,
            title: "Change Password",
            subtitle: "Update your password",
            accent: accent,
            onTap: () => _showComingSoonDialog(context, "Change Password"),
          ),
          _SettingsItem(
            icon: Icons.email_rounded,
            title: "Change Email",
            subtitle: "Update your email address",
            accent: accent,
            onTap: () => _showComingSoonDialog(context, "Change Email"),
          ),
          _SettingsItem(
            icon: Icons.security_rounded,
            title: "Two-Factor Authentication",
            subtitle: "Add extra security layer",
            accent: accent,
            trailing: Switch(
              value: false,
              onChanged: (_) => _showComingSoonDialog(context, "2FA"),
              activeColor: accent,
            ),
            onTap: null,
          ),
          _SettingsItem(
            icon: Icons.devices_rounded,
            title: "Trusted Devices",
            subtitle: "Manage logged-in devices",
            accent: accent,
            onTap: () => _showComingSoonDialog(context, "Trusted Devices"),
          ),
          _SettingsItem(
            icon: Icons.history_rounded,
            title: "Activity Log",
            subtitle: "View account activity",
            accent: accent,
            onTap: () => _showComingSoonDialog(context, "Activity Log"),
          ),
          _SettingsItem(
            icon: Icons.key_rounded,
            title: "API Keys",
            subtitle: "Manage API access keys",
            accent: accent,
            isLast: true,
            onTap: () => _showComingSoonDialog(context, "API Keys"),
          ),
        ],
      ),
    );
  }
}

// SETTINGS SECTION
class _SettingsSection extends StatelessWidget {
  final Color accent;

  const _SettingsSection({required this.accent});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      blur: 20,
      opacity: isDark ? 0.2 : 0.6,
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          // DEMO MODE TOGGLE
          Consumer<AppStateProvider>(
            builder: (context, appState, _) {
              return _SettingsItem(
                icon: Icons.science_rounded,
                title: "Demo Mode",
                subtitle: appState.isDemoMode
                    ? "Simulating data..."
                    : "Live Data",
                accent: Colors.purpleAccent,
                trailing: Switch(
                  value: appState.isDemoMode,
                  onChanged: (val) {
                    HapticFeedback.lightImpact();
                    appState.toggleDemoMode(val);
                  },
                  activeColor: Colors.purpleAccent,
                ),
                onTap: null,
              );
            },
          ),
          _SettingsItem(
            icon: Icons.notifications_rounded,
            title: "Notifications",
            subtitle: "Manage notification preferences",
            accent: accent,
            onTap: () => _showComingSoonDialog(context, "Notifications"),
          ),
          _SettingsItem(
            icon: Icons.language_rounded,
            title: "Language",
            subtitle: "English (US)",
            accent: accent,
            onTap: () => _showComingSoonDialog(context, "Language"),
          ),
          _SettingsItem(
            icon: Icons.dark_mode_rounded,
            title: "Dark Mode",
            subtitle: "Enable dark theme",
            accent: accent,
            trailing: const ThemeToggleButton(),
            onTap: null,
          ),
          _SettingsItem(
            icon: Icons.download_rounded,
            title: "Export Data",
            subtitle: "Download your data",
            accent: accent,
            onTap: () => _showComingSoonDialog(context, "Export Data"),
          ),
          _SettingsItem(
            icon: Icons.delete_forever_rounded,
            title: "Delete Account",
            subtitle: "Permanently delete account",
            accent: Colors.redAccent,
            isLast: true,
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }
}

// SETTINGS ITEM
class _SettingsItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isLast;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    this.onTap,
    this.trailing,
    this.isLast = false,
  });

  @override
  State<_SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<_SettingsItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: widget.onTap != null
            ? (_) => setState(() => _isPressed = true)
            : null,
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: widget.isLast
                ? const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              widget.trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary(context).withOpacity(0.5),
                    size: 24,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// LOGOUT BUTTON
class _LogoutButton extends StatelessWidget {
  final Color accent;

  const _LogoutButton({required this.accent});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(isDark ? 0.5 : 0.3),
            blurRadius: isDark ? 20 : 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 22),
            SizedBox(width: 10),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// DIALOGS (Theme-aware)
void _showComingSoonDialog(BuildContext context, String feature) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final accent = AppColors.accent(context);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.info_outline_rounded, color: accent),
          ),
          const SizedBox(width: 12),
          Text(
            "Coming Soon",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
      content: Text(
        "$feature will be available in a future update.",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.textSecondary(context),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'OK',
            style: TextStyle(fontWeight: FontWeight.w900, color: accent),
          ),
        ),
      ],
    ),
  );
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.logout_rounded, color: Colors.redAccent),
          const SizedBox(width: 12),
          Text(
            "Logout",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
      content: Text(
        "Are you sure you want to logout?",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.textSecondary(context),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await AuthService().signOut();
          },
          child: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.redAccent,
            ),
          ),
        ),
      ],
    ),
  );
}

void _showDeleteAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.warning_rounded, color: Colors.redAccent),
          const SizedBox(width: 12),
          Text(
            "Delete Account",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
      content: Text(
        "This feature is not yet available. In a future update, you'll be able to permanently delete your account and all associated data.",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.textSecondary(context),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'OK',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
      ],
    ),
  );
}

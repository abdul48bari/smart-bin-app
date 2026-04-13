import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
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
    final userEmail = authService.getUserEmail() ?? 'admin';

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
                  borderRadius: BorderRadius.circular(24),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha:isDark ? 0.3 : 0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
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
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary(context),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "Settings & Security",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
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
                      color: AppColors.textSecondary(context).withValues(alpha:0.6),
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
            fontWeight: FontWeight.w800,
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
      borderRadius: BorderRadius.circular(24),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha:isDark ? 0.3 : 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
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
                    fontWeight: FontWeight.w800,
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
                        color: Colors.black.withValues(alpha:0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "Administrator",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
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
    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          _SettingsItem(
            icon: Icons.add_circle_rounded,
            title: "Add New Bin",
            subtitle: "Register a new smart bin",
            accent: accent,
            onTap: () => _showAddBinDialog(context),
          ),
          _SettingsItem(
            icon: Icons.remove_circle_rounded,
            title: "Remove Bin",
            subtitle: "Unregister an existing bin",
            accent: accent,
            onTap: () => _showRemoveBinDialog(context),
          ),
          _SettingsItem(
            icon: Icons.edit_rounded,
            title: "Edit Bin Details",
            subtitle: "Update bin information",
            accent: accent,
            isLast: true,
            onTap: () => _showEditBinDialog(context),
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
    return GlassContainer(
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
              activeThumbColor: accent,
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
    return GlassContainer(
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
                    // If entered via "Try Demo", turning off demo = logout back to login
                    if (!val && appState.isDemoEntry) {
                      appState.exitDemoMode();
                    } else {
                      appState.toggleDemoMode(val);
                    }
                  },
                  activeThumbColor: Colors.purpleAccent,
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
                  color: widget.accent.withValues(alpha:0.1),
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
                        fontWeight: FontWeight.w800,
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
                    color: AppColors.textSecondary(context).withValues(alpha:0.5),
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
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withValues(alpha:isDark ? 0.3 : 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
                fontWeight: FontWeight.w800,
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
  final accent = AppColors.accent(context);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.info_outline_rounded, color: accent),
          ),
          const SizedBox(width: 12),
          Text(
            "Coming Soon",
            style: TextStyle(
              fontWeight: FontWeight.w800,
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
            style: TextStyle(fontWeight: FontWeight.w800, color: accent),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.logout_rounded, color: Colors.redAccent),
          const SizedBox(width: 12),
          Text(
            "Logout",
            style: TextStyle(
              fontWeight: FontWeight.w800,
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
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            final appState = Provider.of<AppStateProvider>(context, listen: false);
            if (appState.isDemoEntry) {
              appState.exitDemoMode();
            } else {
              await AuthService().signOut();
            }
          },
          child: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.redAccent,
            ),
          ),
        ),
      ],
    ),
  );
}

// ─── ADD BIN ──────────────────────────────────────────────────────────────────

void _showAddBinDialog(BuildContext context) {
  final appState = Provider.of<AppStateProvider>(context, listen: false);
  if (appState.isDemoMode) {
    _showDemoRestrictedDialog(context);
    return;
  }
  showDialog(
    context: context,
    builder: (context) => const _AddBinDialog(),
  );
}

class _AddBinDialog extends StatefulWidget {
  const _AddBinDialog();

  @override
  State<_AddBinDialog> createState() => _AddBinDialogState();
}

class _AddBinDialogState extends State<_AddBinDialog> {
  final _formKey = GlobalKey<FormState>();
  final _binIdCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _status = 'online';
  bool _isLoading = false;
  String? _errorMsg;

  static const _statusOptions = ['online', 'offline', 'maintenance'];
  static final _binIdRegex = RegExp(r'^[A-Za-z0-9_-]{1,64}$');

  @override
  void dispose() {
    _binIdCtrl.dispose();
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      await FirestoreService().addBin(
        binId: _binIdCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        status: _status,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Bin "${_nameCtrl.text.trim()}" added successfully'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      final msg = e.toString().contains('BIN_EXISTS')
          ? 'A bin with this ID already exists. Choose a different ID.'
          : 'Failed to add bin. Please try again.';
      setState(() { _isLoading = false; _errorMsg = msg; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);
    return AlertDialog(
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: _dialogTitle(context, 'Add New Bin', Icons.add_circle_rounded, accent),
      content: SizedBox(
        width: 320,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _binTextField(context, controller: _binIdCtrl, label: 'Bin ID', hint: 'e.g. CAFE_C_08',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Bin ID is required';
                  if (!_binIdRegex.hasMatch(v.trim())) return 'Only letters, numbers, _ and - allowed';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _binTextField(context, controller: _nameCtrl, label: 'Name', hint: 'e.g. Cafeteria Block C',
                validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              _binTextField(context, controller: _locationCtrl, label: 'Location', hint: 'e.g. Food Court',
                validator: (v) => v == null || v.trim().isEmpty ? 'Location is required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: _inputDecoration(context, 'Status', accent),
                dropdownColor: AppColors.surface(context),
                style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w600, fontSize: 14),
                items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _status = v ?? 'online'),
              ),
              if (_errorMsg != null) ...[
                const SizedBox(height: 12),
                Text(_errorMsg!, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textSecondary(context))),
        ),
        TextButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: accent))
              : Text('Add', style: TextStyle(fontWeight: FontWeight.w800, color: accent)),
        ),
      ],
    );
  }
}

// ─── REMOVE BIN ───────────────────────────────────────────────────────────────

void _showRemoveBinDialog(BuildContext context) {
  final appState = Provider.of<AppStateProvider>(context, listen: false);
  if (appState.isDemoMode) {
    _showDemoRestrictedDialog(context);
    return;
  }
  showDialog(
    context: context,
    builder: (context) => const _RemoveBinDialog(),
  );
}

class _RemoveBinDialog extends StatefulWidget {
  const _RemoveBinDialog();

  @override
  State<_RemoveBinDialog> createState() => _RemoveBinDialogState();
}

class _RemoveBinDialogState extends State<_RemoveBinDialog> {
  List<Map<String, String>>? _bins;
  String? _selectedId;
  bool _isFetching = true;
  bool _isRemoving = false;
  bool _confirming = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadBins();
  }

  Future<void> _loadBins() async {
    try {
      final list = await FirestoreService().getBinsList();
      setState(() { _bins = list; _isFetching = false; });
    } catch (_) {
      setState(() { _isFetching = false; _errorMsg = 'Failed to load bins.'; });
    }
  }

  Future<void> _remove() async {
    if (_selectedId == null) return;
    setState(() { _isRemoving = true; _errorMsg = null; });
    try {
      await FirestoreService().removeBin(_selectedId!);
      if (mounted) {
        final bin = _bins?.firstWhere((b) => b['id'] == _selectedId, orElse: () => {'name': _selectedId!});
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Bin "${bin?['name'] ?? _selectedId}" removed'),
          backgroundColor: Colors.redAccent,
        ));
      }
    } catch (_) {
      setState(() { _isRemoving = false; _errorMsg = 'Failed to remove bin. Please try again.'; });
    }
  }

  Map<String, String>? get _selected =>
      _selectedId != null ? _bins?.firstWhere((b) => b['id'] == _selectedId, orElse: () => {'name': _selectedId!, 'location': '', 'id': _selectedId!}) : null;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);

    if (_isFetching) {
      return AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(height: 80, child: Center(child: CircularProgressIndicator(color: accent))),
      );
    }

    return AlertDialog(
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: _dialogTitle(context, _confirming ? 'Confirm Remove' : 'Remove Bin', Icons.remove_circle_rounded, Colors.redAccent),
      content: SizedBox(
        width: 320,
        child: _confirming ? _buildConfirmView(context) : _buildSelectView(context),
      ),
      actions: _confirming ? _confirmActions(context) : _selectActions(context),
    );
  }

  Widget _buildSelectView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select the bin you want to remove:',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textSecondary(context)),
        ),
        const SizedBox(height: 12),
        if (_bins == null || _bins!.isEmpty)
          Text('No bins found.', style: TextStyle(color: AppColors.textSecondary(context), fontWeight: FontWeight.w600))
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: SingleChildScrollView(
              child: Column(
                children: _bins!.map((bin) {
                  final isSelected = bin['id'] == _selectedId;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedId = bin['id']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.redAccent.withValues(alpha: 0.1) : AppColors.background(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? Colors.redAccent : AppColors.textSecondary(context).withValues(alpha: 0.2),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              color: isSelected ? Colors.redAccent : AppColors.textSecondary(context), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bin['name']!,
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary(context))),
                                Text('${bin['id']} · ${bin['location']}',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.textSecondary(context))),
                              ],
                            ),
                          ),
                          if (isSelected) const Icon(Icons.check_circle_rounded, color: Colors.redAccent, size: 18),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        if (_errorMsg != null) ...[
          const SizedBox(height: 10),
          Text(_errorMsg!, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ],
    );
  }

  Widget _buildConfirmView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Are you sure you want to remove this bin? This cannot be undone.',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textSecondary(context)),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selected?['name'] ?? _selectedId!,
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary(context))),
                    Text(_selected?['location'] ?? '',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textSecondary(context))),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_errorMsg != null) ...[
          const SizedBox(height: 10),
          Text(_errorMsg!, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ],
    );
  }

  List<Widget> _selectActions(BuildContext context) => [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textSecondary(context))),
    ),
    TextButton(
      onPressed: _selectedId == null ? null : () => setState(() => _confirming = true),
      child: const Text('Next', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.redAccent)),
    ),
  ];

  List<Widget> _confirmActions(BuildContext context) => [
    TextButton(
      onPressed: _isRemoving ? null : () => setState(() { _confirming = false; _errorMsg = null; }),
      child: Text('Back', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textSecondary(context))),
    ),
    TextButton(
      onPressed: _isRemoving ? null : _remove,
      child: _isRemoving
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent))
          : const Text('Remove', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.redAccent)),
    ),
  ];
}

// ─── EDIT BIN ─────────────────────────────────────────────────────────────────

void _showEditBinDialog(BuildContext context) {
  final appState = Provider.of<AppStateProvider>(context, listen: false);
  if (appState.isDemoMode) {
    _showDemoRestrictedDialog(context);
    return;
  }
  showDialog(
    context: context,
    builder: (context) => const _EditBinDialog(),
  );
}

class _EditBinDialog extends StatefulWidget {
  const _EditBinDialog();

  @override
  State<_EditBinDialog> createState() => _EditBinDialogState();
}

class _EditBinDialogState extends State<_EditBinDialog> {
  List<Map<String, String>>? _bins;
  String? _selectedId;
  bool _isFetching = true;
  bool _isEditing = false; // step 2: edit form
  bool _isSaving = false;
  String? _errorMsg;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _status = 'online';

  static const _statusOptions = ['online', 'offline', 'maintenance'];

  @override
  void initState() {
    super.initState();
    _loadBins();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBins() async {
    try {
      final list = await FirestoreService().getBinsList();
      setState(() { _bins = list; _isFetching = false; });
    } catch (_) {
      setState(() { _isFetching = false; _errorMsg = 'Failed to load bins.'; });
    }
  }

  void _openEditForm() {
    final bin = _bins!.firstWhere((b) => b['id'] == _selectedId);
    _nameCtrl.text = bin['name'] ?? '';
    _locationCtrl.text = bin['location'] ?? '';
    _status = bin['status'] ?? 'online';
    setState(() { _isEditing = true; _errorMsg = null; });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSaving = true; _errorMsg = null; });
    try {
      await FirestoreService().updateBinDetails(
        binId: _selectedId!,
        name: _nameCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        status: _status,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Bin "${_nameCtrl.text.trim()}" updated'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (_) {
      setState(() { _isSaving = false; _errorMsg = 'Failed to save changes. Please try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);

    if (_isFetching) {
      return AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(height: 80, child: Center(child: CircularProgressIndicator(color: accent))),
      );
    }

    return AlertDialog(
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: _dialogTitle(context, _isEditing ? 'Edit Details' : 'Edit Bin', Icons.edit_rounded, accent),
      content: SizedBox(
        width: 320,
        child: _isEditing ? _buildEditForm(context, accent) : _buildSelectView(context),
      ),
      actions: _isEditing ? _editActions(context, accent) : _selectActions(context),
    );
  }

  Widget _buildSelectView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select the bin you want to edit:',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textSecondary(context)),
        ),
        const SizedBox(height: 12),
        if (_bins == null || _bins!.isEmpty)
          Text('No bins found.', style: TextStyle(color: AppColors.textSecondary(context), fontWeight: FontWeight.w600))
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: SingleChildScrollView(
              child: Column(
                children: _bins!.map((bin) {
                  final isSelected = bin['id'] == _selectedId;
                  final accent = AppColors.accent(context);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedId = bin['id']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? accent.withValues(alpha: 0.1) : AppColors.background(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? accent : AppColors.textSecondary(context).withValues(alpha: 0.2),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, color: isSelected ? accent : AppColors.textSecondary(context), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bin['name']!,
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary(context))),
                                Text('${bin['id']} · ${bin['location']}',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.textSecondary(context))),
                              ],
                            ),
                          ),
                          if (isSelected) Icon(Icons.check_circle_rounded, color: accent, size: 18),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        if (_errorMsg != null) ...[
          const SizedBox(height: 10),
          Text(_errorMsg!, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ],
    );
  }

  Widget _buildEditForm(BuildContext context, Color accent) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bin ID (read-only badge)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.textSecondary(context).withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bin ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary(context))),
                const SizedBox(height: 2),
                Text(_selectedId!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _binTextField(context, controller: _nameCtrl, label: 'Name', hint: 'e.g. Cafeteria Block C',
            validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null),
          const SizedBox(height: 12),
          _binTextField(context, controller: _locationCtrl, label: 'Location', hint: 'e.g. Food Court',
            validator: (v) => v == null || v.trim().isEmpty ? 'Location is required' : null),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: _inputDecoration(context, 'Status', accent),
            dropdownColor: AppColors.surface(context),
            style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w600, fontSize: 14),
            items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _status = v ?? 'online'),
          ),
          if (_errorMsg != null) ...[
            const SizedBox(height: 12),
            Text(_errorMsg!, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }

  List<Widget> _selectActions(BuildContext context) => [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textSecondary(context))),
    ),
    TextButton(
      onPressed: _selectedId == null ? null : _openEditForm,
      child: Text('Next', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.accent(context))),
    ),
  ];

  List<Widget> _editActions(BuildContext context, Color accent) => [
    TextButton(
      onPressed: _isSaving ? null : () => setState(() { _isEditing = false; _errorMsg = null; }),
      child: Text('Back', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textSecondary(context))),
    ),
    TextButton(
      onPressed: _isSaving ? null : _save,
      child: _isSaving
          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: accent))
          : Text('Save', style: TextStyle(fontWeight: FontWeight.w800, color: accent)),
    ),
  ];
}

// ─── DEMO RESTRICTED ──────────────────────────────────────────────────────────

void _showDemoRestrictedDialog(BuildContext context) {
  final accent = AppColors.accent(context);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.purpleAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.science_rounded, color: Colors.purpleAccent),
          ),
          const SizedBox(width: 12),
          Text('Demo Mode', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary(context))),
        ],
      ),
      content: Text(
        'Bin management is not available in Demo Mode. Please log in with a real account to add or remove bins.',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textSecondary(context)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK', style: TextStyle(fontWeight: FontWeight.w800, color: accent)),
        ),
      ],
    ),
  );
}

// ─── SHARED DIALOG HELPERS ────────────────────────────────────────────────────

Widget _dialogTitle(BuildContext context, String text, IconData icon, Color color) {
  return Row(
    children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color),
      ),
      const SizedBox(width: 12),
      Text(text, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary(context))),
    ],
  );
}

InputDecoration _inputDecoration(BuildContext context, String label, Color accent) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: AppColors.textSecondary(context), fontWeight: FontWeight.w600, fontSize: 13),
    filled: true,
    fillColor: AppColors.background(context),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.textSecondary(context).withValues(alpha: 0.2))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.textSecondary(context).withValues(alpha: 0.2))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: accent)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent)),
  );
}

Widget _binTextField(
  BuildContext context, {
  required TextEditingController controller,
  required String label,
  required String hint,
  required String? Function(String?) validator,
}) {
  final accent = AppColors.accent(context);
  return TextFormField(
    controller: controller,
    style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w600, fontSize: 14),
    decoration: _inputDecoration(context, label, accent).copyWith(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textSecondary(context).withValues(alpha: 0.5), fontSize: 13),
    ),
    validator: validator,
  );
}

// ─── DELETE ACCOUNT ───────────────────────────────────────────────────────────

void _showDeleteAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.warning_rounded, color: Colors.redAccent),
          const SizedBox(width: 12),
          Text(
            "Delete Account",
            style: TextStyle(
              fontWeight: FontWeight.w800,
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
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
      ],
    ),
  );
}

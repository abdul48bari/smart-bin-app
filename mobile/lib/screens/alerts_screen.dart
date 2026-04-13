import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/alert.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../utils/shadows.dart';

class AlertsScreen extends StatefulWidget {
  final String binId;

  const AlertsScreen({
    super.key,
    required this.binId,
  });

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  // 'active' or 'old'
  String _selectedFilter = 'active';

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final accent = AppColors.accent(context);
    final bg = AppColors.background(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          widget.binId,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: AppColors.textPrimary(context),
          ),
        ),
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: StreamBuilder<List<AlertModel>>(
        stream: firestoreService.getActiveAlerts(widget.binId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: accent));
          }

          final alerts = snapshot.data ?? [];
          final activeAlerts = alerts.where((a) => !a.isResolved).toList();
          final resolvedAlerts = alerts.where((a) => a.isResolved).toList();
          final displayed =
              _selectedFilter == 'active' ? activeAlerts : resolvedAlerts;

          return Column(
            children: [
              // FILTER TAB BAR
              Container(
                color: AppColors.surface(context),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    _FilterTab(
                      label: 'Active',
                      count: activeAlerts.length,
                      selected: _selectedFilter == 'active',
                      color: Colors.redAccent,
                      accent: accent,
                      onTap: () => setState(() => _selectedFilter = 'active'),
                    ),
                    const SizedBox(width: 10),
                    _FilterTab(
                      label: 'Old',
                      count: resolvedAlerts.length,
                      selected: _selectedFilter == 'old',
                      color: Colors.green,
                      accent: accent,
                      onTap: () => setState(() => _selectedFilter = 'old'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),

              // ALERTS LIST
              Expanded(
                child: displayed.isEmpty
                    ? _EmptyAlertsState(
                        accent: accent,
                        isOld: _selectedFilter == 'old',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                        itemCount: displayed.length,
                        itemBuilder: (context, index) {
                          return _AnimatedIn(
                            delayMs: 40 + (index * 50),
                            child: _AlertCard(
                              alert: displayed[index],
                              binId: widget.binId,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ======================= FILTER TAB =======================

class _FilterTab extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final Color color;
  final Color accent;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.color,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = selected ? color : AppColors.textSecondary(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.1)
              : AppColors.surfaceSecondary(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.35)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: activeColor,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withValues(alpha: 0.15)
                      : AppColors.border(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: activeColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ======================= EMPTY STATE =======================

class _EmptyAlertsState extends StatelessWidget {
  final Color accent;
  final bool isOld;

  const _EmptyAlertsState({required this.accent, this.isOld = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 44,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isOld ? 'No History' : 'All Clear',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isOld
                  ? 'No resolved alerts yet'
                  : 'No active alerts for this bin',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= ALERT CARD =======================

class _AlertCard extends StatefulWidget {
  final AlertModel alert;
  final String binId;

  const _AlertCard({required this.alert, required this.binId});

  @override
  State<_AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<_AlertCard> {
  bool _isResolving = false;

  Color _getAlertColor() {
    switch (widget.alert.alertType) {
      case 'BATTERY_DETECTED':
        return const Color(0xFFDC2626); // Red
      case 'HARMFUL_GAS':
        return const Color(0xFFD97706); // Dark orange
      case 'MOISTURE_DETECTED':
        return const Color(0xFF2563EB); // Blue
      case 'HARDWARE_ERROR':
        return const Color(0xFF7C3AED); // Purple
      case 'BIN_FULL':
        return const Color(0xFFF59E0B); // Amber
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  IconData _getAlertIcon() {
    switch (widget.alert.alertType) {
      case 'BATTERY_DETECTED':
        return Icons.battery_alert_rounded;
      case 'HARMFUL_GAS':
        return Icons.air_rounded;
      case 'MOISTURE_DETECTED':
        return Icons.water_drop_rounded;
      case 'HARDWARE_ERROR':
        return Icons.build_circle_rounded;
      case 'BIN_FULL':
        return Icons.delete_rounded;
      default:
        return Icons.warning_rounded;
    }
  }

  String _getAlertTypeLabel() {
    switch (widget.alert.alertType) {
      case 'BATTERY_DETECTED':
        return 'Battery Detected';
      case 'HARMFUL_GAS':
        return 'Harmful Gas';
      case 'MOISTURE_DETECTED':
        return 'Moisture Detected';
      case 'HARDWARE_ERROR':
        return 'Hardware Error';
      case 'BIN_FULL':
        return 'Bin Full';
      default:
        return widget.alert.alertType;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _showResolveDialog() async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface(ctx),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Resolve Alert',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(ctx),
                ),
              ),
            ],
          ),
          content: Text(
            'Have you handled this issue? This will mark the alert as resolved.',
            style: TextStyle(
              color: AppColors.textSecondary(ctx),
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary(ctx),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Mark Resolved',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() => _isResolving = true);
      try {
        await FirestoreService().resolveAlert(widget.binId, widget.alert.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Alert resolved',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isResolving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to resolve: $e'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alertColor = _getAlertColor();
    final isResolved = widget.alert.isResolved;

    // Severity badge
    final severityColor =
        widget.alert.severity == 'error' ? Colors.redAccent : Colors.amber.shade700;

    // Dangerous badge for gas >= 1000 PPM
    final isDangerous =
        widget.alert.alertType == 'HARMFUL_GAS' &&
        (widget.alert.gasLevel ?? 0) >= 1000;

    return AnimatedOpacity(
      opacity: isResolved ? 0.65 : 1.0,
      duration: const Duration(milliseconds: 400),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isResolved
              ? (isDark
                  ? Colors.green.withValues(alpha:0.08)
                  : Colors.green.withValues(alpha:0.06))
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isResolved
                ? Colors.green.withValues(alpha:0.2)
                : alertColor.withValues(alpha:isDark ? 0.35 : 0.18),
            width: 1.5,
          ),
          boxShadow: AppShadows.elevation(context, 'medium'),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP ROW: icon + type label + severity + resolve btn
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon circle
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isResolved
                          ? Colors.green.withValues(alpha:0.12)
                          : alertColor.withValues(alpha:0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isResolved ? Icons.check_circle_rounded : _getAlertIcon(),
                      color: isResolved ? Colors.green : alertColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Type + message
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _getAlertTypeLabel(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isResolved
                                    ? Colors.green
                                    : alertColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Severity badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: isResolved
                                    ? Colors.green.withValues(alpha:0.12)
                                    : severityColor.withValues(alpha:0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                isResolved
                                    ? 'resolved'
                                    : widget.alert.severity,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isResolved
                                      ? Colors.green
                                      : severityColor,
                                ),
                              ),
                            ),
                            // Dangerous badge for high gas
                            if (isDangerous && !isResolved) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha:0.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'DANGEROUS',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.alert.message,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isResolved
                                ? AppColors.textSecondary(context)
                                : AppColors.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Resolve button OR resolved checkmark
                  if (!isResolved && widget.alert.requiresManualResolution)
                    _isResolving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.green,
                            ),
                          )
                        : GestureDetector(
                            onTap: _showResolveDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha:0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Resolve',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                  else if (isResolved)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle_rounded,
                            color: Colors.green, size: 18),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 10),

              // BOTTOM ROW: extra info chips + time
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  // Sub-bin chip
                  if (widget.alert.subBin != null)
                    _InfoChip(
                      icon: Icons.category_rounded,
                      label: widget.alert.subBin!,
                      color: AppColors.subBinColor(
                          widget.alert.subBin!, context),
                    ),

                  // Gas level chip
                  if (widget.alert.alertType == 'HARMFUL_GAS' &&
                      widget.alert.gasLevel != null)
                    _InfoChip(
                      icon: Icons.air_rounded,
                      label:
                          '${widget.alert.gasType ?? "gas"} · ${widget.alert.gasLevel} PPM',
                      color: isDangerous
                          ? Colors.red
                          : Colors.orange.shade700,
                    ),

                  // Moisture level chip
                  if (widget.alert.alertType == 'MOISTURE_DETECTED' &&
                      widget.alert.moistureLevel != null)
                    _InfoChip(
                      icon: Icons.water_drop_rounded,
                      label: '${widget.alert.moistureLevel}% moisture',
                      color: const Color(0xFF2563EB),
                    ),

                  // Time chip
                  _InfoChip(
                    icon: Icons.access_time_rounded,
                    label: isResolved && widget.alert.resolvedAt != null
                        ? 'Resolved ${_timeAgo(widget.alert.resolvedAt!)}'
                        : _timeAgo(widget.alert.createdAt),
                    color: AppColors.textSecondary(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================= INFO CHIP =======================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= ANIMATED IN =======================

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

    if (widget.delayMs > 0) {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) _c.forward();
      });
    } else {
      _c.forward();
    }
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

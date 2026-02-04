import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../widgets/live_bin_status_card.dart';
import '../services/firestore_service.dart';
import '../models/alert.dart';
import '../screens/alerts_screen.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_container.dart';
import '../providers/app_state_provider.dart';

class BinsPage extends StatelessWidget {
  const BinsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);
    final accentSoft = AppColors.accentSoft(context);
    final bg = AppColors.background(context);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: accent,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 450));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // HERO HEADER
              SliverToBoxAdapter(
                child: _HeroHeader(accent: accent, accentSoft: accentSoft),
              ),

              // SYSTEM HEALTH OVERVIEW
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _SystemHealthCard(
                    accent: accent,
                    accentSoft: accentSoft,
                  ),
                ),
              ),

              // QUICK STATS
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _QuickStatsRow(accent: accent, accentSoft: accentSoft),
                ),
              ),

              // SECTION HEADER
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Row(
                    children: [
                      Icon(Icons.storage_rounded, color: accent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "All Bins",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const Spacer(),
                      Consumer<AppStateProvider>(
                        builder: (context, appState, _) {
                          return StreamBuilder<QuerySnapshot>(
                            stream: appState.binsStream,
                            builder: (context, snapshot) {
                              final count = snapshot.data?.docs.length ?? 0;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: accentSoft,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  "$count",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: accent,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // BINS LIST
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                sliver: Consumer<AppStateProvider>(
                  builder: (context, appState, _) {
                    return StreamBuilder<QuerySnapshot>(
                      stream: appState.binsStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          );
                        }

                        final bins = snapshot.data!.docs;

                        if (bins.isEmpty) {
                          return SliverToBoxAdapter(
                            child: _EmptyState(accent: accent),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final bin = bins[index];
                            final data =
                                bin.data() as Map<String, dynamic>? ?? {};

                            return _AnimatedIn(
                              delayMs: 100 + (index * 50),
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('bins')
                                    .doc(bin.id)
                                    .collection('alerts')
                                    .where('resolved', isEqualTo: false)
                                    .snapshots(),
                                builder: (context, alertSnap) {
                                  final alertCount =
                                      alertSnap.data?.docs.length ?? 0;

                                  return _ModernBinCard(
                                    binId: bin.id,
                                    name: data['name'] ?? bin.id,
                                    location: data['location'] ?? 'Unknown',
                                    alertCount: alertCount,
                                    accent: accent,
                                    accentSoft: accentSoft,
                                  );
                                },
                              ),
                            );
                          }, childCount: bins.length),
                        ); // SliverList
                      },
                    ); // StreamBuilder
                  },
                ), // Consumer
              ), // SliverPadding
              // Bottom padding for floating nav bar
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

// HERO HEADER
class _HeroHeader extends StatelessWidget {
  final Color accent;
  final Color accentSoft;

  const _HeroHeader({required this.accent, required this.accentSoft});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      blur: 20,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Row(
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
                  Icons.delete_outline_rounded,
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
                      "Bins Management",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Monitor & control all bins",
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
        ],
      ),
    );
  }
}

// SYSTEM HEALTH CARD
class _SystemHealthCard extends StatelessWidget {
  final Color accent;
  final Color accentSoft;

  const _SystemHealthCard({required this.accent, required this.accentSoft});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = Provider.of<AppStateProvider>(context);

    return StreamBuilder<QuerySnapshot>(
      stream: appState.binsStream,
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        int online = 0;
        int offline = 0;
        int maintenance = 0;

        for (final d in docs) {
          final data = d.data() as Map<String, dynamic>? ?? {};
          final status = data['status'] ?? 'offline';

          if (status == 'online') {
            online++;
          } else if (status == 'maintenance') {
            maintenance++;
          } else {
            offline++;
          }
        }

        final healthScore = docs.isEmpty
            ? 0
            : ((online / docs.length) * 100).round();

        final Color healthColor = healthScore >= 80
            ? accent
            : healthScore >= 50
            ? Colors.amber.shade700
            : Colors.redAccent;

        return _AnimatedIn(
          delayMs: 50,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentSoft, AppColors.surface(context)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? accent.withOpacity(0.2)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: isDark ? 24 : 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: healthColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: healthColor.withOpacity(isDark ? 0.5 : 0.3),
                            blurRadius: isDark ? 20 : 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "System Health",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                "$healthScore%",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: healthColor,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                healthScore >= 80
                                    ? "Excellent"
                                    : healthScore >= 50
                                    ? "Good"
                                    : "Needs Attention",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _HealthMetric(
                        label: "Active",
                        value: online,
                        icon: Icons.check_circle_rounded,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HealthMetric(
                        label: "Offline",
                        value: offline,
                        icon: Icons.cancel_rounded,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HealthMetric(
                        label: "Maintenance",
                        value: maintenance,
                        icon: Icons.build_circle_rounded,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HealthMetric extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _HealthMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            "$value",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// QUICK STATS ROW
class _QuickStatsRow extends StatelessWidget {
  final Color accent;
  final Color accentSoft;

  const _QuickStatsRow({required this.accent, required this.accentSoft});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bins').snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        int totalBins = docs.length;
        int activeBins = 0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          if ((data['status'] ?? 'offline') == 'online') {
            activeBins++;
          }
        }

        return _AnimatedIn(
          delayMs: 80,
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: "Total Bins",
                  value: "$totalBins",
                  icon: Icons.inventory_2_rounded,
                  accent: accent,
                  background: AppColors.surface(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: "Active",
                  value: "$activeBins",
                  icon: Icons.check_circle_rounded,
                  accent: Colors.green,
                  background: AppColors.surface(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: "Capacity",
                  value: "${(totalBins * 85).round()}L",
                  icon: Icons.water_drop_rounded,
                  accent: accent,
                  background: AppColors.surface(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final Color background;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

// REPLACE the entire _ModernBinCard class with this:

class _ModernBinCard extends StatefulWidget {
  final String binId;
  final String name;
  final String location;
  final int alertCount;
  final Color accent;
  final Color accentSoft;

  const _ModernBinCard({
    required this.binId,
    required this.name,
    required this.location,
    required this.alertCount,
    required this.accent,
    required this.accentSoft,
  });

  @override
  State<_ModernBinCard> createState() => _ModernBinCardState();
}

class _ModernBinCardState extends State<_ModernBinCard>
    with SingleTickerProviderStateMixin {
  bool expanded = false;
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      expanded = !expanded;
      if (expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'online':
        return widget.accent;
      case 'maintenance':
        return Colors.amber.shade700;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'online':
        return 'Active';
      case 'maintenance':
        return 'Maintenance';
      default:
        return 'Offline';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'online':
        return Icons.check_circle_rounded;
      case 'maintenance':
        return Icons.build_circle_rounded;
      default:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // STREAM BUILDER TO LISTEN TO STATUS CHANGES
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bins')
          .doc(widget.binId)
          .snapshots(),
      builder: (context, snapshot) {
        // Get current status from Firebase (real-time)
        final status = snapshot.hasData
            ? ((snapshot.data!.data() as Map<String, dynamic>?)?['status'] ??
                  'offline')
            : 'offline';

        final statusColor = _getStatusColor(status);
        final statusLabel = _getStatusLabel(status);
        final statusIcon = _getStatusIcon(status);

        return Column(
          children: [
            GestureDetector(
              onTap: _toggleExpanded,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            AppColors.surface(context),
                            widget.alertCount > 0
                                ? Colors.redAccent.withOpacity(0.1)
                                : status == 'online'
                                ? widget.accentSoft.withOpacity(0.2)
                                : const Color(0xFF2A2A2A),
                          ]
                        : [
                            Colors.white,
                            widget.alertCount > 0
                                ? Colors.redAccent.withOpacity(0.05)
                                : status == 'online'
                                ? widget.accentSoft.withOpacity(0.3)
                                : Colors.grey.shade50,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: widget.alertCount > 0
                        ? Colors.redAccent.withOpacity(isDark ? 0.4 : 0.2)
                        : status == 'online' && isDark
                        ? widget.accent.withOpacity(0.3)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? (status == 'online'
                                ? widget.accent.withOpacity(0.15)
                                : Colors.black.withOpacity(0.3))
                          : Colors.black.withOpacity(0.06),
                      blurRadius: isDark ? 24 : 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Status indicator with glow
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(
                                  isDark ? 0.6 : 0.4,
                                ),
                                blurRadius: isDark ? 12 : 8,
                                spreadRadius: isDark ? 2 : 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Bin info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: AppColors.textPrimary(context),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 14,
                                    color: AppColors.textSecondary(context),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.location,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: AppColors.textSecondary(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 14, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                statusLabel,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Alert badge with glow
                        if (widget.alertCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(
                                    isDark ? 0.5 : 0.3,
                                  ),
                                  blurRadius: isDark ? 12 : 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.warning_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${widget.alertCount}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(width: 8),

                        // 3-DOT MENU BUTTON
                        GestureDetector(
                          onTap: () {
                            _showStatusMenu(
                              context,
                              widget.binId,
                              status,
                              widget.accent,
                            );
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary(
                                context,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.more_vert_rounded,
                              color: AppColors.textSecondary(context),
                              size: 20,
                            ),
                          ),
                        ),

                        const SizedBox(width: 4),

                        // Expand icon
                        RotationTransition(
                          turns: _rotationAnimation,
                          child: Icon(
                            Icons.expand_more_rounded,
                            color: AppColors.textSecondary(context),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Expanded content
            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              child: expanded
                  ? Column(
                      children: [
                        // Live status card
                        LiveBinStatusCard(
                          binId: widget.binId,
                          accent: widget.accent,
                        ),
                        const SizedBox(height: 12),

                        // Alerts card
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    AlertsScreen(binId: widget.binId),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      final curved = CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      );
                                      return FadeTransition(
                                        opacity: curved,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 0.04),
                                            end: Offset.zero,
                                          ).animate(curved),
                                          child: child,
                                        ),
                                      );
                                    },
                              ),
                            );
                          },
                          child: _BinAlertsCard(
                            binId: widget.binId,
                            accent: widget.accent,
                            accentSoft: widget.accentSoft,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}

// BIN ALERTS CARD
class _BinAlertsCard extends StatelessWidget {
  final String binId;
  final Color accent;
  final Color accentSoft;

  const _BinAlertsCard({
    required this.binId,
    required this.accent,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<AlertModel>>(
      stream: firestoreService.getActiveAlerts(binId),
      builder: (context, snapshot) {
        final alerts = snapshot.data ?? [];

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentSoft, AppColors.surface(context)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? accent.withOpacity(0.15)
                    : Colors.black.withOpacity(0.06),
                blurRadius: isDark ? 20 : 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications_active_rounded, color: accent),
                  const SizedBox(width: 10),
                  Text(
                    "Alerts",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      "${alerts.length}",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: accent,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (alerts.isEmpty)
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: accent, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "No active alerts",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                )
              else
                ...alerts.take(5).map((a) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            a.message,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              if (alerts.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 14,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Tap to view all alerts",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// EMPTY STATE
class _EmptyState extends StatelessWidget {
  final Color accent;

  const _EmptyState({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2_outlined, size: 40, color: accent),
          ),
          const SizedBox(height: 20),
          Text(
            "No Bins Found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add your first bin to start monitoring",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

// Add these helper functions at the END of the bins_page.dart file (before the final closing brace):

// ================= STATUS CHANGE FUNCTIONS =================

void _showStatusMenu(
  BuildContext context,
  String binId,
  String currentStatus,
  Color accent,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary(context).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            "Change Bin Status",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            binId,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 24),

          // Status options
          _StatusOption(
            icon: Icons.check_circle_rounded,
            label: "Online",
            subtitle: "Bin is active and operational",
            color: accent,
            isSelected: currentStatus == 'online',
            onTap: () {
              Navigator.pop(context);
              if (currentStatus != 'online') {
                _showConfirmationDialog(context, binId, 'online', accent);
              }
            },
          ),
          const SizedBox(height: 12),
          _StatusOption(
            icon: Icons.build_circle_rounded,
            label: "Maintenance",
            subtitle: "Bin is under maintenance",
            color: Colors.amber.shade700,
            isSelected: currentStatus == 'maintenance',
            onTap: () {
              Navigator.pop(context);
              if (currentStatus != 'maintenance') {
                _showConfirmationDialog(context, binId, 'maintenance', accent);
              }
            },
          ),
          const SizedBox(height: 12),
          _StatusOption(
            icon: Icons.cancel_rounded,
            label: "Offline",
            subtitle: "Bin is not operational",
            color: Colors.grey,
            isSelected: currentStatus == 'offline',
            onTap: () {
              Navigator.pop(context);
              if (currentStatus != 'offline') {
                _showConfirmationDialog(context, binId, 'offline', accent);
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

void _showConfirmationDialog(
  BuildContext context,
  String binId,
  String newStatus,
  Color accent,
) {
  final statusInfo = _getStatusInfo(newStatus);

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
              color: statusInfo['color'].withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              statusInfo['icon'],
              color: statusInfo['color'],
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Confirm Status Change",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
      content: Text(
        "Set $binId to ${statusInfo['label']}?",
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
            await _updateBinStatus(context, binId, newStatus, accent);
          },
          child: Text(
            'Confirm',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: statusInfo['color'],
            ),
          ),
        ),
      ],
    ),
  );
}

Future<void> _updateBinStatus(
  BuildContext context,
  String binId,
  String newStatus,
  Color accent,
) async {
  final firestoreService = FirestoreService();

  // Show loading
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Updating status...",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: accent,
    ),
  );

  try {
    await firestoreService.updateBinStatus(binId, newStatus);

    // Show success
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Status updated to ${_getStatusInfo(newStatus)['label']}",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    // Show error
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_rounded, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Failed to update status",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}

Map<String, dynamic> _getStatusInfo(String status) {
  switch (status) {
    case 'online':
      return {
        'label': 'Online',
        'icon': Icons.check_circle_rounded,
        'color': const Color(0xFF14B8A6),
      };
    case 'maintenance':
      return {
        'label': 'Maintenance',
        'icon': Icons.build_circle_rounded,
        'color': Colors.amber.shade700,
      };
    case 'offline':
    default:
      return {
        'label': 'Offline',
        'icon': Icons.cancel_rounded,
        'color': Colors.grey,
      };
  }
}

// Status Option Widget
class _StatusOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : AppColors.background(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}

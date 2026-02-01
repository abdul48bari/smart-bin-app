import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/live_bin_status_card.dart';
import '../services/firestore_service.dart';
import '../models/alert.dart';
import '../screens/alerts_screen.dart';

class BinsPage extends StatelessWidget {
  const BinsPage({super.key});

  static const Color _accent = Color(0xFF0F766E);
  static const Color _accentSoft = Color(0xFFE6F4F1);
  static const Color _bg = Color(0xFFF6F8F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: _accent,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 450));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // =========================
              // HERO HEADER
              // =========================
              SliverToBoxAdapter(
                child: _HeroHeader(
                  accent: _accent,
                  accentSoft: _accentSoft,
                ),
              ),

              // =========================
              // SYSTEM HEALTH OVERVIEW
              // =========================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _SystemHealthCard(
                    accent: _accent,
                    accentSoft: _accentSoft,
                  ),
                ),
              ),

              // =========================
              // QUICK STATS
              // =========================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _QuickStatsRow(
                    accent: _accent,
                    accentSoft: _accentSoft,
                  ),
                ),
              ),

              // =========================
              // SECTION HEADER
              // =========================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Row(
                    children: [
                      Icon(Icons.storage_rounded, color: _accent, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        "All Bins",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('bins')
                            .snapshots(),
                        builder: (context, snapshot) {
                          final count = snapshot.data?.docs.length ?? 0;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _accentSoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              "$count",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: _accent,
                                fontSize: 13,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // =========================
              // BINS LIST
              // =========================
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                sliver: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance.collection('bins').snapshots(),
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
                        child: _EmptyState(accent: _accent),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
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
                                  status: data['status'] ?? 'offline',
                                  location: data['location'] ?? 'Unknown',
                                  alertCount: alertCount,
                                  accent: _accent,
                                  accentSoft: _accentSoft,
                                );
                              },
                            ),
                          );
                        },
                        childCount: bins.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================
// HERO HEADER
// =========================
class _HeroHeader extends StatelessWidget {
  final Color accent;
  final Color accentSoft;

  const _HeroHeader({
    required this.accent,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentSoft, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
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
                      color: accent.withOpacity(0.3),
                      blurRadius: 20,
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bins Management",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Monitor & control all bins",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
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

// =========================
// SYSTEM HEALTH CARD
// =========================
class _SystemHealthCard extends StatelessWidget {
  final Color accent;
  final Color accentSoft;

  const _SystemHealthCard({
    required this.accent,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bins').snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        int online = 0;
        int offline = 0;
        int maintenance = 0;
        int totalAlerts = 0;

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
                colors: [
                  accentSoft,
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
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
                            color: healthColor.withOpacity(0.3),
                            blurRadius: 16,
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
                          const Text(
                            "System Health",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
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
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black54,
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
        color: Colors.white,
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
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// =========================
// QUICK STATS ROW
// =========================
class _QuickStatsRow extends StatelessWidget {
  final Color accent;
  final Color accentSoft;

  const _QuickStatsRow({
    required this.accent,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bins').snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        int totalBins = docs.length;
        int totalAlerts = 0;

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
                  background: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: "Locations",
                  value: "${(totalBins * 0.7).round()}",
                  icon: Icons.location_on_rounded,
                  accent: accent,
                  background: accentSoft,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: "Capacity",
                  value: "${(totalBins * 85).round()}L",
                  icon: Icons.water_drop_rounded,
                  accent: accent,
                  background: Colors.white,
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// MODERN BIN CARD
// =========================
class _ModernBinCard extends StatefulWidget {
  final String binId;
  final String name;
  final String status;
  final String location;
  final int alertCount;
  final Color accent;
  final Color accentSoft;

  const _ModernBinCard({
    required this.binId,
    required this.name,
    required this.status,
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
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
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

  Color get statusColor {
    switch (widget.status) {
      case 'online':
        return widget.accent;
      case 'maintenance':
        return Colors.amber.shade700;
      default:
        return Colors.grey;
    }
  }

  String get statusLabel {
    switch (widget.status) {
      case 'online':
        return 'Active';
      case 'maintenance':
        return 'Maintenance';
      default:
        return 'Offline';
    }
  }

  IconData get statusIcon {
    switch (widget.status) {
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
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleExpanded,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  widget.alertCount > 0
                      ? Colors.redAccent.withOpacity(0.05)
                      : widget.status == 'online'
                          ? widget.accentSoft.withOpacity(0.3)
                          : Colors.grey.shade50,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.alertCount > 0
                    ? Colors.redAccent.withOpacity(0.2)
                    : Colors.transparent,
                width: 1.5,
              ),
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
                Row(
                  children: [
                    // Status indicator
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
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
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Colors.black,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: Colors.black45,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.location,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: Colors.black54,
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
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: 14,
                            color: statusColor,
                          ),
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

                    // Alert badge
                    if (widget.alertCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.3),
                              blurRadius: 8,
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

                    // Expand icon
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: Colors.black54,
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
                                (context, animation, secondaryAnimation, child) {
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
  }
}

// =========================
// BIN ALERTS CARD
// =========================
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

    return StreamBuilder<List<AlertModel>>(
      stream: firestoreService.getActiveAlerts(binId),
      builder: (context, snapshot) {
        final alerts = snapshot.data ?? [];

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accentSoft,
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
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
              Row(
                children: [
                  Icon(Icons.notifications_active_rounded, color: accent),
                  const SizedBox(width: 10),
                  const Text(
                    "Alerts",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                    Icon(
                      Icons.check_circle_rounded,
                      color: accent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "No active alerts",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
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
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              if (alerts.isNotEmpty) ...[
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 14,
                      color: Colors.black45,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Tap to view all alerts",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Colors.black45,
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

// =========================
// EMPTY STATE
// =========================
class _EmptyState extends StatelessWidget {
  final Color accent;

  const _EmptyState({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
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
            child: Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: accent,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Bins Found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add your first bin to start monitoring",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// =========================
// ANIMATED IN
// =========================
class _AnimatedIn extends StatefulWidget {
  final Widget child;
  final int delayMs;

  const _AnimatedIn({
    required this.child,
    this.delayMs = 0,
  });

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
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
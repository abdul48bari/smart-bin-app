import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/alert.dart';
import '../screens/alerts_screen.dart';
import '../widgets/live_bin_status_card.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String _binId = 'BIN_001';

  // Modern palette (teal)
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
            // Pull-to-refresh trigger for user feel (streams refresh anyway)
            await Future.delayed(const Duration(milliseconds: 450));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _TopHeader(
                  accent: _accent,
                  accentSoft: _accentSoft,
                ),
              ),

              // Quick stats row based on subBins stream
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _SectionTitle(
                    title: "Overview",
                    subtitle: "Live snapshot across all bins",
                    icon: Icons.dashboard_rounded,
                    accent: _accent,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _OverviewCards(
                    binId: _binId,
                    accent: _accent,
                    accentSoft: _accentSoft,
                  ),
                ),
              ),
              SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: _BinsSystemOverviewCard(
      accent: _accent,
      accentSoft: _accentSoft,
    ),
  ),
),


              

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: _SectionTitle(
                    title: "Alerts",
                    subtitle: "Latest notifications & events",
                    icon: Icons.warning_amber_rounded,
                    accent: _accent,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _AlertsPreviewCard(
                    binId: _binId,
                    accent: _accent,
                    accentSoft: _accentSoft,
                  ),
                ),
              ),

              // Fill the “empty” feel: Quick actions + Insights
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: _SectionTitle(
                    title: "Quick Actions",
                    subtitle: "Fast controls for demo use",
                    icon: Icons.bolt_rounded,
                    accent: _accent,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _QuickActionsRow(
                    accent: _accent,
                    accentSoft: _accentSoft,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: _SectionTitle(
                    title: "Insights",
                    subtitle: "",
                    icon: Icons.insights_rounded,
                    accent: _accent,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: _InsightsCard(
                    accent: _accent,
                    accentSoft: _accentSoft,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* =========================
   TOP HEADER
   ========================= */

class _TopHeader extends StatelessWidget {
  final Color accent;
  final Color accentSoft;

  const _TopHeader({
    required this.accent,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Subtle gradient makes it feel modern instantly
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentSoft,
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          // App “logo” bubble (no assets needed)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.recycling_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Smart Bin",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Dashboard",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          // Right side chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_done_rounded, size: 18, color: accent),
                const SizedBox(width: 6),
                const Text(
                  "Online",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
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

/* =========================
   SECTION TITLE
   ========================= */

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: accent),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/* =========================
   OVERVIEW CARDS (fills empty feel)
   ========================= */

class _OverviewCards extends StatelessWidget {
  final String binId;
  final Color accent;
  final Color accentSoft;

  const _OverviewCards({
    required this.binId,
    required this.accent,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bins')
          .doc(binId)
          .collection('subBins')
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        int maxFill = 0;
        int fullCount = 0;

        for (final d in docs) {
          final data = d.data() as Map<String, dynamic>;
          final int fill = (data['currentFillPercent'] ?? 0).toInt();
          maxFill = fill > maxFill ? fill : maxFill;
          if ((data['isFull'] ?? false) == true || fill >= 100) fullCount++;
        }

        return _AnimatedIn(
          delayMs: 60,
          child: Row(
            children: [
              Expanded(
                child: _MiniCard(
                  title: "Peak Fill",
                  value: "$maxFill%",
                  icon: Icons.stacked_line_chart_rounded,
                  accent: accent,
                  background: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniCard(
                  title: "Full Sub-bins",
                  value: "$fullCount",
                  icon: Icons.error_rounded,
                  accent: accent,
                  background: accentSoft,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniCard(
                  title: "Status",
                  value: docs.isEmpty ? "—" : "LIVE",
                  icon: Icons.sensors_rounded,
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

class _MiniCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final Color background;

  const _MiniCard({
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
          Icon(icon, color: accent),
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





/* =========================
   ALERTS PREVIEW CARD
   ========================= */

class _AlertsPreviewCard extends StatelessWidget {
  final String binId;
  final Color accent;
  final Color accentSoft;

  const _AlertsPreviewCard({
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

        return _AnimatedIn(
          delayMs: 180,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (_, __, ___) => AlertsScreen(binId: binId),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: accentSoft,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
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
                      const SizedBox(width: 8),
                      const Text(
                        "ALERTS",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          "${alerts.length}",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (alerts.isEmpty)
                    const Text(
                      "No alerts to show",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    )
                  else
                    ...alerts.take(3).map((alert) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                alert.message,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 2),
                  const Text(
                    "Tap to view all alerts",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/* QUICK ACTIONS (fills empty feel)*/

class _QuickActionsRow extends StatelessWidget {
  final Color accent;
  final Color accentSoft;

  const _QuickActionsRow({
    required this.accent,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedIn(
      delayMs: 220,
      child: Row(
        children: [
          Expanded(
            child: _ActionTile(
              title: "Simulate Full",
              subtitle: "BIN_FULL",
              icon: Icons.error_rounded,
              accent: accent,
              background: Colors.white,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Use your curl BIN_FULL test to simulate.")),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionTile(
              title: "Simulate Level",
              subtitle: "LEVEL_UPDATE",
              icon: Icons.tune_rounded,
              accent: accent,
              background: Colors.white,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Use your curl LEVEL_UPDATE test to simulate.")),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionTile(
              title: "Reset",
              subtitle: "BIN_EMPTIED",
              icon: Icons.restart_alt_rounded,
              accent: accent,
              background: Colors.white,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Use your curl BIN_EMPTIED test to simulate.")),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color background;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
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
            Icon(icon, color: accent),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.black,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*INSIGHTS CARD*/

class _InsightsCard extends StatelessWidget {
  final Color accent;
  final Color accentSoft;

  const _InsightsCard({
    required this.accent,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedIn(
      delayMs: 260,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.lightbulb_rounded, color: accent),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Tip: Keep an eye on sub-bins above 50% (yellow). "
                "Once it reaches 100% (red), a BIN_FULL alert is generated.",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



/*SIMPLE ENTRY ANIMATION*/

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

/* =========================
   BINS SYSTEM OVERVIEW CARD
   ========================= */

class _BinsSystemOverviewCard extends StatelessWidget {
  final Color accent;
  final Color accentSoft;

  const _BinsSystemOverviewCard({
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

        return _AnimatedIn(
          delayMs: 140,
          child: Container(
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
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Bins Overview",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _MiniStatusBox(
                        label: "Active",
                        value: online,
                        icon: Icons.cloud_done_rounded,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniStatusBox(
                        label: "Offline",
                        value: offline,
                        icon: Icons.cloud_off_rounded,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniStatusBox(
                        label: "Maintenance",
                        value: maintenance,
                        icon: Icons.build_rounded,
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

class _MiniStatusBox extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _MiniStatusBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
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



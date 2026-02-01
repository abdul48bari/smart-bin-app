import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/alert.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            await Future.delayed(const Duration(milliseconds: 450));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // HERO HEADER
              SliverToBoxAdapter(
                child: _TopHeader(
                  accent: _accent,
                  accentSoft: _accentSoft,
                ),
              ),

              // OVERVIEW SECTION
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _SectionTitle(
                    title: "Overview",
                    subtitle: "Quick system snapshot",
                    icon: Icons.dashboard_rounded,
                    accent: _accent,
                  ),
                ),
              ),

              // OVERVIEW CARDS (ALL BINS)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _OverviewCards(
                    accent: _accent,
                    accentSoft: _accentSoft,
                  ),
                ),
              ),

              // SYSTEM STATUS
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _BinsSystemOverviewCard(
                    accent: _accent,
                    accentSoft: _accentSoft,
                  ),
                ),
              ),

              // WEEKLY ACTIVITY CHART
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _SectionTitle(
                    title: "Activity",
                    subtitle: "Past 7 days trend",
                    icon: Icons.trending_up_rounded,
                    accent: _accent,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _WeeklyActivityCard(
                    accent: _accent,
                    accentSoft: _accentSoft,
                  ),
                ),
              ),

              // COLLECTION SCHEDULE
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _CollectionScheduleCard(
                    accent: _accent,
                    accentSoft: _accentSoft,
                  ),
                ),
              ),

              // ALERTS SECTION (ALL BINS - EXPANDABLE)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: _SectionTitle(
                    title: "Alerts",
                    subtitle: "All bins combined",
                    icon: Icons.notifications_active_rounded,
                    accent: _accent,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _AllBinsAlertsCard(
                    accent: _accent,
                    accentSoft: _accentSoft,
                  ),
                ),
              ),

              // QUICK ACTIONS
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: _SectionTitle(
                    title: "Quick Actions",
                    subtitle: "Simulate bin events",
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

              // INSIGHTS
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: _SectionTitle(
                    title: "Insights",
                    subtitle: "Smart recommendations",
                    icon: Icons.lightbulb_rounded,
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

// HERO HEADER
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentSoft, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
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
                  color: accent.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.recycling_rounded,
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
                  "Smart Bin",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 3),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                    fontSize: 13,
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

// SECTION TITLE
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
        Icon(icon, color: accent, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
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
            ],
          ),
        ),
      ],
    );
  }
}

// OVERVIEW CARDS - UPDATED FOR ALL BINS
class _OverviewCards extends StatelessWidget {
  final Color accent;
  final Color accentSoft;

  const _OverviewCards({
    required this.accent,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bins').snapshots(),
      builder: (context, binsSnapshot) {
        if (!binsSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        final bins = binsSnapshot.data!.docs;
        int maxFill = 0;
        int fullCount = 0;

        // Create a list of futures to get all subBins
        return FutureBuilder<List<QuerySnapshot>>(
          future: Future.wait(
            bins.map((bin) => FirebaseFirestore.instance
                .collection('bins')
                .doc(bin.id)
                .collection('subBins')
                .get()).toList(),
          ),
          builder: (context, subBinsSnapshot) {
            if (subBinsSnapshot.hasData) {
              for (final snapshot in subBinsSnapshot.data!) {
                for (final doc in snapshot.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final int fill = (data['currentFillPercent'] ?? 0).toInt();
                  maxFill = fill > maxFill ? fill : maxFill;
                  if ((data['isFull'] ?? false) == true || fill >= 100) {
                    fullCount++;
                  }
                }
              }
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
                      title: "Full Bins",
                      value: "$fullCount",
                      icon: Icons.error_rounded,
                      accent: fullCount > 0 ? Colors.redAccent : accent,
                      background: fullCount > 0 ? Colors.red.shade50 : accentSoft,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniCard(
                      title: "Total Bins",
                      value: "${bins.length}",
                      icon: Icons.storage_rounded,
                      accent: accent,
                      background: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
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
          Icon(icon, color: accent, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// Continue in next message...

// BINS SYSTEM OVERVIEW CARD
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
          delayMs: 100,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentSoft, Colors.white],
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "System Overview",
                        style: TextStyle(
                          fontSize: 18,
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
                        icon: Icons.check_circle_rounded,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniStatusBox(
                        label: "Offline",
                        value: offline,
                        icon: Icons.cancel_rounded,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniStatusBox(
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
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
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// WEEKLY ACTIVITY CARD
class _WeeklyActivityCard extends StatelessWidget {
  final Color accent;
  final Color accentSoft;

  const _WeeklyActivityCard({
    required this.accent,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<Map<String, int>>(
      stream: firestoreService.getFullCountsPerSubBin('BIN_001'),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};
        final total = data.values.fold(0, (sum, count) => sum + count);

        final dailyCounts = _generateDemoCounts(total);
        final maxCount = dailyCounts.isEmpty || dailyCounts.reduce((a, b) => a > b ? a : b) == 0
            ? 1
            : dailyCounts.reduce((a, b) => a > b ? a : b);

        return _AnimatedIn(
          delayMs: 140,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accentSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.show_chart_rounded,
                        color: accent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Activity",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Total BIN_FULL events",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "$total",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: accent,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final count = dailyCounts[index];
                    final percentage = maxCount > 0 ? count / maxCount : 0.0;
                    final height = 60.0 * percentage.clamp(0.15, 1.0);

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: height),
                              duration: Duration(milliseconds: 600 + (index * 50)),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Container(
                                  height: value,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [accent, accent.withOpacity(0.6)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<int> _generateDemoCounts(int total) {
    if (total == 0) return List.filled(7, 0);
    final base = total ~/ 10;
    return [
      base + 2,
      base + 3,
      base + 1,
      base + 2,
      base + 1,
      base,
      base,
    ];
  }
}

// COLLECTION SCHEDULE CARD
class _CollectionScheduleCard extends StatelessWidget {
  final Color accent;
  final Color accentSoft;

  const _CollectionScheduleCard({
    required this.accent,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    DateTime nextCollection;

    if (now.weekday < 1) {
      nextCollection = now.add(Duration(days: 1 - now.weekday));
    } else if (now.weekday < 4) {
      nextCollection = now.add(Duration(days: 4 - now.weekday));
    } else {
      nextCollection = now.add(Duration(days: 8 - now.weekday));
    }

    final daysUntil = nextCollection.difference(now).inDays;

    return _AnimatedIn(
      delayMs: 180,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFEF3C7), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.amber.shade600,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.shade600.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_shipping_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Next Collection",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    daysUntil == 0
                        ? "Today"
                        : daysUntil == 1
                            ? "Tomorrow"
                            : "In $daysUntil days",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.amber.shade700,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][nextCollection.weekday - 1]}, ${nextCollection.day}/${nextCollection.month}",
                    style: const TextStyle(
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
      ),
    );
  }
}

// ALL BINS ALERTS CARD - NEW EXPANDABLE VERSION
class _AllBinsAlertsCard extends StatelessWidget {
  final Color accent;
  final Color accentSoft;

  const _AllBinsAlertsCard({
    required this.accent,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bins').snapshots(),
      builder: (context, binsSnapshot) {
        if (!binsSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        final bins = binsSnapshot.data!.docs;

        return _AnimatedIn(
          delayMs: 220,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentSoft, Colors.white],
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Active Alerts",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (bins.isEmpty)
                  Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: accent, size: 20),
                      const SizedBox(width: 10),
                      const Text(
                        "No bins configured",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  )
                else
                  ...bins.map((bin) => _BinAlertsExpansionTile(
                        binId: bin.id,
                        accent: accent,
                        accentSoft: accentSoft,
                      )),
              ],
            ),
          ),
        );
      },
    );
  }
}

// BIN ALERTS EXPANSION TILE
class _BinAlertsExpansionTile extends StatefulWidget {
  final String binId;
  final Color accent;
  final Color accentSoft;

  const _BinAlertsExpansionTile({
    required this.binId,
    required this.accent,
    required this.accentSoft,
  });

  @override
  State<_BinAlertsExpansionTile> createState() => _BinAlertsExpansionTileState();
}

class _BinAlertsExpansionTileState extends State<_BinAlertsExpansionTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<List<AlertModel>>(
      stream: firestoreService.getActiveAlerts(widget.binId),
      builder: (context, snapshot) {
        final alerts = snapshot.data ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                // Header (always visible)
                InkWell(
                  onTap: _toggleExpanded,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: widget.accentSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.delete_rounded,
                            color: widget.accent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.binId,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${alerts.length} alert${alerts.length != 1 ? 's' : ''}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: alerts.isEmpty ? widget.accentSoft : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${alerts.length}",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: alerts.isEmpty ? widget.accent : Colors.redAccent,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Icon(
                            Icons.expand_more,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Expandable content with animation
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  axisAlignment: -1,
                  child: Container(
                    color: widget.accentSoft.withOpacity(0.3),
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                    child: alerts.isEmpty
                        ? Row(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: widget.accent, size: 18),
                              const SizedBox(width: 8),
                              const Text(
                                "No active alerts",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: alerts.take(5).map((alert) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.redAccent,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        alert.message,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// QUICK ACTIONS ROW
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
      delayMs: 260,
      child: Row(
        children: [
          Expanded(
            child: _ActionTile(
              title: "Full",
              subtitle: "Simulate",
              icon: Icons.error_rounded,
              accent: accent,
              background: Colors.white,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Use BIN_FULL curl command"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionTile(
              title: "Level",
              subtitle: "Update",
              icon: Icons.tune_rounded,
              accent: accent,
              background: Colors.white,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Use LEVEL_UPDATE curl command"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionTile(
              title: "Reset",
              subtitle: "Empty",
              icon: Icons.restart_alt_rounded,
              accent: accent,
              background: Colors.white,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Use BIN_EMPTIED curl command"),
                    duration: Duration(seconds: 2),
                  ),
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
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
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
            Icon(icon, color: accent, size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
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

// INSIGHTS CARD
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
      delayMs: 300,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.lightbulb_rounded, color: accent, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                "Check the Bins tab for detailed fill levels. Visit Analytics for waste patterns and trends.",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ),
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
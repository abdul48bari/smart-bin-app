import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/time_filter.dart';
import '../widgets/horizontal_bar_chart.dart';
import '../widgets/vertical_bar_chart.dart';
import '../utils/app_colors.dart';
import '../utils/shadows.dart';
import '../widgets/clean_container.dart';
import '../providers/app_state_provider.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  static const String _binId = 'BIN_001';

  TimeFilter _selectedFilter = TimeFilter.day;

  // Sub-bin colors — kept in sync with AppColors.subBinColors
  static const Map<String, Color> _subBinColors = {
    'plastic': Color(0xFFE8703A), // Orange
    'paper': Color(0xFF4E80EE),   // Blue
    'organic': Color(0xFFD4A017), // Yellow
    'cans': Color(0xFF6B7280),    // Gray
    'mixed': Color(0xFF8B5CF6),   // Purple
  };

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
            await Future.delayed(const Duration(milliseconds: 1500));
            setState(() {});
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // HERO HEADER
              SliverToBoxAdapter(
                child: _HeroHeader(accent: accent, accentSoft: accentSoft),
              ),

              // TIME FILTER CHIPS
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _TimeFilterChips(
                    selectedFilter: _selectedFilter,
                    onFilterChanged: (filter) {
                      setState(() => _selectedFilter = filter);
                    },
                    accent: accent,
                    accentSoft: accentSoft,
                  ),
                ),
              ),

              // TOTAL PIECES COLLECTED (HERO METRIC)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _TotalPiecesCard(
                    binId: _binId,
                    filter: _selectedFilter,
                    accent: accent,
                    accentSoft: accentSoft,
                  ),
                ),
              ),

              // COMBINED SECTION LABEL
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Row(
                    children: [
                      Icon(Icons.layers_rounded, color: accent, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "All Bins Combined",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: accent,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // PIECES BY TYPE (combined)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: _PiecesBreakdownCard(
                    binId: _binId,
                    filter: _selectedFilter,
                    accent: accent,
                    accentSoft: accentSoft,
                    colors: _subBinColors,
                  ),
                ),
              ),

              // PER-BIN SECTION LABEL
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: accent, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "Individual Bin Breakdown",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: accent,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // PER-BIN PIECES COLLECTED
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: _PerBinPiecesSection(
                    filter: _selectedFilter,
                    accent: accent,
                    accentSoft: accentSoft,
                    colors: _subBinColors,
                  ),
                ),
              ),

              // QUICK STATS
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _QuickStatsRow(
                    binId: _binId,
                    filter: _selectedFilter,
                    accent: accent,
                    accentSoft: accentSoft,
                  ),
                ),
              ),

              // BIN FULL EVENTS
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _BinFullEventsCard(
                    binId: _binId,
                    filter: _selectedFilter,
                    accent: accent,
                    colors: _subBinColors,
                  ),
                ),
              ),

              // ENVIRONMENTAL IMPACT
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Consumer<AppStateProvider>(
                    builder: (context, appState, _) {
                      return StreamBuilder<dynamic>(
                        stream: appState.isDemoMode
                            ? appState.binsStream
                            : FirebaseFirestore.instance
                                  .collection('bins')
                                  .doc(_binId)
                                  .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              height: 100,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          // Simplified check for demo purposes
                          final hasContent = appState.isDemoMode
                              ? (snapshot.data as QuerySnapshot).docs.isNotEmpty
                              : (snapshot.data as DocumentSnapshot).exists;

                          if (!hasContent) return const SizedBox.shrink();

                          return _EnvironmentalImpactCard(
                            binId: _binId,
                            filter: _selectedFilter,
                            accent: accent,
                            accentSoft: accentSoft,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // TOP PERFORMERS
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: _TopPerformersCard(
                    binId: _binId,
                    filter: _selectedFilter,
                    accent: accent,
                    colors: _subBinColors,
                  ),
                ),
              ),

              // Bottom padding
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

    return CleanContainer(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      elevation: 'medium',
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha:isDark ? 0.3 : 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Analytics",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Waste collection insights",
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
    );
  }
}

// TIME FILTER CHIPS
class _TimeFilterChips extends StatelessWidget {
  final TimeFilter selectedFilter;
  final Function(TimeFilter) onFilterChanged;
  final Color accent;
  final Color accentSoft;

  const _TimeFilterChips({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.accent,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedIn(
      delayMs: 50,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.elevation(context, 'medium'),
        ),
        child: Row(
          children: TimeFilter.values.map((filter) {
            final isSelected = selectedFilter == filter;
            final label = filter == TimeFilter.day
                ? '24 Hrs'
                : filter == TimeFilter.week
                ? '7 Days'
                : '30 Days';

            return Expanded(
              child: GestureDetector(
                onTap: () => onFilterChanged(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? accentSoft : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? accent
                          : AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// TOTAL PIECES COLLECTED CARD (HERO)
class _TotalPiecesCard extends StatelessWidget {
  final String binId;
  final TimeFilter filter;
  final Color accent;
  final Color accentSoft;

  const _TotalPiecesCard({
    required this.binId,
    required this.filter,
    required this.accent,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<Map<String, int>>(
      stream: firestoreService.getAllBinsPieceCount(filter),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};
        final total = data.values.fold(0, (acc, n) => acc + n);

        return _AnimatedIn(
          delayMs: 100,
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentSoft, AppColors.surface(context)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border(context), width: 1.5),
              boxShadow: AppShadows.elevation(context, 'large'),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                        Icons.recycling_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Pieces Collected",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Across all bins combined",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary(
                                context,
                              ).withValues(alpha:0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: total),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Text(
                          "$value",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: accent,
                            letterSpacing: -2,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        "pieces",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary(context),
                        ),
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

// PIECES BREAKDOWN CARD (VERTICAL BARS)
class _PiecesBreakdownCard extends StatelessWidget {
  final String binId;
  final TimeFilter filter;
  final Color accent;
  final Color accentSoft;
  final Map<String, Color> colors;

  const _PiecesBreakdownCard({
    required this.binId,
    required this.filter,
    required this.accent,
    required this.accentSoft,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<Map<String, int>>(
      stream: firestoreService.getAllBinsPieceCount(filter),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};

        return _AnimatedIn(
          delayMs: 150,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.elevation(context, 'large'),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.category_rounded, color: accent),
                    const SizedBox(width: 10),
                    Text(
                      "Breakdown by Type",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                VerticalBarChart(data: data, colors: colors),
              ],
            ),
          ),
        );
      },
    );
  }
}

// BIN FULL EVENTS CARD (SECONDARY)
class _BinFullEventsCard extends StatelessWidget {
  final String binId;
  final TimeFilter filter;
  final Color accent;
  final Map<String, Color> colors;

  const _BinFullEventsCard({
    required this.binId,
    required this.filter,
    required this.accent,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<Map<String, int>>(
      stream: firestoreService.getFullCountsByTimeFilter(binId, filter),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};

        return _AnimatedIn(
          delayMs: 200,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.elevation(context, 'medium'),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: accent, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      "Full Events",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Times bins reached 100% capacity",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 16),
                HorizontalBarChart(data: data, colors: colors),
              ],
            ),
          ),
        );
      },
    );
  }
}

// QUICK STATS ROW
class _QuickStatsRow extends StatelessWidget {
  final String binId;
  final TimeFilter filter;
  final Color accent;
  final Color accentSoft;

  const _QuickStatsRow({
    required this.binId,
    required this.filter,
    required this.accent,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedIn(
      delayMs: 250,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bins').snapshots(),
        builder: (context, snapshot) {
          final totalBins = snapshot.data?.docs.length ?? 0;
          final activeBins =
              snapshot.data?.docs
                  .where((d) => (d.data() as Map)['status'] == 'online')
                  .length ??
              0;

          return Row(
            children: [
              Expanded(
                child: _MiniStatCard(
                  title: "Active Bins",
                  value: "$activeBins",
                  icon: Icons.check_circle_rounded,
                  color: accent,
                  background: accentSoft,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatCard(
                  title: "Total Bins",
                  value: "$totalBins",
                  icon: Icons.storage_rounded,
                  color: accent,
                  background: AppColors.surface(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatCard(
                  title: "Efficiency",
                  value: "94%",
                  icon: Icons.speed_rounded,
                  color: accent,
                  background: AppColors.surface(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.elevation(context, 'medium'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ENVIRONMENTAL IMPACT CARD
class _EnvironmentalImpactCard extends StatelessWidget {
  final String binId;
  final TimeFilter filter;
  final Color accent;
  final Color accentSoft;

  const _EnvironmentalImpactCard({
    required this.binId,
    required this.filter,
    required this.accent,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<Map<String, int>>(
      stream: firestoreService.getAllBinsPieceCount(filter),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};
        final total = data.values.fold(0, (acc, n) => acc + n);

        // Estimate: avg 50g per piece
        final estimatedKg = (total * 0.05).round();

        return _AnimatedIn(
          delayMs: 300,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1A3A2A), AppColors.surface(context)]
                    : [const Color(0xFFD1FAE5), AppColors.surface(context)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border(context), width: 1.5),
              boxShadow: AppShadows.elevation(context, 'large'),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha:isDark ? 0.3 : 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Environmental Impact",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TweenAnimationBuilder<int>(
                            tween: IntTween(begin: 0, end: estimatedKg),
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Text(
                                "~$value",
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF10B981),
                                  letterSpacing: -1,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              "kg sorted",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

// TOP PERFORMERS CARD
class _TopPerformersCard extends StatelessWidget {
  final String binId;
  final TimeFilter filter;
  final Color accent;
  final Map<String, Color> colors;

  const _TopPerformersCard({
    required this.binId,
    required this.filter,
    required this.accent,
    required this.colors,
  });

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'plastic':
        return Icons.local_drink_rounded;
      case 'paper':
        return Icons.description_rounded;
      case 'organic':
        return Icons.eco_rounded;
      case 'cans':
        return Icons.local_cafe_rounded;
      default:
        return Icons.layers_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<Map<String, int>>(
      stream: firestoreService.getAllBinsPieceCount(filter),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};

        // Sort by count descending
        final sorted = data.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final topThree = sorted.take(3).toList();

        return _AnimatedIn(
          delayMs: 350,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.elevation(context, 'large'),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events_rounded, color: accent),
                    const SizedBox(width: 10),
                    Text(
                      "Top Collected",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (topThree.isEmpty)
                  Text(
                    "No data yet",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary(context),
                    ),
                  )
                else
                  ...topThree.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final type = item.key;
                    final count = item.value;
                    final color = colors[type] ?? accent;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha:0.08),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(_getIcon(type), color: color),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                          ),
                          Text(
                            "$count pieces",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}

// PER-BIN PIECES SECTION
class _PerBinPiecesSection extends StatefulWidget {
  final TimeFilter filter;
  final Color accent;
  final Color accentSoft;
  final Map<String, Color> colors;

  const _PerBinPiecesSection({
    required this.filter,
    required this.accent,
    required this.accentSoft,
    required this.colors,
  });

  @override
  State<_PerBinPiecesSection> createState() => _PerBinPiecesSectionState();
}

class _PerBinPiecesSectionState extends State<_PerBinPiecesSection> {
  String? _selectedBinId;

  String _shortBinName(String name) {
    if (name.length <= 12) return name;
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0]} ${parts[1][0]}.';
    return name.substring(0, 10);
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        return StreamBuilder<QuerySnapshot>(
          stream: appState.binsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();

            final bins = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'id': doc.id,
                'name': (data['name'] as String?) ?? doc.id,
              };
            }).toList();

            if (bins.isEmpty) return const SizedBox.shrink();

            // Default to first bin
            _selectedBinId ??= bins.first['id'] as String;

            return _AnimatedIn(
              delayMs: 120,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppShadows.elevation(context, 'large'),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, color: widget.accent),
                        const SizedBox(width: 10),
                        Text(
                          "Pieces by Bin",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Pieces collected per individual bin",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Bin selector chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: bins.map((bin) {
                          final id = bin['id'] as String;
                          final name = bin['name'] as String;
                          final isSelected = _selectedBinId == id;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedBinId = id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? widget.accent : AppColors.surfaceSecondary(context),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _shortBinName(name),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : AppColors.textSecondary(context),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Chart or no-data for selected bin
                    StreamBuilder<Map<String, int>?>(
                      stream: firestoreService.getPerBinPieceCount(
                        _selectedBinId!,
                        widget.filter,
                      ),
                      builder: (context, pieceSnapshot) {
                        if (!pieceSnapshot.hasData && pieceSnapshot.connectionState == ConnectionState.waiting) {
                          return SizedBox(
                            height: 80,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: widget.accent,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }

                        final data = pieceSnapshot.data;

                        if (data == null || data.values.every((v) => v == 0)) {
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 28),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSecondary(context),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.hourglass_empty_rounded,
                                    size: 32,
                                    color: AppColors.textSecondary(context),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "No data available yet",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary(context),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "This bin hasn't recorded any\npiece collection events",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary(context).withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Show total for this bin
                        final total = data.values.fold(0, (a, b) => a + b);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                TweenAnimationBuilder<int>(
                                  tween: IntTween(begin: 0, end: total),
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, _) => Text(
                                    "$value pieces",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: widget.accent,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                Text(
                                  " total",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            VerticalBarChart(data: data, colors: widget.colors),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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

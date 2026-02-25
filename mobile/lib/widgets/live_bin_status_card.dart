import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';

class LiveBinStatusCard extends StatelessWidget {
  final String binId;
  final Color accent;

  const LiveBinStatusCard({
    super.key,
    required this.binId,
    required this.accent,
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
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _EmptyCard(
            title: "No sub-bin data",
            subtitle: "Waiting for live updates",
            icon: Icons.hourglass_empty_rounded,
            accent: accent,
          );
        }

        return _LiveBinStatusCard(
          docs: snapshot.data!.docs,
          accent: accent,
        );
      },
    );
  }
}

/* =========================
   LIVE BIN STATUS CARD UI
   ========================= */

class _LiveBinStatusCard extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  final Color accent;

  const _LiveBinStatusCard({
    required this.docs,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? accent.withOpacity(0.15)
                : Colors.black.withOpacity(0.08),
            blurRadius: isDark ? 20 : 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "BIN STATUS",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary(context),
                ),
              ),
              _LiveBadge(accent: accent),
            ],
          ),
          const SizedBox(height: 14),

          ...docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final int fillPercent =
                (data['currentFillPercent'] ?? 0).toInt();

            return _SubBinRow(
              label: doc.id,
              fillPercent: fillPercent,
              accent: accent,
            );
          }).toList(),
        ],
      ),
    );
  }
}

/* =========================
   SUB BIN ROW
   ========================= */

class _SubBinRow extends StatelessWidget {
  final String label;
  final int fillPercent;
  final Color accent;

  const _SubBinRow({
    required this.label,
    required this.fillPercent,
    required this.accent,
  });

  Color _getFillColor(int percent) {
    if (percent >= 100) return Colors.redAccent;
    if (percent >= 50) return Colors.amber;
    return Colors.green;
  }

  IconData _getIcon(String id) {
    switch (id.toLowerCase()) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double percent = (fillPercent / 100).clamp(0.0, 1.0);
    final Color barColor = _getFillColor(fillPercent);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_getIcon(label), color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      "$fillPercent%",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 12,
                    color: isDark 
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.shade200,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 650),
                          curve: Curves.easeOutCubic,
                          width: constraints.maxWidth * percent,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: isDark ? [
                              BoxShadow(
                                color: barColor.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ] : null,
                          ),
                        );
                      },
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

/* =========================
   LIVE BADGE
   ========================= */

class _LiveBadge extends StatelessWidget {
  final Color accent;

  const _LiveBadge({required this.accent});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isDark 
            ? accent.withOpacity(0.2)
            : const Color(0xFFE6F4F1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: isDark ? [
                BoxShadow(
                  color: accent.withOpacity(0.6),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ] : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            "LIVE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================
   EMPTY CARD
   ========================= */

class _EmptyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const _EmptyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
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
          Icon(icon, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
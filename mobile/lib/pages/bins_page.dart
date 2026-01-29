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
        child: Column(
          children: [
            // =========================
            // HEADER (EXACT HOME STYLE)
            // =========================
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_accentSoft, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _accent.withOpacity(0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bins",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "System-wide bin monitoring",
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
            ),

            // =========================
            // PAGE CONTENT
            // =========================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // =========================
                    // SUMMARY CARDS (HOME STYLE)
                    // =========================
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('bins')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        int online = 0;
                        int offline = 0;

                        for (final d in snapshot.data!.docs) {
                          final data =
                              d.data() as Map<String, dynamic>? ?? {};
                          if (data['status'] == 'online') {
                            online++;
                          } else {
                            offline++;
                          }
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: _SummaryCard(
                                title: "Online",
                                value: "$online",
                                icon: Icons.cloud_done_rounded,
                                accent: _accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryCard(
                                title: "Offline",
                                value: "$offline",
                                icon: Icons.cloud_off_rounded,
                                accent: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryCard(
                                title: "Health",
                                value: online > 0 ? "GOOD" : "—",
                                icon: Icons.favorite_rounded,
                                accent: _accent,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // =========================
                    // SYSTEM INFO / FILLER CARD
                    // =========================
                    Container(
                      padding: const EdgeInsets.all(16),
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
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _accentSoft,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: _accent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Tap any bin to view live fill levels and alerts. "
                              "Bins marked offline are currently inactive.",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =========================
                    // BINS LIST
                    // =========================
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('bins')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final bins = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: bins.length,
                            itemBuilder: (context, index) {
                              final bin = bins[index];
                              final data =
                                  bin.data() as Map<String, dynamic>? ?? {};
                              final bool online =
                                  data['status'] == 'online';

                              return StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('bins')
                                    .doc(bin.id)
                                    .collection('alerts')
                                    .where('resolved', isEqualTo: false)
                                    .snapshots(),
                                builder: (context, alertSnap) {
                                  final alertCount =
                                      alertSnap.data?.docs.length ?? 0;

                                  return _ExpandableBinCard(
                                    binId: bin.id,
                                    name: data['name'] ?? bin.id,
                                    online: online,
                                    alertCount: alertCount,
                                    accent: _accent,
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// SUMMARY CARD (HOME STYLE)
// =========================
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withOpacity(0.12),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// EXPANDABLE BIN CARD
// =========================
class _ExpandableBinCard extends StatefulWidget {
  final String binId;
  final String name;
  final bool online;
  final int alertCount;
  final Color accent;

  const _ExpandableBinCard({
    required this.binId,
    required this.name,
    required this.online,
    required this.alertCount,
    required this.accent,
  });

  @override
  State<_ExpandableBinCard> createState() => _ExpandableBinCardState();
}

class _ExpandableBinCardState extends State<_ExpandableBinCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  widget.alertCount > 0
                      ? Colors.redAccent.withOpacity(0.08)
                      : widget.online
                          ? const Color(0xFFE6F4F1)
                          : Colors.grey.shade100,
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
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color:
                        widget.online ? widget.accent : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.online ? "Online" : "Offline",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: widget.online
                              ? widget.accent
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (widget.alertCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          "${widget.alertCount}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Icon(
                      expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        AnimatedCrossFade(
          duration: const Duration(milliseconds: 280),
          crossFadeState: expanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Column(
            children: [
              LiveBinStatusCard(
                binId: widget.binId,
                accent: widget.accent,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AlertsScreen(binId: widget.binId),
                    ),
                  );
                },
                child: _BinAlertsCard(binId: widget.binId),
              ),
              const SizedBox(height: 12),
            ],
          ),
          secondChild: const SizedBox.shrink(),
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

  const _BinAlertsCard({required this.binId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<List<AlertModel>>(
      stream: firestoreService.getActiveAlerts(binId),
      builder: (context, snapshot) {
        final alerts = snapshot.data ?? [];

        return Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Alerts",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              if (alerts.isEmpty)
                const Text(
                  "No active alerts",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                )
              else
                ...alerts.take(5).map((a) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
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
            ],
          ),
        );
      },
    );
  }
}

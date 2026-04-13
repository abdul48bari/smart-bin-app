import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_state_provider.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../utils/shadows.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data helpers
// ─────────────────────────────────────────────────────────────────────────────

class _SuggestionItem {
  final String binId;
  final String binName;
  final String location;
  final String wasteType;
  final int fillLevel;

  const _SuggestionItem({
    required this.binId,
    required this.binName,
    required this.location,
    required this.wasteType,
    required this.fillLevel,
  });
}

// Multiple tip sets per waste type — rotated on each refresh.
// Content aligned with UAE Circular Economy Policy 2021–2031, COP28
// commitments, and UN Sustainable Development Goals (SDGs).
const Map<String, List<List<String>>> _recyclingTipSets = {
  'plastic': [
    [
      'UAE banned single-use plastics in 2024 — switch to reusable bottles and bags to support the Clean Emirates initiative.',
      'Drop clean PET bottles at EEG (Emirates Environmental Group) monthly collection drives across Dubai, Abu Dhabi & Sharjah.',
      'Shredded plastic bottles can be recycled into polyester fibre — fuelling UAE\'s growing sustainable fashion industry.',
    ],
    [
      'Clean plastic containers repurposed as seedling pots support UAE\'s urban greening and food security goals.',
      'Plastic waste processed into 3D printer filament is being used in UAE makerspaces and university STEM labs.',
      'Plastic bottles packed with compressed non-recyclable waste (eco-bricks) are used in low-cost eco-construction projects globally.',
    ],
    [
      'UN SDG 12 (Responsible Consumption) calls for a 50% cut in plastic waste by 2030 — start by refusing single-use plastics.',
      'Supermarkets in Dubai and Abu Dhabi have plastic film drop-off points — collect bags and wrap and take them monthly.',
      'Recycling 1 tonne of plastic saves 5,774 kWh of energy — enough to power a UAE household for over 6 months.',
    ],
  ],
  'paper': [
    [
      'EEG\'s Paper Chase campaign collects newspapers and cardboard at schools and malls — check eegobalance.com for dates.',
      'UAE offices can register with Bee\'ah or Tadweer for free paper and cardboard collection — reducing landfill pressure.',
      'Shredded office paper is an ideal compost "brown" material, supporting UAE\'s organic waste diversion targets.',
    ],
    [
      'Rolled newspaper shaped into pots makes 100% biodegradable seed starters — no plastic trays needed.',
      'Layered cardboard used as garden mulch suppresses weeds, retains moisture, and breaks down into rich soil.',
      'Paper bags reused as gift wrap or packaging reduce the demand for virgin paper and plastic bubble wrap.',
    ],
    [
      'Recycling 1 tonne of paper saves 17 trees and 26,500 litres of water — vital in the UAE\'s water-scarce environment.',
      'The Paris Agreement supports global forest conservation — every sheet of paper recycled reduces deforestation pressure.',
      'UN SDG 15 (Life on Land) is directly supported by paper recycling — forests absorb 2.6 billion tonnes of CO₂ annually.',
    ],
  ],
  'organic': [
    [
      'UAE Food Bank redistributes surplus food free of charge — donate before it becomes waste and support zero-hunger goals.',
      'Tadweer (Abu Dhabi) runs community composting hubs that convert organic waste into agricultural-grade soil amendment.',
      'Dubai Municipality\'s food waste reduction campaign targets 50% less waste by 2030 — home composting is the first step.',
    ],
    [
      'Food scraps composted at home turn into nutrient-rich soil in just 8–12 weeks, perfect for UAE balcony gardens.',
      'Coffee grounds and used tea leaves applied directly around plants act as a slow-release nitrogen fertiliser.',
      'Vermicomposting (using worms) converts organic waste into premium fertiliser 4× faster than traditional composting.',
    ],
    [
      'Organic waste processed via anaerobic digestion produces biogas — a clean energy source aligned with UAE\'s net-zero 2050 target.',
      'UN SDG 2 (Zero Hunger) is supported by reducing food waste — meal planning and portion control are the simplest wins.',
      'Fruit and citrus peels soaked in white vinegar for two weeks create a natural, chemical-free all-purpose cleaner.',
    ],
  ],
  'cans': [
    [
      'Aluminum recycling uses 95% less energy than producing new metal — directly supporting UAE\'s energy efficiency strategy.',
      'Reverse vending machines by Enviroserve in UAE malls and campuses give reward points for returned aluminum cans.',
      'EEG\'s Metal Drive collects cans at schools and community events across the UAE — check their schedule at eeg.ae.',
    ],
    [
      'Clean tin cans make sturdy desk organisers, herb planters, or candle lanterns — zero cost, zero waste.',
      'Aluminum can be melted and recast indefinitely with no degradation in quality — true closed-loop recycling.',
      'Large food cans converted into rooftop herb planters support UAE\'s urban farming and food security initiatives.',
    ],
    [
      'The global aluminum recycling industry prevents over 100 million tonnes of CO₂ per year — equal to taking 20 million cars off the road.',
      'UN SDG 13 (Climate Action) is directly supported by metal recycling — landfilled metals leach toxins and generate methane.',
      'Recycling one aluminium can saves enough energy to run a laptop for 11 hours — scale that across your whole bin.',
    ],
  ],
  'mixed': [
    [
      'UAE\'s Tadweer provides free household sorting guides for Abu Dhabi residents — download at tadweer.ae.',
      'Dubai\'s smart bin network (grey, green, blue) sorts waste at source — always check the label before disposing.',
      'Bee\'ah recycling centres in Sharjah accept clean sorted waste free of charge — bring dry items for best results.',
    ],
    [
      'UAE standard colour coding: blue = plastic, white = paper, green = organic, yellow = metals — memorise and share.',
      'Food contamination is the #1 reason recycling is rejected at facilities — rinse containers before sorting.',
      'Batteries, e-waste, and light bulbs must go to dedicated collection points — never in general mixed bins.',
    ],
    [
      'UAE Circular Economy Policy 2021–2031 targets 75% waste recycled by 2031 — every correctly sorted bag counts.',
      'UN SDG 11 (Sustainable Cities) calls for 50% of municipal waste recycled by 2030 — sorting is step one.',
      'Waste-to-energy plants in Dubai convert only non-recyclable mixed waste into electricity — always sort first to maximise recycling.',
    ],
  ],
};

List<String> _getTips(String wasteType, int generation) {
  final sets = _recyclingTipSets[wasteType] ?? _recyclingTipSets['mixed']!;
  return sets[generation % sets.length];
}

const Map<String, IconData> _wasteIcons = {
  'plastic': Icons.local_drink_rounded,
  'paper':   Icons.description_rounded,
  'organic': Icons.eco_rounded,
  'cans':    Icons.local_cafe_rounded,
  'mixed':   Icons.layers_rounded,
};

const Map<String, String> _wasteLabels = {
  'plastic': 'Plastic',
  'paper':   'Paper',
  'organic': 'Organic',
  'cans':    'Cans',
  'mixed':   'Mixed',
};

// One card per waste type — picks the bin with the highest fill level.
// Max 5 cards total (one per sub-bin type).
List<_SuggestionItem> _buildSuggestions(
  List<Map<String, dynamic>> binsData, {
  int threshold = 20,
}) {
  final Map<String, _SuggestionItem> bestPerType = {};

  for (final bin in binsData) {
    final fills = bin['fills'] as Map<String, int>;
    for (final entry in fills.entries) {
      if (entry.value < threshold) continue;
      final existing = bestPerType[entry.key];
      if (existing == null || entry.value > existing.fillLevel) {
        bestPerType[entry.key] = _SuggestionItem(
          binId: bin['binId'] as String,
          binName: bin['name'] as String,
          location: bin['location'] as String,
          wasteType: entry.key,
          fillLevel: entry.value,
        );
      }
    }
  }

  final items = bestPerType.values.toList();
  items.sort((a, b) => b.fillLevel.compareTo(a.fillLevel));
  return items;
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  static const _savedPrefKey = 'suggestions_saved_v1';
  static const _dismissedPrefKey = 'suggestions_dismissed_v1';

  Set<String> _savedKeys = {};
  Set<String> _dismissedKeys = {};
  bool _prefsLoaded = false;
  int _generation = 0; // incremented on refresh to force card rebuilds

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedKeys = Set<String>.from(prefs.getStringList(_savedPrefKey) ?? []);
      _dismissedKeys = Set<String>.from(prefs.getStringList(_dismissedPrefKey) ?? []);
      _prefsLoaded = true;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedPrefKey, _savedKeys.toList());
    await prefs.setStringList(_dismissedPrefKey, _dismissedKeys.toList());
  }

  String _itemKey(_SuggestionItem item) => '${item.binId}_${item.wasteType}';

  void _toggleSave(_SuggestionItem item) {
    final key = _itemKey(item);
    setState(() {
      if (_savedKeys.contains(key)) {
        _savedKeys.remove(key);
      } else {
        _savedKeys.add(key);
      }
    });
    _savePrefs();
  }

  void _dismiss(_SuggestionItem item) {
    final key = _itemKey(item);
    setState(() {
      _dismissedKeys.add(key);
      _savedKeys.remove(key); // ensure it doesn't reappear in saved after refresh
    });
    _savePrefs();
  }

  void _share(_SuggestionItem item) {
    final tips = _getTips(item.wasteType, _generation);
    final text =
        '♻️ Recycling tip for ${item.binName} (${item.location}) — '
        '${_wasteLabels[item.wasteType] ?? item.wasteType} bin at ${item.fillLevel}%:\n\n'
        '${tips.map((t) => '• $t').join('\n')}';
    Clipboard.setData(ClipboardData(text: text));
    _showToast('Copied to clipboard', Icons.copy_rounded);
  }

  /// Clears dismissed keys so all current bin-based suggestions reappear.
  /// If bins are all too low, shows an info dialog instead.
  void _refreshSuggestions(List<Map<String, dynamic>> binsData) {
    final all = _buildSuggestions(binsData);
    final wouldShow = all.where((s) => !_savedKeys.contains(_itemKey(s))).toList();

    if (wouldShow.isEmpty) {
      // No suggestions possible with current fill levels
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.surface(context),
          title: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: AppColors.accent(context), size: 22),
              const SizedBox(width: 10),
              Text(
                'No Suggestions Yet',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          content: Text(
            'All bins are currently below 20% fill level. '
            'Suggestions will appear automatically once any sub-bin reaches 20% or more.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(context),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Got it',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent(context),
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _dismissedKeys.clear();
      _generation++;
    });
    _savePrefs();
    _showToast('${wouldShow.length} suggestions refreshed', Icons.tips_and_updates_rounded);
  }

  void _showToast(String message, IconData icon) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (ctx) => _ToastOverlay(message: message, icon: icon),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 2400), entry.remove);
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);
    final accentSoft = AppColors.accentSoft(context);
    final bg = AppColors.background(context);

    if (!_prefsLoaded) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(child: CircularProgressIndicator(color: accent)),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: Consumer<AppStateProvider>(
          builder: (context, appState, _) {
            final firestoreService = FirestoreService();
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: firestoreService.getAllBinsSubBinFills(),
              builder: (context, snapshot) {
                final binsData = snapshot.data ?? [];
                final allSuggestions = _buildSuggestions(binsData);
                final active = allSuggestions
                    .where((s) =>
                        !_dismissedKeys.contains(_itemKey(s)) &&
                        !_savedKeys.contains(_itemKey(s)))
                    .toList();
                final saved = allSuggestions
                    .where((s) =>
                        _savedKeys.contains(_itemKey(s)) &&
                        !_dismissedKeys.contains(_itemKey(s)))
                    .toList();

                return RefreshIndicator(
                  color: accent,
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 1000));
                    setState(() {});
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // HEADER
                      SliverToBoxAdapter(
                        child: _HeroHeader(accent: accent, accentSoft: accentSoft),
                      ),

                      // STATS ROW
                      if (snapshot.hasData)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: _AnimatedIn(
                              delayMs: 60,
                              child: _StatsRow(
                                total: active.length,
                                saved: saved.length,
                                accent: accent,
                                accentSoft: accentSoft,
                              ),
                            ),
                          ),
                        ),

                      // LOADING
                      if (!snapshot.hasData)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 80),
                            child: Center(
                              child: CircularProgressIndicator(color: accent),
                            ),
                          ),
                        ),

                      // REFRESH BUTTON
                      if (snapshot.hasData)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: _AnimatedIn(
                              delayMs: 80,
                              child: _RefreshButton(
                                onTap: () => _refreshSuggestions(binsData),
                              ),
                            ),
                          ),
                        ),

                      // ACTIVE SUGGESTIONS HEADER
                      if (snapshot.hasData)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                            child: Row(
                              children: [
                                Icon(Icons.bolt_rounded, color: accent, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  "Active Suggestions",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: accentSoft,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${active.length}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // EMPTY STATE
                      if (snapshot.hasData && active.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                            child: _AnimatedIn(
                              child: _EmptyState(accent: accent, accentSoft: accentSoft),
                            ),
                          ),
                        ),

                      // ACTIVE CARDS
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = active[index];
                            final key = '${_itemKey(item)}_$_generation';
                            return KeyedSubtree(
                              key: ValueKey(key),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                child: _SuggestionCard(
                                  key: ValueKey(key),
                                  item: item,
                                  isSaved: _savedKeys.contains(_itemKey(item)),
                                  tipSetIndex: _generation,
                                  onSave: () => _toggleSave(item),
                                  onDismiss: () => _dismiss(item),
                                  onShare: () => _share(item),
                                ),
                              ),
                            );
                          },
                          childCount: active.length,
                        ),
                      ),

                      // SAVED SECTION
                      if (saved.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                            child: Row(
                              children: [
                                Icon(Icons.bookmark_rounded, color: accent, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  "Saved",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = saved[index];
                              final key = 'saved_${_itemKey(item)}';
                              return KeyedSubtree(
                                key: ValueKey(key),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                  child: _SuggestionCard(
                                    key: ValueKey(key),
                                    item: item,
                                    isSaved: true,
                                    compact: true,
                                    onSave: () => _toggleSave(item),
                                    onDismiss: () => _dismiss(item),
                                    onShare: () => _share(item),
                                  ),
                                ),
                              );
                            },
                            childCount: saved.length,
                          ),
                        ),
                      ],

                      const SliverPadding(padding: EdgeInsets.only(bottom: 110)),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final Color accent;
  final Color accentSoft;
  const _HeroHeader({required this.accent, required this.accentSoft});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.elevation(context, 'medium'),
      ),
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
                  color: accent.withValues(alpha: isDark ? 0.3 : 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.tips_and_updates_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Suggestions",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Recycling ideas based on fill levels",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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

class _StatsRow extends StatelessWidget {
  final int total;
  final int saved;
  final Color accent;
  final Color accentSoft;

  const _StatsRow({
    required this.total,
    required this.saved,
    required this.accent,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            label: 'Active',
            value: '$total',
            icon: Icons.lightbulb_rounded,
            color: accent,
            bg: accentSoft,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStat(
            label: 'Saved',
            value: '$saved',
            icon: Icons.bookmark_rounded,
            color: const Color(0xFF8B5CF6),
            bg: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStat(
            label: 'Bins tracked',
            value: '7',
            icon: Icons.delete_outline_rounded,
            color: const Color(0xFF10B981),
            bg: const Color(0xFF10B981).withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
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
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Color accent;
  final Color accentSoft;
  const _EmptyState({required this.accent, required this.accentSoft});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: accentSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_rounded, color: accent, size: 48),
          const SizedBox(height: 14),
          Text(
            "All bins are low",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "No bins are full enough for recycling suggestions yet.\nCheck back when fill levels rise above 20%.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Suggestion Card ─────────────────────────────────────────────────────────

class _SuggestionCard extends StatefulWidget {
  final _SuggestionItem item;
  final bool isSaved;
  final bool compact;
  final int tipSetIndex;
  final VoidCallback onSave;
  final VoidCallback onDismiss;
  final VoidCallback onShare;

  const _SuggestionCard({
    super.key,
    required this.item,
    required this.isSaved,
    this.compact = false,
    this.tipSetIndex = 0,
    required this.onSave,
    required this.onDismiss,
    required this.onShare,
  });

  @override
  State<_SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<_SuggestionCard>
    with TickerProviderStateMixin {
  late final AnimationController _fillAnim;
  late final Animation<double> _fillTween;
  late final AnimationController _exitAnim;
  late final Animation<double> _exitOpacity;
  late final Animation<Offset> _exitSlide;
  bool _expanded = false;
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();

    _fillAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fillTween = CurvedAnimation(parent: _fillAnim, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fillAnim.forward();
    });

    _exitAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _exitOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _exitAnim, curve: Curves.easeInCubic),
    );
    _exitSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.12, 0),
    ).animate(CurvedAnimation(parent: _exitAnim, curve: Curves.easeInCubic));
  }

  @override
  void dispose() {
    _fillAnim.dispose();
    _exitAnim.dispose();
    super.dispose();
  }

  Future<void> _animateThenCall(VoidCallback cb) async {
    await _exitAnim.forward();
    if (mounted) setState(() => _collapsed = true);
    await Future.delayed(const Duration(milliseconds: 220));
    cb();
  }

  Color get _typeColor =>
      AppColors.subBinColors[widget.item.wasteType] ??
      AppColors.subBinColors['mixed']!;

  Color _fillColor(int pct) {
    if (pct >= 80) return const Color(0xFFEF4444);
    if (pct >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final tips = _getTips(item.wasteType, widget.tipSetIndex);
    final icon = _wasteIcons[item.wasteType] ?? Icons.layers_rounded;
    final label = _wasteLabels[item.wasteType] ?? item.wasteType;
    final typeColor = _typeColor;
    final fillColor = _fillColor(item.fillLevel);

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: _collapsed
          ? const SizedBox.shrink()
          : FadeTransition(
      opacity: _exitOpacity,
      child: SlideTransition(
        position: _exitSlide,
        child: Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.elevation(context, 'large'),
        border: Border(
          left: BorderSide(color: typeColor, width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: badge + bin info + fill ──────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Waste type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: typeColor, size: 15),
                      const SizedBox(width: 5),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: typeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Fill level pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: fillColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${item.fillLevel}% full',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: fillColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Bin name + location ───────────────────────────────────────
            Row(
              children: [
                Icon(Icons.location_on_rounded,
                    size: 14, color: AppColors.textSecondary(context)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${item.binName}  ·  ${item.location}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Animated fill bar ─────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AnimatedBuilder(
                animation: _fillTween,
                builder: (context, _) {
                  return LinearProgressIndicator(
                    value: (item.fillLevel / 100) * _fillTween.value,
                    minHeight: 7,
                    backgroundColor:
                        AppColors.surfaceSecondary(context),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(fillColor),
                  );
                },
              ),
            ),

            if (widget.compact) ...[
              // Tap-to-expand row for saved cards
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Row(
                  children: [
                    Text(
                      _expanded ? 'Hide tips' : 'Show recycling tips',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: typeColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18, color: typeColor),
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: _expanded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          ...tips.map(
                            (tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: typeColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary(context),
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ] else ...[
              const SizedBox(height: 16),

              // ── Recycling tips ────────────────────────────────────────────
              Text(
                "Recycling ideas",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              ...tips.map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: typeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary(context),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // ── Action buttons ────────────────────────────────────────────
            Row(
              children: [
                // Save / Unsave
                _ActionBtn(
                  icon: widget.isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  label: widget.isSaved ? 'Saved' : 'Save',
                  color: widget.isSaved
                      ? const Color(0xFF8B5CF6)
                      : AppColors.textSecondary(context),
                  onTap: widget.isSaved
                      ? widget.onSave  // unsave: no exit anim, just toggle back
                      : () => _animateThenCall(widget.onSave),
                ),
                const SizedBox(width: 8),
                // Share
                _ActionBtn(
                  icon: Icons.copy_rounded,
                  label: 'Copy',
                  color: AppColors.textSecondary(context),
                  onTap: widget.onShare,
                ),
                const Spacer(),
                // Dismiss
                _ActionBtn(
                  icon: Icons.check_rounded,
                  label: 'Done',
                  color: const Color(0xFF10B981),
                  filled: true,
                  onTap: () => _animateThenCall(widget.onDismiss),
                ),
              ],
            ),
          ],
        ),
      ),
        ),
      ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    this.filled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: filled
              ? null
              : Border.all(
                  color: AppColors.border(context),
                  width: 1.2,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Toast overlay
// ─────────────────────────────────────────────────────────────────────────────

class _ToastOverlay extends StatefulWidget {
  final String message;
  final IconData icon;
  const _ToastOverlay({required this.message, required this.icon});

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _opacity =
        CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(
            begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    _c.forward();

    // Fade out before removal
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) _c.reverse();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 110,
      left: 24,
      right: 24,
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, color: const Color(0xFF14B8A6), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Refresh button
// ─────────────────────────────────────────────────────────────────────────────

class _RefreshButton extends StatefulWidget {
  final VoidCallback onTap;
  const _RefreshButton({required this.onTap});

  @override
  State<_RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<_RefreshButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;
  bool _spinning = false;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (_spinning) return;
    setState(() => _spinning = true);
    _spin.forward(from: 0);
    widget.onTap();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _spinning = false);
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);
    final accentSoft = AppColors.accentSoft(context);

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          color: accentSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accent.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _spin,
              child: Icon(Icons.refresh_rounded, color: accent, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              'Get New Suggestions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AnimatedIn (entry animation)
// ─────────────────────────────────────────────────────────────────────────────

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

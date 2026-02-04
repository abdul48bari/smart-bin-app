import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class HorizontalBarChart extends StatelessWidget {
  final Map<String, int> data;
  final Map<String, Color> colors;

  const HorizontalBarChart({
    super.key,
    required this.data,
    required this.colors,
  });

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'plastic':
        return Icons.local_drink_rounded;
      case 'glass':
        return Icons.wine_bar_rounded;
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
    final total = data.values.fold(0, (sum, count) => sum + count);
    
    if (total == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            "No data available for this period",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
      );
    }

    // Sort by count descending for better visual hierarchy
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedEntries.map((entry) {
        final type = entry.key;
        final count = entry.value;
        final percentage = total > 0 ? (count / total) : 0.0;
        final color = colors[type] ?? const Color(0xFF0F766E);

        return _BarRow(
          label: type,
          count: count,
          percentage: percentage,
          color: color,
          icon: _getIcon(type),
        );
      }).toList(),
    );
  }
}

// BAR ROW
class _BarRow extends StatefulWidget {
  final String label;
  final int count;
  final double percentage;
  final Color color;
  final IconData icon;

  const _BarRow({
    required this.label,
    required this.count,
    required this.percentage,
    required this.color,
    required this.icon,
  });

  @override
  State<_BarRow> createState() => _BarRowState();
}

class _BarRowState extends State<_BarRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0.0, end: widget.percentage).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    
    // Start animation after a small delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(_BarRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation = Tween<double>(
        begin: oldWidget.percentage,
        end: widget.percentage,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label and count
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: widget.count),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Text(
                    "$value",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: widget.color,
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              Text(
                "(${(widget.percentage * 100).round()}%)",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Animated bar with glow in dark mode
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _animation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.color,
                            widget.color.withOpacity(0.7),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withOpacity(isDark ? 0.5 : 0.3),
                            blurRadius: isDark ? 12 : 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
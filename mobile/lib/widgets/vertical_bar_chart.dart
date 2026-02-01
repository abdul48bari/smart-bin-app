import 'package:flutter/material.dart';

class VerticalBarChart extends StatelessWidget {
  final Map<String, int> data;
  final Map<String, Color> colors;

  const VerticalBarChart({
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.inbox_rounded,
                size: 48,
                color: Colors.black26,
              ),
              SizedBox(height: 12),
              Text(
                "No pieces collected yet",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sort by count descending
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxCount = sortedEntries.first.value;

    return Column(
      children: [
        // Main vertical bars
        SizedBox(
          height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: sortedEntries.map((entry) {
              final type = entry.key;
              final count = entry.value;
              final percentage = maxCount > 0 ? count / maxCount : 0.0;
              final color = colors[type] ?? const Color(0xFF0F766E);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _VerticalBar(
                    label: type,
                    count: count,
                    percentage: percentage,
                    color: color,
                    icon: _getIcon(type),
                    maxHeight: 200,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Circular indicators row
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: sortedEntries.map((entry) {
            final type = entry.key;
            final count = entry.value;
            final percentage = total > 0 ? (count / total) : 0.0;
            final color = colors[type] ?? const Color(0xFF0F766E);

            return _CircularIndicator(
              label: type,
              count: count,
              percentage: percentage,
              color: color,
              icon: _getIcon(type),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// =========================
// VERTICAL BAR
// =========================
class _VerticalBar extends StatefulWidget {
  final String label;
  final int count;
  final double percentage;
  final Color color;
  final IconData icon;
  final double maxHeight;

  const _VerticalBar({
    required this.label,
    required this.count,
    required this.percentage,
    required this.color,
    required this.icon,
    required this.maxHeight,
  });

  @override
  State<_VerticalBar> createState() => _VerticalBarState();
}

class _VerticalBarState extends State<_VerticalBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0.0, end: widget.percentage).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(_VerticalBar oldWidget) {
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Count on top
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: widget.count),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Text(
              "$value",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: widget.color,
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        
        // Animated bar
        Flexible(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final height = widget.maxHeight * _animation.value * 0.5;
              
              return Container(
                width: double.infinity,
                height: height < 15 ? 15 : height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.color,
                      widget.color.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                    bottom: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 6),
        
        // Icon
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.icon,
            color: widget.color,
            size: 16,
          ),
        ),
        
        const SizedBox(height: 3),
        
        // Label
        Text(
          widget.label.toUpperCase(),
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// =========================
// CIRCULAR INDICATOR
// =========================
class _CircularIndicator extends StatefulWidget {
  final String label;
  final int count;
  final double percentage;
  final Color color;
  final IconData icon;

  const _CircularIndicator({
    required this.label,
    required this.count,
    required this.percentage,
    required this.color,
    required this.icon,
  });

  @override
  State<_CircularIndicator> createState() => _CircularIndicatorState();
}

class _CircularIndicatorState extends State<_CircularIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0.0, end: widget.percentage).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          // Circular progress
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
                
                // Animated progress
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: _animation.value,
                        strokeWidth: 5,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(widget.color),
                      ),
                    );
                  },
                ),
                
                // Icon in center
                Icon(
                  widget.icon,
                  color: widget.color,
                  size: 24,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Count
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: widget.count),
            duration: const Duration(milliseconds: 1200),
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
          
          const SizedBox(height: 2),
          
          // Label
          Text(
            widget.label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Percentage
          Text(
            "${(widget.percentage * 100).round()}%",
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}
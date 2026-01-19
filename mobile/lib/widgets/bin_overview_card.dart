import 'package:flutter/material.dart';
import '../models/bin_sub.dart';

class BinOverviewCard extends StatelessWidget {
  final String binName;
  final List<BinSub> subBins;

  const BinOverviewCard({
    super.key,
    required this.binName,
    required this.subBins,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bin title
            Row(
              children: [
                const Icon(
                  Icons.delete_outline,
                  size: 28,
                  color: Colors.green,
                ),
                const SizedBox(width: 10),
                Text(
                  binName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Sub-bins
            ...subBins.map((bin) => _SubBinRow(bin: bin)).toList(),
          ],
        ),
      ),
    );
  }
}

class _SubBinRow extends StatelessWidget {
  final BinSub bin;

  const _SubBinRow({required this.bin});

  @override
  Widget build(BuildContext context) {
    final bool isFull = bin.isFull;
    final Color statusColor = isFull ? Colors.redAccent : Colors.green;

    return Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Row(
    children: [
      // LEFT: Sub-bin name (flexible)
      Expanded(
        child: Text(
          bin.name.toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),

      // RIGHT: Status + percentage (fixed)
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: bin.isFull ? Colors.redAccent : Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${bin.currentFillPercent}%',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    ],
  ),
);

  }
}

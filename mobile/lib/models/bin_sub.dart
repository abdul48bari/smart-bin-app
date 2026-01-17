class BinSub {
  final String name;
  final int currentFillPercent;
  final bool isFull;

  BinSub({
    required this.name,
    required this.currentFillPercent,
    required this.isFull,
  });

  factory BinSub.fromFirestore(String id, Map<String, dynamic> data) {
    return BinSub(
      name: id,
      currentFillPercent: data['currentFillPercent'] ?? 0,
      isFull: data['isFull'] ?? false,
    );
  }
}

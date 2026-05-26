class BlacklistItem {
  final String domain;
  final DateTime addedAt;

  BlacklistItem({
    required this.domain,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'domain': domain,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory BlacklistItem.fromMap(Map<String, dynamic> map) {
    return BlacklistItem(
      domain: map['domain'] as String,
      addedAt: DateTime.parse(map['addedAt'] as String),
    );
  }
}

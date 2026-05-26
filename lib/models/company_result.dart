class CompanyResult {
  final String company;
  final List<String> websites;
  final String facebook;
  final String linkedin;
  final List<String> emails;
  final DateTime createdAt;
  final bool isProcessed;

  CompanyResult({
    required this.company,
    this.websites = const [],
    this.facebook = '',
    this.linkedin = '',
    this.emails = const [],
    DateTime? createdAt,
    this.isProcessed = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'company': company,
      'websites': websites.join(','),
      'facebook': facebook,
      'linkedin': linkedin,
      'emails': emails.join(','),
      'createdAt': createdAt.toIso8601String(),
      'isProcessed': isProcessed ? 1 : 0,
    };
  }

  factory CompanyResult.fromMap(Map<String, dynamic> map) {
    return CompanyResult(
      company: map['company'] as String,
      websites: (map['websites'] as String).split(',').where((e) => e.isNotEmpty).toList(),
      facebook: map['facebook'] as String? ?? '',
      linkedin: map['linkedin'] as String? ?? '',
      emails: (map['emails'] as String).split(',').where((e) => e.isNotEmpty).toList(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      isProcessed: (map['isProcessed'] as int) == 1,
    );
  }

  CompanyResult copyWith({
    String? company,
    List<String>? websites,
    String? facebook,
    String? linkedin,
    List<String>? emails,
    DateTime? createdAt,
    bool? isProcessed,
  }) {
    return CompanyResult(
      company: company ?? this.company,
      websites: websites ?? this.websites,
      facebook: facebook ?? this.facebook,
      linkedin: linkedin ?? this.linkedin,
      emails: emails ?? this.emails,
      createdAt: createdAt ?? this.createdAt,
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }
}

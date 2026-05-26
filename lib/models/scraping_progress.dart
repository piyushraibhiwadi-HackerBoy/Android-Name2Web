class ScrapingProgress {
  final int totalCompanies;
  final int processedCompanies;
  final int remainingCompanies;
  final String currentCompany;
  final bool isRunning;
  final bool isPaused;

  ScrapingProgress({
    required this.totalCompanies,
    required this.processedCompanies,
    required this.remainingCompanies,
    this.currentCompany = '',
    this.isRunning = false,
    this.isPaused = false,
  });

  double get progressPercentage {
    if (totalCompanies == 0) return 0.0;
    return processedCompanies / totalCompanies;
  }

  ScrapingProgress copyWith({
    int? totalCompanies,
    int? processedCompanies,
    int? remainingCompanies,
    String? currentCompany,
    bool? isRunning,
    bool? isPaused,
  }) {
    return ScrapingProgress(
      totalCompanies: totalCompanies ?? this.totalCompanies,
      processedCompanies: processedCompanies ?? this.processedCompanies,
      remainingCompanies: remainingCompanies ?? this.remainingCompanies,
      currentCompany: currentCompany ?? this.currentCompany,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

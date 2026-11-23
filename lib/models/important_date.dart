class ImportantDate {
  final String id;
  String title;
  DateTime date;
  bool repeatsYearly;
  String iconEmoji;
  String createdBy;

  ImportantDate({
    required this.id,
    required this.title,
    required this.date,
    this.repeatsYearly = true,
    this.iconEmoji = '💖',
    this.createdBy = 'Miftah',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'repeatsYearly': repeatsYearly,
        'iconEmoji': iconEmoji,
        'createdBy': createdBy,
      };

  factory ImportantDate.fromJson(Map<String, dynamic> json) => ImportantDate(
        id: json['id'] as String,
        title: json['title'] as String,
        date: DateTime.parse(json['date'] as String),
        repeatsYearly: (json['repeatsYearly'] as bool?) ?? true,
        iconEmoji: (json['iconEmoji'] as String?) ?? '💖',
        createdBy: (json['createdBy'] as String?) ?? 'Miftah',
      );

  /// Calculates remaining days until next occurrence
  int daysRemaining() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (!repeatsYearly) {
      final target = DateTime(date.year, date.month, date.day);
      return target.difference(today).inDays;
    }

    var next = DateTime(now.year, date.month, date.day);
    if (next.isBefore(today)) {
      next = DateTime(now.year + 1, date.month, date.day);
    }
    return next.difference(today).inDays;
  }
}

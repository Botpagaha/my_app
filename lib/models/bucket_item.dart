class BucketItem {
  final String id;
  String title;
  String category; // 'tempat' | 'makanan' | 'film' | 'lainnya'
  String notes;
  bool isCompleted;
  DateTime? targetDate;
  DateTime? completedAt;
  String memoryNote;
  List<String> photos;
  String createdBy;
  bool isFavorite;

  BucketItem({
    required this.id,
    required this.title,
    required this.category,
    this.notes = '',
    this.isCompleted = false,
    this.targetDate,
    this.completedAt,
    this.memoryNote = '',
    List<String>? photos,
    this.createdBy = 'Miftah',
    this.isFavorite = false,
  }) : photos = photos ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'notes': notes,
        'isCompleted': isCompleted,
        'targetDate': targetDate?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'memoryNote': memoryNote,
        'photos': photos,
        'createdBy': createdBy,
        'isFavorite': isFavorite,
      };

  factory BucketItem.fromJson(Map<String, dynamic> json) => BucketItem(
        id: json['id'] as String,
        title: json['title'] as String,
        category: (json['category'] as String?) ?? 'lainnya',
        notes: (json['notes'] as String?) ?? '',
        isCompleted: (json['isCompleted'] as bool?) ?? false,
        targetDate: json['targetDate'] != null ? DateTime.tryParse(json['targetDate'] as String) : null,
        completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'] as String) : null,
        memoryNote: (json['memoryNote'] as String?) ?? '',
        photos: (json['photos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        createdBy: (json['createdBy'] as String?) ?? 'Miftah',
        isFavorite: (json['isFavorite'] as bool?) ?? false,
      );

  String get categoryLabel {
    switch (category.toLowerCase()) {
      case 'tempat':
        return 'Tempat 📍';
      case 'makanan':
        return 'Makanan ☕';
      case 'film':
        return 'Film 🎬';
      default:
        return 'Lainnya ✨';
    }
  }
}

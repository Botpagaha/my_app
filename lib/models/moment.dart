class Moment {
  final String id;
  String title;
  DateTime date;
  String location;
  String story;
  List<String> photos;
  String createdBy;
  bool isBucketListCompleted;
  String? bucketItemId;

  Moment({
    required this.id,
    required this.title,
    required this.date,
    this.location = '',
    this.story = '',
    List<String>? photos,
    this.createdBy = 'Miftah',
    this.isBucketListCompleted = false,
    this.bucketItemId,
  }) : photos = photos ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'location': location,
        'story': story,
        'photos': photos,
        'createdBy': createdBy,
        'isBucketListCompleted': isBucketListCompleted,
        'bucketItemId': bucketItemId,
      };

  factory Moment.fromJson(Map<String, dynamic> json) => Moment(
        id: json['id'] as String,
        title: json['title'] as String,
        date: DateTime.parse(json['date'] as String),
        location: (json['location'] as String?) ?? '',
        story: (json['story'] as String?) ?? '',
        photos: (json['photos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        createdBy: (json['createdBy'] as String?) ?? 'Miftah',
        isBucketListCompleted: (json['isBucketListCompleted'] as bool?) ?? false,
        bucketItemId: json['bucketItemId'] as String?,
      );
}

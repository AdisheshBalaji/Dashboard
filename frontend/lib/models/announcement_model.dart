class AnnouncementModel {
  final num id;
  final String title;
  final String description;
  final num createdAt;
  final String createdBy;
  final List<String> tags;
	final List<String>? category;
  final String? imageUrl;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.createdBy,
    required this.tags,
		this.category,
    this.imageUrl
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: json['createdAt'],
      createdBy: json['createdBy'],
      tags: List<String>.from(json['tags']),
			category: List<String>.from(json['category']),
      imageUrl: json['imageURI'],
    );
  }
}

class MerchImage {
  final String url;

  MerchImage({
    required this.url
  });

  factory MerchImage.fromJson(Map<String, dynamic> json) {
    return MerchImage(url: json['url']);
  }
}

class MerchItem {
  final int id;
  final String title;
  final String description;
  final DateTime deadline;
  final double price;
  final String imageUrl;
  final List<MerchImage> images;
  final String upiId;
  final DateTime createdAt;

  MerchItem({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.price,
    required this.imageUrl,
    required this.images,
    required this.upiId,
    required this.createdAt,
  });

  factory MerchItem.fromJson(Map<String, dynamic> json) {
    List<MerchImage> images = [];
    if (json['images'] != null) {
      images = (json['images'] as List)
          .map((img) => MerchImage.fromJson(img))
          .toList();
    }

    return MerchItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      deadline: DateTime.parse(json['deadline']),
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'],
      images: images,
      upiId: json['upi_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
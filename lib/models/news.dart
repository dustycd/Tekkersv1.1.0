class News {
  final int id;
  final String title;
  final String content;
  final DateTime postedAt;
  final String imageUrl; // Optional: If news includes an image

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.postedAt,
    this.imageUrl = '',
  });

  // Factory constructor to create a News instance from a JSON object
  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      postedAt: DateTime.parse(json['postedAt']), // Assuming the date is in a valid ISO 8601 format
      imageUrl: json['imageUrl'] ?? '', // Fallback to an empty string if no image URL is provided
    );
  }

  // To convert the News instance back to JSON (optional)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'postedAt': postedAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}
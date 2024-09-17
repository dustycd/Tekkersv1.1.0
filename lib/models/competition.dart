class Competition {
  final int id;
  final String name;
  final String country;
  final String emblemUrl;

  Competition({
    required this.id,
    required this.name,
    required this.country,
    required this.emblemUrl,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      id: json['id'],
      name: json['name'],
      country: json['area']['name'],  // This maps the area to country
      emblemUrl: json['emblemUrl'] ?? '',
    );
  }
}
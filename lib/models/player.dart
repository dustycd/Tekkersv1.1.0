class Player {
  final int id;
  final String name;
  final String position;
  final String nationality;
  final String teamName;
  final String photoUrl;
  final int goals;

  Player({
    required this.id,
    required this.name,
    required this.position,
    required this.nationality,
    required this.teamName,
    required this.photoUrl,
    required this.goals,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Player',
      position: json['position'] ?? 'N/A',
      nationality: json['nationality'] ?? 'N/A',
      teamName: json['team'] ?? 'Unknown Team',
      photoUrl: json['imageUrl'] ?? 'https://example.com/default-image.png',
      goals: json['goals'] ?? 0,
    );
  }
}
// lib/models/team.dart

class Team {
  final int id;
  final String name;
  final String logoUrl;
  final String? league;
  final String? stadium;
  final String? formation;

  Team({
    required this.id,
    required this.name,
    required this.logoUrl,
    this.league,
    this.stadium,
    this.formation,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'], // Ensure 'id' is present and is an integer
      name: json['name'], // Ensure 'name' is present and is a string
      logoUrl: json['logoUrl'] ?? '', // Handle potential null values
      league: json['league'],
      stadium: json['stadium'],
      formation: json['formation'],
    );
  }
}
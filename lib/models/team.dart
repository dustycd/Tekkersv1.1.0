// lib/models/team.dart

class Team {
  final int id;
  final String name;
  final String crestUrl; // Updated from logoUrl to crestUrl
  final String? league;
  final String? stadium;
  final String? formation;
  final String? shortName;
  final String? tla;
  final String? address;
  final String? website;
  final int? founded;
  final String? clubColors;
  final String? venue;

  Team({
    required this.id,
    required this.name,
    required this.crestUrl,
    this.league,
    this.stadium,
    this.formation,
    this.shortName,
    this.tla,
    this.address,
    this.website,
    this.founded,
    this.clubColors,
    this.venue,
  });

  // Getter for backward compatibility with 'logoUrl'
  String get logoUrl => crestUrl;

  // Existing factory constructor for football-data.org API
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'], // Ensure 'id' is present and is an integer
      name: json['name'], // Ensure 'name' is present and is a string
      crestUrl: json['crest'] ?? '', // Map 'crest' from API to 'crestUrl'
      league: json['league'], // May not be present in API; handle accordingly
      stadium: json['stadium'], // May not be present in API
      formation: json['formation'], // May not be present in API
      shortName: json['shortName'],
      tla: json['tla'],
      address: json['address'],
      website: json['website'],
      founded: json['founded'],
      clubColors: json['clubColors'],
      venue: json['venue'],
    );
  }

  // New factory constructor for API-Football JSON structure
  factory Team.fromApiSportsJson(Map<String, dynamic> json) {
    return Team(
      id: json['team']['id'],
      name: json['team']['name'],
      crestUrl: json['team']['logo'] ?? '',
      league: json['league']['name'] ?? '', // Extract league name if available
      stadium: json['venue']['name'] ?? '', // Extract stadium name if available
      address: json['team']['address'] ?? '',
      website: json['team']['website'] ?? '',
      founded: json['team']['founded'],
      venue: json['venue']['name'] ?? '',
      // The following fields may not be available; set them to null or extract if available
      formation: null,
      shortName: json['team']['name_short'] ?? null,
      tla: null,
      clubColors: null,
    );
  }
}
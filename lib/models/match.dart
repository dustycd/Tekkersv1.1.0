// lib/models/match.dart

class Match {
  final int id;
  final String utcDate;
  final String status;
  final String homeTeamName;
  final String awayTeamName;
  final String? homeTeamCrestUrl;
  final String? awayTeamCrestUrl;
  final int? scoreHome;
  final int? scoreAway;

  Match({
    required this.id,
    required this.utcDate,
    required this.status,
    required this.homeTeamName,
    required this.awayTeamName,
    this.homeTeamCrestUrl,
    this.awayTeamCrestUrl,
    this.scoreHome,
    this.scoreAway,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      utcDate: json['utcDate'],
      status: json['status'],
      homeTeamName: json['homeTeam']['shortName'] ?? json['homeTeam']['name'],
      awayTeamName: json['awayTeam']['shortName'] ?? json['awayTeam']['name'],
      homeTeamCrestUrl: json['homeTeam']['crest'] ?? '',
      awayTeamCrestUrl: json['awayTeam']['crest'] ?? '',
      scoreHome: json['score']['fullTime']['home'],
      scoreAway: json['score']['fullTime']['away'],
    );
  }
}
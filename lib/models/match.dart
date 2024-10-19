// lib/models/match.dart

class Match {
  final int id;
  final String utcDate;
  final String status;
  final int homeTeamId;
  final String homeTeamName;
  final String? homeTeamCrestUrl;
  final int awayTeamId;
  final String awayTeamName;
  final String? awayTeamCrestUrl;
  final int? scoreHome;
  final int? scoreAway;
  final String leagueName;
   final int? minute;

  Match({
    required this.id,
    required this.utcDate,
    required this.status,
    required this.homeTeamId,
    required this.homeTeamName,
    this.homeTeamCrestUrl,
    required this.awayTeamId,
    required this.awayTeamName,
    this.awayTeamCrestUrl,
    this.scoreHome,
    this.scoreAway,
    required this.leagueName,
    this.minute,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      utcDate: json['utcDate'],
      status: json['status'],
      homeTeamId: json['homeTeam']['id'],
      homeTeamName: json['homeTeam']['shortName'] ?? json['homeTeam']['name'],
      homeTeamCrestUrl: json['homeTeam']['crest'],
      awayTeamId: json['awayTeam']['id'],
      awayTeamName: json['awayTeam']['shortName'] ?? json['awayTeam']['name'],
      awayTeamCrestUrl: json['awayTeam']['crest'],
      scoreHome: json['score']['fullTime']['home'],
      scoreAway: json['score']['fullTime']['away'],
      leagueName: json['competition']['name'],
      minute: json['minute'],
    );
  }
}
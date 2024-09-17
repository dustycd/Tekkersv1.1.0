class Standing {
  final int position;
  final String teamName;
  final String teamCrestUrl;
  final int playedGames;
  final int won;
  final int draw;
  final int lost;
  final int points;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;

  Standing({
    required this.position,
    required this.teamName,
    required this.teamCrestUrl,
    required this.playedGames,
    required this.won,
    required this.draw,
    required this.lost,
    required this.points,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
  });

  factory Standing.fromJson(Map<String, dynamic> json) {
    return Standing(
      position: json['position'],
      teamName: json['team']['name'],
      teamCrestUrl: json['team']['crest'],
      playedGames: json['playedGames'],
      won: json['won'],
      draw: json['draw'],
      lost: json['lost'],
      points: json['points'],
      goalsFor: json['goalsFor'],
      goalsAgainst: json['goalsAgainst'],
      goalDifference: json['goalDifference'],
    );
  }
}
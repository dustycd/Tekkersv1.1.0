class Scorer {
  final String playerName;
  final String teamName;
  final int goals;

  Scorer({
    required this.playerName,
    required this.teamName,
    required this.goals,
  });

  factory Scorer.fromJson(Map<String, dynamic> json) {
    return Scorer(
      playerName: json['player']['name'],
      teamName: json['team']['name'],
      goals: json['numberOfGoals'],
    );
  }
}
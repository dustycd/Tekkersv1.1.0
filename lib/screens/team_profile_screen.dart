import 'dart:async'; // Added for Timer
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tekkers/providers/player_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:tekkers/screens/all_matches_screen.dart'; // Ensure this import is correct

class TeamProfileScreen extends StatefulWidget {
  final int teamId;
  final String teamName;

  const TeamProfileScreen({
    Key? key,
    required this.teamId,
    required this.teamName,
  }) : super(key: key);

  @override
  _TeamProfileScreenState createState() => _TeamProfileScreenState();
}

class _TeamProfileScreenState extends State<TeamProfileScreen> {
  final String apiKey = 'b373e81675174781839c2a00b33385b0';
  late Future<Map<String, dynamic>> _fetchTeamFuture;
  late Future<List<dynamic>> _fetchMatchesFuture;
  late Future<List<dynamic>> _fetchSquadFuture;
  late Future<List<dynamic>> _fetchLiveMatchesFuture; // Added for live matches
  Timer? _timer; // Added for periodic refresh

  @override
  void initState() {
    super.initState();
    _fetchTeamFuture = fetchTeamDetails();
    _fetchMatchesFuture = fetchTeamMatches(limit: 3); // Limit to 3 matches
    _fetchSquadFuture = fetchTeamSquad();
    _fetchLiveMatchesFuture = fetchLiveMatches(); // Fetch live matches

    // Set up a timer to refresh live matches every 60 seconds
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      setState(() {
        _fetchLiveMatchesFuture = fetchLiveMatches();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchTeamDetails() async {
    final String apiUrl =
        'https://api.football-data.org/v4/teams/${widget.teamId}';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'X-Auth-Token': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data; // Team details
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load team details: $e');
    }
  }

  Future<List<dynamic>> fetchTeamMatches({int limit = 15}) async {
    final String apiUrl =
        'https://api.football-data.org/v4/teams/${widget.teamId}/matches?limit=$limit';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'X-Auth-Token': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['matches']; // List of recent matches
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load team matches: $e');
    }
  }

  // Added function to fetch live matches
  Future<List<dynamic>> fetchLiveMatches() async {
    final String apiUrl =
        'https://api.football-data.org/v4/teams/${widget.teamId}/matches?status=LIVE,IN_PLAY';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'X-Auth-Token': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['matches']; // List of live matches
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load live matches: $e');
    }
  }

  Future<List<dynamic>> fetchTeamSquad() async {
    final String apiUrl =
        'https://api.football-data.org/v4/teams/${widget.teamId}';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'X-Auth-Token': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['squad']; // List of players
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load team squad: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.teamName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchTeamFuture,
        builder: (context, teamSnapshot) {
          if (teamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          } else if (teamSnapshot.hasError) {
            return Center(
              child: Text(
                '${teamSnapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else {
            final team = teamSnapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTeamHeader(team),
                  const SizedBox(height: 24),
                  _buildTeamDetails(team),
                  const SizedBox(height: 24),
                  _buildLiveMatches(), // Display live matches
                  const SizedBox(height: 24),
                  _buildRecentMatches(),
                  const SizedBox(height: 24),
                  _buildSquad(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTeamHeader(Map<String, dynamic> team) {
    return Column(
      children: [
        // Team Crest
        team['crest'] != null && team['crest'].isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(75),
                child: Image.network(
                  team['crest'],
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error,
                        size: 100, color: Colors.white);
                  },
                ),
              )
            : const Icon(Icons.sports_soccer, size: 100, color: Colors.white),
        const SizedBox(height: 16),
        // Team Name
        Text(
          team['name'] ?? 'N/A',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamDetails(Map<String, dynamic> team) {
    String coachName = team['coach']?['name'] ?? 'N/A';
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDetailRow('Coach', coachName),
          _buildDetailRow('Short Name', team['shortName'] ?? 'N/A'),
          _buildDetailRow('TLA', team['tla'] ?? 'N/A'),
          _buildDetailRow('Founded', team['founded']?.toString() ?? 'N/A'),
          _buildDetailRow('Club Colors', team['clubColors'] ?? 'N/A'),
          _buildDetailRow('Venue', team['venue'] ?? 'N/A'),
          _buildDetailRow('Address', team['address'] ?? 'N/A'),
          _buildDetailRow('Website', team['website'] ?? 'N/A', isLink: true),
        ],
      ),
    );
  }

  // Added widget to display live matches
  Widget _buildLiveMatches() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchLiveMatchesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              '${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else {
          final liveMatches = snapshot.data!;
          if (liveMatches.isEmpty) {
            return const SizedBox(); // No live matches
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Live Matches',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: liveMatches.length,
                itemBuilder: (context, index) {
                  return _buildMatchTile(liveMatches[index]);
                },
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildRecentMatches() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchMatchesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              '${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else {
          final matches = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Matches',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  return _buildMatchTile(matches[index]);
                },
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Navigate to a screen that shows all matches
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllMatchesScreen(
                          teamId: widget.teamId,
                          teamName: widget.teamName,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'See All Matches',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildMatchTile(Map<String, dynamic> match) {
    String homeTeamName =
        match['homeTeam']['shortName'] ?? match['homeTeam']['name'];
    String awayTeamName =
        match['awayTeam']['shortName'] ?? match['awayTeam']['name'];
    String homeTeamCrest = match['homeTeam']['crest'] ?? '';
    String awayTeamCrest = match['awayTeam']['crest'] ?? '';
    String matchDate = match['utcDate'];
    DateTime utcDate = DateTime.parse(matchDate);
    DateTime localDate = utcDate.toLocal();
    String formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(localDate);
    String status = match['status'];

    // Fetch the current minute of the match if available
    String minute = match['minute']?.toString() ?? '';

    // Get current scores
    String scoreHome = match['score']['fullTime']['home']?.toString() ?? '-';
    String scoreAway = match['score']['fullTime']['away']?.toString() ?? '-';

    if (status == 'LIVE' || status == 'IN_PLAY' || status == 'PAUSED') {
      // Use live score if available
      scoreHome = match['score']['fullTime']['home']?.toString() ?? '0';
      scoreAway = match['score']['fullTime']['away']?.toString() ?? '0';
    }

    String matchStatus;
    if (status == 'SCHEDULED') {
      matchStatus = 'Scheduled';
    } else if (status == 'LIVE' || status == 'IN_PLAY') {
      matchStatus = 'Live';
    } else if (status == 'PAUSED') {
      matchStatus = 'Half-Time';
    } else if (status == 'FINISHED') {
      matchStatus = 'Finished';
    } else {
      matchStatus = status;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            '$formattedDate - $matchStatus ${minute.isNotEmpty ? '(${minute}\')' : ''}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Home Team
              Expanded(
                child: Row(
                  children: [
                    homeTeamCrest.isNotEmpty
                        ? Image.network(
                            homeTeamCrest,
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error,
                                  size: 24, color: Colors.white);
                            },
                          )
                        : const Icon(Icons.sports_soccer,
                            size: 24, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        homeTeamName,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Score
              Text(
                '$scoreHome : $scoreAway',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              // Away Team
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        awayTeamName,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    awayTeamCrest.isNotEmpty
                        ? Image.network(
                            awayTeamCrest,
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error,
                                  size: 24, color: Colors.white);
                            },
                          )
                        : const Icon(Icons.sports_soccer,
                            size: 24, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSquad() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchSquadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              '${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else {
          final squad = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Squad',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: squad.length,
                itemBuilder: (context, index) {
                  return _buildPlayerTile(squad[index]);
                },
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildPlayerTile(Map<String, dynamic> playerData) {
    String name = playerData['name'] ?? 'N/A';
    String position = playerData['position'] ?? 'N/A';
    String nationality = playerData['nationality'] ?? 'N/A';
    int playerId = playerData['id'];

    // Simplify position names
    String positionAbbreviation = _getPositionAbbreviation(position);

    // Get country code for nationality
    String countryCode = _getCountryCode(nationality);

    return GestureDetector(
      onTap: () {
        // Optionally, navigate to player details screen
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Player Photo
            FutureBuilder(
              future: Provider.of<PlayerProvider>(context, listen: false)
                  .fetchPlayer(playerId),
              builder: (context, snapshot) {
                PlayerProvider playerProvider =
                    Provider.of<PlayerProvider>(context);
                if (playerProvider.players.containsKey(playerId)) {
                  String photoUrl = playerProvider.players[playerId]!.photoUrl;
                  if (photoUrl.isNotEmpty) {
                    return ClipOval(
                      child: Image.network(
                        photoUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person,
                              size: 40, color: Colors.white);
                        },
                      ),
                    );
                  }
                }
                return const Icon(Icons.person, size: 40, color: Colors.white);
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Text(
              positionAbbreviation,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(width: 8),
            countryCode.isNotEmpty
                ? Image.network(
                    'https://flagcdn.com/w20/${countryCode.toLowerCase()}.png',
                    width: 20,
                    height: 15,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.flag,
                          size: 20, color: Colors.white);
                    },
                  )
                : Text(
                    nationality,
                    style: const TextStyle(color: Colors.grey),
                  ),
          ],
        ),
      ),
    );
  }

  String _getPositionAbbreviation(String position) {
    Map<String, String> positionMap = {
      'Goalkeeper': 'GK',
      'Goalie': 'GK',
      'Defender': 'DF',
      'Midfielder': 'CM',
      'Attacker': 'FW',
      'Left-Back': 'LB',
      'Right-Back': 'RB',
      'Centre-Back': 'CB',
      'Striker': 'ST',
      'Centre-Forward': 'CF',
      'Right Wing': 'RW',
      'Left Wing': 'LW',
      'Left Midfield': 'LM',
      'Right Midfield': 'RM',
      // Add more mappings as needed
    };
    return positionMap[position] ?? position.substring(0, 2).toUpperCase();
  }

  String _getCountryCode(String countryName) {
    Map<String, String> countryCodeMap = {
      'England': 'gb',
      'France': 'fr',
      'Spain': 'es',
      'Germany': 'de',
      'Italy': 'it',
      'Brazil': 'br',
      'Portugal': 'pt',
      'Argentina': 'ar',
      'Belgium': 'be',
      // Add more country mappings as needed
    };
    return countryCodeMap[countryName] ?? '';
  }

  Widget _buildDetailRow(String title, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isLink
                ? GestureDetector(
                    onTap: () async {
                      final Uri url = Uri.parse(value);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        // Can't launch URL
                      }
                    },
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tekkers/models/match.dart';
import 'package:tekkers/models/stand.dart'; // Import the Standing model
import 'package:tekkers/models/player.dart'; // Import the updated Player model

class MatchProvider with ChangeNotifier {
  final String _apiKey = 'b373e81675174781839c2a00b33385b0'; // Replace with your API key
  final String _baseUrl = 'api.football-data.org';

  List<Match> _matches = [];
  List<Standing> _standings = []; // Standings list
  List<Player> _players = []; // Players list for statistics

  List<Match> get matches => _matches;
  List<Standing> get standings => _standings;
  List<Player> get players => _players;

  /// Fetch matches by competition ID
  Future<void> fetchMatchesByCompetition(int competitionId) async {
    var url = Uri.https(_baseUrl, '/v4/competitions/$competitionId/matches');

    try {
      final response = await http.get(url, headers: {
        'X-Auth-Token': _apiKey,
      });

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final List<dynamic> matchesJson = decodedResponse['matches'];
        _matches = matchesJson.map((json) => Match.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load matches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching matches: $e');
    }
  }

  /// Fetch standings by competition ID
  Future<void> fetchStandingsByCompetition(int competitionId) async {
    var url = Uri.https(_baseUrl, '/v4/competitions/$competitionId/standings');

    try {
      final response = await http.get(url, headers: {
        'X-Auth-Token': _apiKey,
      });

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        // Ensure that 'standings' and 'table' exist in the response
        if (decodedResponse['standings'] != null &&
            decodedResponse['standings'].isNotEmpty &&
            decodedResponse['standings'][0]['table'] != null) {
          final List<dynamic> standingsJson = decodedResponse['standings'][0]['table'];
          _standings = standingsJson.map((json) => Standing.fromJson(json)).toList();
          notifyListeners();
        } else {
          throw Exception('Standings data is missing in the response.');
        }
      } else {
        throw Exception('Failed to load standings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching standings: $e');
    }
  }

  /// Fetch player statistics (top scorers) by competition ID
  Future<void> fetchPlayerStatistics(int competitionId) async {
    var url = Uri.https(_baseUrl, '/v4/competitions/$competitionId/scorers');

    try {
      final response = await http.get(url, headers: {
        'X-Auth-Token': _apiKey,
      });

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final List<dynamic> scorersJson = decodedResponse['scorers'];

        // Ensure that 'scorers' exist in the response
        if (scorersJson != null && scorersJson.isNotEmpty) {
          _players = scorersJson.map((json) => Player.fromJson(json)).toList();
          notifyListeners();
        } else {
          throw Exception('No player statistics found in the response.');
        }
      } else {
        throw Exception('Failed to load player statistics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching player statistics: $e');
    }
  }
}
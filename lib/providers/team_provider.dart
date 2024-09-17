import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tekkers/models/team.dart';

class TeamProvider with ChangeNotifier {
  List<Team> _teams = [];  // List of teams using the Team model
  bool _isLoading = false;
  String? _errorMessage;

  List<Team> get teams => _teams;  // Return a list of Team objects
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get a team by its ID
  Team? getTeamById(int id) {
    try {
      return _teams.firstWhere((team) => team.id == id);
    } catch (e) {
      return null;  // Return null if no team is found
    }
  }

  // Constructor to automatically fetch teams
  TeamProvider() {
    fetchTeams();  // Automatically load teams when the provider is initialized
  }

  // Fetch teams from an API
  Future<void> fetchTeams() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://api.football-data.org/v4/teams'),  // Correct API endpoint
        headers: {
          'X-Auth-Token': 'b373e81675174781839c2a00b33385b0',  // Your API key
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['teams'];
        _teams = data.map((teamJson) => Team.fromJson(teamJson)).toList();  // Map API data to Team model
      } else {
        throw Exception('Failed to load teams');
      }
    } catch (error) {
      _errorMessage = 'Error loading teams: $error';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
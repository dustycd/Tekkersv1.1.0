import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tekkers/models/team.dart';

class TeamProvider with ChangeNotifier {
  List<Team> _teams = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Team> get teams => _teams;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTeams() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    List<String> competitionCodes = [
      'PL', 'BL1', 'SA', 'PD', 'FL1', 'CL', 'ELC', 'PPL', 'DED', 'BSA', 'MLS', 'RFPL', 'SPL', 'EC', 'WC'
    ];

    List<Team> allTeams = [];

    try {
      for (String code in competitionCodes) {
        final response = await http.get(
          Uri.parse('https://api.football-data.org/v4/competitions/$code/teams'),
          headers: {'X-Auth-Token': 'b373e81675174781839c2a00b33385b0'},
        );

        if (response.statusCode == 200) {
          List<dynamic> data = jsonDecode(response.body)['teams'];
          List<Team> teams = data.map((teamJson) => Team.fromJson(teamJson)).toList();
          allTeams.addAll(teams);
        } else if (response.statusCode == 429) {
          _errorMessage = 'API rate limit exceeded. Please try again later.';
          throw Exception(_errorMessage);
        } else {
          _errorMessage = 'Failed to load teams for competition $code with status code ${response.statusCode}';
          throw Exception(_errorMessage);
        }

        // Delay to mitigate rate limit risks
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Deduplicate teams based on unique ID
      _teams = { for (var team in allTeams) team.id : team }.values.toList();
    } catch (error) {
      _errorMessage = 'Error loading teams: $error';
      print(_errorMessage);  // Consider logging to a remote server in production apps
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
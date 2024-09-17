import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/competition.dart';

class CompetitionProvider with ChangeNotifier {
  List<Competition> _competitions = [];
  List<Competition> _topCompetitions = [];

  List<Competition> get competitions => _competitions;
  List<Competition> get topCompetitions => _topCompetitions;

  // Fetch all competitions from the API
  Future<void> fetchCompetitions() async {
    const String apiUrl = 'https://api.football-data.org/v4/competitions';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'X-Auth-Token': 'b373e81675174781839c2a00b33385b0',  
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _competitions = (data['competitions'] as List)
            .map((item) => Competition.fromJson(item))
            .toList();
        notifyListeners();  // Notify listeners that data has been updated
      } else {
        throw Exception('Failed to load competitions');
      }
    } catch (error) {
      print('Error fetching competitions: $error');
    }
  }

  // Fetch top competitions
  Future<void> fetchTopCompetitions() async {
    const String apiUrl = 'https://api.football-data.org/v4/competitions';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'X-Auth-Token': 'b373e81675174781839c2a00b33385b0',  
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _topCompetitions = (data['competitions'] as List)
            .map((item) => Competition.fromJson(item))
            .toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load top competitions');
      }
    } catch (error) {
      print('Error fetching top competitions: $error');
    }
  }

  List<Competition> searchCompetitions(String query) {
    return _competitions
        .where((competition) => competition.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
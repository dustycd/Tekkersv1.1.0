import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlayerProvider with ChangeNotifier {
  List<dynamic> _players = [];
  final List<dynamic> _followedPlayers = [];

  List<dynamic> get players => _players;
  List<dynamic> get followedPlayers => _followedPlayers;

  PlayerProvider() {
    fetchPlayers(); // Fetch the players when the provider is initialized
  }

  Future<void> fetchPlayers() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.football-data.org/v4/players'), // Replace with correct endpoint
        headers: {
          'X-Auth-Token': 'b373e81675174781839c2a00b33385b0', // Your API key
        },
      );
      if (response.statusCode == 200) {
        _players = jsonDecode(response.body);
        notifyListeners();
      } else {
        throw Exception('Failed to load players');
      }
    } catch (error) {
      print('Error fetching players: $error');
    }
  }

  Future<void> loadFollowedPlayers() async {
    // Logic for loading followed players can be added here
  }
}
// lib/providers/player_provider.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tekkers/models/player.dart';

class PlayerProvider with ChangeNotifier {
  final String apiKey = 'b373e81675174781839c2a00b33385b0';
  Map<int, Player> _players = {}; // Map of playerId to Player object

  Map<int, Player> get players => _players;

  Future<void> fetchPlayer(int playerId) async {
    if (_players.containsKey(playerId)) {
      return; // Player data already fetched
    }
    try {
      final response = await http.get(
        Uri.parse('https://api.football-data.org/v4/persons/$playerId'),
        headers: {
          'X-Auth-Token': apiKey,
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Player player = Player.fromJson(data);
        _players[playerId] = player;
        notifyListeners();
      } else {
        throw Exception('Failed to load player data');
      }
    } catch (error) {
      print('Error fetching player $playerId: $error');
    }
  }
}
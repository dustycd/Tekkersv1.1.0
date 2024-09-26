// lib/screens/all_matches_screen.dart

import 'package:flutter/material.dart';

class AllMatchesScreen extends StatelessWidget {
  final int teamId;
  final String teamName;

  const AllMatchesScreen({
    Key? key,
    required this.teamId,
    required this.teamName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Your implementation to display all matches
    return Scaffold(
      appBar: AppBar(
        title: Text('$teamName Matches'),
      ),
      body: Center(
        child: Text('All matches for $teamName will be displayed here.'),
      ),
    );
  }
}
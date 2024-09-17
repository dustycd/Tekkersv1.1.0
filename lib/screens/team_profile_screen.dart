import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tekkers/providers/team_provider.dart';

class TeamProfileScreen extends StatelessWidget {
  final int teamId;

  const TeamProfileScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context);
    final team = teamProvider.getTeamById(teamId);  // Get team by its ID

    if (team == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Team Profile')),
        body: const Center(child: Text('Team not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Team Name: ${team.name}', style: Theme.of(context).textTheme.titleLarge),
            if (team.stadium != null)
              Text('Stadium: ${team.stadium}', style: Theme.of(context).textTheme.bodyLarge),
            if (team.formation != null)
              Text('Formation: ${team.formation}', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

extension on TeamProvider {
  getTeamById(int teamId) {}
}
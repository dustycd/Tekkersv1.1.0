import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekkers/models/match.dart';
import 'package:tekkers/providers/team_provider.dart';
import 'package:provider/provider.dart';
import 'team_profile_screen.dart';

class MatchDetailsScreen extends StatelessWidget {
  final Match match;

  const MatchDetailsScreen({
    Key? key,
    required this.match,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine screen height to set header height to 25%
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = screenHeight * 0.25;

    return DefaultTabController(
      length: 2, // Adjusted number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: BackButton(color: Colors.white), // Back arrow
        ),
        body: Column(
          children: [
            // Custom Header
            Container(
              height: headerHeight,
              width: double.infinity,
              child: Stack(
                children: [
                  // Background Field Image
                  Positioned.fill(
                    child: Image.asset(
                      "assets/field.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Semi-transparent overlay for better readability
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                  // League Identification
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        match.leagueName, // Ensure this field exists in Match model
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Team Logos and Names
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Home Team
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TeamProfileScreen(
                                        teamId: match.homeTeamId,
                                        teamName: match.homeTeamName,
                                      ),
                                    ),
                                  );
                                },
                                child: Image.network(
                                  match.homeTeamCrestUrl ?? '',
                                  height: headerHeight * 0.4,
                                  width: headerHeight * 0.4,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                match.homeTeamName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        // VS Text
                        Text(
                          'vs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Away Team
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TeamProfileScreen(
                                        teamId: match.awayTeamId,
                                        teamName: match.awayTeamName,
                                      ),
                                    ),
                                  );
                                },
                                child: Image.network(
                                  match.awayTeamCrestUrl ?? '',
                                  height: headerHeight * 0.4,
                                  width: headerHeight * 0.4,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                match.awayTeamName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tab Bar
            Container(
              color: Colors.black,
              child: TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Summary'),
                  Tab(text: 'Statistics'),
                ],
              ),
            ),
            // Tab Bar Views
            Expanded(
              child: TabBarView(
                children: [
                  // Summary Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Match Details
                        Card(
                          color: Colors.grey[200],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text('Date and Time'),
                                  subtitle: Text(
                                      DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(match.utcDate).toLocal())
                                  ),
                                ),
                                ListTile(
                                  title: Text('Match Status'),
                                  subtitle: Text(match.status),
                                ),
                                ListTile(
                                  title: Text('Score'),
                                  subtitle: Text('${match.scoreHome} - ${match.scoreAway}'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Statistics Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Add statistics widgets here
                        Text('Statistics coming soon...'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
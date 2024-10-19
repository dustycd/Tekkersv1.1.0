// match_details_screen.dart

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekkers/models/match.dart';
import 'team_profile_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

class MatchDetailsScreen extends StatefulWidget {
  final Match match;

  const MatchDetailsScreen({
    Key? key,
    required this.match,
  }) : super(key: key);

  @override
  _MatchDetailsScreenState createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  // Variables for highlight data
  String? _highlightEmbedCode;
  bool _isHighlightLoading = true;
  String? _highlightErrorMessage;

  // Variables for match statistics
  Map<String, dynamic>? _matchStatistics;
  bool _isStatisticsLoading = true;
  String? _statisticsErrorMessage;

  // Variables for match events
  List<dynamic>? _matchEvents;
  bool _isEventsLoading = true;
  String? _eventsErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMatchHighlight();
    _fetchMatchStatistics(); // Fetch detailed match statistics
    _fetchMatchEvents(); // Fetch match events
  }

  Future<void> _fetchMatchStatistics() async {
    final String apiKey = 'b373e81675174781839c2a00b33385b0';
    final String fixturesUrl = 'https://v3.football.api-sports.io/fixtures';
    final headers = {'x-apisports-key': apiKey};

    try {
      // First, search for the fixture ID based on the teams and date
      final response = await http.get(
        Uri.parse(
            '$fixturesUrl?team=${widget.match.homeTeamId}&date=${widget.match.utcDate.split('T')[0]}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['response'] != null && data['response'].isNotEmpty) {
          final fixtureId = data['response'][0]['fixture']['id'];

          // Now, fetch statistics using the fixture ID
          final statsResponse = await http.get(
            Uri.parse('$fixturesUrl/statistics?fixture=$fixtureId'),
            headers: headers,
          );

          if (statsResponse.statusCode == 200) {
            final statsData = jsonDecode(statsResponse.body);
            setState(() {
              _matchStatistics = statsData['response'];
              _isStatisticsLoading = false;
            });
          } else {
            throw Exception('Failed to load match statistics');
          }
        } else {
          setState(() {
            _statisticsErrorMessage = 'No statistics available for this match.';
            _isStatisticsLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load fixture information');
      }
    } catch (error) {
      print('Error fetching match statistics: $error');
      setState(() {
        _statisticsErrorMessage = 'Error fetching statistics: $error';
        _isStatisticsLoading = false;
      });
    }
  }

  Future<void> _fetchMatchEvents() async {
    final String apiKey = 'b373e81675174781839c2a00b33385b0';
    final String eventsUrl = 'https://v3.football.api-sports.io/fixtures/events';
    final String fixturesUrl = 'https://v3.football.api-sports.io/fixtures';
    final headers = {'x-apisports-key': apiKey};

    try {
      // First, search for the fixture ID based on the teams and date
      final response = await http.get(
        Uri.parse(
            '$fixturesUrl?team=${widget.match.homeTeamId}&date=${widget.match.utcDate.split('T')[0]}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['response'] != null && data['response'].isNotEmpty) {
          final fixtureId = data['response'][0]['fixture']['id'];

          // Now, fetch events using the fixture ID
          final eventsResponse = await http.get(
            Uri.parse('$eventsUrl?fixture=$fixtureId'),
            headers: headers,
          );

          if (eventsResponse.statusCode == 200) {
            final eventsData = jsonDecode(eventsResponse.body);
            setState(() {
              _matchEvents = eventsData['response'];
              _isEventsLoading = false;
            });
          } else {
            throw Exception('Failed to load match events');
          }
        } else {
          setState(() {
            _eventsErrorMessage = 'No events available for this match.';
            _isEventsLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load fixture information');
      }
    } catch (error) {
      print('Error fetching match events: $error');
      setState(() {
        _eventsErrorMessage = 'Error fetching events: $error';
        _isEventsLoading = false;
      });
    }
  }

  Future<void> _fetchMatchHighlight() async {
    // Your code to fetch match highlights
  }

  String _getStatusAbbreviation(String status) {
    switch (status.toUpperCase()) {
      case 'FINISHED':
        return 'FT';
      case 'PAUSED':
        return 'HT';
      case 'IN_PLAY':
        return 'LIVE';
      case 'SCHEDULED':
        return '';
      default:
        return status;
    }
  }

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
          leading: const BackButton(color: Colors.white), // Back arrow
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
                  // Date at the top
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        DateFormat('dd MMMM, yyyy').format(
                          DateTime.parse(widget.match.utcDate).toLocal(),
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  // League Identification
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        widget.match.leagueName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Team Logos, Names, and Score
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                          teamId: widget.match.homeTeamId,
                                          teamName: widget.match.homeTeamName,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.network(
                                    widget.match.homeTeamCrestUrl ?? '',
                                    height: headerHeight * 0.25,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return Icon(
                                        Icons.broken_image,
                                        size: headerHeight * 0.25,
                                        color: Colors.white,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  widget.match.homeTeamName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14, // Reduced text size
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          // Score and Status
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Score
                              Text(
                                '${widget.match.scoreHome} - ${widget.match.scoreAway}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28, // Larger font for score
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              // Match Status
                              Text(
                                _getStatusAbbreviation(widget.match.status),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
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
                                          teamId: widget.match.awayTeamId,
                                          teamName: widget.match.awayTeamName,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.network(
                                    widget.match.awayTeamCrestUrl ?? '',
                                    height: headerHeight * 0.25,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return Icon(
                                        Icons.broken_image,
                                        size: headerHeight * 0.25,
                                        color: Colors.white,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  widget.match.awayTeamName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14, // Reduced text size
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.calendar_today),
                                  title: Text('Date and Time'),
                                  subtitle: Text(
                                    DateFormat('dd MMMM yyyy, HH:mm').format(
                                      DateTime.parse(widget.match.utcDate)
                                          .toLocal(),
                                    ),
                                  ),
                                ),
                                Divider(),
                                ListTile(
                                  leading: Icon(Icons.sports_soccer),
                                  title: Text('Score'),
                                  subtitle: Text(
                                      '${widget.match.scoreHome} - ${widget.match.scoreAway}'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        // Match Events
                        _buildEventsSection(),
                        SizedBox(height: 16.0),
                        // Highlight Section
                        _buildHighlightSection(),
                      ],
                    ),
                  ),
                  // Statistics Tab
                  _buildStatisticsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    if (_isEventsLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_eventsErrorMessage != null) {
      return Text(
        _eventsErrorMessage!,
        style: TextStyle(color: Colors.red),
      );
    } else if (_matchEvents != null && _matchEvents!.isNotEmpty) {
      // Build the events UI
      List<Widget> eventWidgets = [];

      // Filter events for goals and cards
      var filteredEvents = _matchEvents!.where((event) {
        String eventType = event['type'];
        return eventType == 'Goal' || eventType == 'Card';
      }).toList();

      // Sort events by time
      filteredEvents.sort((a, b) {
        int timeA = a['time']['elapsed'];
        int timeB = b['time']['elapsed'];
        return timeA.compareTo(timeB);
      });

      for (var event in filteredEvents) {
        String teamName = event['team']['name'];
        String playerName = event['player']['name'];
        String eventType = event['type']; // 'Goal', 'Card', etc.
        String detail = event['detail']; // 'Normal Goal', 'Yellow Card', etc.
        String time = event['time']['elapsed'].toString(); // Minute

        // Determine the icon and color based on event type
        IconData eventIcon = Icons.info;
        Color iconColor = Colors.black;

        if (eventType == 'Goal') {
          eventIcon = Icons.sports_soccer;
          iconColor = Colors.green;
        } else if (eventType == 'Card') {
          if (detail == 'Yellow Card') {
            eventIcon = Icons.square;
            iconColor = Colors.yellow;
          } else if (detail == 'Red Card') {
            eventIcon = Icons.square;
            iconColor = Colors.red;
          }
        }

        eventWidgets.add(
          ListTile(
            leading: Text('$time\''),
            title: Text('$playerName'),
            subtitle: Text('$detail'),
            trailing: Icon(eventIcon, color: iconColor),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Match Events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: eventWidgets,
            ),
          ),
        ],
      );
    } else {
      return Text('No events available for this match.');
    }
  }

  Widget _buildHighlightSection() {
    if (_isHighlightLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_highlightErrorMessage != null) {
      return Text(
        _highlightErrorMessage!,
        style: TextStyle(color: Colors.red),
      );
    } else if (_highlightEmbedCode != null) {
      // Display the video using WebView
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Match Highlight',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 200,
            child: WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadHtmlString('''
                <!DOCTYPE html>
                <html>
                <head>
                  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
                  <style>
                    body, html {
                      margin: 0;
                      padding: 0;
                      background-color: black;
                    }
                    iframe {
                      position: fixed;
                      top: 0;
                      left: 0;
                      bottom: 0;
                      right: 0;
                      width: 100%;
                      height: 100%;
                      border: none;
                    }
                  </style>
                </head>
                <body>
                  ${_highlightEmbedCode!}
                </body>
                </html>
                '''),
            ),
          ),
        ],
      );
    } else {
      return SizedBox(); // Empty widget if no highlight is available
    }
  }

  Widget _buildStatisticsTab() {
    if (_isStatisticsLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_statisticsErrorMessage != null) {
      return Center(
        child: Text(
          _statisticsErrorMessage!,
          style: TextStyle(color: Colors.red),
        ),
      );
    } else if (_matchStatistics != null) {
      // Build the statistics UI
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Match Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildStatisticsList(),
          ],
        ),
      );
    } else {
      return Center(
        child: Text('No statistics available for this match.'),
      );
    }
  }

  Widget _buildStatisticsList() {
    List<Widget> statsWidgets = [];

    Map<String, dynamic> homeStats = _matchStatistics![0]['statistics'];
    Map<String, dynamic> awayStats = _matchStatistics![1]['statistics'];

    for (int i = 0; i < homeStats.length; i++) {
      String type = homeStats[i]['type'];
      String homeValue = homeStats[i]['value']?.toString() ?? '0';
      String awayValue = awayStats[i]['value']?.toString() ?? '0';

      statsWidgets.add(Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Home team value
              Expanded(
                child: Text(
                  homeValue,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 14), // Reduced text size
                ),
              ),
              // Statistic type
              Expanded(
                child: Text(
                  type,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14), // Reduced text size
                ),
              ),
              // Away team value
              Expanded(
                child: Text(
                  awayValue,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 14), // Reduced text size
                ),
              ),
            ],
          ),
          Divider(),
        ],
      ));
    }

    return Column(
      children: statsWidgets,
    );
  }
}
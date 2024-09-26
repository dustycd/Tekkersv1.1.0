import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tekkers/providers/match_provider.dart';
import 'package:tekkers/models/match.dart';
import 'package:tekkers/models/stand.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tekkers/screens/match_details_screen.dart';
import 'team_profile_screen.dart';

class MatchesScreen extends StatefulWidget {
  final int competitionId;
  final String competitionName;

  const MatchesScreen({
    Key? key,
    required this.competitionId,
    required this.competitionName,
  }) : super(key: key);

  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with SingleTickerProviderStateMixin {
  late Future<void> _fetchMatchesFuture;
  late Future<void> _fetchStandingsFuture;
  late TabController _tabController;

  final ScrollController _matchesScrollController = ScrollController();

  // GlobalKey to identify today's matches section
  final GlobalKey _todayMatchesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchMatchesFuture = _fetchMatches();
    _fetchStandingsFuture = _fetchStandings();
    _tabController = TabController(length: 3, vsync: this);

    // Listen to tab changes to handle specific actions
    _tabController.addListener(() {
      if (_tabController.index == 2 && !_tabController.indexIsChanging) {
        // When Matches tab is selected, scroll to today's matches
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToTodayMatches();
        });
      }
    });
  }

  Future<void> _fetchMatches() async {
    await Provider.of<MatchProvider>(context, listen: false)
        .fetchMatchesByCompetition(widget.competitionId);
  }

  Future<void> _fetchStandings() async {
    await Provider.of<MatchProvider>(context, listen: false)
        .fetchStandingsByCompetition(widget.competitionId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _matchesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchProvider = Provider.of<MatchProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.competitionName,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black, // Transparent AppBar background
        elevation: 0, // Remove shadow
        iconTheme:
            const IconThemeData(color: Colors.white), // Back button color
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // Highlighted tab color
          unselectedLabelColor: Colors.white,
          indicatorColor: Colors.white, // Tab underline
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Table'),
            Tab(text: 'Matches'),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              "assets/field.png",
              fit: BoxFit.cover,
            ),
          ),

          TabBarView(
            controller: _tabController,
            children: [
              // Overview Tab
              _buildOverviewTab(matchProvider),

              // Table Tab
              FutureBuilder<void>(
                future: _fetchStandingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else {
                    if (matchProvider.standings.isEmpty) {
                      return const Center(child: Text('No standings found'));
                    } else {
                      return _buildStandingsTable(matchProvider.standings);
                    }
                  }
                },
              ),

              // Matches Tab
              FutureBuilder<void>(
                future: _fetchMatchesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else {
                    if (matchProvider.matches.isEmpty) {
                      return const Center(child: Text('No matches found'));
                    } else {
                      return _buildMatchList(matchProvider.matches);
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the Overview Tab
  Widget _buildOverviewTab(MatchProvider matchProvider) {
    // Example statistics; adjust based on available data
    final totalMatches = matchProvider.matches.length;
    final totalGoals = matchProvider.matches.fold<int>(0,
        (sum, match) => sum + (match.scoreHome ?? 0) + (match.scoreAway ?? 0));
    final topTeam = matchProvider.standings.isNotEmpty
        ? matchProvider.standings.first.teamName
        : 'N/A';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Competition Overview',
             style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildOverviewStatistic(
                      'Total Matches', totalMatches.toString()),
                  const Divider(),
                  _buildOverviewStatistic('Total Goals', totalGoals.toString()),
                  const Divider(),
                  _buildOverviewStatistic('Top Team', topTeam),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Add more overview content as needed, e.g., recent match results
          Text(
            'Recent Matches',
             style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentMatches(matchProvider.matches),
        ],
      ),
    );
  }

  /// Helper method to build overview statistics
  Widget _buildOverviewStatistic(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// Builds the Recent Matches section in the Overview Tab
  Widget _buildRecentMatches(List<Match> matches) {
    // Assuming recent matches are the latest ones; adjust logic as needed
    final recentMatches = matches.where((match) {
      final matchDate = DateTime.parse(match.utcDate);
      return matchDate.isBefore(DateTime.now()) && match.status == 'FINISHED';
    }).toList();

    // Sort by date descending
    recentMatches.sort((a, b) =>
        DateTime.parse(b.utcDate).compareTo(DateTime.parse(a.utcDate)));

    return recentMatches.isEmpty
        ? const Text('No recent matches available.')
        : Column(
            children: recentMatches
                .take(5)
                .map((match) => _buildMatchTile(match))
                .toList(),
          );
  }

// Builds the Standings Table using DataTable with clickable team logos and names
Widget _buildStandingsTable(List<Standing> standings) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Reduced padding
    child: Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            // Set a max height if desired, e.g., half the screen height
            // height: constraints.maxHeight * 0.8,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical, // Enable vertical scrolling
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    // Reduced column spacing for tighter layout
                    columnSpacing: 12.0,
                    dataRowHeight: 36.0, 
                    headingRowHeight: 40.0,
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Pos',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Team',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'P',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'GD',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Pts',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    rows: standings.map((standing) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '${standing.position}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          DataCell(
                            InkWell(
                              onTap: () {
                                // Navigate to TeamProfileScreen for the team
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TeamProfileScreen(
                                      teamId: standing.teamId, // Ensure you have this field
                                      teamName: standing.teamName,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  standing.teamCrestUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: standing.teamCrestUrl,
                                          width: 20, // Reduced size
                                          height: 20, // Reduced size
                                          placeholder: (context, url) =>
                                              const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                                Icons.sports_soccer,
                                                size: 20,
                                              ),
                                        )
                                      : const Icon(
                                          Icons.sports_soccer,
                                          size: 20,
                                        ),
                                  const SizedBox(width: 6), // Reduced spacing
                                  Expanded(
                                    child: Text(
                                      standing.teamName,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${standing.playedGames}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${standing.goalDifference}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${standing.points}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

  /// Builds the Match List categorized by date
  Widget _buildMatchList(List<Match> matches) {
    Map<String, List<Match>> categorizedMatches = {};

    // Categorize matches by date
    for (var match in matches) {
      String matchDate = match.utcDate.substring(0, 10); // YYYY-MM-DD format
      if (!categorizedMatches.containsKey(matchDate)) {
        categorizedMatches[matchDate] = [];
      }
      categorizedMatches[matchDate]!.add(match);
    }

    // Sort dates ascending
    List<String> sortedDates = categorizedMatches.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return ListView.builder(
      controller: _matchesScrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        String dateKey = sortedDates[index];
        String dateLabel =
            DateFormat('EEEE, d MMM').format(DateTime.parse(dateKey));
        bool isToday =
            dateKey == DateFormat('yyyy-MM-dd').format(DateTime.now());
        List<Match> dailyMatches = categorizedMatches[dateKey]!;

        return _buildDateSection(dateLabel, dailyMatches, isToday);
      },
    );
  }

  /// Builds a section for a specific date containing matches
  Widget _buildDateSection(String date, List<Match> matches, bool isToday) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0), // Spacing between sections
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Highlight today's date
          Row(
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isToday
                      ? const Color.fromARGB(255, 95, 80, 255)
                      : Colors.black,
                ),
              ),
              if (isToday)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.today, color: Colors.black, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: matches.map((match) => _buildMatchTile(match)).toList(),
          ),
        ],
      ),
    );
  }

 /// Builds an individual match tile with logos, scores, and match status
Widget _buildMatchTile(Match match) {
  String homeTeamName = match.homeTeamName;
  String awayTeamName = match.awayTeamName;
  String? homeCrestUrl = match.homeTeamCrestUrl;
  String? awayCrestUrl = match.awayTeamCrestUrl;
  String matchStatus = match.status;
  String scoreHome = match.scoreHome?.toString() ?? '-';
  String scoreAway = match.scoreAway?.toString() ?? '-';
  String statusMessage;

  if (matchStatus == 'LIVE' || matchStatus == 'IN_PLAY') {
    int minutesPlayed =
        DateTime.now().difference(DateTime.parse(match.utcDate)).inMinutes;
    statusMessage = '$minutesPlayed\'';
  } else if (matchStatus == 'PAUSED') {
    statusMessage = 'HT';
  } else if (matchStatus == 'FINISHED') {
    statusMessage = 'FT';
  } else {
    statusMessage =
        DateFormat('h:mm a').format(DateTime.parse(match.utcDate).toLocal());
  }

  return Card(
    color: Colors.white.withOpacity(0.95),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    child: ListTile(
      contentPadding:
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            statusMessage,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      title: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to TeamProfileScreen for the home team
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamProfileScreen(
                          teamId: match.homeTeamId,
                          teamName: match.homeTeamName,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    homeTeamName,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // Navigate to TeamProfileScreen for the home team
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeamProfileScreen(
                        teamId: match.homeTeamId,
                        teamName: match.homeTeamName,
                      ),
                    ),
                  );
                },
                child: _buildTeamLogo(homeCrestUrl),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to TeamProfileScreen for the away team
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamProfileScreen(
                          teamId: match.awayTeamId,
                          teamName: match.awayTeamName,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    awayTeamName,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // Navigate to TeamProfileScreen for the away team
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeamProfileScreen(
                        teamId: match.awayTeamId,
                        teamName: match.awayTeamName,
                      ),
                    ),
                  );
                },
                child: _buildTeamLogo(awayCrestUrl),
              ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min, // Ensure minimal space usage
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$scoreHome',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '$scoreAway',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(width: 8), // Spacing between score and menu
          _buildPopupMenu(match),
        ],
      ),
      onTap: () {
        // Navigate to MatchDetailsScreen when the match tile is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchDetailsScreen(match: match),
          ),
        );
      },
    ),
  );
}

  // Builds the popup menu for toggling notifications
  Widget _buildPopupMenu(Match match) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 1) {
          _toggleNotifications(match);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.notifications, size: 18),
              SizedBox(width: 8),
              Text("Toggle Notifications"),
            ],
          ),
        ),
      ],
    );
  }

  // Method to toggle notifications for a match
  void _toggleNotifications(Match match) async {
  // Implement your logic to subscribe/unsubscribe to match notifications

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Subscribed to notifications for ${match.homeTeamName} vs ${match.awayTeamName}',
        ),
      ),
    );
  }

  /// Builds the team logo widget using CachedNetworkImage for performance
  Widget _buildTeamLogo(String? crestUrl) {
    if (crestUrl != null && crestUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: crestUrl,
        width: 24,
        height: 24,
        placeholder: (context, url) =>
            const CircularProgressIndicator(strokeWidth: 2),
        errorWidget: (context, url, error) =>
            const Icon(Icons.sports_soccer, size: 24),
      );
    } else {
      return const Icon(Icons.sports_soccer, size: 24);
    }
  }

  /// Scrolls to today's matches in the Matches Tab
  void _scrollToTodayMatches() {
    // Using GlobalKey to find today's matches section and scroll to it
    // Assign the _todayMatchesKey to the today's date section

    // Find the context of the today's matches section
    BuildContext? todayContext = _todayMatchesKey.currentContext;

    if (todayContext != null) {
      Scrollable.ensureVisible(
        todayContext,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // If GlobalKey approach is not feasible, alternatively, find the index
      final matchProvider = Provider.of<MatchProvider>(context, listen: false);
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Find the index where dateKey == today
      int index = matchProvider.matches
          .indexWhere((match) => match.utcDate.startsWith(today));

      if (index != -1) {
        // Approximate the position to scroll to based on index
        // This is a simplified example; adjust based on your UI's specifics
        double position =
            index * 100.0; // Adjust the multiplier based on item height
        _matchesScrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }
}
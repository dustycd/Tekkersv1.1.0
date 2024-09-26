import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekkers/models/team.dart';
import 'package:tekkers/screens/matches_screen.dart';
import 'package:tekkers/screens/team_profile_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // For Timer
import 'package:logging/logging.dart'; // For logging errors

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // API key and base URL
  final String apiKey =
      'b373e81675174781839c2a00b33385b0'; // Replace with your actual API key
  final String baseUrl = 'https://api.football-data.org/v4';

  // Controllers and variables
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _competitionsData = [];
  List<Team> _teamsData = [];
  List<String> _recentSearches = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchText = '';

  // Logger
  final Logger _logger = Logger('SearchScreen');

  // Timer for data refreshing
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initializeLogging();
    _loadRecentSearches();
    _loadData();
    _startDataRefreshTimer();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Initialize logger
  void _initializeLogging() {
    hierarchicalLoggingEnabled = true; // Enable hierarchical logging
    _logger.level = Level.ALL;
    _logger.onRecord.listen((record) {
      print(
          '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    });
  }

  // Start a timer to refresh data periodically (e.g., every 24 hours)
  void _startDataRefreshTimer() {
    const duration = Duration(hours: 24);
    _refreshTimer = Timer.periodic(duration, (Timer t) {
      _logger.info('Refreshing data...');
      _loadData();
    });
  }

  // Load competitions and teams data
  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _fetchCompetitions();
      await _fetchTeams();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error loading data: $error';
      });
      _logger.severe('Error loading data: $error');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch competitions from API
  Future<void> _fetchCompetitions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/competitions'),
        headers: {'X-Auth-Token': apiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> competitions = data['competitions'];
        competitions = competitions.where((competition) {
          String competitionName =
              competition['name']?.toString().toLowerCase() ?? '';
          return competitionName != 'copa libertadores';
        }).toList();
        if (!mounted) return;
        setState(() {
          _competitionsData = competitions;
        });
        _logger.info('Competitions data loaded successfully.');
      } else {
        throw Exception(
            'Failed to load competitions: ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Error fetching competitions: $error');
    }
  }

  // Fetch teams from API
  Future<void> _fetchTeams() async {
    try {
      List<Team> allTeams = [];

      for (var competition in _competitionsData) {
        final int competitionId = competition['id'];

        try {
          final response = await http.get(
            Uri.parse('$baseUrl/competitions/$competitionId/teams'),
            headers: {'X-Auth-Token': apiKey},
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            List<dynamic> teamsList = data['teams'];

            List<Team> teams = teamsList.map((teamJson) {
              return Team.fromJson(teamJson);
            }).toList();

            allTeams.addAll(teams);
          } else {
            _logger.warning(
                'Failed to load teams for competition ID $competitionId: ${response.reasonPhrase}');
          }
        } catch (e) {
          _logger.warning(
              'Exception when loading teams for competition ID $competitionId: $e');
        }

        // Simple rate limiting to prevent hitting API limits
        await Future.delayed(const Duration(milliseconds: 200));
      }

      if (!mounted) return;
      setState(() {
        _teamsData = allTeams;
      });
      _logger.info('Teams data loaded successfully.');
    } catch (error) {
      throw Exception('Error fetching teams: $error');
    }
  }

  // Load recent searches from local storage
  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
    _logger.info('Recent searches loaded.');
  }

  // Save a recent search to local storage
  Future<void> _saveRecentSearch(String search) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(search);
    _recentSearches.insert(0, search);
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }
    await prefs.setStringList('recentSearches', _recentSearches);
    _logger.info('Recent search "$search" saved.');
  }

  // Remove a recent search from local storage
  Future<void> _removeRecentSearch(String search) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(search);
    await prefs.setStringList('recentSearches', _recentSearches);
    if (!mounted) return;
    setState(() {});
    _logger.info('Recent search "$search" removed.');
  }

  // Handle search submission
  void _onSearchSubmitted(String value) {
    if (value.isNotEmpty) {
      setState(() {
        _searchText = value;
      });
      _saveRecentSearch(value);
    }
  }

  // Handle search text change
  void _onSearchChanged(String value) {
    setState(() {
      _searchText = value;
    });
  }

  // Clear search text
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _errorMessage != null
              ? _buildErrorMessage()
              : _searchText.isEmpty
                  ? _buildRecentSearches()
                  : _buildSearchResults(),
    );
  }

  // Build AppBar with search field
  AppBar _buildAppBar() {
    return AppBar(
      title: TextField(
        controller: _searchController,
        onSubmitted: _onSearchSubmitted,
        onChanged: _onSearchChanged,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Search for teams or competitions...',
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
      ),
      backgroundColor: Colors.black,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: _clearSearch,
        ),
      ],
    );
  }

  // Build loading indicator
  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  // Build error message
  Widget _buildErrorMessage() {
    return Center(
      child: Text(
        _errorMessage!,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  // Build recent searches list
  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return const Center(
        child: Text(
          'No recent searches',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return ListView.builder(
      itemCount: _recentSearches.length,
      itemBuilder: (context, index) {
        final search = _recentSearches[index];
        return ListTile(
          leading: const Icon(Icons.history, color: Colors.white),
          title: Text(
            search,
            style: const TextStyle(color: Colors.white),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => _removeRecentSearch(search),
          ),
          onTap: () {
            _searchController.text = search;
            _onSearchSubmitted(search);
          },
        );
      },
    );
  }

  // Build search results
  Widget _buildSearchResults() {
    final List<dynamic> filteredCompetitions = _filterCompetitions(_searchText);
    final List<Team> filteredTeams = _filterTeams(_searchText);

    final List<Map<String, dynamic>> searchResults = [
      ...filteredCompetitions
          .map((comp) => {'type': 'competition', 'data': comp}),
      ...filteredTeams.map((team) => {'type': 'team', 'data': team}),
    ];

    if (searchResults.isEmpty) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final item = searchResults[index];
        if (item['type'] == 'competition') {
          return _buildCompetitionListItem(item['data']);
        } else if (item['type'] == 'team') {
          return _buildTeamListItem(item['data']);
        } else {
          return Container();
        }
      },
    );
  }

  // Filter competitions based on search text
  List<dynamic> _filterCompetitions(String query) {
    return _competitionsData.where((competition) {
      final name = competition['name']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();
  }

  // Filter teams based on search text
  List<Team> _filterTeams(String query) {
    return _teamsData.where((team) {
      final name = team.name.toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();
  }

  // Build competition list item
  Widget _buildCompetitionListItem(dynamic competition) {
    return ListTile(
      leading: competition['emblem'] != null
          ? Image.network(
              competition['emblem'],
              height: 40,
              width: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.sports_soccer,
                    size: 40, color: Colors.white);
              },
            )
          : const Icon(Icons.sports_soccer, size: 40, color: Colors.white),
      title: Text(
        competition['name'] ?? 'Unknown Competition',
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        'Competition',
        style: TextStyle(color: Colors.grey),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchesScreen(
              competitionId: competition['id'],
              competitionName: competition['name'],
            ),
          ),
        );
      },
    );
  }

  // Build team list item
  Widget _buildTeamListItem(Team team) {
    return ListTile(
      leading: team.crestUrl != null && team.crestUrl.isNotEmpty
          ? Image.network(
              team.crestUrl,
              height: 40,
              width: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.person, size: 40, color: Colors.white);
              },
            )
          : const Icon(Icons.person, size: 40, color: Colors.white),
      title: Text(
        team.name,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        'Team',
        style: TextStyle(color: Colors.grey),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeamProfileScreen(
              teamId: team.id,
              teamName: team.name,
            ),
          ),
        );
      },
    );
  }
}

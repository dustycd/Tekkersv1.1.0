import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tekkers/providers/team_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'matches_screen.dart';
import 'search_screen.dart'; // Import the SearchScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String apiKey =
      'b373e81675174781839c2a00b33385b0'; 
  List<dynamic> _competitionsData = [];
  bool _isCompetitionsLoading = true;
  String? _competitionsErrorMessage;

  @override
  void initState() {
    super.initState();
    fetchCompetitions();
  }

  Future<void> fetchCompetitions() async {
    setState(() {
      _isCompetitionsLoading = true;
      _competitionsErrorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.football-data.org/v4/competitions'),
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
        setState(() {
          _competitionsData = competitions;
        });
      } else {
        throw Exception('Failed to load competitions');
      }
    } catch (error) {
      setState(() {
        _competitionsErrorMessage = 'Error loading competitions: $error';
      });
    } finally {
      setState(() {
        _isCompetitionsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeamProvider(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/tekkersicon.png',
                  height: 30,
                  width: 30,
                ),
                const SizedBox(width: 8),
                const Flexible(
                  child: Text(
                    'Tekkers',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          title: const Text(
            'Home',
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.black,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Navigate to SearchScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: _buildHomeContent(),
      ),
    );
  }

  Widget _buildHomeContent() {
    if (_isCompetitionsLoading) {
      return _shimmerEffect();
    } else if (_competitionsErrorMessage != null) {
      return Center(
        child: Text(
          'Error: $_competitionsErrorMessage',
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Major Competitions'),
            _buildCompetitionCards(_competitionsData),
          ],
        ),
      );
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildCompetitionCards(List<dynamic> competitions) {
    int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.85,
        ),
        itemCount: competitions.length,
        itemBuilder: (context, index) {
          final competition = competitions[index];
          return GestureDetector(
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
            child: _buildCompetitionCard(competition),
          );
        },
      ),
    );
  }

  Widget _buildCompetitionCard(dynamic competition) {
    final String logoUrl = competition['emblem'] ?? '';

    return Card(
      color: const Color.fromARGB(255, 196, 195, 195).withOpacity(0.95),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              logoUrl,
              height: 60,
              width: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.sports_soccer,
                    size: 60, color: Colors.black);
              },
            ),
            const SizedBox(height: 12),
            Text(
              competition['name'],
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              competition['area']['name'],
              style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerEffect() {
    int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: GridView.builder(
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.85,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 6,
          itemBuilder: (context, index) => const Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 160,
            ),
          ),
        ),
      ),
    );
  }
}
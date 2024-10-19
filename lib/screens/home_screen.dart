// home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tekkers/providers/team_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'matches_screen.dart';
import 'search_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flip_card/flip_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String apiKey = 'b373e81675174781839c2a00b33385b0'; // Replace with your API key
  List<dynamic> _competitionsData = [];
  List<dynamic> _newsArticles = [];
  List<Map<String, String>> _gameHighlights = [];
  bool _isCompetitionsLoading = true;
  bool _isNewsLoading = true;
  bool _isHighlightsLoading = true;
  String? _competitionsErrorMessage;
  String? _newsErrorMessage;
  String? _highlightsErrorMessage;

  @override
  void initState() {
    super.initState();
    fetchCompetitions();
    fetchNews();
    _fetchGameHighlights();
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
          String competitionName = competition['name']?.toString().toLowerCase() ?? '';
          return competitionName != 'fifa world cup' &&
              competitionName != 'european championship' &&
              competitionName != 'copa libertadores';
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

  Future<void> fetchNews([String query = 'soccer']) async {
    const String newsApiKey = 'cd2082da9b154b4eb2083a6cf2b29731';

    final String url = 'https://newsapi.org/v2/everything?q=$query+soccer+OR+football+OR+Premier+League+OR+La+Liga+OR+Bundesliga+OR+Serie+A+OR+Ligue+1&apiKey=$newsApiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _newsArticles = data['articles'];
          _isNewsLoading = false;
        });
      } else {
        throw Exception('Failed to load news');
      }
    } catch (error) {
      setState(() {
        _newsErrorMessage = 'Error fetching news: $error';
        _isNewsLoading = false;
      });
    }
  }

  Future<void> _fetchGameHighlights() async {
  final String url = 'https://www.scorebat.com/video-api/v3/';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> highlights = data['response'];
      List<Map<String, String>> processedHighlights = [];

      // Define the top 5 leagues (lowercase for case-insensitive comparison)
      List<String> topLeagues = [
        'premier league',
        'la liga',
        'bundesliga',
        'serie a',
        'ligue 1',
      ];

      for (var item in highlights) {
        String competitionName = item['competition'] ?? '';
        competitionName = competitionName.toLowerCase();

        // Check if the competition is from China or Misli League
        bool isExcludedCompetition = competitionName.contains('china') ||
                                     competitionName.contains('chinese') ||
                                     competitionName.contains('misli');

        // Check if the competition is one of the top leagues and not excluded
        if (topLeagues.any((league) => competitionName.contains(league)) && !isExcludedCompetition) {
          String thumbnail = item['thumbnail'] ?? '';
          String title = item['title'] ?? '';
          List videos = item['videos'];
          if (videos != null && videos.isNotEmpty) {
            String embedCode = videos[0]['embed']; // Take the first video
            // Extract the src attribute from embedCode
            RegExp regExp = RegExp(r"src='([^']+)'");
            Match? match = regExp.firstMatch(embedCode);
            String videoUrl = match != null ? match.group(1)! : '';
            if (thumbnail.isNotEmpty && title.isNotEmpty && videoUrl.isNotEmpty) {
              processedHighlights.add({
                'thumbnail': thumbnail,
                'title': title,
                'videoUrl': videoUrl,
              });
            }
          }
        }
      }

      setState(() {
        _gameHighlights = processedHighlights;
        _isHighlightsLoading = false;
      });
    } else {
      setState(() {
        _highlightsErrorMessage = 'Failed to load highlights';
        _isHighlightsLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _highlightsErrorMessage = 'Error fetching highlights: $e';
      _isHighlightsLoading = false;
    });
  }
}

  Future<void> _launchURL(String? url) async {
    if (url == null) {
      debugPrint('URL is null');
      return;
    }
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeamProvider(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background2.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: _buildHomeContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
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
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompetitionsSection(),
          _buildNewsSection(),
          _buildGameHighlightsSection(),
        ],
      ),
    );
  }

  Widget _buildCompetitionsSection() {
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Major Competitions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _competitionsData.length,
              itemBuilder: (context, index) {
                final competition = _competitionsData[index];
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
                  child: Card(
                    color: Colors.white,
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Container(
                      width: 140,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            competition['emblem'] ?? '',
                            height: 60,
                            width: 60,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.sports_soccer, size: 60, color: Colors.grey);
                            },
                          ),
                          Text(
                            competition['name'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
  }

  Widget _buildGameHighlightsSection() {
    if (_isHighlightsLoading) {
      return _shimmerEffect();
    } else if (_highlightsErrorMessage != null) {
      return Center(
        child: Text(
          'Error: $_highlightsErrorMessage',
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (_gameHighlights.isEmpty) {
      return Center(
        child: Text(
          'No highlights available.',
          style: const TextStyle(color: Colors.white),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
              child: Text(
                'Game Highlights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 120, // Adjusted height for smaller cards
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _gameHighlights.length,
                itemBuilder: (context, index) {
                  final highlight = _gameHighlights[index];
                  return GestureDetector(
                    onTap: () => _launchURL(highlight['videoUrl']!),
                    child: Card(
                      color: Colors.white.withOpacity(0.85),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          highlight['thumbnail']!,
                          width: 160, // Adjusted width for smaller cards
                          height: 120, // Match the height of the SizedBox
                          fit: BoxFit.contain, // Show full image without cropping
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey,
                              width: 160,
                              height: 120,
                              child: const Icon(Icons.broken_image,
                                  color: Colors.white),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildNewsSection() {
    if (_isNewsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_newsErrorMessage != null) {
      return Center(
        child: Text(
          'Error: $_newsErrorMessage',
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (_newsArticles.isEmpty) {
      return Center(
        child: Text(
          'No news articles available.',
          style: const TextStyle(color: Colors.white),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
              child: Text(
                'Latest Football News',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _newsArticles.length,
                itemBuilder: (context, index) {
                  final article = _newsArticles[index];
                  return Container(
                    width: 180,
                    padding: const EdgeInsets.only(left: 16),
                    child: FlipCard(
                      direction: FlipDirection.HORIZONTAL, // default
                      front: Card(
                        color: Colors.white.withOpacity(0.85),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              child: Image.network(
                                article['urlToImage'] ?? '',
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey,
                                    width: double.infinity,
                                    height: 120,
                                    child: const Icon(Icons.broken_image,
                                        color: Colors.white),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                article['title'] ?? 'No title',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      back: Card(
                        color: Colors.white.withOpacity(0.85),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                article['description'] ??
                                    'No description available',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => _launchURL(article['url']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text('Read More'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _shimmerEffect() {
    return SizedBox(
      height: 200,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          itemBuilder: (context, index) => const Card(
            color: Colors.white,
            margin: EdgeInsets.all(8),
            child: SizedBox(width: 140, height: 200),
          ),
        ),
      ),
    );
  }
}
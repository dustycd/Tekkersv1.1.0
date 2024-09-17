import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'matches_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String apiKey =
      'b373e81675174781839c2a00b33385b0'; // football-data.org API key
  late Future<List<dynamic>> _competitions;

  @override
  void initState() {
    super.initState();
    _competitions = fetchCompetitions();
  }

  Future<List<dynamic>> fetchCompetitions() async {
    final response = await http.get(
      Uri.parse('https://api.football-data.org/v4/competitions'),
      headers: {'X-Auth-Token': apiKey},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Filter out "Copa Libertadores" competition
      List<dynamic> competitions = data['competitions'];
      competitions = competitions.where((competition) {
        String competitionName =
            competition['name']?.toString().toLowerCase() ?? '';
        return competitionName != 'copa libertadores';
      }).toList();
      return competitions;
    } else {
      throw Exception('Failed to load competitions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.black, // Set text color to black
            fontSize: 16, // Decreased font size for a smaller header
          ),
        ),
        backgroundColor: Colors.transparent, // Transparent AppBar background
        elevation: 0, // Remove elevation to prevent shadow
        centerTitle: true, // Center the title
        toolbarHeight: 45, // Reduced AppBar height
      ),
      body: Stack(
        children: [
          // Football field background image
          Positioned.fill(
            child: Image.asset(
              "assets/field.png", // Ensure this image exists in assets
              fit: BoxFit.cover,
            ),
          ),
          // Content on top of the background
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20), // Add padding at the bottom
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Major Competitions'),
                _buildCompetitions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Reduced vertical padding
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20, // Decreased font size appropriately
          fontWeight: FontWeight.w500, // Adjusted font weight
          fontFamily: 'Roboto',
          // Removed letter spacing
        ),
        textAlign: TextAlign.left, // Align text to the left
      ),
    );
  }

  Widget _buildCompetitions() {
    return FutureBuilder<List<dynamic>>(
      future: _competitions,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _shimmerEffect();
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No competitions found',
              style: TextStyle(color: Colors.black),
            ),
          );
        }

        return _buildCompetitionCards(snapshot.data!);
      },
    );
  }

  Widget _buildCompetitionCards(List<dynamic> competitions) {
    // Determine the number of columns based on screen width for responsiveness
    int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        physics:
            const NeverScrollableScrollPhysics(), // Disable scrolling since it's wrapped in SingleChildScrollView
        shrinkWrap: true, // Ensure it wraps the content
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount, // Responsive columns
          crossAxisSpacing: 16.0, // Spacing between columns
          mainAxisSpacing: 16.0, // Spacing between rows
          childAspectRatio: 0.85, // Adjusted to make cards slightly taller
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
                    competitionId: competition['id'], // Pass competition ID
                    competitionName:
                        competition['name'], // Pass competition name
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
    final String logoUrl =
        competition['emblem'] ?? ''; // Get logo URL from API response

    return Card(
      color: Colors.white.withOpacity(0.95), // Slightly transparent white
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3, // Slight elevation for subtle shadow
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0), // Adjusted padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              logoUrl, // Use the emblem URL from the API
              height: 60, // Reverted to smaller logo height
              width: 60, // Reverted to smaller logo width
              fit: BoxFit.contain, // Maintain aspect ratio
              errorBuilder: (context, error, stackTrace) {
                // Fallback in case image fails to load
                return const Icon(Icons.sports_soccer, size: 60, color: Colors.black);
              },
            ),
            const SizedBox(height: 12), // Adjusted spacing
            Text(
              competition['name'],
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16), // Maintain increased font size
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6), // Adjusted spacing
            Text(
              competition['area']['name'],
              style: const TextStyle(
                  color: Color.fromARGB(255, 160, 160, 160), fontSize: 14), // Maintain font size
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerEffect() {
    // Determine the number of columns based on screen width for responsiveness
    int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.85, // Match the actual grid's aspect ratio
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 6, // Increased number to better fill space during loading
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
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search for players, teams, competitions...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchTerm = value;
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchTerm = '';
              });
            },
          ),
        ],
      ),
      body: _searchTerm.isEmpty
          ? const Center(child: Text('Enter a search term to begin'))
          : FutureBuilder<List<dynamic>>(
              // Replace with actual search function to fetch results
              future: _fetchSearchResults(_searchTerm),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No results found.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];
                      return ListTile(
                        leading: const Icon(Icons.sports_soccer), // Use actual data for icon
                        title: Text(item['name']), // Replace with actual name
                        subtitle: Text(item['type']), // Replace with actual type (e.g., player, team)
                        onTap: () {
                          // Implement onTap to navigate to detailed page
                        },
                      );
                    },
                  );
                }
              },
            ),
    );
  }

  Future<List<dynamic>> _fetchSearchResults(String query) async {
    // TODO: Implement the search function using API
    // For now, return a dummy list
    await Future.delayed(const Duration(seconds: 1));
    return [
      {'name': 'Real Madrid', 'type': 'Team'},
      {'name': 'Lionel Messi', 'type': 'Player'},
      {'name': 'Premier League', 'type': 'Competition'},
    ];
  }
}
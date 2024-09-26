import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> _newsArticles = [];
  bool _isLoading = true;
  bool _hasError = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews([String query = 'soccer']) async {
    const String apiKey = 'cd2082da9b154b4eb2083a6cf2b29731';

    // Modify the query to include keywords related to soccer (European football)
    final String url =
        'https://newsapi.org/v2/everything?q=$query+soccer+OR+football+OR+Premier+League+OR+La+Liga+OR+Bundesliga+OR+Serie+A+OR+Ligue+1&apiKey=$apiKey'; // Focused on European leagues and soccer

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // Filtering articles that contain specific soccer-related keywords
          _newsArticles = data['articles'].where((article) {
            final title = (article['title'] ?? '').toLowerCase();
            final description = (article['description'] ?? '').toLowerCase();
            return title.contains('soccer') ||
                title.contains('football') ||
                description.contains('soccer') ||
                description.contains('football') ||
                title.contains('premier league') ||
                title.contains('la liga') ||
                title.contains('bundesliga') ||
                title.contains('serie a') ||
                title.contains('ligue 1');
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load news');
      }
    } catch (error) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      debugPrint('Error fetching news: $error');
    }
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      _fetchNews(query);
    }
  }

  // Function to format the published date to 'X time ago'
  String formatTimeAgo(DateTime publishedAt) {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays >= 1) {
      return difference.inDays == 1 ? '1 day ago' : '${difference.inDays} days ago';
    } else if (difference.inHours >= 1) {
      return difference.inHours == 1 ? '1 hour ago' : '${difference.inHours} hours ago';
    } else if (difference.inMinutes >= 1) {
      return difference.inMinutes == 1 ? '1 minute ago' : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using a transparent AppBar to overlay on the background image
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'News',
           style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.white, // Set text color to black
            fontSize: 16, // Decreased font size for a smaller header
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NewsSearch(_newsArticles, _fetchNews),
              );
            },
          ),
        ],
        elevation: 0, // Removes the AppBar shadow
      ),
      extendBodyBehindAppBar: true, // Allows the body to extend behind the AppBar
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/field.png'), // Ensure the path is correct
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent overlay for better readability
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          // Main Content
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hasError
                  ? const Center(
                      child: Text(
                        'Failed to load news. Please try again.',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _fetchNews(),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: kToolbarHeight + 20),
                        itemCount: _newsArticles.length,
                        itemBuilder: (context, index) {
                          final article = _newsArticles[index];
                          final publishedAt = DateTime.parse(article['publishedAt']);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            child: Card(
                              color: Colors.white.withOpacity(0.8),
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (article['urlToImage'] != null)
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                      child: Image.network(
                                        article['urlToImage'],
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context, Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return SizedBox(
                                            width: double.infinity,
                                            height: 200,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                        loadingProgress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: double.infinity,
                                            height: 200,
                                            color: Colors.grey,
                                            child: const Icon(
                                              Icons.broken_image,
                                              size: 50,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article['title'] ?? 'No title',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          article['description'] ?? '',
                                          style: TextStyle(color: Colors.grey[800]),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Source: ${article['source']['name']}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            Text(
                                              formatTimeAgo(publishedAt), // Displaying formatted time ago
                                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: ElevatedButton.icon(
                                            onPressed: () => _launchURL(article['url']),
                                            icon: const Icon(Icons.link, size: 16),
                                            label: const Text('Read more'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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

  void _launchURL(String? url) async {
    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      debugPrint('Could not launch $url');
    }
  }
}

class NewsSearch extends SearchDelegate {
  final List<dynamic> newsArticles;
  final Function(String) fetchNews;

  NewsSearch(this.newsArticles, this.fetchNews);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    fetchNews(query);
    return Container(); // No UI here as it's handled in the original screen
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
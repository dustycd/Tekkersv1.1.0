import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsProvider with ChangeNotifier {
  List<dynamic> _newsArticles = [];
  bool _isLoading = false;
  bool _hasError = false;

  List<dynamic> get newsArticles => _newsArticles;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  // Fetch news articles, defaulting to 'football' as the search query
  Future<void> fetchNews([String query = 'football']) async {
    const String apiKey = 'cd2082da9b154b4eb2083a6cf2b29731';
    final String url = 'https://newsapi.org/v2/everything?q=$query football&apiKey=$apiKey';

    try {
      _isLoading = true;
      _hasError = false;
      notifyListeners();

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _newsArticles = data['articles'];
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (error) {
      _hasError = true;
      _isLoading = false;
      notifyListeners();
      print('Error fetching news: $error');
    }
  }
}


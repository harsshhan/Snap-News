import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsService {
  final String apiKey = dotenv.env['API_KEY'] ?? '';
  static const String baseUrl = 'https://newsapi.org/v2';
  
  Future<List<Article>> fetchTopHeadlines({String? query}) async {
    try {
      String url = '$baseUrl/top-headlines?country=us&apiKey=$apiKey';
      
      if (query != null && query.isNotEmpty) {
        url = '$baseUrl/everything?q=$query&sortBy=publishedAt&apiKey=$apiKey';
      }
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articlesJson = data['articles'] ?? [];
        
        return articlesJson
            .map((json) => Article.fromJson(json))
            .where((article) => article.title.isNotEmpty && article.url.isNotEmpty)
            .toList();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
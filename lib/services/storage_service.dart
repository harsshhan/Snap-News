import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

class StorageService {
  static const String _articlesKey = 'cached_articles';
  static const String _lastFetchKey = 'last_fetch_time';

  static Future<void> saveArticles(List<Article> articles) async {
    final prefs = await SharedPreferences.getInstance();
    final article_json = articles.map((article) => article.toJson()).toList();
    await prefs.setString(_articlesKey, json.encode(article_json));
    await prefs.setInt(_lastFetchKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<List<Article>> loadArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final articlesString = prefs.getString(_articlesKey);
    
    if (articlesString == null) return [];
    
    final List<dynamic> articlesJson = json.decode(articlesString);
    return articlesJson.map((json) => Article.fromJson(json)).toList();
  }

  static Future<DateTime?> getLastFetchTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastFetchKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  static Future<bool> shouldRefresh() async {
    final lastFetch = await getLastFetchTime();
    if (lastFetch == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastFetch);
    return difference.inMinutes > 30; 
  }
}
import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/news_service.dart';
import '../services/storage_service.dart';

enum NewsState { initial, loading, loaded, error }

class NewsProvider extends ChangeNotifier {
  final NewsService _newsService = NewsService();
  
  List<Article> _articles = [];
  List<Article> _filteredArticles = [];
  NewsState _state = NewsState.initial;
  String _errorMessage = '';
  String _searchQuery = '';

  List<Article> get articles => _filteredArticles;
  NewsState get state => _state;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  NewsProvider() {
    _loadCachedArticles();
  }

  Future<void> _loadCachedArticles() async {
    _state = NewsState.loading;
    notifyListeners();

    try {
      final cachedArticles = await StorageService.loadArticles();
      if (cachedArticles.isNotEmpty) {
        _articles = cachedArticles;
        _filteredArticles = cachedArticles;
        _state = NewsState.loaded;
        notifyListeners();
      }


      final shouldRefresh = await StorageService.shouldRefresh();
      if (shouldRefresh || cachedArticles.isEmpty) {
        await fetchNews();
      }
    } catch (e) {
      _errorMessage = 'Failed to load cached articles: $e';
      _state = NewsState.error;
      notifyListeners();
    }
  }

  Future<void> fetchNews() async {
    _state = NewsState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final articles = await _newsService.fetchTopHeadlines(
        query: _searchQuery.isEmpty ? null : _searchQuery,
      );
      
      _articles = articles;
      _filterArticles();
      await StorageService.saveArticles(articles);
      
      _state = NewsState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = NewsState.error;
      
      if (_articles.isNotEmpty) {
        _state = NewsState.loaded;
      }
    }
    
    notifyListeners();
  }

  void searchArticles(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredArticles = List.from(_articles);
    } else {
      _filteredArticles = _articles
          .where((article) =>
              article.title.toLowerCase().contains(query.toLowerCase()) ||
              (article.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    }
    notifyListeners();
  }

  void _filterArticles() {
    if (_searchQuery.isEmpty) {
      _filteredArticles = List.from(_articles);
    } else {
      searchArticles(_searchQuery);
    }
  }

  Future<void> refreshNews() async {
    await fetchNews();
  }
}
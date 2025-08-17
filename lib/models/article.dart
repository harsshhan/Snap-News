class Article {
  final String title;
  final String? description;
  final String? urlToImage;
  final String url;
  final String? publishedAt;
  final String? author;
  final String? sourceName;

  Article({
    required this.title,
    this.description,
    this.urlToImage,
    required this.url,
    this.publishedAt,
    this.author,
    this.sourceName,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      description: json['description'],
      urlToImage: json['urlToImage'],
      url: json['url'] ?? '',
      publishedAt: json['publishedAt'],
      author: json['author'],
      sourceName: json['source']?['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'urlToImage': urlToImage,
      'url': url,
      'publishedAt': publishedAt,
      'author': author,
      'sourceName': sourceName,
    };
  }
}
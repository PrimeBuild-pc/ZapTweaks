class StoreApp {
  const StoreApp({
    required this.id,
    required this.name,
    required this.category,
    required this.wingetId,
    required this.url,
    required this.author,
    required this.sources,
    this.description,
    this.requirements = const [],
    this.warnings = const [],
  });

  final String id;
  final String name;
  final String category;
  final String? wingetId;
  final Uri? url;
  final String author;
  final List<String> sources;
  final String? description;
  final List<String> requirements;
  final List<String> warnings;

  String get attribution => 'by $author';

  factory StoreApp.fromJson(Map<String, dynamic> json) => StoreApp(
    id: json['id']! as String,
    name: json['name']! as String,
    category: json['category']! as String,
    wingetId: json['wingetId'] as String?,
    url: json['url'] == null ? null : Uri.parse(json['url']! as String),
    author: json['author']! as String,
    sources: List<String>.from(json['sources']! as List),
    description: json['description'] as String?,
    requirements: List<String>.from(json['requirements'] as List? ?? const []),
    warnings: List<String>.from(json['warnings'] as List? ?? const []),
  );
}

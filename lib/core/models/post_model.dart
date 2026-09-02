class PostModel {
  final String id;
  final String deputyId;
  final String deputyName;
  final String title;
  final String content;
  final DateTime createdAt;
  int likes;
  int comments;
  List<String> tags;

  PostModel({
    required this.id,
    required this.deputyId,
    required this.deputyName,
    required this.title,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.tags = const [],
  });
}

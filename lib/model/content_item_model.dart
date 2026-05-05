class ContentItemModel {
  const ContentItemModel({
    required this.id,
    required this.title,
    required this.text,
  });

  final int id;
  final String title;
  final String text;

  factory ContentItemModel.fromJson(Map<String, dynamic> json) {
    return ContentItemModel(
      id: json['id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
    );
  }
}

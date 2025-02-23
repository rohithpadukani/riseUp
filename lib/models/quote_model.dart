class QuoteModel {
  final String text;
  final String author;

  QuoteModel({required this.text, required this.author});

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      text: json["q"]?.toString() ?? "No quote available", // Handle null
      author: json["a"]?.toString() ?? "Unknown", // Handle null
    );
  }
}


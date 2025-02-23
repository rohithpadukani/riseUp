import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riseup/models/quote_model.dart';

class QuoteService {
  static Future<List<QuoteModel>> fetchQuotes() async {
    final response = await http.get(Uri.parse('https://zenquotes.io/api/quotes'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['results'];
      return data.map((quote) => QuoteModel.fromJson(quote)).toList();
    } else {
      throw Exception("Failed to load quotes");
    }
  }
}

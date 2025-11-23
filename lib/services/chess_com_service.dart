import 'dart:convert';
import 'package:http/http.dart' as http;

class ChessComService {
  Future<int?> fetchRapidRating(String username) async {
    final cleaned = username.trim().toLowerCase();
    if (cleaned.isEmpty) return null;

    final uri = Uri.parse('https://api.chess.com/pub/player/$cleaned/stats');

    final resp = await http.get(uri);
    if (resp.statusCode != 200) return null;

    final data = jsonDecode(resp.body);
    final rapid = data['chess_rapid'];
    if (rapid == null) return null;

    final last = rapid['last'];
    if (last == null) return null;

    final rating = last['rating'];
    if (rating is int) return rating;
    return null;
  }
}

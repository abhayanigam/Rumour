import 'dart:convert';
import 'package:http/http.dart' as http;

/// Calls https://randomuser.me/api/ to get a unique user UUID.
/// The UUID is used as a stable anonymous user identifier per room.
class RandomUserService {
  static const String _url = 'https://randomuser.me/api/';

  /// Returns a UUID string from randomuser.me.
  /// Falls back to a timestamp-based string if the API is unavailable.
  Future<String> fetchRandomUserId() async {
    try {
      final response =
          await http.get(Uri.parse(_url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final results = body['results'] as List<dynamic>;
        if (results.isNotEmpty) {
          final login =
              (results.first as Map<String, dynamic>)['login']
                  as Map<String, dynamic>;
          return login['uuid'] as String;
        }
      }
    } catch (_) {
      // Network unavailable — fall through to fallback
    }
    // Fallback: millisecond-based pseudo-UUID
    return '${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond}';
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://omok-production-341a.up.railway.app';

  static String? accessToken;

  static String? username;

  static Map<String, String> get jsonHeaders => {
        'Content-Type': 'application/json',
      };

  static Map<String, String> get authHeaders => {
        ...jsonHeaders,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

  static Future<(bool, String)> register(
      String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: jsonHeaders,
      body: jsonEncode({'username': username, 'password': password}),
    );
    final body = decode(res.body);
    return (res.statusCode == 201, (body['message'] ?? '오류') as String);
  }

  static Future<(bool, String)> login(
      String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: jsonHeaders,
      body: jsonEncode({'username': username, 'password': password}),
    );
    final body = decode(res.body);
    if (res.statusCode == 200) {
      accessToken = body['accessToken'] as String?;
      ApiService.username = username;
      return (true, '로그인 성공');
    }
    return (false, (body['message'] ?? '로그인 실패') as String);
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: authHeaders,
    );
    if (res.statusCode == 200) return decode(res.body);
    return null;
  }

  static Future<Map<String, dynamic>?> getRoom(String roomId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/room/$roomId'),
      headers: authHeaders,
    );
    if (res.statusCode == 200) return decode(res.body);
    return null;
  }

  static Map<String, dynamic> decode(String body) {
    if (body.isEmpty) return {};
    return jsonDecode(body) as Map<String, dynamic>;
  }
}

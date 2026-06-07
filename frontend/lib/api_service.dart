import 'dart:convert';
import 'package:http/http.dart' as http;

/// 오목 백엔드 REST API 클라이언트.
/// 명세서 기준: /register, /login, /profile, /room/{room_id}
class ApiService {
  static const String baseUrl = 'https://omok-production-341a.up.railway.app';

  /// 로그인 성공 후 받은 JWT. 앱 전역에서 공유.
  static String? accessToken;

  /// 로그인한 아이디. 앱 전역에서 공유.
  static String? username;

  static Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
      };

  static Map<String, String> get _authHeaders => {
        ..._jsonHeaders,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

  /// 회원가입. 성공 시 201.
  /// 반환: (성공여부, 메시지)
  static Future<(bool, String)> register(
      String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: _jsonHeaders,
      body: jsonEncode({'username': username, 'password': password}),
    );
    final body = _decode(res.body);
    return (res.statusCode == 201, (body['message'] ?? '오류') as String);
  }

  /// 로그인. 성공 시 200 + accessToken 저장.
  /// 반환: (성공여부, 메시지)
  static Future<(bool, String)> login(
      String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _jsonHeaders,
      body: jsonEncode({'username': username, 'password': password}),
    );
    final body = _decode(res.body);
    if (res.statusCode == 200) {
      accessToken = body['accessToken'] as String?;
      ApiService.username = username;
      return (true, '로그인 성공');
    }
    return (false, (body['message'] ?? '로그인 실패') as String);
  }

  /// 내 프로필 조회. (username, id, wins, losses)
  static Future<Map<String, dynamic>?> getProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: _authHeaders,
    );
    if (res.statusCode == 200) return _decode(res.body);
    return null;
  }

  /// 방 정보 조회.
  static Future<Map<String, dynamic>?> getRoom(String roomId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/room/$roomId'),
      headers: _authHeaders,
    );
    if (res.statusCode == 200) return _decode(res.body);
    return null;
  }

  static Map<String, dynamic> _decode(String body) {
    if (body.isEmpty) return {};
    return jsonDecode(body) as Map<String, dynamic>;
  }
}

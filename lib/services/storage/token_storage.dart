import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage(this._prefs);

  static const String _tokenKey = 'auth_token';

  final SharedPreferences _prefs;

  Future<void> writeToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? readToken() => _prefs.getString(_tokenKey);

  Future<void> clear() => _prefs.remove(_tokenKey);
}


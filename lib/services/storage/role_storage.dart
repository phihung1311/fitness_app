import 'package:shared_preferences/shared_preferences.dart';

class RoleStorage {
  RoleStorage(this._prefs);

  static const String _roleKey = 'user_role_id';

  final SharedPreferences _prefs;

  Future<void> saveRoleId(int roleId) async {
    await _prefs.setInt(_roleKey, roleId);
  }

  int? getRoleId() => _prefs.getInt(_roleKey);

  Future<void> clear() async {
    await _prefs.remove(_roleKey);
  }

  bool isAdmin() => getRoleId() == 2;
  
  bool isUser() => getRoleId() == 1;
}


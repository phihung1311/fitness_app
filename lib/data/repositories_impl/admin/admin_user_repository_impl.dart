import '../../../domain/entities/user.dart';
import '../../../domain/repositories/admin/admin_user_repository.dart';
import '../../datasources/remote/admin/admin_user_api.dart';

/// Repository implementation cho Admin quản lý tài khoản
class AdminUserRepositoryImpl implements AdminUserRepository {
  final AdminUserApi _api;

  AdminUserRepositoryImpl(this._api);

  @override
  Future<List<User>> getUsers() async {
    try {
      final dtos = await _api.getUsers();
      return dtos.map((dto) => dto.toEntity()).whereType<User>().toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách users: $e');
    }
  }

  @override
  Future<User> getUserDetail(int userId) async {
    try {
      final dto = await _api.getUserDetail(userId);
      return dto.toEntity();
    } catch (e) {
      throw Exception('Lỗi lấy chi tiết user: $e');
    }
  }

  @override
  Future<void> updateUserRole(int userId, int roleId) async {
    try {
      await _api.updateUserRole(userId, roleId);
    } catch (e) {
      throw Exception('Lỗi cập nhật quyền user: $e');
    }
  }

  @override
  Future<void> lockUser(int userId) async {
    try {
      await _api.lockUser(userId);
    } catch (e) {
      throw Exception('Lỗi khóa user: $e');
    }
  }

  @override
  Future<void> unlockUser(int userId) async {
    try {
      await _api.unlockUser(userId);
    } catch (e) {
      throw Exception('Lỗi mở khóa user: $e');
    }
  }

  @override
  Future<void> deleteUser(int userId) async {
    try {
      await _api.deleteUser(userId);
    } catch (e) {
      throw Exception('Lỗi xóa user: $e');
    }
  }
}


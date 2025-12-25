import '../../entities/user.dart';

abstract class AdminUserRepository {
  Future<List<User>> getUsers();
  Future<User> getUserDetail(int userId);
  Future<void> updateUserRole(int userId, int roleId);
  Future<void> lockUser(int userId);
  Future<void> unlockUser(int userId);
  Future<void> deleteUser(int userId);
}


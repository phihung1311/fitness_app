import '../../../repositories/admin/admin_user_repository.dart';

class UpdateUserRole {
  UpdateUserRole(this._repository);

  final AdminUserRepository _repository;

  Future<void> execute(int userId, int roleId) {
    return _repository.updateUserRole(userId, roleId);
  }
}


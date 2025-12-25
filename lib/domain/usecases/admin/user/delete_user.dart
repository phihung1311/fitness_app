import '../../../repositories/admin/admin_user_repository.dart';

class DeleteUser {
  DeleteUser(this._repository);

  final AdminUserRepository _repository;

  Future<void> execute(int userId) {
    return _repository.deleteUser(userId);
  }
}


import '../../../repositories/admin/admin_user_repository.dart';

class UnlockUser {
  UnlockUser(this._repository);

  final AdminUserRepository _repository;

  Future<void> execute(int userId) {
    return _repository.unlockUser(userId);
  }
}


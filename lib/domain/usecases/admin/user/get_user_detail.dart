import '../../../entities/user.dart';
import '../../../repositories/admin/admin_user_repository.dart';

class GetUserDetail {
  GetUserDetail(this._repository);

  final AdminUserRepository _repository;

  Future<User> execute(int userId) {
    return _repository.getUserDetail(userId);
  }
}


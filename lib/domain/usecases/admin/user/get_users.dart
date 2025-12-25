import '../../../entities/user.dart';
import '../../../repositories/admin/admin_user_repository.dart';

class GetUsers {
  GetUsers(this._repository);

  final AdminUserRepository _repository;

  Future<List<User>> execute() {
    return _repository.getUsers();
  }
}


import '../../entities/auth_session.dart';
import '../../repositories/auth_repository.dart';

class RegisterUseCase {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> execute({
    required String email,
    required String password,
  }) {
    return _repository.register(email: email, password: password);
  }
}


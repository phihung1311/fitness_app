import '../../entities/auth_session.dart';
import '../../repositories/auth_repository.dart';

class GoogleLoginUseCase {
  GoogleLoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> execute(String idToken) {
    return _repository.googleLogin(idToken);
  }
}

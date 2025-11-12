import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../domain/usecases/auth/login.dart';
import '../form_status.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._loginUseCase) : super(const LoginState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  final LoginUseCase _loginUseCase;

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: FormStatus.loading, clearError: true, clearSession: true));
    try {
      final session = await _loginUseCase.execute(
        email: event.email.trim(),
        password: event.password,
      );
      emit(state.copyWith(status: FormStatus.success, session: session));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: FormStatus.failure,
        errorMessage: e.message,
        clearSession: true,
      ));
    } catch (e, stack) {
      logDebug('Login error: $e\n$stack');
      emit(state.copyWith(
        status: FormStatus.failure,
        errorMessage: 'Đăng nhập thất bại, vui lòng thử lại.',
        clearSession: true,
      ));
    }
  }
}


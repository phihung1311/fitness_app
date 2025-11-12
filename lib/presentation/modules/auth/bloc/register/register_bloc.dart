import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../domain/usecases/auth/register.dart';
import '../form_status.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc(this._registerUseCase) : super(const RegisterState()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  final RegisterUseCase _registerUseCase;

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(status: FormStatus.loading, clearError: true, clearSession: true));
    try {
      final session = await _registerUseCase.execute(
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
      logDebug('Register error: $e\n$stack');
      emit(state.copyWith(
        status: FormStatus.failure,
        errorMessage: 'Đăng ký thất bại, vui lòng thử lại.',
        clearSession: true,
      ));
    }
  }
}


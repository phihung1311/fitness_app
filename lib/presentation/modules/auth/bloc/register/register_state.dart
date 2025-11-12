import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/auth_session.dart';
import '../form_status.dart';

class RegisterState extends Equatable {
  const RegisterState({
    this.status = FormStatus.initial,
    this.errorMessage,
    this.session,
  });

  final FormStatus status;
  final String? errorMessage;
  final AuthSession? session;

  RegisterState copyWith({
    FormStatus? status,
    String? errorMessage,
    bool clearError = false,
    AuthSession? session,
    bool clearSession = false,
  }) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      session: clearSession ? null : (session ?? this.session),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, session];
}


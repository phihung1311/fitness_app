import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/auth_session.dart';
import '../form_status.dart';

class LoginState extends Equatable {
  const LoginState({
    this.status = FormStatus.initial,
    this.errorMessage,
    this.session,
  });

  final FormStatus status;
  final String? errorMessage;
  final AuthSession? session;

  LoginState copyWith({
    FormStatus? status,
    String? errorMessage,
    bool clearError = false,
    AuthSession? session,
    bool clearSession = false,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      session: clearSession ? null : (session ?? this.session),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, session];
}


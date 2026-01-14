import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class GoogleLoginSubmitted extends LoginEvent {
  const GoogleLoginSubmitted(this.idToken);

  final String idToken;

  @override
  List<Object?> get props => [idToken];
}

class AuthResponseDto {
  AuthResponseDto({
    required this.token,
    required this.user,
    this.message,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? {};
    return AuthResponseDto(
      token: json['token'] as String?,
      message: json['message'] as String?,
      user: AuthUserDto.fromJson(userJson),
    );
  }

  final String? token;
  final AuthUserDto user;
  final String? message;
}

class AuthUserDto {
  AuthUserDto({
    required this.id,
    required this.email,
  });

  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    return AuthUserDto(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
    );
  }

  final int id;
  final String email;
}


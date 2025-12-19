import 'package:dio/dio.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../services/storage/token_storage.dart';
import '../datasources/remote/auth_api.dart';
import '../dtos/auth_request_dto.dart';
import '../dtos/auth_response_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthApi api,
    required TokenStorage tokenStorage,
  })  : _api = api,
        _tokenStorage = tokenStorage;

  final AuthApi _api;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.login(AuthRequestDto(email: email, password: password));
      final session = _mapToSession(response);
      await saveToken(session.token);
      return session;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
  }) async {
    final request = AuthRequestDto(email: email, password: password);
    try {
      var response = await _api.register(request);
      if (response.token == null || response.token!.isEmpty) {
        response = await _api.login(request);
      }
      final session = _mapToSession(response);
      await saveToken(session.token);
      return session;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> saveToken(String token) => _tokenStorage.writeToken(token);

  AuthSession _mapToSession(AuthResponseDto dto) {
    final token = dto.token;
    if (token == null || token.isEmpty) {
      throw AppException(dto.message ?? 'Token không hợp lệ từ server');
    }
    final user = AuthUser(id: dto.user.id, email: dto.user.email);
    return AuthSession(token: token, user: user);
  }

  AppException _mapDioError(DioException e) {
    // Xử lý lỗi connection
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return AppException(
        'Kết nối timeout. Vui lòng kiểm tra kết nối mạng và thử lại.',
        code: 'TIMEOUT',
      );
    }

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return AppException(
        'Không thể kết nối đến server. Vui lòng kiểm tra:\n'
        '1. Backend đã chạy chưa?\n'
        '2. URL đúng chưa? (http://10.0.2.2:3000/api)\n'
        '3. Kết nối mạng ổn định không?',
        code: 'CONNECTION_ERROR',
      );
    }

    // Xử lý lỗi từ server
    final response = e.response?.data;
    if (response is Map<String, dynamic>) {
      final message = response['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return AppException(message, code: e.response?.statusCode?.toString());
      }
    }

    // Lỗi khác
    return AppException(
      e.message ?? 'Yêu cầu thất bại, vui lòng thử lại.',
      code: e.response?.statusCode?.toString(),
    );
  }
}


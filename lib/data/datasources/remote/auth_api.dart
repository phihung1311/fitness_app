import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../dtos/auth_request_dto.dart';
import '../../dtos/auth_response_dto.dart';

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<AuthResponseDto> login(AuthRequestDto request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    return AuthResponseDto.fromJson(response.data ?? {});
  }

  Future<AuthResponseDto> register(AuthRequestDto request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: request.toJson(),
    );
    return AuthResponseDto.fromJson(response.data ?? {});
  }
}


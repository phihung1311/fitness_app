import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../services/storage/token_storage.dart';
import '../../../dtos/user_dto.dart';

/// API client cho Admin quản lý tài khoản
class AdminUserApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AdminUserApi(this._dio, this._tokenStorage);

  /// Lấy danh sách tất cả users (chỉ admin)
  Future<List<UserDto>> getUsers() async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/admin/users',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return (response.data as List)
          .map((e) => UserDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Lỗi lấy danh sách users: ${e.message}');
    }
  }

  /// Lấy chi tiết 1 user (chỉ admin)
  Future<UserDto> getUserDetail(int userId) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/admin/users/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return UserDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Lỗi lấy chi tiết user: ${e.message}');
    }
  }

  /// Cập nhật role của user (chỉ admin)
  Future<void> updateUserRole(int userId, int roleId) async {
    try {
      final token = _tokenStorage.readToken();
      await _dio.patch(
        '${ApiEndpoints.baseUrl}/admin/users/$userId/role',
        data: {'role_id': roleId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception('Lỗi cập nhật quyền user: ${e.message}');
    }
  }

  /// Khóa user (chỉ admin)
  Future<void> lockUser(int userId) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.patch(
        '${ApiEndpoints.baseUrl}/admin/users/$userId/lock',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      // Kiểm tra response có message không
      if (response.data != null && response.data['message'] != null) {
        // Success
        return;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['error'] ?? 
                            e.response?.data['message'] ?? 
                            e.message;
        throw Exception('Lỗi khóa user: $errorMessage');
      }
      throw Exception('Lỗi khóa user: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi khóa user: $e');
    }
  }

  /// Mở khóa user (chỉ admin)
  Future<void> unlockUser(int userId) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.patch(
        '${ApiEndpoints.baseUrl}/admin/users/$userId/unlock',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      // Kiểm tra response có message không
      if (response.data != null && response.data['message'] != null) {
        // Success
        return;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['error'] ?? 
                            e.response?.data['message'] ?? 
                            e.message;
        throw Exception('Lỗi mở khóa user: $errorMessage');
      }
      throw Exception('Lỗi mở khóa user: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi mở khóa user: $e');
    }
  }

  /// Xóa user (chỉ admin)
  Future<void> deleteUser(int userId) async {
    try {
      final token = _tokenStorage.readToken();
      await _dio.delete(
        '${ApiEndpoints.baseUrl}/admin/users/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception('Lỗi xóa user: ${e.message}');
    }
  }
}


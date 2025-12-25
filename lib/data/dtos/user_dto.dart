import '../../domain/entities/user.dart';

class UserDto {
  final int id;
  final int? roleId;
  final String? name;
  final String email;
  final String? gender;
  final int? age;
  final String? createdAt;
  final bool? locked;

  const UserDto({
    required this.id,
    this.roleId,
    this.name,
    required this.email,
    this.gender,
    this.age,
    this.createdAt,
    this.locked,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    // Helper function để parse boolean an toàn
    bool? _parseBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is int) return value != 0;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return null;
    }

    return UserDto(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      roleId: json['role_id'] is int ? json['role_id'] as int : int.tryParse(json['role_id']?.toString() ?? ''),
      name: json['name']?.toString(),
      email: json['email']?.toString() ?? '',
      gender: json['gender']?.toString(),
      age: json['age'] is int ? json['age'] as int : int.tryParse(json['age']?.toString() ?? ''),
      createdAt: json['created_at']?.toString(),
      locked: _parseBool(json['locked']),
    );
  }

  User toEntity() {
    DateTime? parsedCreatedAt;
    if (createdAt != null) {
      try {
        parsedCreatedAt = DateTime.parse(createdAt!);
      } catch (e) {
        parsedCreatedAt = null;
      }
    }

    return User(
      id: id,
      roleId: roleId,
      name: name,
      email: email,
      gender: gender,
      age: age,
      createdAt: parsedCreatedAt,
      locked: locked,
    );
  }
}


class User {
  final int id;
  final int? roleId;
  final String? name;
  final String email;
  final String? gender;
  final int? age;
  final DateTime? createdAt;
  final bool? locked;

  User({
    required this.id,
    this.roleId,
    this.name,
    required this.email,
    this.gender,
    this.age,
    this.createdAt,
    this.locked,
  });

  bool get isAdmin => roleId == 2;
  bool get isUser => roleId == 1;
  bool get isLocked => locked == true;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}


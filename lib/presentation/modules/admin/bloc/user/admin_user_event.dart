import 'package:equatable/equatable.dart';

abstract class AdminUserEvent extends Equatable {
  const AdminUserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends AdminUserEvent {
  const LoadUsers();
}

class LoadUserDetail extends AdminUserEvent {
  final int userId;

  const LoadUserDetail(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateUserRoleEvent extends AdminUserEvent {
  final int userId;
  final int roleId;

  const UpdateUserRoleEvent({
    required this.userId,
    required this.roleId,
  });

  @override
  List<Object?> get props => [userId, roleId];
}

class LockUserEvent extends AdminUserEvent {
  final int userId;

  const LockUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UnlockUserEvent extends AdminUserEvent {
  final int userId;

  const UnlockUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class DeleteUserEvent extends AdminUserEvent {
  final int userId;

  const DeleteUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SearchUsersEvent extends AdminUserEvent {
  final String query;

  const SearchUsersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterUsersByRoleEvent extends AdminUserEvent {
  final int? roleId; // null = tất cả, 1 = user, 2 = admin

  const FilterUsersByRoleEvent(this.roleId);

  @override
  List<Object?> get props => [roleId];
}

class FilterUsersByLockStatusEvent extends AdminUserEvent {
  final bool? isLocked; // null = tất cả, true = đã khóa, false = chưa khóa

  const FilterUsersByLockStatusEvent(this.isLocked);

  @override
  List<Object?> get props => [isLocked];
}


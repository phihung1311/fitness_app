import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../domain/entities/user.dart';
import '../../../../../domain/usecases/admin/user/get_user_detail.dart';
import '../../../../../domain/usecases/admin/user/delete_user.dart';
import '../../../../../domain/usecases/admin/user/get_users.dart';
import '../../../../../domain/usecases/admin/user/lock_user.dart';
import '../../../../../domain/usecases/admin/user/unlock_user.dart';
import '../../../../../domain/usecases/admin/user/update_user_role.dart';
import 'admin_user_event.dart';
import 'admin_user_state.dart';

class AdminUserBloc extends Bloc<AdminUserEvent, AdminUserState> {
  final GetUsers _getUsers;
  final GetUserDetail _getUserDetail;
  final UpdateUserRole _updateUserRole;
  final LockUser _lockUser;
  final UnlockUser _unlockUser;
  final DeleteUser _deleteUser;

  AdminUserBloc(
    this._getUsers,
    this._getUserDetail,
    this._updateUserRole,
    this._lockUser,
    this._unlockUser,
    this._deleteUser,
  ) : super(const AdminUserState()) {
    on<LoadUsers>(_onLoadUsers);
    on<LoadUserDetail>(_onLoadUserDetail);
    on<UpdateUserRoleEvent>(_onUpdateUserRole);
    on<LockUserEvent>(_onLockUser);
    on<UnlockUserEvent>(_onUnlockUser);
    on<DeleteUserEvent>(_onDeleteUser);
    on<SearchUsersEvent>(_onSearchUsers);
    on<FilterUsersByRoleEvent>(_onFilterUsersByRole);
    on<FilterUsersByLockStatusEvent>(_onFilterUsersByLockStatus);
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<AdminUserState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final users = await _getUsers.execute();
      emit(state.copyWith(
        users: users,
        displayedUsers: users,
        isLoading: false,
      ));
      // Áp dụng lại filter/search nếu có
      _applyFilters(
        emit,
        users,
        state.searchQuery,
        state.selectedRoleFilter,
        state.selectedLockStatusFilter,
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadUserDetail(
    LoadUserDetail event,
    Emitter<AdminUserState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final user = await _getUserDetail.execute(event.userId);
      emit(state.copyWith(
        selectedUser: user,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _applyFilters(
    Emitter<AdminUserState> emit,
    List<User> users,
    String searchQuery,
    int? roleFilter,
    bool? lockStatusFilter,
  ) {
    List<User> filtered = users;

    // Filter theo role
    if (roleFilter != null) {
      filtered = filtered
          .where((user) => user.roleId == roleFilter)
          .toList();
    }

    // Filter theo lock status
    if (lockStatusFilter != null) {
      filtered = filtered
          .where((user) => (user.locked ?? false) == lockStatusFilter)
          .toList();
    }

    // Filter theo search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered
          .where((user) =>
              (user.name?.toLowerCase().contains(query) ?? false) ||
              user.email.toLowerCase().contains(query))
          .toList();
    }

    emit(state.copyWith(displayedUsers: filtered));
  }

  void _onSearchUsers(
    SearchUsersEvent event,
    Emitter<AdminUserState> emit,
  ) {
    _applyFilters(
      emit,
      state.users,
      event.query,
      state.selectedRoleFilter,
      state.selectedLockStatusFilter,
    );
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onFilterUsersByRole(
    FilterUsersByRoleEvent event,
    Emitter<AdminUserState> emit,
  ) {
    _applyFilters(
      emit,
      state.users,
      state.searchQuery,
      event.roleId,
      state.selectedLockStatusFilter,
    );
    emit(state.copyWith(selectedRoleFilter: event.roleId));
  }

  void _onFilterUsersByLockStatus(
    FilterUsersByLockStatusEvent event,
    Emitter<AdminUserState> emit,
  ) {
    _applyFilters(
      emit,
      state.users,
      state.searchQuery,
      state.selectedRoleFilter,
      event.isLocked,
    );
    emit(state.copyWith(selectedLockStatusFilter: event.isLocked));
  }

  Future<void> _onUpdateUserRole(
    UpdateUserRoleEvent event,
    Emitter<AdminUserState> emit,
  ) async {
    if (state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));
    try {
      await _updateUserRole.execute(event.userId, event.roleId);
      // Reload danh sách và cập nhật user trong danh sách
      final users = await _getUsers.execute();
      // Cập nhật selectedUser nếu đang xem user này
      User? updatedSelectedUser;
      if (state.selectedUser?.id == event.userId) {
        updatedSelectedUser = users.firstWhere(
          (u) => u.id == event.userId,
          orElse: () => state.selectedUser!,
        );
      }
      // Áp dụng filter nhưng không thay đổi filter hiện tại
      _applyFilters(
        emit,
        users,
        state.searchQuery,
        state.selectedRoleFilter,
        state.selectedLockStatusFilter,
      );
      emit(state.copyWith(
        users: users,
        selectedUser: updatedSelectedUser ?? state.selectedUser,
        isSubmitting: false,
        successMessage: 'Đã cập nhật quyền tài khoản thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLockUser(
    LockUserEvent event,
    Emitter<AdminUserState> emit,
  ) async {
    if (state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));
    try {
      await _lockUser.execute(event.userId);
      // Reload danh sách và cập nhật user trong danh sách
      final users = await _getUsers.execute();
      // Cập nhật selectedUser nếu đang xem user này
      User? updatedSelectedUser;
      if (state.selectedUser?.id == event.userId) {
        try {
          updatedSelectedUser = users.firstWhere((u) => u.id == event.userId);
        } catch (e) {
          updatedSelectedUser = state.selectedUser;
        }
      }
      // Nếu filter đang là "Chưa khóa" (false), chuyển về null để hiển thị tất cả
      // vì user vừa lock sẽ không match với filter "Chưa khóa" nữa
      final lockStatusFilter = state.selectedLockStatusFilter == false 
          ? null 
          : state.selectedLockStatusFilter;
      // Áp dụng filter
      _applyFilters(
        emit,
        users,
        state.searchQuery,
        state.selectedRoleFilter,
        lockStatusFilter,
      );
      emit(state.copyWith(
        users: users,
        selectedUser: updatedSelectedUser ?? state.selectedUser,
        selectedLockStatusFilter: lockStatusFilter,
        isSubmitting: false,
        successMessage: 'Đã khóa tài khoản thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUnlockUser(
    UnlockUserEvent event,
    Emitter<AdminUserState> emit,
  ) async {
    if (state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));
    try {
      await _unlockUser.execute(event.userId);
      // Reload danh sách và cập nhật user trong danh sách
      final users = await _getUsers.execute();
      // Cập nhật selectedUser nếu đang xem user này
      User? updatedSelectedUser;
      if (state.selectedUser?.id == event.userId) {
        try {
          updatedSelectedUser = users.firstWhere((u) => u.id == event.userId);
        } catch (e) {
          updatedSelectedUser = state.selectedUser;
        }
      }
      // Nếu filter đang là "Đã khóa" (true), chuyển về null để hiển thị tất cả
      // vì user vừa unlock sẽ không match với filter "Đã khóa" nữa
      final lockStatusFilter = state.selectedLockStatusFilter == true 
          ? null 
          : state.selectedLockStatusFilter;
      // Áp dụng filter
      _applyFilters(
        emit,
        users,
        state.searchQuery,
        state.selectedRoleFilter,
        lockStatusFilter,
      );
      emit(state.copyWith(
        users: users,
        selectedUser: updatedSelectedUser ?? state.selectedUser,
        selectedLockStatusFilter: lockStatusFilter,
        isSubmitting: false,
        successMessage: 'Đã mở khóa tài khoản thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<AdminUserState> emit,
  ) async {
    if (state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));
    try {
      await _deleteUser.execute(event.userId);
      // Reload danh sách
      final users = await _getUsers.execute();
      _applyFilters(
        emit,
        users,
        state.searchQuery,
        state.selectedRoleFilter,
        state.selectedLockStatusFilter,
      );
      emit(state.copyWith(
        users: users,
        isSubmitting: false,
        successMessage: 'Đã xóa tài khoản thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      ));
    }
  }
}


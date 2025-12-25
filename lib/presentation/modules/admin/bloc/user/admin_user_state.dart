import 'package:equatable/equatable.dart';
import '../../../../../domain/entities/user.dart';

class AdminUserState extends Equatable {
  final List<User> users;
  final List<User> displayedUsers;
  final User? selectedUser;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;
  final String searchQuery;
  final int? selectedRoleFilter; // null = tất cả, 1 = user, 2 = admin
  final bool? selectedLockStatusFilter; // null = tất cả, true = đã khóa, false = chưa khóa

  const AdminUserState({
    this.users = const [],
    this.displayedUsers = const [],
    this.selectedUser,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.searchQuery = '',
    this.selectedRoleFilter,
    this.selectedLockStatusFilter,
  });

  AdminUserState copyWith({
    List<User>? users,
    List<User>? displayedUsers,
    User? selectedUser,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    String? searchQuery,
    int? selectedRoleFilter,
    bool? selectedLockStatusFilter,
  }) {
    return AdminUserState(
      users: users ?? this.users,
      displayedUsers: displayedUsers ?? this.displayedUsers,
      selectedUser: selectedUser ?? this.selectedUser,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      successMessage: successMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedRoleFilter: selectedRoleFilter ?? this.selectedRoleFilter,
      selectedLockStatusFilter: selectedLockStatusFilter ?? this.selectedLockStatusFilter,
    );
  }

  @override
  List<Object?> get props => [
        users,
        displayedUsers,
        selectedUser,
        isLoading,
        isSubmitting,
        errorMessage,
        successMessage,
        searchQuery,
        selectedRoleFilter,
        selectedLockStatusFilter,
      ];
}


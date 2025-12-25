import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injector.dart';
import '../../../../../domain/entities/user.dart';
import '../../bloc/user/admin_user_bloc.dart';
import '../../bloc/user/admin_user_event.dart';
import '../../bloc/user/admin_user_state.dart';
import 'admin_user_detail_screen.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  static const String routeName = '/admin/user-management';

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _roleFilters = [
    {'label': 'Tất cả', 'value': null},
    {'label': 'User', 'value': 1},
    {'label': 'Admin', 'value': 2},
  ];

  final List<Map<String, dynamic>> _lockStatusFilters = [
    {'label': 'Tất cả', 'value': null},
    {'label': 'Đã khóa', 'value': true},
    {'label': 'Chưa khóa', 'value': false},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminUserBloc(
        injector(),
        injector(),
        injector(),
        injector(),
        injector(),
        injector(),
      )..add(const LoadUsers()),
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0F0E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D0F0E),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Quản lý Tài khoản',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocConsumer<AdminUserBloc, AdminUserState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF52C41A)),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1E1D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm theo tên hoặc email...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (value) {
                        context.read<AdminUserBloc>().add(SearchUsersEvent(value));
                      },
                    ),
                  ),
                ),

                // Filter Buttons - Role
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _roleFilters.length,
                    itemBuilder: (context, index) {
                      final roleFilter = _roleFilters[index];
                      final isSelected = state.selectedRoleFilter == roleFilter['value'];

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            context.read<AdminUserBloc>().add(
                                  FilterUsersByRoleEvent(roleFilter['value'] as int?),
                                );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF52C41A)
                                  : const Color(0xFF1C1E1D),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                roleFilter['label']!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Filter Buttons - Lock Status
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _lockStatusFilters.length,
                    itemBuilder: (context, index) {
                      final lockFilter = _lockStatusFilters[index];
                      final isSelected = state.selectedLockStatusFilter == lockFilter['value'];

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            context.read<AdminUserBloc>().add(
                                  FilterUsersByLockStatusEvent(lockFilter['value'] as bool?),
                                );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF52C41A)
                                  : const Color(0xFF1C1E1D),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                lockFilter['label']!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // User List
                Expanded(
                  child: state.displayedUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.users.isEmpty
                                    ? 'Chưa có tài khoản nào'
                                    : 'Không tìm thấy tài khoản',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          itemCount: state.displayedUsers.length,
                          itemBuilder: (context, index) {
                            final user = state.displayedUsers[index];
                            return _buildUserItem(context, user);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserItem(BuildContext context, User user) {
    return Dismissible(
      key: Key('user_${user.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          _showDeleteConfirmation(context, user);
          return false;
        }
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1E1D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _navigateToUserDetail(context, user),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF52C41A).withOpacity(0.2),
                    child: Text(
                      (user.name?.isNotEmpty == true
                          ? user.name![0].toUpperCase()
                          : user.email[0].toUpperCase()),
                      style: const TextStyle(
                        color: Color(0xFF52C41A),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Thông tin user
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name?.isNotEmpty == true
                                    ? user.name!
                                    : 'Chưa có tên',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Role badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: user.isAdmin
                                    ? Colors.orange.withOpacity(0.2)
                                    : Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user.isAdmin ? 'Admin' : 'User',
                                style: TextStyle(
                                  color: user.isAdmin ? Colors.orange : Colors.blue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (user.isLocked) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Đã khóa',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Icon arrow
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToUserDetail(BuildContext context, User user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AdminUserBloc>(),
          child: AdminUserDetailScreen(user: user),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AdminUserBloc>(),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1C1E1D),
          title: const Text(
            'Xóa tài khoản',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Bạn có chắc muốn xóa tài khoản "${user.name?.isNotEmpty == true ? user.name : user.email}"?',
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                context.read<AdminUserBloc>().add(DeleteUserEvent(user.id));
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Xóa',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


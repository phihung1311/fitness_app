import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../domain/entities/user.dart';
import '../../bloc/user/admin_user_bloc.dart';
import '../../bloc/user/admin_user_event.dart';
import '../../bloc/user/admin_user_state.dart';

class AdminUserDetailScreen extends StatelessWidget {
  final User user;

  const AdminUserDetailScreen({
    super.key,
    required this.user,
  });

  static const String routeName = '/admin/user-detail';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0F0E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Chi tiết tài khoản',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocListener<AdminUserBloc, AdminUserState>(
        listenWhen: (previous, current) {
          return previous.errorMessage != current.errorMessage ||
              previous.successMessage != current.successMessage;
        },
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
            // Reload user detail sau khi cập nhật
            context.read<AdminUserBloc>().add(LoadUserDetail(user.id));
            // Không reload danh sách users từ detail screen để tránh ảnh hưởng đến filter
            // Danh sách sẽ được reload khi quay lại màn hình management
          }
        },
        child: BlocBuilder<AdminUserBloc, AdminUserState>(
          builder: (context, state) {
            // Sử dụng user từ state nếu có, nếu không dùng user từ constructor
            final currentUser = state.selectedUser ?? user;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar và thông tin cơ bản
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF52C41A).withOpacity(0.2),
                          child: Text(
                            (currentUser.name?.isNotEmpty == true
                                ? currentUser.name![0].toUpperCase()
                                : currentUser.email[0].toUpperCase()),
                            style: const TextStyle(
                              color: Color(0xFF52C41A),
                              fontWeight: FontWeight.bold,
                              fontSize: 36,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentUser.name?.isNotEmpty == true
                              ? currentUser.name!
                              : 'Chưa có tên',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentUser.email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Badges
                        Wrap(
                          spacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: currentUser.isAdmin
                                    ? Colors.orange.withOpacity(0.2)
                                    : Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                currentUser.isAdmin ? 'Quản trị viên' : 'Người dùng',
                                style: TextStyle(
                                  color: currentUser.isAdmin ? Colors.orange : Colors.blue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (currentUser.isLocked)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Đã khóa',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Thông tin chi tiết
                  _buildInfoCard(
                    'Thông tin cá nhân',
                    [
                      _buildInfoRow('Tên', currentUser.name ?? 'Chưa có'),
                      _buildInfoRow('Email', currentUser.email),
                      _buildInfoRow(
                        'Giới tính',
                        currentUser.gender == 'male'
                            ? 'Nam'
                            : currentUser.gender == 'female'
                                ? 'Nữ'
                                : currentUser.gender == 'other'
                                    ? 'Khác'
                                    : 'Chưa cập nhật',
                      ),
                      _buildInfoRow(
                        'Tuổi',
                        currentUser.age?.toString() ?? 'Chưa cập nhật',
                      ),
                      _buildInfoRow(
                        'Ngày tạo',
                        currentUser.createdAt != null
                            ? '${currentUser.createdAt!.day}/${currentUser.createdAt!.month}/${currentUser.createdAt!.year}'
                            : 'Chưa có',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Actions
                  _buildInfoCard(
                    'Thao tác',
                    [
                      // Phân quyền
                      _buildActionButton(
                        context,
                        icon: Icons.admin_panel_settings,
                        title: 'Phân quyền',
                        subtitle: currentUser.isAdmin ? 'Chuyển thành User' : 'Chuyển thành Admin',
                        color: Colors.orange,
                        onTap: () => _showUpdateRoleDialog(context, currentUser),
                      ),
                      const SizedBox(height: 12),
                      // Khóa/Mở khóa
                      _buildActionButton(
                        context,
                        icon: currentUser.isLocked ? Icons.lock_open : Icons.lock,
                        title: currentUser.isLocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản',
                        subtitle: currentUser.isLocked
                            ? 'Cho phép user đăng nhập lại'
                            : 'Ngăn user đăng nhập',
                        color: currentUser.isLocked ? Colors.green : Colors.red,
                        onTap: () => _handleLockUnlock(context, currentUser),
                      ),
                      const SizedBox(height: 12),
                      // Xóa tài khoản
                      _buildActionButton(
                        context,
                        icon: Icons.delete_outline,
                        title: 'Xóa tài khoản',
                        subtitle: 'Xóa vĩnh viễn tài khoản này',
                        color: Colors.red,
                        onTap: () => _showDeleteConfirmation(context, currentUser),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E1D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdateRoleDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1E1D),
        title: const Text(
          'Phân quyền tài khoản',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Bạn muốn chuyển "${user.name?.isNotEmpty == true ? user.name : user.email}" thành ${user.isAdmin ? 'User' : 'Admin'}?',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              final newRoleId = user.isAdmin ? 1 : 2;
              context.read<AdminUserBloc>().add(
                    UpdateUserRoleEvent(userId: user.id, roleId: newRoleId),
                  );
              Navigator.of(dialogContext).pop();
            },
            child: const Text(
              'Xác nhận',
              style: TextStyle(color: Color(0xFF52C41A)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLockUnlock(BuildContext context, User user) {
    final action = user.isLocked ? 'mở khóa' : 'khóa';
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1E1D),
        title: Text(
          '${user.isLocked ? 'Mở khóa' : 'Khóa'} tài khoản',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'Bạn có chắc muốn $action tài khoản "${user.name?.isNotEmpty == true ? user.name : user.email}"?',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              if (user.isLocked) {
                context.read<AdminUserBloc>().add(UnlockUserEvent(user.id));
              } else {
                context.read<AdminUserBloc>().add(LockUserEvent(user.id));
              }
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              'Xác nhận',
              style: TextStyle(
                color: user.isLocked ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1E1D),
        title: const Text(
          'Xóa tài khoản',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Bạn có chắc muốn xóa tài khoản "${user.name?.isNotEmpty == true ? user.name : user.email}"? Hành động này không thể hoàn tác!',
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
              // Quay lại màn hình trước sau khi xóa
              Future.microtask(() {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              });
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}


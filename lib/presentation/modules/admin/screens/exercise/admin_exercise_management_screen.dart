import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injector.dart';
import '../../../../../domain/entities/exercise.dart';
import '../../../../../core/constants/api_endpoints.dart';
import '../../bloc/exercise/admin_exercise_bloc.dart';
import '../../bloc/exercise/admin_exercise_event.dart';
import '../../bloc/exercise/admin_exercise_state.dart';
import 'admin_add_exercise_screen.dart';
import 'admin_edit_exercise_screen.dart';

class AdminExerciseManagementScreen extends StatefulWidget {
  const AdminExerciseManagementScreen({super.key});

  static const String routeName = '/admin/exercises';

  @override
  State<AdminExerciseManagementScreen> createState() => _AdminExerciseManagementScreenState();
}

class _AdminExerciseManagementScreenState extends State<AdminExerciseManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String?>> _muscleGroups = [
    {'label': 'Tất cả', 'value': null},
    {'label': 'Ngực', 'value': 'chest'},
    {'label': 'Lưng', 'value': 'back'},
    {'label': 'Chân', 'value': 'legs'},
    {'label': 'Tay', 'value': 'arms'},
    {'label': 'Vai', 'value': 'shoulders'},
    {'label': 'Bụng', 'value': 'core'},
    {'label': 'Toàn thân', 'value': 'full_body'},
  ];

  final List<Map<String, String?>> _difficulties = [
    {'label': 'Tất cả', 'value': null},
    {'label': 'Mới bắt đầu', 'value': 'beginner'},
    {'label': 'Trung bình', 'value': 'intermediate'},
    {'label': 'Nâng cao', 'value': 'advanced'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminExerciseBloc(
        injector(),
        injector(),
        injector(),
        injector(),
      )..add(const LoadExercises()),
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
            'Quản lý Bài tập',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                // Có thể thêm menu options ở đây
              },
            ),
          ],
        ),
        body: BlocConsumer<AdminExerciseBloc, AdminExerciseState>(
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
                        hintText: 'Tìm kiếm bài tập...',
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
                        context.read<AdminExerciseBloc>().add(SearchExercisesEvent(value));
                      },
                    ),
                  ),
                ),

                // Filter Buttons - Muscle Group
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _muscleGroups.length,
                    itemBuilder: (context, index) {
                      final muscleGroup = _muscleGroups[index];
                      final isSelected = state.selectedMuscleGroup == muscleGroup['value'];

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            context.read<AdminExerciseBloc>().add(
                                  FilterExercisesByMuscleGroupEvent(muscleGroup['value']),
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
                                muscleGroup['label']!,
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

                // Filter Buttons - Difficulty
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _difficulties.length,
                    itemBuilder: (context, index) {
                      final difficulty = _difficulties[index];
                      final isSelected = state.selectedDifficulty == difficulty['value'];

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            context.read<AdminExerciseBloc>().add(
                                  FilterExercisesByDifficultyEvent(difficulty['value']),
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
                                difficulty['label']!,
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

                // Exercise List
                Expanded(
                  child: state.displayedExercises.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 64,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.exercises.isEmpty
                                    ? 'Chưa có bài tập nào'
                                    : 'Không tìm thấy bài tập',
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
                            bottom: 90, // Padding cho FAB
                          ),
                          itemCount: state.displayedExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = state.displayedExercises[index];
                            return _buildExerciseItem(context, exercise);
                          },
                        ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (fabContext) => FloatingActionButton(
            onPressed: () async {
              try {
                final bloc = fabContext.read<AdminExerciseBloc>();
                final result = await Navigator.of(fabContext).pushNamed(
                  AdminAddExerciseScreen.routeName,
                  arguments: bloc,
                );
                if (result == true && fabContext.mounted) {
                  bloc.add(const LoadExercises());
                }
              } catch (e) {
                if (fabContext.mounted) {
                  ScaffoldMessenger.of(fabContext).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi mở form thêm: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            backgroundColor: const Color(0xFF52C41A),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseItem(BuildContext context, Exercise exercise) {
    return Dismissible(
      key: Key('exercise_${exercise.id}'),
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
          _showDeleteConfirmation(context, exercise);
          return false; // Không tự động dismiss, đợi user confirm
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
            onTap: () => _showEditExerciseDialog(context, exercise),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ảnh bài tập
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildExerciseImage(exercise.imageUrl),
                  ),
                  const SizedBox(width: 12),
                  // Thông tin bài tập
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          exercise.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (exercise.muscleGroup != null)
                              Text(
                                exercise.muscleGroup!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            if (exercise.difficulty != null)
                              Text(
                                '• ${_getDifficultyLabel(exercise.difficulty!)}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            if (exercise.caloriesBurned != null && exercise.caloriesBurned! > 0)
                              Text(
                                '• ${exercise.caloriesBurned} cal/set',
                                style: const TextStyle(
                                  color: Color(0xFF52C41A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        if (exercise.sets != null && exercise.reps != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${exercise.sets} sets × ${exercise.reps} reps',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Icon edit
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF52C41A), size: 20),
                      onPressed: () => _showEditExerciseDialog(context, exercise),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getDifficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return 'Mới bắt đầu';
      case 'intermediate':
        return 'Trung bình';
      case 'advanced':
        return 'Nâng cao';
      default:
        return difficulty;
    }
  }

  Widget _buildExerciseImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2C2B),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.fitness_center, color: Colors.white38),
      );
    }

    // Network image (full URL)
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2C2B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fitness_center, color: Colors.white38),
          ),
        ),
      );
    }

    // Server upload path
    if (imageUrl.startsWith('/uploads/')) {
      final baseUrl = ApiEndpoints.baseUrl.replaceAll('/api', '');
      final fullUrl = '$baseUrl$imageUrl';
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          fullUrl,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2C2B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fitness_center, color: Colors.white38),
          ),
        ),
      );
    }

    // Asset image
    final assetPath = imageUrl.contains('assets/')
        ? imageUrl
        : 'assets/images/exercises/$imageUrl';
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        assetPath,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2C2B),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.fitness_center, color: Colors.white38),
        ),
      ),
    );
  }

  void _showEditExerciseDialog(BuildContext context, Exercise exercise) {
    final bloc = context.read<AdminExerciseBloc>();
    Navigator.of(context).pushNamed(
      AdminEditExerciseScreen.routeName,
      arguments: {
        'exercise': exercise,
        'bloc': bloc,
      },
    ).then((result) {
      // Reload danh sách nếu cập nhật thành công
      if (result == true) {
        bloc.add(const LoadExercises());
      }
    });
  }

  void _showDeleteConfirmation(BuildContext context, Exercise exercise) {
    final bloc = context.read<AdminExerciseBloc>();
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: bloc,
          child: BlocListener<AdminExerciseBloc, AdminExerciseState>(
            listenWhen: (previous, current) {
              return previous.successMessage != current.successMessage ||
                  (previous.errorMessage != current.errorMessage && current.errorMessage != null);
            },
            listener: (context, state) {
              if (state.successMessage != null || state.errorMessage != null) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: BlocBuilder<AdminExerciseBloc, AdminExerciseState>(
              builder: (context, state) => AlertDialog(
                backgroundColor: const Color(0xFF1C1E1D),
                title: const Text(
                  'Xóa bài tập',
                  style: TextStyle(color: Colors.white),
                ),
                content: Text(
                  'Bạn có chắc muốn xóa "${exercise.name}"?',
                  style: const TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
                  ),
                  ElevatedButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () {
                            bloc.add(DeleteExerciseEvent(exercise.id));
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Xóa'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


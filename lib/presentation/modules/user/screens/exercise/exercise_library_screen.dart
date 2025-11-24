import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../domain/entities/exercise.dart';
import '../../../../../domain/usecases/exercise/calculate_exercise_calories.dart';
import '../../bloc/exercise/exercise_bloc.dart';
import '../../bloc/exercise/exercise_event.dart';
import '../../bloc/exercise/exercise_state.dart';
import '../../bloc/profile_metrics/profile_metrics_bloc.dart';
import '../../bloc/profile_metrics/profile_metrics_state.dart';
import 'exercise_detail_screen.dart';
import 'exercise_history_screen.dart';
import 'exercise_favorites_screen.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedMuscleGroup;
  String? _selectedDifficulty;

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
  void initState() {
    super.initState();
    context.read<ExerciseBloc>().add(LoadExercises());
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    context
        .read<ExerciseBloc>()
        .add(SearchExercises(query: _searchController.text));
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D0F0E), // Pure black background
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thư viện Bài tập',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      // History Button
                      IconButton(
                        icon: const Icon(
                          Icons.history_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ExerciseHistoryScreen(),
                            ),
                          );
                        },
                        tooltip: 'Lịch sử tập luyện',
                      ),
                      // Favorites Button
                      IconButton(
                        icon: const Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ExerciseFavoritesScreen(),
                            ),
                          );
                        },
                        tooltip: 'Yêu thích',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                    hintStyle:
                        TextStyle(color: Colors.white.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.search,
                        color: Colors.white.withOpacity(0.7)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _muscleGroups.length,
                itemBuilder: (context, index) {
                  final group = _muscleGroups[index];
                  final isSelected = _selectedMuscleGroup == group['value'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMuscleGroup = group['value'];
                      });
                      context.read<ExerciseBloc>().add(FilterExercises(
                            muscleGroup: _selectedMuscleGroup,
                            difficulty: _selectedDifficulty,
                          ));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF52C41A)
                            : const Color(0xFF1C1E1D),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          group['label']!,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Difficulty Filter Tabs
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _difficulties.length,
                itemBuilder: (context, index) {
                  final diff = _difficulties[index];
                  final isSelected = _selectedDifficulty == diff['value'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDifficulty = diff['value'];
                      });
                      context.read<ExerciseBloc>().add(FilterExercises(
                            muscleGroup: _selectedMuscleGroup,
                            difficulty: _selectedDifficulty,
                          ));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF52C41A).withOpacity(0.3)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF52C41A)
                              : Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          diff['label']!,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF52C41A)
                                : Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
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
              child: BlocBuilder<ExerciseBloc, ExerciseState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF52C41A)));
                  }
                  if (state.errorMessage != null) {
                    return Center(
                      child: Text(
                        'Lỗi: ${state.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (state.filteredExercises.isEmpty) {
                    return const Center(
                      child: Text(
                        'Không tìm thấy bài tập nào.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }
                  return BlocBuilder<ProfileMetricsBloc, ProfileMetricsState>(
                    builder: (context, profileState) {
                      final userWeight = profileState.metrics?.weight ?? 70.0;
                      
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = state.filteredExercises[index];
                          return _buildExerciseCard(exercise, userWeight);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, double userWeight) {
    // Tính calories điều chỉnh theo user
    final baseCalories = exercise.caloriesBurned ?? 0;
    final adjustedCaloriesPerSet = CalculateExerciseCalories.calculateCaloriesPerSet(
      baseCalories: baseCalories,
      userWeight: userWeight,
      difficulty: exercise.difficulty ?? 'intermediate',
    );
    final totalCalories = CalculateExerciseCalories.calculateTotalCalories(
      caloriesPerSet: adjustedCaloriesPerSet,
      sets: exercise.sets ?? 1,
    );
    

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E1D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseDetailScreen(exercise: exercise),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Exercise Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  color: const Color(0xFF0D0F0E),
                  child: Hero(
                    tag: 'exercise-${exercise.id}',
                    child: _buildExerciseImage(exercise),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Exercise Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (exercise.difficulty != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(exercise.difficulty!)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getDifficultyLabel(exercise.difficulty!),
                              style: TextStyle(
                                color: _getDifficultyColor(exercise.difficulty!),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (exercise.muscleGroup != null)
                          Text(
                            _getMuscleGroupLabel(exercise.muscleGroup!),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.fitness_center,
                            size: 14,
                            color: Colors.white.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        Text(
                          '${exercise.sets ?? 0} sets × ${exercise.reps ?? 0} reps',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.local_fire_department,
                            size: 14, color: Colors.orange.shade400),
                        const SizedBox(width: 4),
                        Text(
                          '$totalCalories kcal',
                          style: TextStyle(
                            color: Colors.orange.shade400,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.3), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseImage(Exercise exercise) {
    if (exercise.imageUrl == null || exercise.imageUrl!.isEmpty) {
      return Center(
        child: Icon(
          Icons.fitness_center,
          color: Colors.white.withOpacity(0.3),
          size: 32,
        ),
      );
    }

    final imageUrl = exercise.imageUrl!;

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    }

    if (imageUrl.startsWith('/uploads/')) {
      const baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://10.0.2.2:3000',
      );
      final serverUrl = baseUrl.replaceAll('/api', '');
      final fullUrl = '$serverUrl$imageUrl';
      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    }


    final assetPath = imageUrl.contains('assets/')
        ? imageUrl
        : 'assets/images/exercises/$imageUrl';
    
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Asset image error for ${exercise.name}: $error');
        return _buildPlaceholderImage();
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(
        Icons.fitness_center,
        color: Colors.white.withOpacity(0.3),
        size: 32,
      ),
    );
  }

  String _getDifficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return 'MỚI';
      case 'intermediate':
        return 'TRUNG';
      case 'advanced':
        return 'NÂNG';
      default:
        return difficulty.toUpperCase();
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return const Color(0xFF52C41A); // Green
      case 'intermediate':
        return const Color(0xFFF7B731); // Yellow
      case 'advanced':
        return const Color(0xFFFF6B6B); // Red
      default:
        return Colors.grey;
    }
  }

  String _getMuscleGroupLabel(String muscleGroup) {
    switch (muscleGroup) {
      case 'chest':
        return 'Ngực';
      case 'back':
        return 'Lưng';
      case 'legs':
        return 'Chân';
      case 'arms':
        return 'Tay';
      case 'shoulders':
        return 'Vai';
      case 'core':
        return 'Bụng';
      case 'full_body':
        return 'Toàn thân';
      default:
        return muscleGroup;
    }
  }
}


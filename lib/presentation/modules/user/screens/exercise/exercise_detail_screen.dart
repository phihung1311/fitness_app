import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../domain/entities/exercise.dart';
import '../../../../../domain/usecases/exercise/calculate_exercise_calories.dart';
import '../../../../../core/di/injector.dart';
import '../../../../../domain/usecases/profile/get_profile_metrics.dart';
import '../../../../../data/datasources/remote/exercise_api.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  static const String routeName = '/exercise-detail';

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen>
    with SingleTickerProviderStateMixin {
  int _sets = 3;
  double? _userWeight;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoadingWeight = true;

  @override
  void initState() {
    super.initState();
    _sets = widget.exercise.sets ?? 3;
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _loadUserWeight();
    _animationController.forward();
  }

  Future<void> _loadUserWeight() async {
    try {
      final getProfileMetrics = injector<GetProfileMetrics>();
      final metrics = await getProfileMetrics();
      setState(() {
        _userWeight = metrics.weight ?? 70.0; // Default 70kg
        _isLoadingWeight = false;
      });
    } catch (e) {
      setState(() {
        _userWeight = 70.0; // Default fallback
        _isLoadingWeight = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Tính calories dựa trên sets và user weight
  int _calculateCalories() {
    if (_userWeight == null || widget.exercise.caloriesBurned == null) {
      return 0;
    }

    final caloriesPerSet = CalculateExerciseCalories.calculateCaloriesPerSet(
      baseCalories: widget.exercise.caloriesBurned!,
      userWeight: _userWeight!,
      difficulty: widget.exercise.difficulty ?? 'intermediate',
    );

    return CalculateExerciseCalories.calculateTotalCalories(
      caloriesPerSet: caloriesPerSet,
      sets: _sets,
    );
  }

  Color _getDifficultyColor() {
    switch (widget.exercise.difficulty?.toLowerCase()) {
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

  String _getDifficultyLabel() {
    switch (widget.exercise.difficulty?.toLowerCase()) {
      case 'beginner':
        return 'Cơ bản';
      case 'intermediate':
        return 'Trung bình';
      case 'advanced':
        return 'Nâng cao';
      default:
        return 'Không xác định';
    }
  }

  String _getMuscleGroupLabel() {
    final group = widget.exercise.muscleGroup?.toLowerCase() ?? '';
    final Map<String, String> labels = {
      'chest': 'Ngực',
      'back': 'Lưng',
      'shoulders': 'Vai',
      'arms': 'Tay',
      'legs': 'Chân',
      'core': 'Cơ bụng',
      'cardio': 'Cardio',
      'full body': 'Toàn thân',
    };
    return labels[group] ?? widget.exercise.muscleGroup ?? 'Không xác định';
  }

  @override
  Widget build(BuildContext context) {
    final totalCalories = _calculateCalories();
    final caloriesPerSet = _userWeight != null && widget.exercise.caloriesBurned != null
        ? CalculateExerciseCalories.calculateCaloriesPerSet(
            baseCalories: widget.exercise.caloriesBurned!,
            userWeight: _userWeight!,
            difficulty: widget.exercise.difficulty ?? 'intermediate',
          )
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F0E),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // App Bar với Hero Image
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                backgroundColor: const Color(0xFF0D0F0E),
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'exercise-${widget.exercise.id}',
                    child: _buildExerciseImage(),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF0D0F0E),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Exercise Name & Basic Info
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.exercise.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _buildInfoBadge(
                                      icon: Icons.fitness_center_rounded,
                                      label: _getMuscleGroupLabel(),
                                      color: const Color(0xFF52C41A),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildInfoBadge(
                                      icon: Icons.trending_up_rounded,
                                      label: _getDifficultyLabel(),
                                      color: _getDifficultyColor(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Sets Slider
                          _buildSetsSlider(),

                          const SizedBox(height: 24),

                          // Calories Card
                          _buildCaloriesCard(caloriesPerSet, totalCalories),

                          const SizedBox(height: 24),

                          // Exercise Details
                          _buildExerciseDetails(),

                          const SizedBox(height: 24),

                          // Instructions
                          if (widget.exercise.instructions != null &&
                              widget.exercise.instructions!.isNotEmpty)
                            _buildInstructions(),

                          const SizedBox(height: 120), // Space for button
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Floating Action Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildFloatingButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseImage() {
    final imageUrl = widget.exercise.imageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    // Network image
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    // Server upload
    if (imageUrl.startsWith('/uploads/')) {
      const baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://10.0.2.2:3000',
      );
      final serverUrl = baseUrl.replaceAll('/api', '');
      return Image.network(
        '$serverUrl$imageUrl',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    // Asset
    return Image.asset(
      imageUrl.contains('assets/')
          ? imageUrl
          : 'assets/images/exercises/$imageUrl',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF1C1E1D),
      child: Center(
        child: Icon(
          Icons.fitness_center,
          color: Colors.white.withOpacity(0.2),
          size: 80,
        ),
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetsSlider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E1D),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Số hiệp (Sets)',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  Text(
                    _sets.toString(),
                    style: const TextStyle(
                      color: Color(0xFF52C41A),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'hiệp',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _sets.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: const Color(0xFF52C41A),
            inactiveColor: Colors.white.withOpacity(0.1),
            onChanged: (value) {
              setState(() {
                _sets = value.toInt();
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              Text(
                '10',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesCard(int caloriesPerSet, int totalCalories) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF52C41A).withOpacity(0.2),
            const Color(0xFF52C41A).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF52C41A).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCalorieItem(
                label: 'Calories/hiệp',
                value: caloriesPerSet.toString(),
                icon: Icons.local_fire_department_rounded,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.1),
              ),
              _buildCalorieItem(
                label: 'Tổng calories',
                value: totalCalories.toString(),
                icon: Icons.whatshot_rounded,
                isTotal: true,
              ),
            ],
          ),
          if (_isLoadingWeight)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Đang tải thông tin cân nặng...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            )
          else if (_userWeight != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Dựa trên cân nặng: ${_userWeight!.toStringAsFixed(1)} kg',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalorieItem({
    required String label,
    required String value,
    required IconData icon,
    bool isTotal = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: isTotal ? const Color(0xFFFF6B6B) : const Color(0xFF52C41A),
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? const Color(0xFFFF6B6B) : const Color(0xFF52C41A),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E1D),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin bài tập',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (widget.exercise.reps != null)
            _buildDetailRow(
              icon: Icons.repeat_rounded,
              label: 'Số lần lặp lại',
              value: '${widget.exercise.reps} lần/hiệp',
            ),
          if (widget.exercise.restTimeSec != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.timer_outlined,
              label: 'Thời gian nghỉ',
              value: '${widget.exercise.restTimeSec} giây',
            ),
          ],
          if (widget.exercise.caloriesBurned != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.local_fire_department_outlined,
              label: 'Calories cơ bản',
              value: '${widget.exercise.caloriesBurned} kcal/hiệp (70kg)',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF52C41A).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF52C41A),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E1D),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: const Color(0xFF52C41A),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Hướng dẫn thực hiện',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.exercise.instructions!,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F0E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF52C41A), Color(0xFF45A049)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF52C41A).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _showAddExerciseBottomSheet();
              },
              borderRadius: BorderRadius.circular(16),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Thêm vào kế hoạch',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddExerciseBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1E1D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thêm bài tập vào...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Option 1: Hôm nay
            _buildAddOption(
              icon: Icons.today_rounded,
              title: 'Hôm nay',
              subtitle: DateFormat('dd/MM/yyyy').format(DateTime.now()),
              onTap: () {
                Navigator.pop(context);
                _addExerciseToday();
              },
            ),
            const SizedBox(height: 12),
            // Option 2: Chọn ngày khác
            _buildAddOption(
              icon: Icons.calendar_today_rounded,
              title: 'Chọn ngày khác',
              subtitle: 'Lên lịch cho ngày khác',
              onTap: () {
                Navigator.pop(context);
                _selectDateAndAdd();
              },
            ),
            const SizedBox(height: 12),
            // Option 3: Yêu thích
            _buildAddOption(
              icon: Icons.star_outline_rounded,
              title: 'Thêm vào yêu thích',
              subtitle: 'Lưu để xem sau',
              onTap: () {
                Navigator.pop(context);
                _addToFavorites();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0F0E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2A2C2B),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF52C41A).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF52C41A),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addExerciseToday() async {
    try {
      final exerciseApi = injector<ExerciseApi>();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      await exerciseApi.addUserExercise(
        exerciseId: widget.exercise.id,
        workoutDate: today,
        sets: _sets,
        reps: widget.exercise.reps,
        durationMin: null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm "${widget.exercise.name}" vào hôm nay!'),
            backgroundColor: const Color(0xFF52C41A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _selectDateAndAdd() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF52C41A),
              onPrimary: Colors.white,
              surface: Color(0xFF1C1E1D),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return;

    try {
      final exerciseApi = injector<ExerciseApi>();
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
      
      await exerciseApi.addUserExercise(
        exerciseId: widget.exercise.id,
        workoutDate: dateStr,
        sets: _sets,
        reps: widget.exercise.reps,
        durationMin: null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã lên lịch "${widget.exercise.name}" cho ${DateFormat('dd/MM/yyyy').format(selectedDate)}!',
            ),
            backgroundColor: const Color(0xFF52C41A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _addToFavorites() async {
    try {
      final exerciseApi = injector<ExerciseApi>();
      
      await exerciseApi.addToFavorites(widget.exercise.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm "${widget.exercise.name}" vào yêu thích!'),
            backgroundColor: const Color(0xFF52C41A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}


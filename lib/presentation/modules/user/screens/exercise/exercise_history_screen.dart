import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/injector.dart';
import '../../../../../data/datasources/remote/exercise_api.dart';

class ExerciseHistoryScreen extends StatefulWidget {
  const ExerciseHistoryScreen({super.key});

  @override
  State<ExerciseHistoryScreen> createState() => _ExerciseHistoryScreenState();
}

class _ExerciseHistoryScreenState extends State<ExerciseHistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _historyData;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final exerciseApi = injector<ExerciseApi>();
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      final response = await exerciseApi.getExerciseHistory(dateStr);
      
      setState(() {
        _historyData = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
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

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0F0E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lịch sử Tập luyện',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF52C41A),
        backgroundColor: const Color(0xFF1C1E1D),
        onRefresh: _loadHistory,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF52C41A)),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.redAccent.shade200,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadHistory,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF52C41A),
                          ),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Picker
                          _buildDatePicker(),
                          const SizedBox(height: 24),

                          // Summary Card
                          if (_historyData != null) _buildSummaryCard(),
                          const SizedBox(height: 24),

                          // Exercises List
                          if (_historyData != null) _buildExercisesList(),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1E1D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2A2C2B),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF52C41A).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: Color(0xFF52C41A),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chọn ngày',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  Widget _buildSummaryCard() {
    final totalCalories = _historyData!['total_calories'] as int? ?? 0;
    final totalDuration = _historyData!['total_duration_min'] as int? ?? 0;
    final exercises = _historyData!['exercises'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF52C41A).withOpacity(0.2),
            const Color(0xFF52C41A).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF52C41A).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                icon: Icons.local_fire_department_rounded,
                label: 'Calories',
                value: '$totalCalories kcal',
                color: Colors.redAccent.shade200,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.1),
              ),
              // _buildSummaryItem(
              //   icon: Icons.timer_outlined,
              //   label: 'Thời gian',
              //   value: '$totalDuration phút',
              //   color: const Color(0xFF52C41A),
              // ),
              // Container(
              //   width: 1,
              //   height: 40,
              //   color: Colors.white.withOpacity(0.1),
              // ),
              _buildSummaryItem(
                icon: Icons.fitness_center_rounded,
                label: 'Bài tập',
                value: '${exercises.length}',
                color: Colors.blueAccent.shade200,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
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

  Widget _buildExercisesList() {
    final exercises = _historyData!['exercises'] as List<dynamic>? ?? [];

    if (exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              color: Colors.white.withOpacity(0.3),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có bài tập nào trong ngày này',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bài tập hôm nay:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: exercises.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return _buildExerciseCard(exercise);
          },
        ),
      ],
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    final exerciseData = exercise['Exercise'] as Map<String, dynamic>?;
    final exerciseName = exerciseData?['name'] as String? ?? 'Unknown';
    final muscleGroup = exerciseData?['muscle_group'] as String? ?? '';
    final caloriesBurned = exercise['calories_burned'] as int? ?? 0;
    final durationMin = exercise['duration_min'] as int?;
    final imageUrl = exerciseData?['image_url'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2C2B),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Exercise Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: const Color(0xFF0D0F0E),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? _buildExerciseImage(imageUrl)
                  : Center(
                      child: Icon(
                        Icons.fitness_center,
                        color: Colors.white.withOpacity(0.3),
                        size: 32,
                      ),
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
                  exerciseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (muscleGroup.isNotEmpty)
                  Text(
                    muscleGroup.capitalize(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.redAccent.shade200,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$caloriesBurned kcal',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                    if (durationMin != null) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.timer_outlined,
                        color: Colors.white.withOpacity(0.6),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$durationMin phút',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseImage(String imageUrl) {
    // Network image
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.fitness_center,
              color: Colors.white.withOpacity(0.3),
              size: 32,
            ),
          );
        },
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
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.fitness_center,
              color: Colors.white.withOpacity(0.3),
              size: 32,
            ),
          );
        },
      );
    }

    // Asset
    return Image.asset(
      imageUrl.contains('assets/')
          ? imageUrl
          : 'assets/images/exercises/$imageUrl',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(
            Icons.fitness_center,
            color: Colors.white.withOpacity(0.3),
            size: 32,
          ),
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}


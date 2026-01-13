import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/injector.dart';
import '../../../../../data/datasources/remote/meal_api.dart';
import '../../../../../domain/entities/user_meal.dart';

class MealHistoryScreen extends StatefulWidget {
  const MealHistoryScreen({super.key});

  @override
  State<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends State<MealHistoryScreen> {
  final MealApi _mealApi = injector<MealApi>();
  List<UserMeal> _allMeals = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMealHistory();
  }

  Future<void> _loadMealHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Lấy tất cả meals
      final meals = await _mealApi.getMealsByDate('');
      setState(() {
        _allMeals = meals.map((dto) => dto.toEntity()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
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
      _loadMealsForDate(picked);
    }
  }

  Future<void> _loadMealsForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final meals = await _mealApi.getMealsByDate(dateStr);
      setState(() {
        _allMeals = meals.map((dto) => dto.toEntity()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Map<String, List<UserMeal>> _groupMealsByDate() {
    final Map<String, List<UserMeal>> grouped = {};
    for (final meal in _allMeals) {
      String date;
      if (meal.mealDate != null) {
        date = DateFormat('yyyy-MM-dd').format(meal.mealDate!);
      } else {
        date = DateFormat('yyyy-MM-dd').format(meal.createdAt);
      }
      if (!grouped.containsKey(date)) {
        grouped[date] = <UserMeal>[];
      }
      final dateList = grouped[date];
      if (dateList != null) {
        dateList.add(meal);
      }
    }
    return grouped;
  }

  Map<String, List<UserMeal>> _groupMealsBySession(List<UserMeal> meals) {
    final Map<String, List<UserMeal>> grouped = {
      'breakfast': <UserMeal>[],
      'lunch': <UserMeal>[],
      'dinner': <UserMeal>[],
      'snack': <UserMeal>[],
    };
    for (final meal in meals) {
      final session = meal.mealSession ?? 'snack';
      final sessionList = grouped[session];
      if (sessionList != null) {
        sessionList.add(meal);
      }
    }
    return grouped;
  }

  int _calculateTotalCalories(List<UserMeal> meals) {
    return meals.fold<int>(0, (sum, meal) => sum + (meal.calories ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F0E),
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF52C41A)),
        )
            : _errorMessage != null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lỗi: $_errorMessage',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadMealHistory,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        )
            : RefreshIndicator(
          color: const Color(0xFF52C41A),
          backgroundColor: const Color(0xFF1C1E1D),
          onRefresh: _loadMealHistory,
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final groupedByDate = _groupMealsByDate();
    final sortedDates = groupedByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Mới nhất trước

    if (sortedDates.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header có nút back
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Lịch sử bữa ăn',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 80),

              // Nội dung empty state
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có lịch sử bữa ăn',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }


    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Lịch sử món ăn',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Summary info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1E1D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng số món: ${_allMeals.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tổng calo: ${_calculateTotalCalories(_allMeals)} kcal',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF52C41A),
                    ),
                    onPressed: _selectDate,
                    tooltip: 'Lọc theo ngày',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Meals grouped by date
            ...sortedDates.map((date) {
              final meals = groupedByDate[date]!;
              final groupedBySession = _groupMealsBySession(meals);
              final totalCalories = _calculateTotalCalories(meals);

              return _buildDateSection(
                date,
                totalCalories,
                groupedBySession,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection(
    String date,
    int totalCalories,
    Map<String, List<UserMeal>> groupedBySession,
  ) {
    DateTime? dateTime;
    try {
      dateTime = DateFormat('yyyy-MM-dd').parse(date);
    } catch (e) {
      dateTime = DateTime.now();
    }

    // Extract meal lists outside of children list
    final breakfastMeals = groupedBySession['breakfast'] ?? [];
    final lunchMeals = groupedBySession['lunch'] ?? [];
    final dinnerMeals = groupedBySession['dinner'] ?? [];
    final snackMeals = groupedBySession['snack'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header with total calories
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDateVietnamese(dateTime),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${breakfastMeals.length + lunchMeals.length + dinnerMeals.length + snackMeals.length} món',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF52C41A).withOpacity(0.8),
                      const Color(0xFF52C41A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalCalories kcal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF2A2C2B)),
          const SizedBox(height: 16),

          // Meal sessions
          if (breakfastMeals.isNotEmpty) ...[
            _buildMealSession(
              'Bữa sáng',
              Icons.wb_sunny,
              breakfastMeals,
            ),
            const SizedBox(height: 12),
          ],
          if (lunchMeals.isNotEmpty) ...[
            _buildMealSession(
              'Bữa trưa',
              Icons.lunch_dining,
              lunchMeals,
            ),
            const SizedBox(height: 12),
          ],
          if (dinnerMeals.isNotEmpty) ...[
            _buildMealSession(
              'Bữa tối',
              Icons.dinner_dining,
              dinnerMeals,
            ),
            const SizedBox(height: 12),
          ],
          if (snackMeals.isNotEmpty)
            _buildMealSession(
              'Bữa phụ',
              Icons.cookie,
              snackMeals,
            ),
        ],
      ),
    );
  }

  Widget _buildMealSession(
    String title,
    IconData icon,
    List<UserMeal> meals,
  ) {
    final sessionCalories = _calculateTotalCalories(meals);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F0E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF52C41A), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF52C41A).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$sessionCalories kcal',
                  style: const TextStyle(
                    color: Color(0xFF52C41A),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...meals.map((meal) => _buildFoodItem(meal)).toList(),
        ],
      ),
    );
  }

  Widget _buildFoodItem(UserMeal meal) {
    final food = meal.food;
    if (food == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E1D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2C2B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildFoodImage(food.imageUrl),
          ),
          const SizedBox(width: 12),

          // Food Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${meal.weightGrams}g • ${meal.calories} kcal',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholderImage();
    }

    // Case 1: Full URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    }

    // Case 2: Server upload path
    if (imageUrl.startsWith('/uploads/')) {
      const baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://10.0.2.2:3000',
      );
      final serverUrl = baseUrl.replaceAll('/api', '');
      final fullUrl = '$serverUrl$imageUrl';
      return Image.network(
        fullUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    }

    // Case 3: Asset
    final assetPath = imageUrl.contains('assets/')
        ? imageUrl
        : 'assets/images/foods/$imageUrl';
    return Image.asset(
      assetPath,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 50,
      height: 50,
      color: const Color(0xFF2A2C2B),
      child: Center(
        child: Icon(
          Icons.restaurant,
          color: Colors.white.withOpacity(0.3),
          size: 20,
        ),
      ),
    );
  }

  String _formatDateVietnamese(DateTime date) {
    final weekdays = [
      'Chủ nhật',
      'Thứ hai',
      'Thứ ba',
      'Thứ tư',
      'Thứ năm',
      'Thứ sáu',
      'Thứ bảy',
    ];
    final weekday = weekdays[date.weekday % 7];
    return '$weekday, ${DateFormat('dd/MM/yyyy').format(date)}';
  }
}


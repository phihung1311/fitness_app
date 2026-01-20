import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/injector.dart';
import '../../../../../data/datasources/remote/meal_api.dart';
import '../../../../../domain/entities/user_meal.dart';
import '../../../../../domain/usecases/meal/update_meal.dart';
import '../../../../../domain/usecases/meal/delete_meal.dart';

class MealHistoryScreen extends StatefulWidget {
  const MealHistoryScreen({super.key});

  @override
  State<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends State<MealHistoryScreen> {
  final MealApi _mealApi = injector<MealApi>();
  final UpdateMeal _updateMeal = injector<UpdateMeal>();
  final DeleteMeal _deleteMeal = injector<DeleteMeal>();

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

  void _showEditDialog(UserMeal meal) {
    final controller = TextEditingController(text: meal.weightGrams.toString());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1E1D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Chỉnh sửa khối lượng',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meal.food?.name ?? '',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Khối lượng (gram)',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                suffixText: 'g',
                suffixStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF52C41A),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newWeight = int.tryParse(controller.text);
              if (newWeight != null && newWeight > 0) {
                Navigator.pop(dialogContext);

                setState(() => _isLoading = true);

                try {
                  await _updateMeal(
                    mealId: meal.id!,
                    weightGrams: newWeight,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã cập nhật món ăn'),
                        backgroundColor: Color(0xFF52C41A),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }

                  await _loadMealHistory();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                  setState(() => _isLoading = false);
                }
              } else {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập số gram hợp lệ'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF52C41A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Lưu',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(UserMeal meal) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1E1D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Xác nhận xóa',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Bạn có chắc muốn xóa "${meal.food?.name ?? 'món ăn này'}" khỏi lịch sử?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              setState(() => _isLoading = true);

              try {
                await _deleteMeal(meal.id!);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa món ăn'),
                      backgroundColor: Color(0xFF52C41A),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }

                await _loadMealHistory();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: ${e.toString()}'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Xóa',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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
      grouped[date]!.add(meal);
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
      grouped[session]?.add(meal);
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
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Lỗi: $_errorMessage',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadMealHistory,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF52C41A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
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
      ..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) {
      return _buildEmptyState();
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Lịch sử món ăn',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSummaryCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Meals by date
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final date = sortedDates[index];
                final meals = groupedByDate[date]!;
                final groupedBySession = _groupMealsBySession(meals);
                final totalCalories = _calculateTotalCalories(meals);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildDateSection(
                    date,
                    totalCalories,
                    groupedBySession,
                  ),
                );
              },
              childCount: sortedDates.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Chưa có lịch sử bữa ăn',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bắt đầu thêm món ăn vào nhật ký của bạn',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
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

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
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
          ),
          IconButton(
            icon: const Icon(
              Icons.calendar_today,
              color: Color(0xFF52C41A),
              size: 24,
            ),
            onPressed: _selectDate,
            tooltip: 'Lọc theo ngày',
          ),
        ],
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

    final breakfastMeals = groupedBySession['breakfast'] ?? [];
    final lunchMeals = groupedBySession['lunch'] ?? [];
    final dinnerMeals = groupedBySession['dinner'] ?? [];
    final snackMeals = groupedBySession['snack'] ?? [];
    final totalMeals = breakfastMeals.length + lunchMeals.length +
        dinnerMeals.length + snackMeals.length;

    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
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
                      '$totalMeals món',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
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
          const Divider(color: Color(0xFF2A2C2B), height: 1),
          const SizedBox(height: 16),
          if (breakfastMeals.isNotEmpty) ...[
            _buildMealSession('Bữa sáng', Icons.wb_sunny, breakfastMeals),
            const SizedBox(height: 12),
          ],
          if (lunchMeals.isNotEmpty) ...[
            _buildMealSession('Bữa trưa', Icons.lunch_dining, lunchMeals),
            const SizedBox(height: 12),
          ],
          if (dinnerMeals.isNotEmpty) ...[
            _buildMealSession('Bữa tối', Icons.dinner_dining, dinnerMeals),
            const SizedBox(height: 12),
          ],
          if (snackMeals.isNotEmpty)
            _buildMealSession('Bữa phụ', Icons.cookie, snackMeals),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildFoodImage(food.imageUrl),
          ),
          const SizedBox(width: 12),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showEditDialog(meal),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF52C41A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Color(0xFF52C41A),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showDeleteConfirmation(meal),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete,
                      size: 18,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholderImage();
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
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
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    }

    final assetPath = imageUrl.contains('assets/')
        ? imageUrl
        : 'assets/images/foods/$imageUrl';
    return Image.asset(
      assetPath,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2C2B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant,
          color: Colors.white.withOpacity(0.3),
          size: 24,
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
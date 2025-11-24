import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../domain/entities/food.dart';
import '../../../../../core/di/injector.dart';
import '../../bloc/meal/meal_bloc.dart';
import '../../bloc/meal/meal_event.dart';
import '../../bloc/meal/meal_state.dart';

class FoodDetailScreen extends StatefulWidget {
  final Food food;

  const FoodDetailScreen({super.key, required this.food});

  static const String routeName = '/food-detail';

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> with SingleTickerProviderStateMixin {
  double _weight = 100.0; // gram
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Tính toán dinh dưỡng theo trọng lượng
  double _calculateNutrition(double? per100g) {
    if (per100g == null) return 0;
    return (per100g / 100) * _weight;
  }

  @override
  Widget build(BuildContext context) {
    final calories = _calculateNutrition(widget.food.calories100g);
    final protein = _calculateNutrition(widget.food.protein100g);
    final carbs = _calculateNutrition(widget.food.carbs100g);
    final fat = _calculateNutrition(widget.food.fat100g);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F0E),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // App Bar với Hero Image
              SliverAppBar(
                expandedHeight: 300,
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
                    tag: 'food-${widget.food.id}',
                    child: _buildFoodImage(),
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
                          // Food Name & Basic Info
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.food.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildMealTypeBadge(),
                              ],
                            ),
                          ),

                          // Weight Slider
                          _buildWeightSlider(),

                          const SizedBox(height: 32),

                          // Nutrition Cards
                          _buildNutritionCards(calories, protein, carbs, fat),

                          const SizedBox(height: 32),

                          // Detailed Nutrition
                          _buildDetailedNutrition(calories, protein, carbs, fat),

                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Floating Add Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildFloatingAddButton(calories),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImage() {
    final imageUrl = widget.food.imageUrl;

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
      imageUrl.contains('assets/') ? imageUrl : 'assets/images/foods/$imageUrl',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF1C1E1D),
      child: Center(
        child: Icon(
          Icons.restaurant,
          color: Colors.white.withOpacity(0.2),
          size: 80,
        ),
      ),
    );
  }

  Widget _buildMealTypeBadge() {
    final mealType = widget.food.mealType;
    if (mealType == null) return const SizedBox.shrink();

    final Map<String, Map<String, dynamic>> mealTypeInfo = {
      'breakfast': {'label': 'Bữa sáng', 'icon': Icons.wb_sunny_rounded},
      'lunch': {'label': 'Bữa trưa', 'icon': Icons.wb_sunny_outlined},
      'dinner': {'label': 'Bữa tối', 'icon': Icons.nightlight_round},
      'snack': {'label': 'Bữa phụ', 'icon': Icons.cookie_rounded},
      'all': {'label': 'Phù hợp mọi bữa', 'icon': Icons.all_inclusive},
    };

    final info = mealTypeInfo[mealType] ?? mealTypeInfo['all']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF52C41A).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF52C41A).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            info['icon'],
            color: const Color(0xFF52C41A),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            info['label'],
            style: const TextStyle(
              color: Color(0xFF52C41A),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSlider() {
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
                'Khối lượng',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  Text(
                    _weight.toInt().toString(),
                    style: const TextStyle(
                      color: Color(0xFF52C41A),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'gram',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF52C41A),
              inactiveTrackColor: const Color(0xFF2A2C2B),
              thumbColor: const Color(0xFF52C41A),
              overlayColor: const Color(0xFF52C41A).withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              trackHeight: 6,
            ),
            child: Slider(
              value: _weight,
              min: 10,
              max: 500,
              divisions: 49,
              onChanged: (value) {
                setState(() {
                  _weight = value;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '10g',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              Text(
                '500g',
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

  Widget _buildNutritionCards(double calories, double protein, double carbs, double fat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin dinh dưỡng',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNutritionCard(
                  'Calories',
                  calories.toInt().toString(),
                  'kcal',
                  Icons.local_fire_department,
                  const Color(0xFFFF6B6B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNutritionCard(
                  'Protein',
                  protein.toStringAsFixed(1),
                  'g',
                  Icons.fitness_center,
                  const Color(0xFF4ECDC4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNutritionCard(
                  'Carbs',
                  carbs.toStringAsFixed(1),
                  'g',
                  Icons.grain,
                  const Color(0xFFFFD93D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNutritionCard(
                  'Fat',
                  fat.toStringAsFixed(1),
                  'g',
                  Icons.water_drop,
                  const Color(0xFFFF8A5B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(String label, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedNutrition(double calories, double protein, double carbs, double fat) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E1D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết dinh dưỡng',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildNutritionRow('Calories', '${calories.toInt()} kcal', Colors.white),
          if (widget.food.protein100g != null)
            _buildNutritionRow('Protein', '${protein.toStringAsFixed(1)}g', const Color(0xFF4ECDC4)),
          if (widget.food.carbs100g != null)
            _buildNutritionRow('Carbohydrates', '${carbs.toStringAsFixed(1)}g', const Color(0xFFFFD93D)),
          if (widget.food.fat100g != null)
            _buildNutritionRow('Fat', '${fat.toStringAsFixed(1)}g', const Color(0xFFFF8A5B)),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            '* Giá trị dinh dưỡng tính cho ${_weight.toInt()}g',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
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
    );
  }

  Widget _buildFloatingAddButton(double calories) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0D0F0E).withOpacity(0.0),
            const Color(0xFF0D0F0E),
          ],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            _showMealSessionDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF52C41A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: const Color(0xFF52C41A).withOpacity(0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline, size: 24),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Thêm vào bữa ăn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_weight.toInt()}g • ${calories.toInt()} kcal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMealSessionDialog() {
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
              'Chọn bữa ăn',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildMealSessionOption('Bữa sáng', 'breakfast', Icons.wb_sunny_rounded),
            _buildMealSessionOption('Bữa trưa', 'lunch', Icons.wb_sunny_outlined),
            _buildMealSessionOption('Bữa tối', 'dinner', Icons.nightlight_round),
            _buildMealSessionOption('Bữa phụ', 'snack', Icons.cookie_rounded),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSessionOption(String label, String session, IconData icon) {
    return BlocProvider(
      create: (context) => MealBloc(injector(), injector()),
      child: BlocConsumer<MealBloc, MealState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: const Color(0xFF52C41A),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return InkWell(
            onTap: state.isAdding ? null : () {
              // Add meal
              context.read<MealBloc>().add(AddMealEvent(
                foodId: widget.food.id,
                mealSession: session,
                weightGrams: _weight.toInt(),
              ));
              Navigator.pop(context);
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0F0E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
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
              child: Icon(icon, color: const Color(0xFF52C41A), size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            state.isAdding
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF52C41A),
                    ),
                  )
                : const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
          ],
        ),
      ),
            );
        },
      ),
    );
  }
}


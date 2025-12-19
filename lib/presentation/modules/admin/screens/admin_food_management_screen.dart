import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/di/injector.dart';
import '../../../../../domain/entities/food.dart';
import '../bloc/admin_food/admin_food_bloc.dart';
import '../bloc/admin_food/admin_food_event.dart';
import '../bloc/admin_food/admin_food_state.dart';
import 'admin_add_food_screen.dart';

/// Màn hình quản lý món ăn cho Admin
/// Tách biệt hoàn toàn với FoodLibraryScreen của User
class AdminFoodManagementScreen extends StatefulWidget {
  const AdminFoodManagementScreen({super.key});

  @override
  State<AdminFoodManagementScreen> createState() => _AdminFoodManagementScreenState();
}

class _AdminFoodManagementScreenState extends State<AdminFoodManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String?>> _mealTypes = [
    {'label': 'Tất cả', 'value': null},
    {'label': 'Bữa sáng', 'value': 'breakfast'},
    {'label': 'Bữa trưa', 'value': 'lunch'},
    {'label': 'Bữa tối', 'value': 'dinner'},
    {'label': 'Đồ ăn vặt', 'value': 'snack'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminFoodBloc(
        injector(),
        injector(),
        injector(),
        injector(),
      )..add(const LoadFoods()),
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
            'Quản lý Món ăn',
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
        body: BlocConsumer<AdminFoodBloc, AdminFoodState>(
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
                        hintText: 'Tìm kiếm món ăn...',
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
                        context.read<AdminFoodBloc>().add(SearchFoodsEvent(value));
                      },
                    ),
                  ),
                ),

                // Filter Buttons
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _mealTypes.length,
                    itemBuilder: (context, index) {
                      final mealType = _mealTypes[index];
                      final isSelected = state.selectedMealType == mealType['value'];

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            context.read<AdminFoodBloc>().add(
                                  FilterFoodsByMealTypeEvent(mealType['value']),
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
                                mealType['label']!,
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

                // Food List
                Expanded(
                  child: state.displayedFoods.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 64,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.foods.isEmpty
                                    ? 'Chưa có món ăn nào'
                                    : 'Không tìm thấy món ăn',
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
                            bottom: 80, // Padding cho FAB
                          ),
                          itemCount: state.displayedFoods.length,
                          itemBuilder: (context, index) {
                            final food = state.displayedFoods[index];
                            return _buildFoodItem(context, food);
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
                final bloc = fabContext.read<AdminFoodBloc>();
                final result = await Navigator.of(fabContext).pushNamed(
                  AdminAddFoodScreen.routeName,
                  arguments: bloc,
                );
                if (result == true && fabContext.mounted) {
                  bloc.add(const LoadFoods());
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

  Widget _buildFoodItem(BuildContext context, Food food) {
    return Dismissible(
      key: Key('food_${food.id}'),
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
          _showDeleteConfirmation(context, food);
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
            onTap: () => _showEditFoodDialog(context, food),
              child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ảnh món ăn
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildFoodImage(food.imageUrl),
                  ),
                  const SizedBox(width: 12),
                  // Thông tin món ăn
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          food.name,
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
                            Text(
                              '${food.calories100g.toStringAsFixed(0)} kcal',
                              style: const TextStyle(
                                color: Color(0xFF52C41A),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (food.protein100g != null && food.protein100g! > 0)
                              Text(
                                '• ${food.protein100g?.toStringAsFixed(0) ?? '0'}g protein',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            if (food.fat100g != null && food.fat100g! > 0)
                              Text(
                                '• ${food.fat100g?.toStringAsFixed(0) ?? '0'}g chất béo',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Icon edit
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF52C41A), size: 20),
                      onPressed: () => _showEditFoodDialog(context, food),
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

  Widget _buildFoodImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2C2B),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.restaurant, color: Colors.white38),
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
            child: const Icon(Icons.restaurant, color: Colors.white38),
          ),
        ),
      );
    }

    // Server upload path (e.g., /uploads/foods/image.jpg)
    if (imageUrl.startsWith('/uploads/')) {
      const baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://10.0.2.2:3000',
      );
      final serverUrl = baseUrl.replaceAll('/api', '');
      final fullUrl = '$serverUrl$imageUrl';
      
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
            child: const Icon(Icons.restaurant, color: Colors.white38),
          ),
        ),
      );
    }

    // Asset image
    final assetPath = imageUrl.contains('assets/')
        ? imageUrl
        : 'assets/images/foods/$imageUrl';
    
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
          child: const Icon(Icons.restaurant, color: Colors.white38),
        ),
      ),
    );
  }

  void _showEditFoodDialog(BuildContext context, Food food) {
    final bloc = context.read<AdminFoodBloc>();
    Navigator.of(context).pushNamed(
      '/admin/edit-food',
      arguments: {
        'food': food,
        'bloc': bloc,
      },
    ).then((result) {
      // Reload danh sách nếu cập nhật thành công
      if (result == true) {
        bloc.add(const LoadFoods());
      }
    });
  }

  void _showFoodFormDialog_DEPRECATED(
    BuildContext context, {
    required bool isEdit,
    Food? food,
  }) {
    final nameController = TextEditingController(text: food?.name ?? '');
    final caloriesController =
        TextEditingController(text: food?.calories100g.toStringAsFixed(0) ?? '');
    final proteinController =
        TextEditingController(text: food?.protein100g?.toStringAsFixed(0) ?? '');
    final carbsController =
        TextEditingController(text: food?.carbs100g?.toStringAsFixed(0) ?? '');
    final fatController =
        TextEditingController(text: food?.fat100g?.toStringAsFixed(0) ?? '');
    final categoryController = TextEditingController(
      text: food?.mealType ?? 'protein',
    );

    String? selectedImagePath;
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      useRootNavigator: false, // Sửa lỗi BLoC context
      builder: (dialogContext) {
        // Lấy BLoC từ parent context trước khi vào dialog
        final bloc = context.read<AdminFoodBloc>();
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: const Color(0xFF1C1E1D),
          title: Text(
            isEdit ? 'Sửa món ăn' : 'Thêm món ăn mới',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chọn ảnh
                GestureDetector(
                  onTap: () async {
                    final image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      setState(() {
                        selectedImagePath = image.path;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2C2B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: selectedImagePath != null
                        ? Image.file(
                            File(selectedImagePath!),
                            fit: BoxFit.cover,
                          )
                        : food?.imageUrl != null
                            ? _buildFoodImage(food!.imageUrl)
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate,
                                      color: Colors.white38),
                                  SizedBox(height: 8),
                                  Text(
                                    'Chọn ảnh',
                                    style: TextStyle(color: Colors.white38),
                                  ),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Tên món ăn',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF2A2C2B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: caloriesController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Calories/100g',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF2A2C2B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: proteinController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Protein',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: const Color(0xFF2A2C2B),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: carbsController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Carbs',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: const Color(0xFF2A2C2B),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: fatController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Fat',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: const Color(0xFF2A2C2B),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: categoryController.text.isEmpty
                      ? 'protein'
                      : categoryController.text,
                  dropdownColor: const Color(0xFF1C1E1D),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF2A2C2B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'protein', child: Text('Protein')),
                    DropdownMenuItem(value: 'carb', child: Text('Carb')),
                    DropdownMenuItem(value: 'fat', child: Text('Fat')),
                    DropdownMenuItem(value: 'vegetable', child: Text('Vegetable')),
                  ],
                  onChanged: (value) {
                    categoryController.text = value ?? 'protein';
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
            ),
            BlocBuilder<AdminFoodBloc, AdminFoodState>(
              bloc: bloc, // Sử dụng BLoC đã lấy từ parent context
              builder: (context, state) => ElevatedButton(
                onPressed: state.isSubmitting
                    ? null
                    : () {
                        final name = nameController.text.trim();
                        final calories = int.tryParse(caloriesController.text);
                        final protein = int.tryParse(proteinController.text) ?? 0;
                        final carbs = int.tryParse(carbsController.text) ?? 0;
                        final fat = int.tryParse(fatController.text) ?? 0;
                        final category = categoryController.text;

                        if (name.isEmpty || calories == null) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text('Vui lòng điền đầy đủ thông tin'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (isEdit && food != null) {
                          bloc.add(
                                UpdateFoodEvent(
                                  foodId: food.id,
                                  name: name,
                                  calories100g: calories,
                                  protein: protein,
                                  carbs: carbs,
                                  fat: fat,
                                  mealType: category, // category ở đây là mealType từ dropdown
                                  imagePath: selectedImagePath,
                                ),
                              );
                        } else {
                          bloc.add(
                                AddFoodEvent(
                                  name: name,
                                  calories100g: calories,
                                  protein: protein,
                                  carbs: carbs,
                                  fat: fat,
                                  mealType: category, // category ở đây là mealType từ dropdown
                                  imagePath: selectedImagePath,
                                ),
                              );
                        }

                        Navigator.of(dialogContext).pop();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF52C41A),
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
                    : Text(isEdit ? 'Cập nhật' : 'Thêm'),
              ),
            ),
          ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Food food) {
    final bloc = context.read<AdminFoodBloc>();
    showDialog(
      context: context,
      useRootNavigator: false, // Sử dụng cùng navigator với parent
      builder: (dialogContext) {
        // Truyền BLoC vào dialog để có thể access
        return BlocProvider.value(
          value: bloc,
          child: BlocListener<AdminFoodBloc, AdminFoodState>(
            listenWhen: (previous, current) {
              // Chỉ listen khi có thay đổi về success hoặc error
              return previous.successMessage != current.successMessage ||
                  (previous.errorMessage != current.errorMessage && current.errorMessage != null);
            },
            listener: (context, state) {
              // Đóng dialog khi thành công hoặc có lỗi
              if (state.successMessage != null || state.errorMessage != null) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: BlocBuilder<AdminFoodBloc, AdminFoodState>(
              builder: (context, state) => AlertDialog(
                backgroundColor: const Color(0xFF1C1E1D),
                title: const Text(
                  'Xóa món ăn',
                  style: TextStyle(color: Colors.white),
                ),
                content: Text(
                  'Bạn có chắc muốn xóa "${food.name}"?',
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
                            bloc.add(DeleteFoodEvent(food.id));
                            // Không đóng dialog ngay, đợi BLoC listener xử lý
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


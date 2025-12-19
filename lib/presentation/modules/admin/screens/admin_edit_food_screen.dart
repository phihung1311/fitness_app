import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../domain/entities/food.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../bloc/admin_food/admin_food_bloc.dart';
import '../bloc/admin_food/admin_food_event.dart';
import '../bloc/admin_food/admin_food_state.dart';

class AdminEditFoodScreen extends StatefulWidget {
  final Food food;
  
  const AdminEditFoodScreen({super.key, required this.food});

  static const String routeName = '/admin/edit-food';

  @override
  State<AdminEditFoodScreen> createState() => _AdminEditFoodScreenState();
}

class _AdminEditFoodScreenState extends State<AdminEditFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  String _selectedMealType = 'all';
  String? _selectedImagePath;
  String? _currentImageUrl; // URL ảnh hiện tại từ server
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false; // Flag để tránh submit nhiều lần
  bool _isDataLoaded = false; // Flag để đánh dấu đã load dữ liệu

  @override
  void initState() {
    super.initState();
    // Load dữ liệu vào form ngay khi init
    _loadFoodData(widget.food);
  }

  void _loadFoodData(Food food) {
    _nameController.text = food.name;
    _caloriesController.text = food.calories100g.toStringAsFixed(0);
    _proteinController.text = food.protein100g?.toStringAsFixed(0) ?? '0';
    _carbsController.text = food.carbs100g?.toStringAsFixed(0) ?? '0';
    _fatController.text = food.fat100g?.toStringAsFixed(0) ?? '0';
    _selectedMealType = food.mealType ?? 'all';
    _currentImageUrl = food.imageUrl;
    _isDataLoaded = true;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Hiển thị dialog cho phép chọn từ gallery hoặc camera
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1E1D),
        title: const Text(
          'Chọn ảnh từ',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF52C41A)),
              title: const Text('Thư viện ảnh', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF52C41A)),
              title: const Text('Máy ảnh', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      // Thêm timeout để tránh đơ app
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: Quá thời gian chờ chọn ảnh');
        },
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
          _currentImageUrl = null; // Xóa URL cũ khi chọn ảnh mới
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Lỗi chọn ảnh';
        if (e.toString().contains('Timeout')) {
          errorMessage = 'Quá thời gian chờ. Vui lòng thử lại.';
        } else if (e.toString().contains('channel-error')) {
          errorMessage = 'Lỗi kết nối. Vui lòng khởi động lại app hoặc dùng máy ảnh thay vì thư viện.';
        } else {
          errorMessage = 'Lỗi: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: _pickImage,
            ),
          ),
        );
      }
    }
  }

  // Helper function để parse số từ input (hỗ trợ cả dấu phẩy và chấm)
  int? _parseInt(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    // Thay dấu phẩy bằng chấm, sau đó parse và làm tròn
    final normalized = value.replaceAll(',', '.').trim();
    final doubleValue = double.tryParse(normalized);
    return doubleValue?.round();
  }

  void _submit() {
    // Tránh submit nhiều lần
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final calories = _parseInt(_caloriesController.text);
    final protein = _parseInt(_proteinController.text) ?? 0;
    final carbs = _parseInt(_carbsController.text) ?? 0;
    final fat = _parseInt(_fatController.text) ?? 0;

    if (calories == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập calories hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _isSubmitting = true;
    context.read<AdminFoodBloc>().add(
          UpdateFoodEvent(
            foodId: widget.food.id,
            name: name,
            calories100g: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            mealType: _selectedMealType,
            imagePath: _selectedImagePath, // Chỉ gửi nếu có ảnh mới
          ),
        );
  }

  Widget _buildImagePreview() {
    if (_selectedImagePath != null) {
      // Hiển thị ảnh mới được chọn
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(_selectedImagePath!),
          fit: BoxFit.cover,
        ),
      );
    } else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      // Hiển thị ảnh hiện tại từ server
      String imageUrl = _currentImageUrl!;
      
      // Network image (full URL)
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF2A2C2B),
              child: const Icon(Icons.broken_image, color: Colors.white38, size: 64),
            ),
          ),
        );
      }
      
      // Server upload path
      if (imageUrl.startsWith('/uploads/')) {
        final baseUrl = ApiEndpoints.baseUrl.replaceAll('/api', '');
        final fullUrl = '$baseUrl$imageUrl';
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            fullUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF2A2C2B),
              child: const Icon(Icons.broken_image, color: Colors.white38, size: 64),
            ),
          ),
        );
      }
      
      // Asset image
      final assetPath = imageUrl.contains('assets/')
          ? imageUrl
          : 'assets/images/foods/$imageUrl';
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF2A2C2B),
            child: const Icon(Icons.broken_image, color: Colors.white38, size: 64),
          ),
        ),
      );
    } else {
      // Placeholder khi chưa có ảnh
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Chọn ảnh từ thư viện',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Nhấn để chọn ảnh',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị loading nếu chưa load dữ liệu
    if (!_isDataLoaded) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0F0E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1C1E1D),
          title: const Text(
            'Chỉnh sửa món ăn',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF52C41A)),
        ),
      );
    }

    return BlocListener<AdminFoodBloc, AdminFoodState>(
      listenWhen: (previous, current) {
        // Chỉ listen khi có thay đổi về error hoặc success message
        return previous.errorMessage != current.errorMessage ||
            previous.successMessage != current.successMessage;
      },
      listener: (context, state) {
        if (state.errorMessage != null) {
          _isSubmitting = false; // Reset flag khi có lỗi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state.successMessage != null) {
          _isSubmitting = false; // Reset flag khi thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
          // Quay lại màn hình trước sau khi cập nhật thành công
          Future.microtask(() {
            if (mounted) {
              Navigator.of(context).pop(true);
            }
          });
        }
      },
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
            'Chỉnh sửa món ăn',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            BlocBuilder<AdminFoodBloc, AdminFoodState>(
              builder: (context, state) => TextButton(
                onPressed: (state.isSubmitting || _isSubmitting) ? null : _submit,
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Lưu',
                        style: TextStyle(
                          color: Color(0xFF52C41A),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Chọn ảnh
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2C2B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                    child: _buildImagePreview(),
                  ),
                ),
                const SizedBox(height: 24),
                // Tên món ăn
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Tên món ăn *',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF1C1E1D),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF52C41A), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên món ăn';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Calories
                TextFormField(
                  controller: _caloriesController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Calories/100g *',
                    hintText: 'VD: 155 hoặc 155.5',
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    filled: true,
                    fillColor: const Color(0xFF1C1E1D),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF52C41A), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập calories';
                    }
                    final normalized = value.replaceAll(',', '.');
                    if (double.tryParse(normalized) == null) {
                      return 'Calories phải là số (có thể dùng dấu phẩy hoặc chấm)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Protein, Carbs, Fat
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _proteinController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Protein (g)',
                          hintText: '12.6',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                          filled: true,
                          fillColor: const Color(0xFF1C1E1D),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF52C41A), width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _carbsController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Carbs (g)',
                          hintText: '1.1',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                          filled: true,
                          fillColor: const Color(0xFF1C1E1D),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF52C41A), width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _fatController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Fat (g)',
                          hintText: '10.6',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                          filled: true,
                          fillColor: const Color(0xFF1C1E1D),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF52C41A), width: 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Meal Type
                DropdownButtonFormField<String>(
                  value: _selectedMealType,
                  dropdownColor: const Color(0xFF1C1E1D),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Loại bữa ăn',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF1C1E1D),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF52C41A), width: 2),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                    DropdownMenuItem(value: 'breakfast', child: Text('Bữa sáng')),
                    DropdownMenuItem(value: 'lunch', child: Text('Bữa trưa')),
                    DropdownMenuItem(value: 'dinner', child: Text('Bữa tối')),
                    DropdownMenuItem(value: 'snack', child: Text('Đồ ăn vặt')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMealType = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/plan/admin_plan_bloc.dart';
import '../../bloc/plan/admin_plan_event.dart';
import '../../bloc/plan/admin_plan_state.dart';
import '../../bloc/admin_food/admin_food_bloc.dart';
import '../../bloc/admin_food/admin_food_state.dart';
import '../../../../../domain/entities/food.dart';

class AdminAddFoodToPlanScreen extends StatefulWidget {
  final int mealPlanId;

  const AdminAddFoodToPlanScreen({
    super.key,
    required this.mealPlanId,
  });

  static const String routeName = '/admin/plan/add-food';

  @override
  State<AdminAddFoodToPlanScreen> createState() => _AdminAddFoodToPlanScreenState();
}

class _AdminAddFoodToPlanScreenState extends State<AdminAddFoodToPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sizeGramController = TextEditingController();
  final _searchController = TextEditingController();

  Food? _selectedFood;
  String _selectedDayOfWeek = 'Monday';
  String _selectedMealSession = 'breakfast';
  bool _isSubmitting = false;

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final Map<String, String> _dayLabels = {
    'Monday': 'Thứ 2',
    'Tuesday': 'Thứ 3',
    'Wednesday': 'Thứ 4',
    'Thursday': 'Thứ 5',
    'Friday': 'Thứ 6',
    'Saturday': 'Thứ 7',
    'Sunday': 'Chủ nhật',
  };

  final Map<String, String> _mealSessionLabels = {
    'breakfast': 'Bữa sáng',
    'lunch': 'Bữa trưa',
    'dinner': 'Bữa tối',
    'snack': 'Bữa phụ',
  };

  @override
  void dispose() {
    _sizeGramController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  int? _calculateCalories() {
    if (_selectedFood == null || _sizeGramController.text.isEmpty) {
      return null;
    }
    final sizeGram = int.tryParse(_sizeGramController.text);
    if (sizeGram == null || _selectedFood!.calories100g == null) {
      return null;
    }
    return ((_selectedFood!.calories100g! / 100) * sizeGram).round();
  }

  void _submit() {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn món ăn'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final sizeGram = int.tryParse(_sizeGramController.text);
    if (sizeGram == null || sizeGram < 50 || sizeGram > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Khối lượng phải từ 50g đến 500g'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _isSubmitting = true;
    context.read<AdminPlanBloc>().add(
          AddFoodToMealPlanEvent(
            mealPlanId: widget.mealPlanId,
            foodId: _selectedFood!.id,
            dayOfWeek: _selectedDayOfWeek,
            mealSession: _selectedMealSession,
            sizeGram: sizeGram,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminPlanBloc, AdminPlanState>(
      listenWhen: (previous, current) {
        return previous.errorMessage != current.errorMessage ||
            previous.successMessage != current.successMessage;
      },
      listener: (context, state) {
        if (state.errorMessage != null) {
          _isSubmitting = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state.successMessage != null) {
          _isSubmitting = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
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
          backgroundColor: const Color(0xFF1C1E1D),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Thêm món ăn vào kế hoạch',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<AdminFoodBloc, AdminFoodState>(
          builder: (context, foodState) {
            final foods = foodState.displayedFoods;
            final filteredFoods = _searchController.text.isEmpty
                ? foods
                : foods.where((food) {
                    final query = _searchController.text.toLowerCase();
                    return food.name.toLowerCase().contains(query);
                  }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Chọn món ăn
                    const Text(
                      'Chọn món ăn *',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Search field
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm món ăn...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
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
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    // Food list
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1E1D),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: filteredFoods.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  _searchController.text.isEmpty
                                      ? 'Không có món ăn nào'
                                      : 'Không tìm thấy món ăn',
                                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredFoods.length,
                              itemBuilder: (context, index) {
                                final food = filteredFoods[index];
                                final isSelected = _selectedFood?.id == food.id;

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedFood = food;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF52C41A).withOpacity(0.2)
                                          : Colors.transparent,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.white.withOpacity(0.1),
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                food.name,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? const Color(0xFF52C41A)
                                                      : Colors.white,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                              if (food.calories100g != null)
                                                Text(
                                                  '${food.calories100g} kcal/100g',
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.7),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF52C41A),
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 24),
                    // Chọn ngày
                    const Text(
                      'Chọn ngày *',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedDayOfWeek,
                      dropdownColor: const Color(0xFF1C1E1D),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
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
                      items: _daysOfWeek.map((day) {
                        return DropdownMenuItem(
                          value: day,
                          child: Text(_dayLabels[day] ?? day),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedDayOfWeek = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Chọn bữa ăn
                    const Text(
                      'Chọn bữa ăn *',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedMealSession,
                      dropdownColor: const Color(0xFF1C1E1D),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
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
                      items: _mealSessionLabels.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedMealSession = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Khối lượng
                    TextFormField(
                      controller: _sizeGramController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Khối lượng (gram) *',
                        hintText: 'VD: 200',
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
                          return 'Vui lòng nhập khối lượng';
                        }
                        final sizeGram = int.tryParse(value);
                        if (sizeGram == null) {
                          return 'Khối lượng phải là số';
                        }
                        if (sizeGram < 50 || sizeGram > 500) {
                          return 'Khối lượng phải từ 50g đến 500g';
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    // Hiển thị calories
                    if (_calculateCalories() != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1E1D),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF52C41A).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: Color(0xFF52C41A),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Calories: ${_calculateCalories()} kcal',
                              style: const TextStyle(
                                color: Color(0xFF52C41A),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Nút Thêm
                    BlocBuilder<AdminPlanBloc, AdminPlanState>(
                      builder: (context, state) => SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: (state.isSubmitting || _isSubmitting) ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF52C41A),
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: state.isSubmitting || _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Thêm món ăn',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

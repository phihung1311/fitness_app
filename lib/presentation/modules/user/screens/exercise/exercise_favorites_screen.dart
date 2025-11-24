import 'package:flutter/material.dart';
import '../../../../../core/di/injector.dart';
import '../../../../../data/datasources/remote/exercise_api.dart';

class ExerciseFavoritesScreen extends StatefulWidget {
  const ExerciseFavoritesScreen({super.key});

  @override
  State<ExerciseFavoritesScreen> createState() => _ExerciseFavoritesScreenState();
}

class _ExerciseFavoritesScreenState extends State<ExerciseFavoritesScreen> {
  List<dynamic> _favorites = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final exerciseApi = injector<ExerciseApi>();
      final favorites = await exerciseApi.getFavorites();
      
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(int exerciseId) async {
    try {
      final exerciseApi = injector<ExerciseApi>();
      await exerciseApi.removeFromFavorites(exerciseId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa khỏi yêu thích'),
            backgroundColor: Color(0xFF52C41A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadFavorites();
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
          'Bài tập Yêu thích',
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
        onRefresh: _loadFavorites,
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
                          onPressed: _loadFavorites,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF52C41A),
                          ),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                : _favorites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star_outline_rounded,
                              color: Colors.white.withOpacity(0.3),
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có bài tập yêu thích',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Thêm bài tập vào yêu thích để xem sau',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _favorites.length,
                        itemBuilder: (context, index) {
                          final favorite = _favorites[index];
                          return _buildFavoriteCard(favorite);
                        },
                      ),
      ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> favorite) {
    final exerciseData = favorite['Exercise'] as Map<String, dynamic>?;
    final exerciseName = exerciseData?['name'] as String? ?? 'Unknown';
    final muscleGroup = exerciseData?['muscle_group'] as String? ?? '';
    final difficulty = exerciseData?['difficulty'] as String? ?? '';
    final imageUrl = exerciseData?['image_url'] as String?;
    final exerciseId = exerciseData?['id'] as int?;

    Color difficultyColor;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        difficultyColor = const Color(0xFF52C41A);
        break;
      case 'intermediate':
        difficultyColor = const Color(0xFFF7B731);
        break;
      case 'advanced':
        difficultyColor = const Color(0xFFFF6B6B);
        break;
      default:
        difficultyColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (muscleGroup.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF52C41A).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          muscleGroup.capitalize(),
                          style: const TextStyle(
                            color: Color(0xFF52C41A),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (difficulty.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: difficultyColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          difficulty.capitalize(),
                          style: TextStyle(
                            color: difficultyColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Remove Button
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
            ),
            onPressed: exerciseId != null
                ? () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF1C1E1D),
                        title: const Text(
                          'Xóa khỏi yêu thích?',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: Text(
                          'Bạn có chắc muốn xóa "$exerciseName" khỏi yêu thích?',
                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Hủy',
                              style: TextStyle(color: Colors.white.withOpacity(0.7)),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _removeFavorite(exerciseId);
                            },
                            child: const Text(
                              'Xóa',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                : null,
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


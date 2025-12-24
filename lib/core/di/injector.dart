import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/remote/auth_api.dart';
import '../../data/datasources/remote/profile_api.dart';
import '../../data/datasources/remote/meal_api.dart';
import '../../data/datasources/remote/exercise_api.dart';
import '../../data/datasources/remote/admin/admin_food_api.dart';
import '../../data/datasources/remote/admin/admin_exercise_api.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../../data/repositories_impl/profile_repository_impl.dart';
import '../../data/repositories_impl/food_repository_impl.dart';
import '../../data/repositories_impl/meal_repository_impl.dart';
import '../../data/repositories_impl/exercise_repository_impl.dart';
import '../../data/repositories_impl/admin/admin_food_repository_impl.dart';
import '../../data/repositories_impl/admin/admin_exercise_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/food_repository.dart';
import '../../domain/repositories/meal_repository.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../domain/repositories/admin/admin_food_repository.dart';
import '../../domain/repositories/admin/exercise/admin_exercise_repository.dart';
import '../../domain/usecases/auth/login.dart';
import '../../domain/usecases/auth/register.dart';
import '../../domain/usecases/profile/get_profile_metrics.dart';
import '../../domain/usecases/food/get_foods.dart';
import '../../domain/usecases/meal/add_meal.dart';
import '../../domain/usecases/meal/get_today_meals.dart';
import '../../domain/usecases/meal/update_meal.dart';
import '../../domain/usecases/meal/delete_meal.dart';
import '../../domain/usecases/exercise/get_exercises.dart';
import '../../domain/usecases/exercise/get_exercise_detail.dart';
import '../../domain/usecases/admin/get_foods.dart' as admin_get_foods;
import '../../domain/usecases/admin/add_food.dart' as admin_add_food;
import '../../domain/usecases/admin/update_food.dart' as admin_update_food;
import '../../domain/usecases/admin/delete_food.dart' as admin_delete_food;
import '../../domain/usecases/admin/exercise/get_exercises.dart' as admin_get_exercises;
import '../../domain/usecases/admin/exercise/add_exercise.dart' as admin_add_exercise;
import '../../domain/usecases/admin/exercise/update_exercise.dart' as admin_update_exercise;
import '../../domain/usecases/admin/exercise/delete_exercise.dart' as admin_delete_exercise;
import '../../services/storage/token_storage.dart';
import '../../services/storage/role_storage.dart';
import '../constants/api_endpoints.dart';

final GetIt injector = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  injector
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<TokenStorage>(() => TokenStorage(prefs))
    ..registerLazySingleton<RoleStorage>(() => RoleStorage(prefs))
    ..registerLazySingleton<Dio>(() {
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          responseType: ResponseType.json,
        ),
      );
      return dio;
    })
    ..registerLazySingleton<AuthApi>(() => AuthApi(injector()))
    ..registerLazySingleton<ProfileApi>(() => ProfileApi(injector(), injector()))
    ..registerLazySingleton<MealApi>(() => MealApi(injector(), injector()))
    ..registerLazySingleton<ExerciseApi>(() => ExerciseApi(injector(), injector()))
    // Admin APIs (tách biệt)
    ..registerLazySingleton<AdminFoodApi>(() => AdminFoodApi(injector(), injector()))
    ..registerLazySingleton<AdminExerciseApi>(() => AdminExerciseApi(injector(), injector()))
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        api: injector(),
        tokenStorage: injector(),
      ),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(injector()),
    )
    ..registerLazySingleton<FoodRepository>(
      () => FoodRepositoryImpl(injector()),
    )
    ..registerLazySingleton<MealRepository>(
      () => MealRepositoryImpl(injector()),
    )
    ..registerLazySingleton<ExerciseRepository>(
      () => ExerciseRepositoryImpl(injector()),
    )
    // Admin Repositories (tách biệt)
    ..registerLazySingleton<AdminFoodRepository>(
      () => AdminFoodRepositoryImpl(injector()),
    )
    ..registerLazySingleton<AdminExerciseRepository>(
      () => AdminExerciseRepositoryImpl(injector()),
    )
    ..registerLazySingleton<LoginUseCase>(() => LoginUseCase(injector()))
    ..registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(injector()))
    ..registerLazySingleton<GetProfileMetrics>(() => GetProfileMetrics(injector()))
    ..registerLazySingleton<GetFoods>(() => GetFoods(injector()))
    ..registerLazySingleton<AddMeal>(() => AddMeal(injector()))
    ..registerLazySingleton<GetTodayMeals>(() => GetTodayMeals(injector()))
    ..registerLazySingleton<UpdateMeal>(() => UpdateMeal(injector()))
    ..registerLazySingleton<DeleteMeal>(() => DeleteMeal(injector()))
    ..registerLazySingleton<GetExercises>(() => GetExercises(injector()))
    ..registerLazySingleton<GetExerciseDetail>(() => GetExerciseDetail(injector()))
    // Admin UseCases (tách biệt)
    ..registerLazySingleton<admin_get_foods.GetFoods>(() => admin_get_foods.GetFoods(injector()))
    ..registerLazySingleton<admin_add_food.AddFood>(() => admin_add_food.AddFood(injector()))
    ..registerLazySingleton<admin_update_food.UpdateFood>(() => admin_update_food.UpdateFood(injector()))
    ..registerLazySingleton<admin_delete_food.DeleteFood>(() => admin_delete_food.DeleteFood(injector()))
    ..registerLazySingleton<admin_get_exercises.GetExercises>(() => admin_get_exercises.GetExercises(injector()))
    ..registerLazySingleton<admin_add_exercise.AddExercise>(() => admin_add_exercise.AddExercise(injector()))
    ..registerLazySingleton<admin_update_exercise.UpdateExercise>(() => admin_update_exercise.UpdateExercise(injector()))
    ..registerLazySingleton<admin_delete_exercise.DeleteExercise>(() => admin_delete_exercise.DeleteExercise(injector()));
}


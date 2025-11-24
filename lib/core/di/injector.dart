import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/remote/auth_api.dart';
import '../../data/datasources/remote/profile_api.dart';
import '../../data/datasources/remote/meal_api.dart';
import '../../data/datasources/remote/exercise_api.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../../data/repositories_impl/profile_repository_impl.dart';
import '../../data/repositories_impl/food_repository_impl.dart';
import '../../data/repositories_impl/meal_repository_impl.dart';
import '../../data/repositories_impl/exercise_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/food_repository.dart';
import '../../domain/repositories/meal_repository.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../domain/usecases/auth/login.dart';
import '../../domain/usecases/auth/register.dart';
import '../../domain/usecases/profile/get_profile_metrics.dart';
import '../../domain/usecases/food/get_foods.dart';
import '../../domain/usecases/meal/add_meal.dart';
import '../../domain/usecases/meal/get_today_meals.dart';
import '../../domain/usecases/exercise/get_exercises.dart';
import '../../domain/usecases/exercise/get_exercise_detail.dart';
import '../../services/storage/token_storage.dart';
import '../constants/api_endpoints.dart';

final GetIt injector = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  injector
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<TokenStorage>(() => TokenStorage(prefs))
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
    ..registerLazySingleton<LoginUseCase>(() => LoginUseCase(injector()))
    ..registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(injector()))
    ..registerLazySingleton<GetProfileMetrics>(() => GetProfileMetrics(injector()))
    ..registerLazySingleton<GetFoods>(() => GetFoods(injector()))
    ..registerLazySingleton<AddMeal>(() => AddMeal(injector()))
    ..registerLazySingleton<GetTodayMeals>(() => GetTodayMeals(injector()))
    ..registerLazySingleton<GetExercises>(() => GetExercises(injector()))
    ..registerLazySingleton<GetExerciseDetail>(() => GetExerciseDetail(injector()));
}


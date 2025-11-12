import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/remote/auth_api.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/login.dart';
import '../../domain/usecases/auth/register.dart';
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
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        api: injector(),
        tokenStorage: injector(),
      ),
    )
    ..registerLazySingleton<LoginUseCase>(() => LoginUseCase(injector()))
    ..registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(injector()));
}


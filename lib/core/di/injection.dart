import 'package:get_it/get_it.dart';
import 'package:shams_mobile_app/core/data/datasources/file_storage_data_source.dart';
import 'package:shams_mobile_app/core/theme/theme_storage.dart';
import 'package:shams_mobile_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:shams_mobile_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shams_mobile_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/complete_sign_up_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/get_current_auth_user_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/watch_auth_state_usecase.dart';
import 'package:shams_mobile_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:shams_mobile_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:shams_mobile_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:shams_mobile_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:shams_mobile_app/features/profile/domain/usecases/get_my_profile_usecase.dart';
import 'package:shams_mobile_app/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

/// Initializes application-wide dependencies.
///
/// Must be called after `Supabase.initialize(...)`.
Future<void> initDependencies() async {
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  sl.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );

  _initCore();
  _initAuth();
  _initProfile();
}

void _initCore() {
  sl.registerLazySingleton<FileStorageDataSource>(
    () => FileStorageDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ThemeStorage>(() => ThemeStorage(sl()));
}

void _initAuth() {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerLazySingleton(() => SignInWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => CompleteSignUpUseCase(sl(), sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => WatchAuthStateUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentAuthUserUseCase(sl()));
  sl.registerFactory(
    () => AuthProvider(
      watchAuthState: sl(),
      getCurrentAuthUser: sl(),
      signInWithEmail: sl(),
      signInWithGoogle: sl(),
      completeSignUp: sl(),
      signOut: sl(),
    ),
  );
}

void _initProfile() {
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetMyProfileUseCase(sl(), sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl(), sl()));
}

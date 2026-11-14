import 'package:get_it/get_it.dart';
import 'package:shams_mobile_app/core/theme/theme_storage.dart';
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
  // Feature registrations are added phase by phase:
  // _initAuth(); _initProfile(); _initPosts(); ...
}

void _initCore() {
  sl.registerLazySingleton<ThemeStorage>(() => ThemeStorage(sl()));
}

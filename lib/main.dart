import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/services/ai_service.dart';
import 'core/services/supabase_service.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/dump/presentation/dump_screen.dart';
import 'features/splash/presentation/splash_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/auth_providers.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/insights/presentation/deep_insight_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // Initialize Services
  AIService().init(); 
  await SupabaseService().init();
  
  runApp(const ProviderScope(child: MyApp()));
}

final _routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final user = Supabase.instance.client.auth.currentUser;
      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      
      // Check if it's the first time the app is opening
      final prefs = await SharedPreferences.getInstance();
      final isFirstRun = prefs.getBool('is_first_run') ?? true;

      if (user == null) {
        if (loggingIn) return null;
        if (isFirstRun) return '/register';
        return '/login';
      }

      // If logged in and first run, mark first run as complete
      if (isFirstRun) {
        await prefs.setBool('is_first_run', false);
      }

      if (loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dump',
        builder: (context, state) => const DumpScreen(),
      ),
      GoRoute(
        path: '/deep-insight',
        builder: (context, state) => const DeepInsightScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    return MaterialApp.router(
      title: 'dots',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Enforce Dark Mode
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

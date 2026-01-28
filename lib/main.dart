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
import 'features/settings/presentation/settings_screen.dart';
import 'features/insights/presentation/deep_insight_screen.dart';
import 'features/dump/data/import_service.dart';


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
        builder: (context, state) => DumpScreen(initialData: state.extra as Map<String, dynamic>?),
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

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {

  @override
  void initState() {
    super.initState();
    // Listen for share intents
    ImportService().listenForShareIntent(context, (noteData) {
       _handleSharedNote(noteData);
    });
  }

  void _handleSharedNote(Map<String, dynamic> noteData) {
    // We need to navigate to DumpScreen or NoteDetail with this data
    // Since we are outside the router's context build tree (in initState), 
    // we should wait for the router to be ready or use the router provider if possible.
    // However, GoRouter is provided via Riverpod.
    
    // Simplest way: Navigate using the router ref once available or 
    // better, just use the router config if we can access it.
    // But `ref.read(_routerProvider)` is safe here? No, initState is too early for context dependent watch?
    // Actually ref.read is fine in callbacks.
    
    // Let's defer navigation slightly to ensure app is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
       final router = ref.read(_routerProvider);
       // Passing data as extra or query params
       // For now, let's go to /dump and maybe pass arguments? 
       // Or go to a specific "create note" route.
       // NoteDetailScreen handles creation if id is new.
       // Let's assume we want to open the DumpScreen (which has the list) 
       // or better, open a new note dialog/screen.
       // Existing DumpScreen seems to list notes. 
       // NoteDetailScreen is likely for editing/creating.
       
       // Let's inspect NoteDetailScreen later. For now, let's navigate to /dump 
       // and maybe we can trigger a "new note" action there?
       // Or better, let's try to verify if we can pass extra data to NoteDetailScreen.
       
       // Assuming we can pass data to a route, let's print for now 
       // and we will refine the route in the next step when we see NoteDetail.
       
       print("Received shared note: $noteData");
       router.push('/dump', extra: noteData); // Passing as extra to DumpScreen
    });
  }

  @override
  Widget build(BuildContext context) {
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

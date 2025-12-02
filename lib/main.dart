import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'services/biometric_service.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/providers/expense_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/profile_provider.dart';
import 'data/repositories/expense_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/profile_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  _disableLogging();
  
  // Initialize services
  await SupabaseService().initialize();
  final sharedPreferences = await SharedPreferences.getInstance();
  final biometricService = BiometricService(sharedPreferences);
  
  // ✅ CORREGIDO: Crear AuthRepository con SharedPreferences
  final authRepository = AuthRepository(sharedPreferences);
  
  runApp(MyApp(
    biometricService: biometricService,
    sharedPreferences: sharedPreferences,
    authRepository: authRepository, // ✅ NUEVO
  ));
}

void _disableLogging() {
  debugPrint = (String? message, {int? wrapWidth}) {};
}

class MyApp extends StatelessWidget {
  final BiometricService biometricService;
  final SharedPreferences sharedPreferences;
  final AuthRepository authRepository; // ✅ NUEVO

  const MyApp({
    super.key,
    required this.biometricService,
    required this.sharedPreferences,
    required this.authRepository, // ✅ NUEVO
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ExpenseRepository(Supabase.instance.client)),
        // ✅ CORREGIDO: Usar la instancia ya creada de AuthRepository
        Provider<AuthRepository>.value(value: authRepository),
        Provider(create: (_) => ProfileRepository()),
        Provider(create: (_) => biometricService),
        Provider(create: (_) => sharedPreferences),
        ChangeNotifierProvider(
          create: (context) => ExpenseProvider(
            context.read<ExpenseRepository>(),
          ),
        ),
        // ✅ CORREGIDO: AuthProvider con 3 parámetros
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            context.read<SharedPreferences>(), // ✅ NUEVO: primer parámetro
            context.read<AuthRepository>(),    // ✅ segundo parámetro  
            context.read<BiometricService>(),  // ✅ tercer parámetro
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileProvider(
            context.read<ProfileRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Mi Billetera Universitaria',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Roboto',
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        // ✅ ACTUALIZADO: Cambiar ruta inicial a splash
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
        debugShowCheckedModeBanner: false,
        checkerboardOffscreenLayers: false,
        checkerboardRasterCacheImages: false,
        showPerformanceOverlay: false,
        showSemanticsDebugger: false,
      ),
    );
  }
}
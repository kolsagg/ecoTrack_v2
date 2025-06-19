import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_config.dart';
import 'core/constants/app_theme.dart';
import 'core/utils/dependency_injection.dart';
import 'providers/auth_provider.dart';
import 'routes/app_routes.dart';
import 'screens/auth/login_screen.dart';
import 'screens/splash_screen.dart';
import 'widgets/navigation/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style globally
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize dependency injection
  await DependencyInjection.init();

  runApp(const ProviderScope(child: EcoTrackApp()));
}

class EcoTrackApp extends StatelessWidget {
  const EcoTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: AppConfig.enableDebugMode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light, // Will be managed by state later
        home: const AuthWrapper(),
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}

// Authentication wrapper to determine which screen to show
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    print(
      '🏠 AuthWrapper - isLoading: ${authState.isLoading}, isAuthenticated: ${authState.isAuthenticated}, error: ${authState.error}',
    );

    // Authenticated durumuna göre temel widget'ı belirle
    Widget baseWidget;
    if (authState.isAuthenticated) {
      print('🏠 Base: MainNavigation - authenticated');
      baseWidget = const MainNavigation();
    } else {
      print('🏠 Base: LoginScreen - not authenticated');
      baseWidget = const LoginScreen();
    }

    // Loading durumunda SplashScreen'i overlay olarak göster
    if (authState.isLoading) {
      print('🏠 Overlay: SplashScreen - loading');
      return Stack(
        children: [
          baseWidget, // LoginScreen veya MainNavigation arkada kalır
          const SplashScreen(), // SplashScreen üstte overlay olarak
        ],
      );
    }

    // Loading yoksa sadece temel widget'ı göster
    return baseWidget;
  }
}

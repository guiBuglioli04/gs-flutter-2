import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/dashboard_screen.dart';
import 'screens/health_units_screen.dart';
import 'screens/new_triage_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/triage_list_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configura a barra de status do sistema operacional
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SaudePertoApp());
}

class SaudePertoApp extends StatelessWidget {
  const SaudePertoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaúdePerto',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Requisito 3: Navegação entre telas do Flutter
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/queue': (context) => const TriageListScreen(),
        '/new-triage': (context) => const NewTriageScreen(),
        '/health-units': (context) => const HealthUnitsScreen(),
      },
    );
  }
}

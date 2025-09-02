import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:vibe_coding_tutorial_weather_app/core/amplify_config.dart';
import 'package:vibe_coding_tutorial_weather_app/core/providers/auth_provider.dart';
import 'package:vibe_coding_tutorial_weather_app/features/auth/presentation/pages/login_page.dart';
import 'package:vibe_coding_tutorial_weather_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar Amplify
  await AmplifyConfig.configure();
  
  runApp(const MedicineApp());
}

class MedicineApp extends StatelessWidget {
  const MedicineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: 'Medicine App',
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF0D1B2A),
              colorScheme: const ColorScheme.dark().copyWith(
                primary: Colors.tealAccent,
                surface: const Color(0xFF1B263B),
              ),
              useMaterial3: true,
              // Configuración para modales y diálogos
              dialogTheme: DialogThemeData(
                backgroundColor: white,
                surfaceTintColor: white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              // Configuración para selectores de tiempo
              timePickerTheme: TimePickerThemeData(
                backgroundColor: white,
                hourMinuteTextColor: Colors.black,
                hourMinuteColor: athens_gray,
                dialHandColor: lightening_yellow,
                dialBackgroundColor: athens_gray,
                dialTextColor: Colors.black,
                entryModeIconColor: Colors.black,
                // Configuración para el título
                helpTextStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English, no country code
              Locale('es', 'ES'), // Spanish, Spain
            ],
            home: _buildHomePage(authProvider),
          );
        },
      ),
    );
  }

  Widget _buildHomePage(AuthProvider authProvider) {
    if (!authProvider.isInitialized) {
      // Mostrar pantalla de carga mientras se inicializa
      return const Scaffold(
        backgroundColor: white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(lightening_yellow),
          ),
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      // Usuario autenticado, mostrar página principal
      return const OnboardingPage();
    } else {
      // Usuario no autenticado, mostrar página de login
      return const LoginPage();
    }
  }
}

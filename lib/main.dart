import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'services/scan_provider.dart';
import 'services/user_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Set translucent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Check if onboarding has been completed
  final prefs = await SharedPreferences.getInstance();
  final onboarded = prefs.getBool('onboarded') ?? false;

  runApp(NutriScanApp(showOnboarding: !onboarded));
}

class NutriScanApp extends StatelessWidget {
  final bool showOnboarding;
  const NutriScanApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()..load()),
      ],
      child: MaterialApp(
        title: 'NutriScan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: showOnboarding ? const OnboardingScreen() : const MainShell(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  int _page = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  static const _steps = [
    _Step(
      icon: '📷',
      title: 'Scan Any Barcode',
      description:
          'Point your camera at any food product and receive instant nutritional intelligence — in under 2 seconds.',
      primaryColor: AppColors.green,
      buttonColor: AppColors.green,
    ),
    _Step(
      icon: '⚠️',
      title: 'Set Allergen Alerts',
      description:
          'Declare your allergies once. NutriScan flags dangerous ingredients automatically on every scan.',
      primaryColor: AppColors.amber,
      buttonColor: AppColors.amber,
    ),
    _Step(
      icon: '🥗',
      title: 'Find Healthier Choices',
      description:
          'Discover better alternatives with less sugar, fat, or sodium — instantly, powered by AI.',
      primaryColor: AppColors.mint,
      buttonColor: AppColors.navy,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _next() async {
    if (_page < _steps.length - 1) {
      await _fadeCtrl.reverse();
      setState(() => _page++);
      _fadeCtrl.forward();
    } else {
      _finish();
    }
  }

  void _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_page];
    return Scaffold(
      backgroundColor: AppColors.neutralLight,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text(step.icon, style: const TextStyle(fontSize: 90)),
                const SizedBox(height: 32),
                Text(
                  step.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSerifDisplay(fontSize: 28, color: AppColors.navy),
                ),
                const SizedBox(height: 16),
                Text(
                  step.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(fontSize: 15, color: const Color(0xFF555555), height: 1.65),
                ),
                const Spacer(),
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page ? step.primaryColor : const Color(0xFFCCCCCC),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: step.buttonColor),
                    onPressed: _next,
                    child: Text(_page < _steps.length - 1 ? 'Continue →' : 'Get Started'),
                  ),
                ),
                const SizedBox(height: 14),
                if (_page < _steps.length - 1)
                  TextButton(
                    onPressed: _finish,
                    child: Text('Skip', style: GoogleFonts.dmSans(color: const Color(0xFFAAAAAA))),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Step {
  final String icon;
  final String title;
  final String description;
  final Color primaryColor;
  final Color buttonColor;

  const _Step({
    required this.icon,
    required this.title,
    required this.description,
    required this.primaryColor,
    required this.buttonColor,
  });
}

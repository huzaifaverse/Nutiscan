import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';
import 'scanner_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    HistoryScreen(),
    SavedScreen(),
    ProfileScreen(),
  ];

  void _openScanner() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScannerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: _openScanner,
        backgroundColor: AppColors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.qr_code_scanner_rounded, size: 28, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home_rounded, label: 'Home', index: 0, current: _index, onTap: (i) => setState(() => _index = i)),
            _NavItem(icon: Icons.history_rounded, label: 'History', index: 1, current: _index, onTap: (i) => setState(() => _index = i)),
            const SizedBox(width: 48), // FAB gap
            _NavItem(icon: Icons.bookmark_rounded, label: 'Saved', index: 2, current: _index, onTap: (i) => setState(() => _index = i)),
            _NavItem(icon: Icons.person_rounded, label: 'Profile', index: 3, current: _index, onTap: (i) => setState(() => _index = i)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({required this.icon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    return InkWell(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? AppColors.green : const Color(0xFFBBBBBB), size: 24),
            Text(label, style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: selected ? AppColors.green : const Color(0xFFBBBBBB))),
          ],
        ),
      ),
    );
  }
}

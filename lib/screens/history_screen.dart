// ============================================================
//  history_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/user_provider.dart';
import '../widgets/widgets.dart';
import 'result_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final history = user.scanHistory;

    return Scaffold(
      backgroundColor: AppColors.neutralLight,
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          if (history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text('${history.length} products', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_rounded, size: 64, color: Color(0xFFCCCCCC)),
                  const SizedBox(height: 14),
                  Text('No scans yet', style: GoogleFonts.dmSerifDisplay(fontSize: 20, color: const Color(0xFFBBBBBB))),
                  Text('Your scan history will appear here.', style: GoogleFonts.dmSans(color: const Color(0xFF999999))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (_, i) {
                final p = history[i];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResultScreen(product: p))),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          ScoreCircle(score: p.nutriScore, size: 40),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text('${p.brand} · ${_fmt(p.scannedAt)}', style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF999999))),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _fmt(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1)   return '${diff.inMinutes}m ago';
    if (diff.inDays < 1)    return '${diff.inHours}h ago';
    if (diff.inDays == 1)   return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}

// ============================================================
//  saved_screen.dart
// ============================================================

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final saved = user.savedProducts;

    return Scaffold(
      backgroundColor: AppColors.neutralLight,
      appBar: AppBar(
        title: const Text('Saved Items'),
        actions: [
          if (saved.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.green.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
                  child: Text('${saved.length} saved', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
        ],
      ),
      body: saved.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bookmark_border_rounded, size: 64, color: Color(0xFFCCCCCC)),
                  const SizedBox(height: 14),
                  Text('Nothing saved yet', style: GoogleFonts.dmSerifDisplay(fontSize: 20, color: const Color(0xFFBBBBBB))),
                  Text('Bookmark products from the result screen.', style: GoogleFonts.dmSans(color: const Color(0xFF999999))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: saved.length,
              itemBuilder: (_, i) {
                final p = saved[i];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResultScreen(product: p))),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          ScoreCircle(score: p.nutriScore, size: 42),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(p.brand, style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF999999))),
                                Text('${p.calories} kcal/100g', style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFFAAAAAA))),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.bookmark_rounded, color: AppColors.green),
                            onPressed: () => context.read<UserProvider>().toggleSaved(p.barcode),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ============================================================
//  profile_screen.dart
// ============================================================

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.neutralLight,
      body: CustomScrollView(
        slivers: [
          // ── Profile header ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20, right: 20, bottom: 24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.person_rounded, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.userName, style: GoogleFonts.dmSerifDisplay(fontSize: 20, color: Colors.white)),
                      Text(user.userEmail.isNotEmpty ? user.userEmail : 'Set up your profile',
                          style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                const SectionHeading('Allergen Alerts'),
                ...AllergenProfile.allAllergens.map((allergen) {
                  final isOn = user.allergenProfile.activeAllergens.contains(allergen);
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(allergen, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navy)),
                          ),
                          Switch(
                            value: isOn,
                            onChanged: (_) => user.toggleAllergen(allergen),
                            activeColor: AppColors.alertRed,
                            trackColor: WidgetStateProperty.resolveWith((states) =>
                                states.contains(WidgetState.selected) ? AppColors.alertRed.withOpacity(0.3) : null),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 12),
                const SectionHeading('Settings'),
                ...['Dietary Goals', 'Nutrition Targets', 'Favourites', 'Privacy & Data', 'Help & Support'].map((label) =>
                  Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Text(label, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navy)),
                            const Spacer(),
                            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC)),
                          ],
                        ),
                      ),
                    ),
                  )),

                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.alertRed),
                    foregroundColor: AppColors.alertRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Sign Out'),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

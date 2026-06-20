import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../services/user_provider.dart';
import '../widgets/widgets.dart';
import 'result_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    return Scaffold(
      backgroundColor: AppColors.neutralLight,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20, right: 20, bottom: 24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('GOOD MORNING', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.mint, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text('${user.userName} 👋', style: GoogleFonts.dmSerifDisplay(fontSize: 24, color: Colors.white)),
                  const SizedBox(height: 18),
                  // Weekly calories mini card
                  const _WeeklyCaloriesCard(),
                ],
              ),
            ),
          ),

          // ── Recent Scans ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const SectionHeading('Recent Scans'),
                  if (user.scanHistory.isEmpty)
                    _EmptyState(message: 'No scans yet. Tap the scan button below!', icon: Icons.qr_code_scanner_rounded)
                  else
                    ...user.scanHistory.take(10).map((p) => Card(
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
                                    Text('${p.brand} · ${_timeAgo(p.scannedAt)}', style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF999999))),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC)),
                            ],
                          ),
                        ),
                      ),
                    )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _WeeklyCaloriesCard extends StatelessWidget {
  const _WeeklyCaloriesCard();

  @override
  Widget build(BuildContext context) {
    final bars = [320, 410, 380, 510, 420, 560, 480];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WEEKLY CALORIES', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.mint, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                  Text('2,840', style: GoogleFonts.dmSerifDisplay(fontSize: 26, color: Colors.white)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('↑ 5%', style: GoogleFonts.dmSans(color: AppColors.mint, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return Text(days[v.toInt()], style: GoogleFonts.dmSans(fontSize: 9, color: Colors.white54));
                      },
                      reservedSize: 16,
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                barGroups: bars.asMap().entries.map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [BarChartRodData(
                    toY: e.value.toDouble(),
                    color: e.key == 6 ? AppColors.mint : Colors.white.withOpacity(0.25),
                    width: 12,
                    borderRadius: BorderRadius.circular(4),
                  )],
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const _EmptyState({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Center(
      child: Column(
        children: [
          Icon(icon, size: 52, color: const Color(0xFFCCCCCC)),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: GoogleFonts.dmSans(color: const Color(0xFF999999), fontSize: 13)),
        ],
      ),
    ),
  );
}

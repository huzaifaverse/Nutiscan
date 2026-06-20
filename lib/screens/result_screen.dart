import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../services/scan_provider.dart';
import '../services/user_provider.dart';
import '../widgets/widgets.dart';

class ResultScreen extends StatefulWidget {
  final Product product;
  const ResultScreen({super.key, required this.product});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final user = context.watch<UserProvider>();
    final scan = context.watch<ScanProvider>();
    final isSaved = user.isSaved(product.barcode);

    return Scaffold(
      backgroundColor: AppColors.neutralLight,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16, right: 16, bottom: 16,
            ),
            decoration: const BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  ),
                  Text('Product Result', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => user.toggleSaved(product.barcode),
                    icon: Icon(isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: isSaved ? AppColors.mint : Colors.white70),
                  ),
                ]),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScoreCircle(score: product.nutriScore, size: 58),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.brand.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.mint, fontWeight: FontWeight.w700, letterSpacing: 1)),
                          Text(product.name, style: GoogleFonts.dmSerifDisplay(fontSize: 17, color: Colors.white), maxLines: 2),
                          Text('${product.calories} kcal per 100g', style: GoogleFonts.dmSans(fontSize: 11, color: Colors.white54)),
                        ],
                      ),
                    ),
                    if (product.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(product.imageUrl!, width: 56, height: 56, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                      ),
                  ],
                ),
                // Allergen banner
                AllergenBanner(allergens: product.allergens),
              ],
            ),
          ),

          // ── Tabs ─────────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabs,
              labelColor: AppColors.green,
              unselectedLabelColor: const Color(0xFFBBBBBB),
              indicatorColor: AppColors.green,
              labelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 12),
              tabs: const [Tab(text: 'NUTRITION'), Tab(text: 'INGREDIENTS'), Tab(text: 'ALTERNATIVES')],
            ),
          ),

          // ── Tab content ───────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _NutritionTab(nutrients: product.nutrients),
                _IngredientsTab(ingredients: product.ingredients, scan: scan),
                _AlternativesTab(product: product, scan: scan),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Nutrition Tab ────────────────────────────────────────────────────────────

class _NutritionTab extends StatelessWidget {
  final List<Nutrient> nutrients;
  const _NutritionTab({required this.nutrients});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: nutrients.map((n) => NutrientRow(nutrient: n)).toList(),
  );
}

// ─── Ingredients Tab ──────────────────────────────────────────────────────────

class _IngredientsTab extends StatelessWidget {
  final List<Ingredient> ingredients;
  final ScanProvider scan;
  const _IngredientsTab({required this.ingredients, required this.scan});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Tap any ingredient for an AI explanation', style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF999999))),
        const SizedBox(height: 10),
        ...ingredients.map((ing) => IngredientTile(
          ingredient: ing,
          onTap: () => context.read<ScanProvider>().decodeIngredient(ing.text),
        )),
        if (scan.decodingIngredient || scan.decodedIngredientText != null)
          AiDecoderCard(
            loading: scan.decodingIngredient,
            ingredientName: scan.decodedIngredientName,
            explanation: scan.decodedIngredientText,
          ),
      ],
    );
  }
}

// ─── Alternatives Tab ─────────────────────────────────────────────────────────

class _AlternativesTab extends StatelessWidget {
  final Product product;
  final ScanProvider scan;
  const _AlternativesTab({required this.product, required this.scan});

  @override
  Widget build(BuildContext context) {
    if (scan.loadingAlternatives) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.green),
            const SizedBox(height: 16),
            Text('AI is finding better options…', style: GoogleFonts.dmSans(color: const Color(0xFF999999))),
          ],
        ),
      );
    }

    if (product.alternatives.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 52, color: Color(0xFFCCCCCC)),
            const SizedBox(height: 12),
            Text('No alternatives found', style: GoogleFonts.dmSans(color: const Color(0xFF999999))),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('AI-ranked healthier alternatives', style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF999999))),
        const SizedBox(height: 10),
        ...product.alternatives.map((a) => AlternativeCard(alt: a)),
      ],
    );
  }
}

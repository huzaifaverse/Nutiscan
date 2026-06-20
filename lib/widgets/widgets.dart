import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Score Circle ────────────────────────────────────────────────────────────

class ScoreCircle extends StatelessWidget {
  final String score;
  final double size;

  const ScoreCircle({super.key, required this.score, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(score);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Center(
        child: Text(
          score,
          style: GoogleFonts.dmSerifDisplay(
            fontSize: size * 0.42,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─── Allergen Banner ─────────────────────────────────────────────────────────

class AllergenBanner extends StatelessWidget {
  final List<String> allergens;

  const AllergenBanner({super.key, required this.allergens});

  @override
  Widget build(BuildContext context) {
    if (allergens.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.alertRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.alertRed.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.warning_rounded, color: AppColors.alertRed, size: 18),
            const SizedBox(width: 6),
            Text('Allergen Alert', style: GoogleFonts.dmSans(color: AppColors.alertRed, fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: allergens.map((a) => _chip(a)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.alertRed.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.alertRed.withOpacity(0.4)),
    ),
    child: Text(label, style: GoogleFonts.dmSans(color: AppColors.alertRed, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}

// ─── Nutrient Row ─────────────────────────────────────────────────────────────

class NutrientRow extends StatelessWidget {
  final Nutrient nutrient;

  const NutrientRow({super.key, required this.nutrient});

  Color get _levelColor {
    switch (nutrient.level) {
      case NutrientLevel.low:      return AppColors.green;
      case NutrientLevel.moderate: return AppColors.amber;
      case NutrientLevel.high:     return AppColors.alertRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(nutrient.name, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.navy)),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: _levelColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(nutrient.levelLabel, style: GoogleFonts.dmSans(color: _levelColor, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Text(nutrient.valueLabel, style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF555555))),
              ]),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: nutrient.dailyPct,
              minHeight: 7,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor: AlwaysStoppedAnimation<Color>(_levelColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ingredient Tile ──────────────────────────────────────────────────────────

class IngredientTile extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onTap;

  const IngredientTile({super.key, required this.ingredient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 18, color: AppColors.navy.withOpacity(0.5)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ingredient.text, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.navy)),
                    if (ingredient.eNumber != null)
                      Text(ingredient.eNumber!, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.amber, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              if (ingredient.isAllergen)
                const Icon(Icons.warning_amber_rounded, color: AppColors.alertRed, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Alternative Card ─────────────────────────────────────────────────────────

class AlternativeCard extends StatelessWidget {
  final AlternativeProduct alt;

  const AlternativeCard({super.key, required this.alt});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ScoreCircle(score: alt.score, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alt.name, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy)),
                  Text('${alt.brand} · ${alt.calories} kcal',
                      style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF999999))),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.green, size: 13),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(alt.benefitSummary, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.green, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Heading ──────────────────────────────────────────────────────────

class SectionHeading extends StatelessWidget {
  final String text;

  const SectionHeading(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 4),
    child: Text(text, style: GoogleFonts.dmSerifDisplay(fontSize: 18, color: AppColors.navy)),
  );
}

// ─── AI Decoder Card ──────────────────────────────────────────────────────────

class AiDecoderCard extends StatelessWidget {
  final bool loading;
  final String? ingredientName;
  final String? explanation;

  const AiDecoderCard({super.key, required this.loading, this.ingredientName, this.explanation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: loading
          ? Row(children: [
              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.mint)),
              const SizedBox(width: 12),
              Text('AI is decoding…', style: GoogleFonts.dmSans(color: AppColors.mint, fontSize: 13)),
            ])
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI INGREDIENT DECODER', style: GoogleFonts.dmSans(color: AppColors.mint, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                const SizedBox(height: 6),
                if (ingredientName != null)
                  Text(ingredientName!, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                if (explanation != null)
                  Text(explanation!, style: GoogleFonts.dmSans(color: const Color(0xFFCCCCCC), fontSize: 12, height: 1.65)),
              ],
            ),
    );
  }
}

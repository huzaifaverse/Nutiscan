import 'package:equatable/equatable.dart';

// ─── Nutrient ───────────────────────────────────────────────────────────────

enum NutrientLevel { low, moderate, high }

class Nutrient extends Equatable {
  final String name;
  final double value;
  final String unit;
  final NutrientLevel level;
  final double dailyPct; // 0.0 – 1.0

  const Nutrient({
    required this.name,
    required this.value,
    required this.unit,
    required this.level,
    required this.dailyPct,
  });

  String get valueLabel => '${value.toStringAsFixed(value < 10 ? 1 : 0)}$unit';

  String get levelLabel {
    switch (level) {
      case NutrientLevel.low:      return 'Low';
      case NutrientLevel.moderate: return 'Moderate';
      case NutrientLevel.high:     return 'High';
    }
  }

  factory Nutrient.fromOpenFoodFacts(String name, dynamic raw, String unit, double dailyRef) {
    final v = (raw as num?)?.toDouble() ?? 0.0;
    final pct = (v / dailyRef).clamp(0.0, 1.0);
    NutrientLevel level;
    if (pct < 0.1) level = NutrientLevel.low;
    else if (pct < 0.4) level = NutrientLevel.moderate;
    else level = NutrientLevel.high;
    return Nutrient(name: name, value: v, unit: unit, level: level, dailyPct: pct);
  }

  @override
  List<Object?> get props => [name, value, unit, level];
}

// ─── Ingredient ─────────────────────────────────────────────────────────────

class Ingredient extends Equatable {
  final String text;
  final bool isAllergen;
  final String? eNumber;
  final String? decodedExplanation; // filled after AI call

  const Ingredient({
    required this.text,
    this.isAllergen = false,
    this.eNumber,
    this.decodedExplanation,
  });

  Ingredient copyWith({String? decodedExplanation}) =>
      Ingredient(text: text, isAllergen: isAllergen, eNumber: eNumber, decodedExplanation: decodedExplanation ?? this.decodedExplanation);

  @override
  List<Object?> get props => [text, isAllergen, eNumber];
}

// ─── Alternative Product ────────────────────────────────────────────────────

class AlternativeProduct extends Equatable {
  final String barcode;
  final String name;
  final String brand;
  final String score;
  final int calories;
  final String benefitSummary; // AI-generated

  const AlternativeProduct({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.score,
    required this.calories,
    required this.benefitSummary,
  });

  @override
  List<Object?> get props => [barcode];
}

// ─── Product ────────────────────────────────────────────────────────────────

class Product extends Equatable {
  final String barcode;
  final String name;
  final String brand;
  final String? imageUrl;
  final String nutriScore; // A–E
  final int calories;
  final String? category;
  final List<Nutrient> nutrients;
  final List<Ingredient> ingredients;
  final List<String> allergens;
  final List<AlternativeProduct> alternatives;
  final DateTime scannedAt;

  const Product({
    required this.barcode,
    required this.name,
    required this.brand,
    this.imageUrl,
    required this.nutriScore,
    required this.calories,
    this.category,
    required this.nutrients,
    required this.ingredients,
    required this.allergens,
    this.alternatives = const [],
    required this.scannedAt,
  });

  Product copyWith({List<AlternativeProduct>? alternatives, List<Ingredient>? ingredients}) =>
      Product(
        barcode: barcode, name: name, brand: brand, imageUrl: imageUrl,
        nutriScore: nutriScore, calories: calories, category: category,
        nutrients: nutrients, allergens: allergens, scannedAt: scannedAt,
        ingredients: ingredients ?? this.ingredients,
        alternatives: alternatives ?? this.alternatives,
      );

  /// Build from Open Food Facts JSON response
  factory Product.fromOpenFoodFacts(Map<String, dynamic> json) {
    final p = json['product'] as Map<String, dynamic>? ?? {};
    final n = p['nutriments'] as Map<String, dynamic>? ?? {};

    String _str(String key) => (p[key] as String? ?? '').trim();
    int _kcal() => (n['energy-kcal_100g'] as num?)?.toInt() ?? (((n['energy_100g'] as num?)?.toDouble() ?? 0) / 4.184).toInt();
    String _score() => (_str('nutriscore_grade') == '') ? 'C' : _str('nutriscore_grade').toUpperCase();

    final nutrients = <Nutrient>[
      Nutrient.fromOpenFoodFacts('Carbohydrates', n['carbohydrates_100g'], 'g', 300),
      Nutrient.fromOpenFoodFacts('Sugars',        n['sugars_100g'],        'g', 90),
      Nutrient.fromOpenFoodFacts('Fat',           n['fat_100g'],           'g', 70),
      Nutrient.fromOpenFoodFacts('Saturated Fat', n['saturated-fat_100g'],'g', 20),
      Nutrient.fromOpenFoodFacts('Protein',       n['proteins_100g'],      'g', 50),
      Nutrient.fromOpenFoodFacts('Salt',          n['salt_100g'],          'g', 6),
      Nutrient.fromOpenFoodFacts('Fibre',         n['fiber_100g'],         'g', 30),
    ];

    // Parse ingredients text into list
    final rawIngredients = (_str('ingredients_text_en').isEmpty
        ? _str('ingredients_text')
        : _str('ingredients_text_en'));
    final ingredientList = rawIngredients
        .split(RegExp(r'[,;]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .take(20)
        .map((s) {
          final eMatch = RegExp(r'E\d{3}[a-z]?', caseSensitive: false).firstMatch(s);
          return Ingredient(text: s, eNumber: eMatch?.group(0));
        })
        .toList();

    // Allergens
    final allergenRaw = _str('allergens_from_ingredients');
    final allergens = allergenRaw
        .split(',')
        .map((s) => s.replaceAll(RegExp(r'en:|fr:'), '').trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();

    return Product(
      barcode: _str('code') != '' ? _str('code') : (json['code'] as String? ?? ''),
      name: _str('product_name_en').isNotEmpty ? _str('product_name_en') : _str('product_name'),
      brand: _str('brands'),
      imageUrl: _str('image_front_url'),
      nutriScore: _score(),
      calories: _kcal(),
      category: _str('categories_tags').split(',').firstWhere((_) => true, orElse: () => ''),
      nutrients: nutrients,
      ingredients: ingredientList,
      allergens: allergens,
      scannedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [barcode, scannedAt];
}

// ─── User Allergen Profile ───────────────────────────────────────────────────

class AllergenProfile extends Equatable {
  final Set<String> activeAllergens;

  const AllergenProfile({required this.activeAllergens});

  static const List<String> allAllergens = [
    'Gluten', 'Dairy', 'Nuts', 'Peanuts',
    'Shellfish', 'Eggs', 'Soy', 'Sesame',
  ];

  bool flagsProduct(List<String> productAllergens) =>
      activeAllergens.any((a) => productAllergens.any(
            (p) => p.toLowerCase().contains(a.toLowerCase()),
          ));

  AllergenProfile toggle(String allergen) {
    final updated = Set<String>.from(activeAllergens);
    if (updated.contains(allergen)) {
      updated.remove(allergen);
    } else {
      updated.add(allergen);
    }
    return AllergenProfile(activeAllergens: updated);
  }

  @override
  List<Object?> get props => [activeAllergens];
}

// ─── App User ────────────────────────────────────────────────────────────────

class AppUser extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? avatarUrl;
  final AllergenProfile allergenProfile;
  final List<Product> scanHistory;
  final List<String> savedBarcodes;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.allergenProfile,
    this.scanHistory = const [],
    this.savedBarcodes = const [],
  });

  @override
  List<Object?> get props => [uid];
}

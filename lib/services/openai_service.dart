import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class OpenAIService {
  // Replace with your actual key or inject via environment
  static const String _apiKey = 'YOUR_OPENAI_API_KEY';
  static const String _base   = 'https://api.openai.com/v1/chat/completions';
  static const String _model  = 'gpt-4o-mini';

  // ── Ingredient decoder ─────────────────────────────────────────────────────
  static Future<String> decodeIngredient(String ingredient) async {
    final prompt = '''
You are a food-safety expert helping everyday shoppers understand food labels.
Explain this food ingredient in exactly 3 short sentences:
1. What it is and where it comes from
2. Why it is added to food
3. Any safety or dietary notes (e.g. allergens, E-number classification, suitable for vegans)

Ingredient: "$ingredient"

Be plain-language, concise, and consumer-friendly. No markdown.
''';
    return _chat(prompt);
  }

  // ── Healthier alternatives summary ─────────────────────────────────────────
  static Future<List<AlternativeProduct>> rankAlternatives({
    required Product scanned,
    required List<Map<String, dynamic>> candidates,
  }) async {
    if (candidates.isEmpty) return [];

    final candidateList = candidates.take(8).map((c) {
      final name  = (c['product_name_en'] as String? ?? c['product_name'] as String? ?? '').trim();
      final brand = (c['brands'] as String? ?? '').trim();
      final score = (c['nutriscore_grade'] as String? ?? 'c').toUpperCase();
      final kcal  = (c['nutriments']?['energy-kcal_100g'] as num?)?.toInt() ?? 0;
      final code  = (c['_id'] as String? ?? c['code'] as String? ?? '');
      return '{"code":"$code","name":"$name","brand":"$brand","score":"$score","calories":$kcal}';
    }).join('\n');

    final prompt = '''
A consumer scanned: "${scanned.name}" by ${scanned.brand} (Nutri-Score ${scanned.nutriScore}, ${scanned.calories} kcal/100g).
Their allergen profile: ${scanned.allergens.isEmpty ? "none" : scanned.allergens.join(", ")}.

From this list of candidate alternatives:
$candidateList

Pick the TOP 3 healthiest alternatives. For each, write a ONE sentence benefit over the scanned product.
Respond ONLY with valid JSON array, no markdown:
[{"code":"...","benefit":"..."},{"code":"...","benefit":"..."},{"code":"...","benefit":"..."}]
''';

    try {
      final raw = await _chat(prompt);
      final cleaned = raw.replaceAll(RegExp(r'```[a-z]*'), '').trim();
      final list = jsonDecode(cleaned) as List<dynamic>;

      final results = <AlternativeProduct>[];
      for (final item in list) {
        final code = item['code'] as String? ?? '';
        final benefit = item['benefit'] as String? ?? '';
        final match = candidates.firstWhere(
          (c) => (c['_id'] ?? c['code']) == code,
          orElse: () => {},
        );
        if (match.isEmpty) continue;

        results.add(AlternativeProduct(
          barcode: code,
          name: (match['product_name_en'] as String? ?? match['product_name'] as String? ?? '').trim(),
          brand: (match['brands'] as String? ?? '').trim(),
          score: (match['nutriscore_grade'] as String? ?? 'C').toUpperCase(),
          calories: (match['nutriments']?['energy-kcal_100g'] as num?)?.toInt() ?? 0,
          benefitSummary: benefit,
        ));
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  // ── Private chat helper ────────────────────────────────────────────────────
  static Future<String> _chat(String userPrompt) async {
    final response = await http.post(
      Uri.parse(_base),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': 300,
        'temperature': 0.4,
        'messages': [
          {'role': 'user', 'content': userPrompt},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('OpenAI error ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['choices'][0]['message']['content'] as String? ?? '';
  }
}

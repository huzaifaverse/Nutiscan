import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class OpenFoodFactsService {
  static const _base = 'https://world.openfoodfacts.org/api/v2/product';
  static const _searchBase = 'https://world.openfoodfacts.org/cgi/search.pl';

  // Fetch full product by barcode
  static Future<Product?> fetchByBarcode(String barcode) async {
    try {
      final uri = Uri.parse('$_base/$barcode.json');
      final response = await http.get(uri, headers: {'User-Agent': 'NutriScan/1.0'});

      if (response.statusCode != 200) return null;
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if ((json['status'] as int? ?? 0) != 1) return null;
      return Product.fromOpenFoodFacts({'code': barcode, 'product': json['product']});
    } catch (e) {
      return null;
    }
  }

  // Search for alternatives in the same category
  static Future<List<Map<String, dynamic>>> searchAlternatives({
    required String category,
    required String nutriScore,
    int count = 5,
  }) async {
    try {
      final uri = Uri.parse(
        '$_searchBase?action=process'
        '&tagtype_0=categories&tag_contains_0=contains&tag_0=${Uri.encodeComponent(category)}'
        '&tagtype_1=nutriscore_grade&tag_contains_1=contains&tag_1=a'
        '&json=1&page_size=$count&sort_by=unique_scans_n',
      );

      final response = await http.get(uri, headers: {'User-Agent': 'NutriScan/1.0'});
      if (response.statusCode != 200) return [];

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final products = (json['products'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      return products;
    } catch (_) {
      return [];
    }
  }
}

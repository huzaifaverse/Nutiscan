import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/open_food_facts_service.dart';
import '../services/openai_service.dart';

enum ScanState { idle, loading, success, error, notFound }

class ScanProvider extends ChangeNotifier {
  ScanState _state = ScanState.idle;
  Product? _product;
  String? _errorMessage;
  bool _decodingIngredient = false;
  String? _decodedIngredientText;
  String? _decodedIngredientName;
  bool _loadingAlternatives = false;

  ScanState get state => _state;
  Product? get product => _product;
  String? get errorMessage => _errorMessage;
  bool get decodingIngredient => _decodingIngredient;
  String? get decodedIngredientText => _decodedIngredientText;
  String? get decodedIngredientName => _decodedIngredientName;
  bool get loadingAlternatives => _loadingAlternatives;

  // ── Scan barcode ───────────────────────────────────────────────────────────
  Future<void> scanBarcode(String barcode) async {
    _state = ScanState.loading;
    _product = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final product = await OpenFoodFactsService.fetchByBarcode(barcode);
      if (product == null) {
        _state = ScanState.notFound;
        notifyListeners();
        return;
      }
      _product = product;
      _state = ScanState.success;
      notifyListeners();

      // Load alternatives in background
      _fetchAlternatives(product);
    } catch (e) {
      _state = ScanState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ── Decode ingredient with AI ──────────────────────────────────────────────
  Future<void> decodeIngredient(String ingredientText) async {
    _decodingIngredient = true;
    _decodedIngredientName = ingredientText;
    _decodedIngredientText = null;
    notifyListeners();

    try {
      final explanation = await OpenAIService.decodeIngredient(ingredientText);
      _decodedIngredientText = explanation;
    } catch (_) {
      _decodedIngredientText = 'Unable to decode this ingredient right now. Please try again.';
    } finally {
      _decodingIngredient = false;
      notifyListeners();
    }
  }

  void clearDecodedIngredient() {
    _decodedIngredientText = null;
    _decodedIngredientName = null;
    notifyListeners();
  }

  // ── Fetch alternatives ─────────────────────────────────────────────────────
  Future<void> _fetchAlternatives(Product product) async {
    if (product.category == null || product.category!.isEmpty) return;

    _loadingAlternatives = true;
    notifyListeners();

    try {
      final candidates = await OpenFoodFactsService.searchAlternatives(
        category: product.category!,
        nutriScore: product.nutriScore,
      );
      final alternatives = await OpenAIService.rankAlternatives(
        scanned: product,
        candidates: candidates,
      );
      _product = _product!.copyWith(alternatives: alternatives);
    } catch (_) {
      // Alternatives are non-critical; fail silently
    } finally {
      _loadingAlternatives = false;
      notifyListeners();
    }
  }

  void reset() {
    _state = ScanState.idle;
    _product = null;
    _errorMessage = null;
    _decodedIngredientText = null;
    _decodedIngredientName = null;
    notifyListeners();
  }
}

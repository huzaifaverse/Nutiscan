import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class UserProvider extends ChangeNotifier {
  AllergenProfile _allergenProfile = const AllergenProfile(activeAllergens: {'Gluten', 'Nuts'});
  List<Product> _scanHistory = [];
  List<String> _savedBarcodes = [];
  String _userName = 'Guest';
  String _userEmail = '';

  AllergenProfile get allergenProfile => _allergenProfile;
  List<Product> get scanHistory => List.unmodifiable(_scanHistory);
  List<String> get savedBarcodes => List.unmodifiable(_savedBarcodes);
  String get userName => _userName;
  String get userEmail => _userEmail;

  bool isSaved(String barcode) => _savedBarcodes.contains(barcode);

  void toggleAllergen(String allergen) {
    _allergenProfile = _allergenProfile.toggle(allergen);
    notifyListeners();
    _persist();
  }

  void addToHistory(Product product) {
    _scanHistory.removeWhere((p) => p.barcode == product.barcode);
    _scanHistory.insert(0, product);
    if (_scanHistory.length > 200) _scanHistory = _scanHistory.take(200).toList();
    notifyListeners();
  }

  void toggleSaved(String barcode) {
    if (_savedBarcodes.contains(barcode)) {
      _savedBarcodes.remove(barcode);
    } else {
      _savedBarcodes.insert(0, barcode);
    }
    notifyListeners();
    _persist();
  }

  List<Product> get savedProducts =>
      _savedBarcodes.map((b) => _scanHistory.firstWhere((p) => p.barcode == b, orElse: () => _placeholderProduct(b))).toList();

  Product _placeholderProduct(String barcode) => Product(
        barcode: barcode, name: 'Saved Product', brand: '', nutriScore: 'C',
        calories: 0, nutrients: [], ingredients: [], allergens: [],
        scannedAt: DateTime.now(),
      );

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final allergens = prefs.getStringList('allergens') ?? ['Gluten', 'Nuts'];
    _allergenProfile = AllergenProfile(activeAllergens: allergens.toSet());
    _savedBarcodes = prefs.getStringList('saved') ?? [];
    _userName = prefs.getString('userName') ?? 'Guest';
    _userEmail = prefs.getString('userEmail') ?? '';
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('allergens', _allergenProfile.activeAllergens.toList());
    await prefs.setStringList('saved', _savedBarcodes);
  }
}

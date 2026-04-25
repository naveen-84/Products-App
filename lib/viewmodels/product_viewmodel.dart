import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/wishlist_service.dart';

class ProductViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final WishlistService _wishlistService = WishlistService();

  final List<Product> _products = [];

  bool isLoading = false;
  bool hasError = false;

  bool isWishlisted(int id) {
    return _wishlistService.isInWishlist(id);
  }

  void toggleWishlist(int id) {
    _wishlistService.toggleWishlist(id);
    notifyListeners();
  }

  int page = 0;

  String _search = "";
  String _selectedCategory = "All";
  RangeValues _priceRange = const RangeValues(0, 2000);

  // ✅ Getters
  String get selectedCategory => _selectedCategory;
  RangeValues get priceRange => _priceRange;

  // ✅ Safe Categories (CRASH FIXED 🔥)
  List<String> get categories {
    final list = _products
        .map((e) => (e.category ?? "Other").toString())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    return ["All", ...list];
  }

  // ✅ Filtered Products (SAFE)
  List<Product> get products {
    return _products.where((p) {
      final title = (p.title ?? "").toLowerCase();
      final category = (p.category ?? "Other");

      final matchSearch = title.contains(_search.toLowerCase());

      final matchCategory =
          _selectedCategory == "All" || category == _selectedCategory;

      final matchPrice =
          p.price >= _priceRange.start && p.price <= _priceRange.end;

      return matchSearch && matchCategory && matchPrice;
    }).toList();
  }

  // 🚀 Fetch Products
  Future<void> fetchProducts() async {
    if (isLoading) return;

    try {
      isLoading = true;
      hasError = false;
      notifyListeners();

      final newProducts = await _apiService.fetchProducts(page);

      // ✅ Avoid duplicates
      final existingIds = _products.map((e) => e.id).toSet();
      final uniqueProducts = newProducts
          .where((p) => !existingIds.contains(p.id))
          .toList();

      _products.addAll(uniqueProducts);

      page++;
    } catch (e) {
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔍 Search
  void search(String value) {
    _search = value;
    notifyListeners();
  }

  // 📂 Category Filter
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // 💰 Price Filter
  void setPriceRange(RangeValues range) {
    _priceRange = range;
    notifyListeners();
  }

  // 🔄 Reset Filters
  void resetFilters() {
    _search = "";
    _selectedCategory = "All";
    _priceRange = const RangeValues(0, 2000);
    notifyListeners();
  }
}

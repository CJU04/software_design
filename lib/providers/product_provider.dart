import 'package:flutter/material.dart';
import 'package:vetcare_connect/models/product.dart';
import 'package:vetcare_connect/services/database_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products => _products;

  Future<void> loadProducts() async {
    _products = await DatabaseService().getProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await DatabaseService().insertProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    await DatabaseService().updateProduct(product);
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await DatabaseService().deleteProduct(id);
    await loadProducts();
  }

  List<Product> searchProducts(String query) {
    return _products.where((product) => product.productname.toLowerCase().contains(query.toLowerCase())).toList();
  }

  List<Product> filterProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }
}


import 'package:flutter/material.dart';
import 'package:vetcare_connect/models/sale_item.dart';
import 'package:vetcare_connect/services/database_service.dart';

class SaleItemProvider with ChangeNotifier {
  List<SaleItem> _saleItems = [];

  List<SaleItem> get saleItems => _saleItems;

  Future<void> loadSaleItems() async {
    _saleItems = await DatabaseService().getSaleItems();
    notifyListeners();
  }

  Future<String> addSaleItem(SaleItem item) async {
    final id = await DatabaseService().insertSaleItem(item);
    await loadSaleItems();
    return id;
  }

  Future<void> updateSaleItem(SaleItem item) async {
    await DatabaseService().updateSaleItem(item);
    await loadSaleItems();
  }

  Future<void> deleteSaleItem(String id) async {
    await DatabaseService().deleteSaleItem(id);
    await loadSaleItems();
  }

  List<SaleItem> getSaleItemsBySale(String saleId) {
    return _saleItems.where((i) => i.saleId == saleId).toList();
  }
}

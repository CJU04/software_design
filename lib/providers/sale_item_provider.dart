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

  Future<void> addSaleItem(SaleItem item) async {
    await DatabaseService().insertSaleItem(item);
    await loadSaleItems();
  }

  Future<void> updateSaleItem(SaleItem item) async {
    await DatabaseService().updateSaleItem(item);
    await loadSaleItems();
  }

  Future<void> deleteSaleItem(int id) async {
    await DatabaseService().deleteSaleItem(id);
    await loadSaleItems();
  }

  List<SaleItem> getSaleItemsBySale(int saleid) {
    return _saleItems.where((item) => item.saleid == saleid).toList();
  }
}


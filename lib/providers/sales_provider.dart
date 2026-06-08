import 'package:flutter/material.dart';
import 'package:vetcare_connect/models/sales.dart';
import 'package:vetcare_connect/services/database_service.dart';

class SalesProvider with ChangeNotifier {
  List<Sales> _sales = [];

  List<Sales> get sales => _sales;

  Future<void> loadSales() async {
    _sales = await DatabaseService().getSales();
    notifyListeners();
  }

  Future<String> addSales(Sales sales) async {
    final id = await DatabaseService().insertSales(sales);
    await loadSales();
    return id;
  }

  Future<void> updateSales(Sales sales) async {
    await DatabaseService().updateSales(sales);
    await loadSales();
  }

  Future<void> deleteSales(String id) async {
    await DatabaseService().deleteSales(id);
    await loadSales();
  }

  List<Sales> getSalesByOwner(String ownerUid) {
    return _sales.where((s) => s.ownerUid == ownerUid).toList();
  }
}

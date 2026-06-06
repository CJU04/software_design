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

  Future<void> addSales(Sales sales) async {
    await DatabaseService().insertSales(sales);
    await loadSales();
  }

  Future<void> updateSales(Sales sales) async {
    await DatabaseService().updateSales(sales);
    await loadSales();
  }

  Future<void> deleteSales(int id) async {
    await DatabaseService().deleteSales(id);
    await loadSales();
  }

  List<Sales> getSalesByUser(int userid) {
    return _sales.where((sale) => sale.userid == userid).toList();
  }
}


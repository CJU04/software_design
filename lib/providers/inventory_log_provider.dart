import 'package:flutter/material.dart';
import 'package:vetcare_connect/models/inventory_log.dart';
import 'package:vetcare_connect/services/database_service.dart';

class InventoryLogProvider with ChangeNotifier {
  List<InventoryLog> _inventoryLogs = [];

  List<InventoryLog> get inventoryLogs => _inventoryLogs;

  Future<void> loadInventoryLogs() async {
    _inventoryLogs = await DatabaseService().getInventoryLogs();
    notifyListeners();
  }

  Future<String> addInventoryLog(InventoryLog log) async {
    final id = await DatabaseService().insertInventoryLog(log);
    await loadInventoryLogs();
    return id;
  }

  Future<void> updateInventoryLog(InventoryLog log) async {
    await DatabaseService().updateInventoryLog(log);
    await loadInventoryLogs();
  }

  Future<void> deleteInventoryLog(String id) async {
    await DatabaseService().deleteInventoryLog(id);
    await loadInventoryLogs();
  }

  List<InventoryLog> getInventoryLogsByProduct(String productId) {
    return _inventoryLogs.where((l) => l.productId == productId).toList();
  }
}

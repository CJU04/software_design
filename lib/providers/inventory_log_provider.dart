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

  Future<void> addInventoryLog(InventoryLog log) async {
    await DatabaseService().insertInventoryLog(log);
    await loadInventoryLogs();
  }

  Future<void> updateInventoryLog(InventoryLog log) async {
    await DatabaseService().updateInventoryLog(log);
    await loadInventoryLogs();
  }

  Future<void> deleteInventoryLog(int id) async {
    await DatabaseService().deleteInventoryLog(id);
    await loadInventoryLogs();
  }
}


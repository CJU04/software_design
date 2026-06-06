import 'package:vetcare_connect/models/user.dart';

import '../models/pet.dart';
import '../models/appointment.dart';
import '../models/medical_history.dart';
import '../models/product.dart';
import '../models/sales.dart';
import '../models/sale_item.dart';
import '../models/inventory_log.dart';

import 'firestore_database_service.dart';

/// DatabaseService now points to Firebase (Firestore) instead of local SQLite.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirestoreDatabaseService _store = FirestoreDatabaseService();

  // User
  Future<int> insertUser(User user) => _store.insertUser(user);
  Future<List<User>> getUsers() => _store.getUsers();
  Future<int> updateUser(User user) => _store.updateUser(user);
  Future<int> deleteUser(int id) => _store.deleteUser(id);
  Future<bool> isUsernameExists(String username) => _store.isUsernameExists(username);
  Future<bool> isEmailExists(String email) => _store.isEmailExists(email);

  // Pet
  Future<int> insertPet(Pet pet) => _store.insertPet(pet);
  Future<List<Pet>> getPets() => _store.getPets();
  Future<int> updatePet(Pet pet) => _store.updatePet(pet);
  Future<int> deletePet(int id) => _store.deletePet(id);

  // Appointment
  Future<int> insertAppointment(Appointment appointment) => _store.insertAppointment(appointment);
  Future<List<Appointment>> getAppointments() => _store.getAppointments();
  Future<List<Appointment>> getAppointmentsByUser(int userId) => _store.getAppointmentsByUser(userId);
  Future<int> updateAppointment(Appointment appointment) => _store.updateAppointment(appointment);
  Future<int> deleteAppointment(int id) => _store.deleteAppointment(id);

  // MedicalHistory
  Future<int> insertMedicalHistory(MedicalHistory medicalHistory) => _store.insertMedicalHistory(medicalHistory);
  Future<List<MedicalHistory>> getMedicalHistories() => _store.getMedicalHistories();
  Future<int> updateMedicalHistory(MedicalHistory medicalHistory) => _store.updateMedicalHistory(medicalHistory);
  Future<int> deleteMedicalHistory(int id) => _store.deleteMedicalHistory(id);

  // Product
  Future<int> insertProduct(Product product) => _store.insertProduct(product);
  Future<List<Product>> getProducts() => _store.getProducts();
  Future<int> updateProduct(Product product) => _store.updateProduct(product);
  Future<int> deleteProduct(int id) => _store.deleteProduct(id);

  // Sales
  Future<int> insertSales(Sales sales) => _store.insertSales(sales);
  Future<List<Sales>> getSales() => _store.getSales();
  Future<int> updateSales(Sales sales) => _store.updateSales(sales);
  Future<int> deleteSales(int id) => _store.deleteSales(id);

  // SaleItem
  Future<int> insertSaleItem(SaleItem saleItem) => _store.insertSaleItem(saleItem);
  Future<List<SaleItem>> getSaleItems() => _store.getSaleItems();
  Future<int> updateSaleItem(SaleItem saleItem) => _store.updateSaleItem(saleItem);
  Future<int> deleteSaleItem(int id) => _store.deleteSaleItem(id);

  // InventoryLog
  Future<int> insertInventoryLog(InventoryLog inventoryLog) => _store.insertInventoryLog(inventoryLog);
  Future<List<InventoryLog>> getInventoryLogs() => _store.getInventoryLogs();
  Future<int> updateInventoryLog(InventoryLog inventoryLog) => _store.updateInventoryLog(inventoryLog);
  Future<int> deleteInventoryLog(int id) => _store.deleteInventoryLog(id);
}




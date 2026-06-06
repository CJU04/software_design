import 'package:sembast_web/sembast_web.dart';
import 'package:vetcare_connect/models/user.dart';
import 'package:vetcare_connect/models/pet.dart';
import 'package:vetcare_connect/models/appointment.dart';
import 'package:vetcare_connect/models/medical_history.dart';
import 'package:vetcare_connect/models/product.dart';
import 'package:vetcare_connect/models/sales.dart';
import 'package:vetcare_connect/models/sale_item.dart';
import 'package:vetcare_connect/models/inventory_log.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final factory = databaseFactoryWeb;
    return await factory.openDatabase('furfectcare.db');
  }

  // Helper method to get store
  StoreRef<String, Map<String, dynamic>> _getStore(String tableName) {
    return stringMapStoreFactory.store(tableName);
  }

  // CRUD methods for User
  Future<List<User>> getUsers() async {
    final db = await database;
    final store = _getStore('user');
    final records = await store.find(db);
    return records.map((record) => User.fromMap(record.value)).toList();
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    final store = _getStore('user');
    final key = await store.add(db, user.toMap());
    return int.parse(key);
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    final store = _getStore('user');
    await store.record(user.userid.toString()).put(db, user.toMap());
    return user.userid!;
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    final store = _getStore('user');
    await store.record(id.toString()).delete(db);
    return id;
  }

  Future<bool> isUsernameExists(String username) async {
    final users = await getUsers();
    return users.any((user) => user.username == username);
  }

  Future<bool> isEmailExists(String email) async {
    final users = await getUsers();
    return users.any((user) => user.email == email);
  }

  // CRUD methods for Pet
  Future<List<Pet>> getPets() async {
    final db = await database;
    final store = _getStore('pet');
    final records = await store.find(db);
    return records.map((record) => Pet.fromMap(record.value)).toList();
  }

  Future<int> insertPet(Pet pet) async {
    final db = await database;
    final store = _getStore('pet');
    final key = await store.add(db, pet.toMap());
    return int.parse(key);
  }

  Future<int> updatePet(Pet pet) async {
    final db = await database;
    final store = _getStore('pet');
    await store.record(pet.petid.toString()).put(db, pet.toMap());
    return pet.petid!;
  }

  Future<int> deletePet(int id) async {
    final db = await database;
    final store = _getStore('pet');
    await store.record(id.toString()).delete(db);
    return id;
  }

  // CRUD methods for Appointment
  Future<List<Appointment>> getAppointments() async {
    final db = await database;
    final store = _getStore('appointment');
    final records = await store.find(db);
    return records.map((record) => Appointment.fromMap(record.value)).toList();
  }

  Future<int> insertAppointment(Appointment appointment) async {
    final db = await database;
    final store = _getStore('appointment');
    final key = await store.add(db, appointment.toMap());
    return int.parse(key);
  }

  Future<int> updateAppointment(Appointment appointment) async {
    final db = await database;
    final store = _getStore('appointment');
    await store.record(appointment.appointmentid.toString()).put(db, appointment.toMap());
    return appointment.appointmentid!;
  }

  Future<int> deleteAppointment(int id) async {
    final db = await database;
    final store = _getStore('appointment');
    await store.record(id.toString()).delete(db);
    return id;
  }

  Future<List<Appointment>> getAppointmentsByUser(int userid) async {
    final appointments = await getAppointments();
    return appointments.where((appointment) => appointment.userid == userid).toList();
  }

  // CRUD methods for MedicalHistory
  Future<List<MedicalHistory>> getMedicalHistories() async {
    final db = await database;
    final store = _getStore('medicalhistory');
    final records = await store.find(db);
    return records.map((record) => MedicalHistory.fromMap(record.value)).toList();
  }

  Future<int> insertMedicalHistory(MedicalHistory history) async {
    final db = await database;
    final store = _getStore('medicalhistory');
    final key = await store.add(db, history.toMap());
    return int.parse(key);
  }

  Future<int> updateMedicalHistory(MedicalHistory history) async {
    final db = await database;
    final store = _getStore('medicalhistory');
    await store.record(history.historyid.toString()).put(db, history.toMap());
    return history.historyid!;
  }

  Future<int> deleteMedicalHistory(int id) async {
    final db = await database;
    final store = _getStore('medicalhistory');
    await store.record(id.toString()).delete(db);
    return id;
  }

  // CRUD methods for Product
  Future<List<Product>> getProducts() async {
    final db = await database;
    final store = _getStore('product');
    final records = await store.find(db);
    return records.map((record) => Product.fromMap(record.value)).toList();
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    final store = _getStore('product');
    final key = await store.add(db, product.toMap());
    return int.parse(key);
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    final store = _getStore('product');
    await store.record(product.productid.toString()).put(db, product.toMap());
    return product.productid!;
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    final store = _getStore('product');
    await store.record(id.toString()).delete(db);
    return id;
  }

  // CRUD methods for Sales
  Future<List<Sales>> getSales() async {
    final db = await database;
    final store = _getStore('sales');
    final records = await store.find(db);
    return records.map((record) => Sales.fromMap(record.value)).toList();
  }

  Future<int> insertSales(Sales sales) async {
    final db = await database;
    final store = _getStore('sales');
    final key = await store.add(db, sales.toMap());
    return int.parse(key);
  }

  Future<int> updateSales(Sales sales) async {
    final db = await database;
    final store = _getStore('sales');
    await store.record(sales.saleid.toString()).put(db, sales.toMap());
    return sales.saleid!;
  }

  Future<int> deleteSales(int id) async {
    final db = await database;
    final store = _getStore('sales');
    await store.record(id.toString()).delete(db);
    return id;
  }

  // CRUD methods for SaleItem
  Future<List<SaleItem>> getSaleItems() async {
    final db = await database;
    final store = _getStore('sale_item');
    final records = await store.find(db);
    return records.map((record) => SaleItem.fromMap(record.value)).toList();
  }

  Future<int> insertSaleItem(SaleItem item) async {
    final db = await database;
    final store = _getStore('sale_item');
    final key = await store.add(db, item.toMap());
    return int.parse(key);
  }

  Future<int> updateSaleItem(SaleItem item) async {
    final db = await database;
    final store = _getStore('sale_item');
    await store.record(item.salesitemid.toString()).put(db, item.toMap());
    return item.salesitemid!;
  }

  Future<int> deleteSaleItem(int id) async {
    final db = await database;
    final store = _getStore('sale_item');
    await store.record(id.toString()).delete(db);
    return id;
  }

  // CRUD methods for InventoryLog
  Future<List<InventoryLog>> getInventoryLogs() async {
    final db = await database;
    final store = _getStore('inventory_log');
    final records = await store.find(db);
    return records.map((record) => InventoryLog.fromMap(record.value)).toList();
  }

  Future<int> insertInventoryLog(InventoryLog log) async {
    final db = await database;
    final store = _getStore('inventory_log');
    final key = await store.add(db, log.toMap());
    return int.parse(key);
  }

  Future<int> updateInventoryLog(InventoryLog log) async {
    final db = await database;
    final store = _getStore('inventory_log');
    await store.record(log.inventoryLogId.toString()).put(db, log.toMap());
    return log.inventoryLogId!;
  }

  Future<int> deleteInventoryLog(int id) async {
    final db = await database;
    final store = _getStore('inventory_log');
    await store.record(id.toString()).delete(db);
    return id;
  }
}


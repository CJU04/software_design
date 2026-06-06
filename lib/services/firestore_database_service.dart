import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';
import '../models/pet.dart';
import '../models/appointment.dart';
import '../models/medical_history.dart';
import '../models/product.dart';
import '../models/sales.dart';
import '../models/sale_item.dart';
import '../models/inventory_log.dart';

/// Firestore-backed replacement for the previous SQLite `DatabaseService`.
///
/// Collections used (mapped 1:1 to your former table names):
/// - user
/// - pet
/// - appointment
/// - medical_history
/// - product
/// - sales
/// - sale_item
/// - inventory_log
class FirestoreDatabaseService {
  final FirebaseFirestore _db;

  FirestoreDatabaseService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String name) {
    return _db.collection(name);
  }

  // --------------------
  // User
  // --------------------
  Future<int> insertUser(User user) async {
    // Use userid as document id if available, otherwise auto-id.
    final data = user.toMap();
    final int? id = user.userid;

    if (id != null) {
      await _col('user').doc(id.toString()).set(data);
      return id;
    }

    final docRef = await _col('user').add(data);
    final parsed = int.tryParse(docRef.id);
    if (parsed != null) return parsed;
    return 0;
  }

  Future<List<User>> getUsers() async {
    final snap = await _col('user').get();
    return snap.docs.map((d) => User.fromMap(d.data())).toList();
  }

  Future<int> updateUser(User user) async {
    if (user.userid == null) {
      throw ArgumentError('updateUser requires user.userid');
    }

    await _col('user').doc(user.userid.toString()).set(user.toMap(), SetOptions(merge: true));
    return user.userid!;
  }

  Future<int> deleteUser(int id) async {
    await _col('user').doc(id.toString()).delete();
    return id;
  }

  Future<bool> isUsernameExists(String username) async {
    final q = await _col('user').where('username', isEqualTo: username).limit(1).get();
    return q.docs.isNotEmpty;
  }

  Future<bool> isEmailExists(String email) async {
    final q = await _col('user').where('email', isEqualTo: email).limit(1).get();
    return q.docs.isNotEmpty;
  }

  // --------------------
  // Pet
  // --------------------
  Future<int> insertPet(Pet pet) async {
    final data = pet.toMap();
    final int? id = pet.petid;

    if (id != null) {
      await _col('pet').doc(id.toString()).set(data);
      return id;
    }

    final docRef = await _col('pet').add(data);
    final parsed = int.tryParse(docRef.id);
    if (parsed != null) return parsed;
    return 0;
  }

  Future<List<Pet>> getPets() async {
    final snap = await _col('pet').get();
    return snap.docs.map((d) => Pet.fromMap(d.data())).toList();
  }

  Future<int> updatePet(Pet pet) async {
    if (pet.petid == null) {
      throw ArgumentError('updatePet requires pet.petid');
    }

    await _col('pet').doc(pet.petid.toString()).set(pet.toMap(), SetOptions(merge: true));
    return pet.petid!;
  }

  Future<int> deletePet(int id) async {
    await _col('pet').doc(id.toString()).delete();
    return id;
  }

  // --------------------
  // Appointment
  // --------------------
  Future<int> insertAppointment(Appointment appointment) async {
    final data = appointment.toMap();
    final int? id = appointment.appointmentid;

    if (id != null) {
      await _col('appointment').doc(id.toString()).set(data);
      return id;
    }

    final docRef = await _col('appointment').add(data);
    final parsed = int.tryParse(docRef.id);
    if (parsed != null) return parsed;
    return 0;
  }

  Future<List<Appointment>> getAppointments() async {
    final snap = await _col('appointment').get();
    return snap.docs.map((d) => Appointment.fromMap(d.data())).toList();
  }

  Future<List<Appointment>> getAppointmentsByUser(int userId) async {
    final q = await _col('appointment').where('userid', isEqualTo: userId).get();
    return q.docs.map((d) => Appointment.fromMap(d.data())).toList();
  }

  Future<int> updateAppointment(Appointment appointment) async {
    if (appointment.appointmentid == null) {
      throw ArgumentError('updateAppointment requires appointment.appointmentid');
    }

    await _col('appointment').doc(appointment.appointmentid.toString()).set(
          appointment.toMap(),
          SetOptions(merge: true),
        );
    return appointment.appointmentid!;
  }

  Future<int> deleteAppointment(int id) async {
    await _col('appointment').doc(id.toString()).delete();
    return id;
  }

  // --------------------
  // MedicalHistory
  // --------------------
  Future<int> insertMedicalHistory(MedicalHistory history) async {
    final data = history.toMap();
    final int? id = history.historyid;

    if (id != null) {
      await _col('medical_history').doc(id.toString()).set(data);
      return id;
    }

    final docRef = await _col('medical_history').add(data);
    final parsed = int.tryParse(docRef.id);
    if (parsed != null) return parsed;
    return 0;
  }

  Future<List<MedicalHistory>> getMedicalHistories() async {
    final snap = await _col('medical_history').get();
    return snap.docs.map((d) => MedicalHistory.fromMap(d.data())).toList();
  }

  Future<int> updateMedicalHistory(MedicalHistory medicalHistory) async {
    if (medicalHistory.historyid == null) {
      throw ArgumentError('updateMedicalHistory requires historyid');
    }

    await _col('medical_history')
        .doc(medicalHistory.historyid.toString())
        .set(medicalHistory.toMap(), SetOptions(merge: true));
    return medicalHistory.historyid!;
  }

  Future<int> deleteMedicalHistory(int id) async {
    await _col('medical_history').doc(id.toString()).delete();
    return id;
  }

  // --------------------
  // Product
  // --------------------
  Future<int> insertProduct(Product product) async {
    final data = product.toMap();
    final int? id = product.productid;

    if (id != null) {
      await _col('product').doc(id.toString()).set(data);
      return id;
    }

    final docRef = await _col('product').add(data);
    final parsed = int.tryParse(docRef.id);
    if (parsed != null) return parsed;
    return 0;
  }

  Future<List<Product>> getProducts() async {
    final snap = await _col('product').get();
    return snap.docs.map((d) => Product.fromMap(d.data())).toList();
  }

  Future<int> updateProduct(Product product) async {
    if (product.productid == null) {
      throw ArgumentError('updateProduct requires product.productid');
    }

    await _col('product').doc(product.productid.toString()).set(product.toMap(), SetOptions(merge: true));
    return product.productid!;
  }

  Future<int> deleteProduct(int id) async {
    await _col('product').doc(id.toString()).delete();
    return id;
  }

  // --------------------
  // Sales
  // --------------------
  Future<int> insertSales(Sales sales) async {
    final data = sales.toMap();
    final int? id = sales.saleid;

    if (id != null) {
      await _col('sales').doc(id.toString()).set(data);
      return id;
    }

    final docRef = await _col('sales').add(data);
    final parsed = int.tryParse(docRef.id);
    if (parsed != null) return parsed;
    return 0;
  }

  Future<List<Sales>> getSales() async {
    final snap = await _col('sales').get();
    return snap.docs.map((d) => Sales.fromMap(d.data())).toList();
  }

  Future<int> updateSales(Sales sales) async {
    if (sales.saleid == null) {
      throw ArgumentError('updateSales requires sales.saleid');
    }

    await _col('sales').doc(sales.saleid.toString()).set(sales.toMap(), SetOptions(merge: true));
    return sales.saleid!;
  }

  Future<int> deleteSales(int id) async {
    await _col('sales').doc(id.toString()).delete();
    return id;
  }

  // --------------------
  // SaleItem
  // --------------------
  Future<int> insertSaleItem(SaleItem saleItem) async {
    final data = saleItem.toMap();
    final int? id = saleItem.salesitemid;

    if (id != null) {
      await _col('sale_item').doc(id.toString()).set(data);
      return id;
    }

    final docRef = await _col('sale_item').add(data);
    final parsed = int.tryParse(docRef.id);
    if (parsed != null) return parsed;
    return 0;
  }

  Future<List<SaleItem>> getSaleItems() async {
    final snap = await _col('sale_item').get();
    return snap.docs.map((d) => SaleItem.fromMap(d.data())).toList();
  }

  Future<int> updateSaleItem(SaleItem saleItem) async {
    if (saleItem.salesitemid == null) {
      throw ArgumentError('updateSaleItem requires saleItem.salesitemid');
    }

    await _col('sale_item')
        .doc(saleItem.salesitemid.toString())
        .set(saleItem.toMap(), SetOptions(merge: true));
    return saleItem.salesitemid!;
  }

  Future<int> deleteSaleItem(int id) async {
    await _col('sale_item').doc(id.toString()).delete();
    return id;
  }

  // --------------------
  // InventoryLog
  // --------------------
  Future<int> insertInventoryLog(InventoryLog inventoryLog) async {
    final data = inventoryLog.toMap();
    final int? id = inventoryLog.inventoryLogId;

    if (id != null) {
      await _col('inventory_log').doc(id.toString()).set(data);
      return id;
    }

    final docRef = await _col('inventory_log').add(data);
    final parsed = int.tryParse(docRef.id);
    if (parsed != null) return parsed;
    return 0;
  }

  Future<List<InventoryLog>> getInventoryLogs() async {
    final snap = await _col('inventory_log').get();
    return snap.docs.map((d) => InventoryLog.fromMap(d.data())).toList();
  }

  Future<int> updateInventoryLog(InventoryLog inventoryLog) async {
    if (inventoryLog.inventoryLogId == null) {
      throw ArgumentError('updateInventoryLog requires inventoryLogId');
    }

    await _col('inventory_log')
        .doc(inventoryLog.inventoryLogId.toString())
        .set(inventoryLog.toMap(), SetOptions(merge: true));
    return inventoryLog.inventoryLogId!;
  }

  Future<int> deleteInventoryLog(int id) async {
    await _col('inventory_log').doc(id.toString()).delete();
    return id;
  }
}



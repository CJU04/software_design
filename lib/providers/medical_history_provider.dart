import 'package:flutter/material.dart';
import 'package:vetcare_connect/models/medical_history.dart';
import 'package:vetcare_connect/services/database_service.dart';

class MedicalHistoryProvider with ChangeNotifier {
  List<MedicalHistory> _medicalHistories = [];

  List<MedicalHistory> get medicalHistories => _medicalHistories;

  Future<void> loadMedicalHistories() async {
    _medicalHistories = await DatabaseService().getMedicalHistories();
    notifyListeners();
  }

  Future<void> loadMedicalHistoriesForOwner(String ownerUid) async {
    final pets = await DatabaseService().getPetsByOwner(ownerUid);
    final petIds = pets.map((p) => p.petId).toSet();
    _medicalHistories = await DatabaseService().getMedicalHistories();
    _medicalHistories = _medicalHistories.where((h) => petIds.contains(h.petId)).toList();
    notifyListeners();
  }

  Future<String> addMedicalHistory(MedicalHistory history) async {
    final id = await DatabaseService().insertMedicalHistory(history);
    await loadMedicalHistories();
    return id;
  }

  Future<void> updateMedicalHistory(MedicalHistory history) async {
    await DatabaseService().updateMedicalHistory(history);
    await loadMedicalHistories();
  }

  Future<void> deleteMedicalHistory(String id) async {
    await DatabaseService().deleteMedicalHistory(id);
    await loadMedicalHistories();
  }

  List<MedicalHistory> getMedicalHistoriesByPet(String petId) {
    return _medicalHistories.where((h) => h.petId == petId).toList();
  }
}

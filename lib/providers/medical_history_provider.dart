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

  Future<void> loadMedicalHistoriesForUser(int userid) async {
    _medicalHistories = await DatabaseService().getMedicalHistories();
    // Filter medical histories where the pet belongs to the user
    List<int> userPetIds = (await DatabaseService().getPets()).where((pet) => pet.userid == userid).map((pet) => pet.petid!).toList();
    _medicalHistories = _medicalHistories.where((history) => userPetIds.contains(history.petid)).toList();
    notifyListeners();
  }

  Future<void> addMedicalHistory(MedicalHistory history) async {
    await DatabaseService().insertMedicalHistory(history);
    await loadMedicalHistories();
  }

  Future<void> updateMedicalHistory(MedicalHistory history) async {
    await DatabaseService().updateMedicalHistory(history);
    await loadMedicalHistories();
  }

  Future<void> deleteMedicalHistory(int id) async {
    await DatabaseService().deleteMedicalHistory(id);
    await loadMedicalHistories();
  }

  List<MedicalHistory> getMedicalHistoriesByPet(int petid) {
    return _medicalHistories.where((history) => history.petid == petid).toList();
  }

  List<MedicalHistory> getMedicalHistoriesByAppointment(int appointmentid) {
    return _medicalHistories.where((history) => history.appointmentid == appointmentid).toList();
  }
}


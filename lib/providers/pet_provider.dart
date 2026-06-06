import 'package:flutter/material.dart';
import 'package:vetcare_connect/models/pet.dart';
import 'package:vetcare_connect/services/database_service.dart';

class PetProvider with ChangeNotifier {
  List<Pet> _pets = [];

  List<Pet> get pets => _pets;

  Future<void> loadPets() async {
    _pets = await DatabaseService().getPets();
    notifyListeners();
  }

  Future<void> loadPetsForUser(int userid) async {
    _pets = await DatabaseService().getPets();
    _pets = _pets.where((pet) => pet.userid == userid).toList();
    notifyListeners();
  }

  Future<void> addPet(Pet pet) async {
    await DatabaseService().insertPet(pet);
    await loadPets();
  }

  Future<void> updatePet(Pet pet) async {
    await DatabaseService().updatePet(pet);
    await loadPets();
  }

  Future<void> deletePet(int id) async {
    await DatabaseService().deletePet(id);
    await loadPets();
  }

  List<Pet> getPetsByUser(int userid) {
    return _pets.where((pet) => pet.userid == userid).toList();
  }
}


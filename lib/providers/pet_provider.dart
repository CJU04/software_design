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

  Future<void> loadPetsForOwner(String ownerUid) async {
    _pets = await DatabaseService().getPetsByOwner(ownerUid);
    notifyListeners();
  }

  Future<String> addPet(Pet pet) async {
    final id = await DatabaseService().insertPet(pet);
    await loadPets();
    return id;
  }

  Future<void> updatePet(Pet pet) async {
    await DatabaseService().updatePet(pet);
    await loadPets();
  }

  Future<void> deletePet(String id) async {
    await DatabaseService().deletePet(id);
    await loadPets();
  }

  List<Pet> getPetsByOwner(String ownerUid) {
    return _pets.where((pet) => pet.ownerUid == ownerUid).toList();
  }
}

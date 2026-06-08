import 'package:flutter/material.dart';
import 'package:vetcare_connect/models/appointment.dart';
import 'package:vetcare_connect/services/database_service.dart';

class AppointmentProvider with ChangeNotifier {
  List<Appointment> _appointments = [];

  List<Appointment> get appointments => _appointments;

  Future<void> loadAppointments() async {
    _appointments = await DatabaseService().getAppointments();
    notifyListeners();
  }

  Future<String> addAppointment(Appointment appointment) async {
    final id = await DatabaseService().insertAppointment(appointment);
    await loadAppointments();
    return id;
  }

  Future<void> updateAppointment(Appointment appointment) async {
    await DatabaseService().updateAppointment(appointment);
    await loadAppointments();
  }

  Future<void> deleteAppointment(String id) async {
    await DatabaseService().deleteAppointment(id);
    await loadAppointments();
  }

  Future<void> loadAppointmentsForOwner(String ownerUid) async {
    _appointments = await DatabaseService().getAppointmentsByOwner(ownerUid);
    notifyListeners();
  }

  List<Appointment> getAppointmentsByOwner(String ownerUid) {
    return _appointments.where((a) => a.ownerUid == ownerUid).toList();
  }

  List<Appointment> getAppointmentsByPet(String petId) {
    return _appointments.where((a) => a.petId == petId).toList();
  }
}

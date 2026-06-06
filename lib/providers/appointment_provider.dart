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

  Future<int> addAppointment(Appointment appointment) async {
    int id = await DatabaseService().insertAppointment(appointment);
    await loadAppointments();
    return id;
  }

  Future<void> updateAppointment(Appointment appointment) async {
    await DatabaseService().updateAppointment(appointment);
    await loadAppointments();
  }

  Future<void> deleteAppointment(int id) async {
    await DatabaseService().deleteAppointment(id);
    await loadAppointments();
  }

  Future<void> loadAppointmentsForUser(int userid) async {
    _appointments = await DatabaseService().getAppointmentsByUser(userid);
    notifyListeners();
  }

  List<Appointment> getAppointmentsByUser(int userid) {
    return _appointments.where((appointment) => appointment.userid == userid).toList();
  }

  List<Appointment> getAppointmentsByPet(int petid) {
    return _appointments.where((appointment) => appointment.petid == petid).toList();
  }
}


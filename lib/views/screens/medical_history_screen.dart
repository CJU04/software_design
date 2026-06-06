import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetcare_connect/models/medical_history.dart';
import 'package:vetcare_connect/models/pet.dart';
import 'package:vetcare_connect/models/appointment.dart';
import 'package:vetcare_connect/providers/medical_history_provider.dart';
import 'package:vetcare_connect/providers/user_provider.dart';
import 'package:vetcare_connect/providers/pet_provider.dart';
import 'package:vetcare_connect/providers/appointment_provider.dart';
import 'package:vetcare_connect/views/widgets/drawer_widget.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Provider.of<MedicalHistoryProvider>(context, listen: false).loadMedicalHistories();
  }

  @override
  Widget build(BuildContext context) {
    final medicalHistoryProvider = Provider.of<MedicalHistoryProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;
    final isCustomer = currentUser?.usertype == 'customer';

    List<MedicalHistory> medicalHistories = medicalHistoryProvider.medicalHistories;

    // Filter medical histories based on user role
    if (isCustomer) {
      // For customers, filter by pets they own
      final petProvider = Provider.of<PetProvider>(context);
      final customerPetIds = petProvider.pets.where((pet) => pet.userid == currentUser!.userid).map((pet) => pet.petid).toList();
      medicalHistories = medicalHistories.where((history) => customerPetIds.contains(history.petid)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      medicalHistories = medicalHistories.where((history) => history.diagnosis.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical History'),
      ),
      drawer: const AppDrawer(currentRoute: '/medical_history'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Medical History',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: medicalHistories.isEmpty
                ? const Center(
                    child: Text('No medical history found'),
                  )
                : ListView.builder(
                    itemCount: medicalHistories.length,
                    itemBuilder: (context, index) {
                      final history = medicalHistories[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          leading: const Icon(Icons.medical_services),
                          title: Text(history.diagnosis),
                          subtitle: Text('${history.date} - ${history.treatment}'),
                          trailing: isCustomer ? null : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editMedicalHistory(history),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteMedicalHistory(history),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMedicalHistory,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addMedicalHistory() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final dateController = TextEditingController();
    final diagnosisController = TextEditingController();
    final treatmentController = TextEditingController();
    final notesController = TextEditingController();

    int? selectedPetId;
    int? selectedAppointmentId;

    List<Pet> availablePets = petProvider.pets;
    List<Appointment> availableAppointments = appointmentProvider.appointments;

    // Filter pets and appointments based on user role
    if (currentUser.usertype == 'customer') {
      availablePets = availablePets.where((pet) => pet.userid == currentUser.userid).toList();
      availableAppointments = availableAppointments.where((appointment) => appointment.userid == currentUser.userid).toList();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Medical History'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: selectedPetId,
                    decoration: const InputDecoration(labelText: 'Select Pet'),
                    items: availablePets.map((pet) {
                      return DropdownMenuItem<int>(
                        value: pet.petid,
                        child: Text('${pet.name} (${pet.type})', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPetId = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: selectedAppointmentId,
                    decoration: const InputDecoration(labelText: 'Select Appointment'),
                    items: availableAppointments.map((appointment) {
                      return DropdownMenuItem<int>(
                        value: appointment.appointmentid,
                        child: Text('${appointment.date} - ${appointment.reason}', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedAppointmentId = value;
                      });
                    },
                  ),
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                ),
                TextField(
                  controller: diagnosisController,
                  decoration: const InputDecoration(labelText: 'Diagnosis'),
                  maxLines: 2,
                ),
                TextField(
                  controller: treatmentController,
                  decoration: const InputDecoration(labelText: 'Treatment'),
                  maxLines: 3,
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Additional Notes'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedPetId != null && selectedAppointmentId != null) {
                  final newHistory = MedicalHistory(
                    historyid: null,
                    petid: selectedPetId!,
                    appointmentid: selectedAppointmentId!,
                    date: dateController.text,
                    diagnosis: diagnosisController.text,
                    treatment: treatmentController.text,
                    notes: notesController.text,
                  );
                  Provider.of<MedicalHistoryProvider>(context, listen: false).addMedicalHistory(newHistory);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a pet and appointment')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _editMedicalHistory(MedicalHistory history) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final dateController = TextEditingController(text: history.date);
    final diagnosisController = TextEditingController(text: history.diagnosis);
    final treatmentController = TextEditingController(text: history.treatment);
    final notesController = TextEditingController(text: history.notes);

    int? selectedPetId = history.petid;
    int? selectedAppointmentId = history.appointmentid;

    List<Pet> availablePets = petProvider.pets;
    List<Appointment> availableAppointments = appointmentProvider.appointments;

    // Filter pets and appointments based on user role
    if (currentUser.usertype == 'customer') {
      availablePets = availablePets.where((pet) => pet.userid == currentUser.userid).toList();
      availableAppointments = availableAppointments.where((appointment) => appointment.userid == currentUser.userid).toList();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Medical History'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: selectedPetId,
                    decoration: const InputDecoration(labelText: 'Select Pet'),
                    items: availablePets.map((pet) {
                      return DropdownMenuItem<int>(
                        value: pet.petid,
                        child: Text('${pet.name} (${pet.type})', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPetId = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: selectedAppointmentId,
                    decoration: const InputDecoration(labelText: 'Select Appointment'),
                    items: availableAppointments.map((appointment) {
                      return DropdownMenuItem<int>(
                        value: appointment.appointmentid,
                        child: Text('${appointment.date} - ${appointment.reason}', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedAppointmentId = value;
                      });
                    },
                  ),
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                ),
                TextField(
                  controller: diagnosisController,
                  decoration: const InputDecoration(labelText: 'Diagnosis'),
                  maxLines: 2,
                ),
                TextField(
                  controller: treatmentController,
                  decoration: const InputDecoration(labelText: 'Treatment'),
                  maxLines: 3,
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Additional Notes'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedPetId != null && selectedAppointmentId != null) {
                  final updatedHistory = MedicalHistory(
                    historyid: history.historyid,
                    petid: selectedPetId!,
                    appointmentid: selectedAppointmentId!,
                    date: dateController.text,
                    diagnosis: diagnosisController.text,
                    treatment: treatmentController.text,
                    notes: notesController.text,
                  );
                  Provider.of<MedicalHistoryProvider>(context, listen: false).updateMedicalHistory(updatedHistory);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a pet and appointment')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMedicalHistory(MedicalHistory history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medical History'),
        content: Text('Are you sure you want to delete ${history.diagnosis}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<MedicalHistoryProvider>(context, listen: false).deleteMedicalHistory(history.historyid!);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}


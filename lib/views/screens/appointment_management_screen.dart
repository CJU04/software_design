import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:vetcare_connect/config/theme/app_theme.dart';
import 'package:vetcare_connect/models/appointment.dart';
import 'package:vetcare_connect/models/medical_history.dart';
import 'package:vetcare_connect/models/pet.dart';
import 'package:vetcare_connect/providers/appointment_provider.dart';
import 'package:vetcare_connect/providers/auth_provider.dart';
import 'package:vetcare_connect/providers/medical_history_provider.dart';
import 'package:vetcare_connect/providers/pet_provider.dart';
import 'package:vetcare_connect/views/widgets/drawer_widget.dart';

class AppointmentManagementScreen extends StatefulWidget {
  const AppointmentManagementScreen({super.key});

  @override
  State<AppointmentManagementScreen> createState() => _AppointmentManagementScreenState();
}

class _AppointmentManagementScreenState extends State<AppointmentManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentProvider>(context, listen: false).loadAppointments();
      Provider.of<PetProvider>(context, listen: false).loadPets();
      Provider.of<MedicalHistoryProvider>(context, listen: false).loadMedicalHistories();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final uid = authProvider.firebaseUser?.uid;

    final role = authProvider.role?.value;
    final appointmentProvider = context.watch<AppointmentProvider>();
    final petProvider = context.watch<PetProvider>();
    final medicalHistoryProvider = context.watch<MedicalHistoryProvider>();

    List<Appointment> appointments = appointmentProvider.appointments;

    // Filter based on role:
    // - customer: only their appointments (ownerUid == current uid)
    // - staff/veterinarian: you might want to show assigned or all; keep it broad but consistent:
    if (role == 'customer' && uid != null) {
      appointments = appointments.where((a) => a.ownerUid == uid).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      appointments = appointments
          .where((a) => a.reason.toLowerCase().contains(q) || a.status.toLowerCase().contains(q))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Management'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(currentRoute: '/appointment_management'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search by reason/status...',
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final a = appointments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(a.reason),
                    subtitle: Text('Date: ${a.date}\nTime: ${a.time}\nStatus: ${a.status}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showAppointmentDialog(
                              appointment: a,
                              appointmentProvider: appointmentProvider,
                              petProvider: petProvider,
                              medicalHistoryProvider: medicalHistoryProvider,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAppointment(a, appointmentProvider),
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
        onPressed: () {
          if (uid == null) return;
          _showAppointmentDialog(
            appointment: null,
            appointmentProvider: appointmentProvider,
            petProvider: petProvider,
            medicalHistoryProvider: medicalHistoryProvider,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPetAge(Pet? pet) {
    if (pet == null) return '-';
    return '${pet.age} years';
  }

  void _showAppointmentDialog({
    required AppointmentProvider appointmentProvider,
    required PetProvider petProvider,
    required MedicalHistoryProvider medicalHistoryProvider,
    Appointment? appointment,
  }) {
    // NOTE: appointment.appointmentId MUST be non-null for edit/delete.
    // This screen previously created new Appointment instances without ensuring that
    // editing/deleting uses the appointmentId returned by the database.

    final formKey = GlobalKey<FormState>();
    final authProvider = context.read<AuthProvider>();
    final uid = authProvider.firebaseUser?.uid;

    if (uid == null) return;

    final role = authProvider.role?.value;

    final reasonController = TextEditingController(text: appointment?.reason ?? '');
    final dateController = TextEditingController(text: appointment?.date ?? '');
    final timeController = TextEditingController(text: appointment?.time ?? '');
    final petNameController = TextEditingController();
    final petDescriptionController = TextEditingController();
    final medicalHistoryController = TextEditingController();

    // For this simplified screen:
    // - customer books for their own pets => ownerUid == uid
    // - pet selection is based on ownerUid
    final String ownerUid = appointment?.ownerUid ?? uid;

    List<Pet> availablePets = petProvider.pets.where((p) => p.ownerUid == ownerUid).toList();

    Pet? selectedPet;
    if (appointment != null) {
      selectedPet = availablePets.where((p) => p.petId == appointment.petId).isNotEmpty
          ? availablePets.firstWhere((p) => p.petId == appointment.petId)
          : null;

      if (selectedPet != null) {
        petNameController.text = selectedPet.name;
      }
    }

    String status = appointment?.status ?? 'scheduled';
    String? assignedUserId = appointment?.assignedUserId;

    List<MedicalHistory> selectedPetHistories = [];

    void populatePetDetails(Pet? pet) {
      if (pet == null) {
        petDescriptionController.clear();
        medicalHistoryController.clear();
        selectedPetHistories = [];
        return;
      }

      // Build readable pet info - each field on its own line for clarity
      petDescriptionController.text = 'Type: ${pet.type}\n'
          'Breed: ${pet.breed}\n'
          'Age: ${pet.age} years\n'
          'Gender: ${pet.gender}\n'
          'Vaccination Status: ${pet.vaccinationStatus}\n'
          'Health Notes: ${pet.healthNotes}';

      selectedPetHistories = medicalHistoryProvider.medicalHistories
          .where((h) => h.petId == pet.petId)
          .toList();

      if (selectedPetHistories.isNotEmpty) {
        medicalHistoryController.text = selectedPetHistories
            .map((h) =>
                'Date: ${h.date}\nDiagnosis: ${h.diagnosis}\nTreatment: ${h.treatment}\nNotes: ${h.notes}')
            .join('\n\n');
      } else {
        medicalHistoryController.text = 'No medical history available';
      }
    }

    populatePetDetails(selectedPet);

    // If no pets available for new appointment, show message and abort
    if (availablePets.isEmpty && appointment == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No pets found. Please add a pet first in Pet Management.'),
            backgroundColor: Colors.orange,
          ),
        );
      });
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(appointment == null ? 'Book Appointment' : 'Edit Appointment'),
              content: SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      // Prevent dialog content from forcing an overflow when screen is short.
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: DropdownButtonFormField<Pet>(
                              decoration: const InputDecoration(
                                labelText: 'Select Pet',
                                border: OutlineInputBorder(),
                              ),
                              value: selectedPet,
                              isExpanded: true,
                              items: availablePets.map((pet) {
                                return DropdownMenuItem<Pet>(
                                  value: pet,
                                  child: Text(pet.name),
                                );
                              }).toList(),
                              onChanged: (Pet? pet) {
                                setState(() {
                                  selectedPet = pet;
                                  if (pet != null) {
                                    petNameController.text = pet.name;
                                  }
                                  populatePetDetails(pet);
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a pet';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          color: Colors.grey.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pet Information',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildReadOnlyField('Type', selectedPet?.type ?? '-'),
                                _buildReadOnlyField('Breed', selectedPet?.breed ?? '-'),
                                _buildReadOnlyField('Age', _getPetAge(selectedPet)),
                                _buildReadOnlyField('Gender', selectedPet?.gender ?? '-'),
                                _buildReadOnlyField('Vaccination Status', selectedPet?.vaccinationStatus ?? '-'),
                                _buildReadOnlyField('Health Notes', selectedPet?.healthNotes ?? '-'),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextFormField(
                              controller: medicalHistoryController,
                              decoration: const InputDecoration(
                                labelText: 'Medical History',
                                border: OutlineInputBorder(),
                              ),
                              minLines: 3,
                              maxLines: 3,
                              enabled: false,
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) {
                                  dateController.text = DateFormat('yyyy-MM-dd').format(date);
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: const Icon(Icons.calendar_today),
                                  errorText: dateController.text.isEmpty && formKey.currentState!.validate() == false && reasonController.text.isNotEmpty
                                      ? null
                                      : null,
                                ),
                                child: Text(
                                  dateController.text.isEmpty ? 'Select Date' : dateController.text,
                                  style: TextStyle(
                                    color: dateController.text.isEmpty ? Colors.grey : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (time != null) {
                                  timeController.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Time',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.access_time),
                                ),
                                child: Text(
                                  timeController.text.isEmpty ? 'Select Time' : timeController.text,
                                  style: TextStyle(
                                    color: timeController.text.isEmpty ? Colors.grey : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextFormField(
                              controller: reasonController,
                              decoration: const InputDecoration(
                                labelText: 'Reason',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please describe the reason for your visit';
                                }
                                if (value.trim().length < 3) {
                                  return 'Reason must be at least 3 characters long';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),

                        // Only allow updating status for non-customers (optional)
                        if (role != 'customer' || appointment != null)
                          Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                  border: OutlineInputBorder(),
                                ),
                                value: status,
                                items: const [
                                  DropdownMenuItem(value: 'scheduled', child: Text('Scheduled')),
                                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                                  DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                                ],
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() {
                                    status = v;
                                  });
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    // Validate date and time are selected
                    if (dateController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a date for the appointment.')),
                      );
                      return;
                    }
                    if (timeController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a time for the appointment.')),
                      );
                      return;
                    }

                    final navigator = Navigator.of(context);

                    if (selectedPet == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a pet from the dropdown list above to continue.')),
                      );
                      return;
                    }

                    final newAppointment = Appointment(
                      appointmentId: appointment?.appointmentId,
                      petId: selectedPet!.petId!,
                      ownerUid: ownerUid,
                      assignedUserId: assignedUserId,
                      date: dateController.text.trim(),
                      time: timeController.text.trim(),
                      reason: reasonController.text.trim(),
                      status: status,
                    );

                    if (appointment == null) {
                      navigator.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Booking appointment...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      try {
                        await appointmentProvider.addAppointment(newAppointment);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Appointment booked successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to book appointment'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                      return;
                    } else {
                      navigator.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Updating appointment...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      try {
                        await appointmentProvider.updateAppointment(newAppointment);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Appointment updated successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to update appointment'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                      return;
                    }
                  },
                  child: Text(appointment == null ? 'Book' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteAppointment(Appointment appointment, AppointmentProvider appointmentProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: Text('Are you sure you want to delete "${appointment.reason}" on ${appointment.date}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Deleting appointment...'),
                  duration: Duration(seconds: 1),
                ),
              );
              try {
                await appointmentProvider.deleteAppointment(appointment.appointmentId!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Appointment deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete appointment. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

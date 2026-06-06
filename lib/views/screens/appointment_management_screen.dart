import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetcare_connect/models/appointment.dart';
import 'package:vetcare_connect/models/pet.dart';
import 'package:vetcare_connect/models/medical_history.dart';
import 'package:vetcare_connect/providers/appointment_provider.dart';
import 'package:vetcare_connect/providers/pet_provider.dart';
import 'package:vetcare_connect/providers/user_provider.dart';
import 'package:vetcare_connect/providers/medical_history_provider.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;
    final isCustomer = currentUser?.usertype == 'customer';

    List<Appointment> appointments = appointmentProvider.appointments;

    // Filter appointments based on user type
    if (isCustomer) {
      appointments = appointments.where((appointment) => appointment.userid == currentUser!.userid).toList();
    } else if (currentUser?.usertype == 'staff' || currentUser?.usertype == 'veterinarian') {
      appointments = appointments.where((appointment) => appointment.assignedUserId == currentUser!.userid || appointment.assignedUserId == null).toList();
    }

    if (_searchQuery.isNotEmpty) {
      appointments = appointments.where((appointment) => appointment.reason.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Management'),
      ),
      drawer: const AppDrawer(currentRoute: '/appointment_management'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Appointments',
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
            child: appointments.isEmpty
                ? const Center(
                    child: Text('No appointments found'),
                  )
                : ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: ExpansionTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(appointment.reason, overflow: TextOverflow.ellipsis),
                          subtitle: Text('${appointment.date} at ${appointment.time} - Status: ${appointment.status}', overflow: TextOverflow.ellipsis),
                          trailing: isCustomer ? null : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editAppointment(appointment),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteAppointment(appointment),
                              ),
                            ],
                          ),
                          children: [
                            FutureBuilder<List<MedicalHistory>>(
                              future: Provider.of<MedicalHistoryProvider>(context, listen: false).loadMedicalHistories().then((_) =>
                                Provider.of<MedicalHistoryProvider>(context, listen: false).medicalHistories
                                  .where((history) => history.appointmentid == appointment.appointmentid)
                                  .toList()
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }

                                final medicalHistories = snapshot.data ?? [];
                                final petProvider = Provider.of<PetProvider>(context);
                                final pet = petProvider.pets.firstWhere(
                                  (p) => p.petid == appointment.petid,
                                  orElse: () => Pet(petid: null, userid: 0, name: 'Unknown', type: '', breed: '', age: 0, gender: '', vaccinationStatus: '', healthNotes: ''),
                                );

                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Pet Information:', style: Theme.of(context).textTheme.titleSmall),
                                      const SizedBox(height: 4),
                                      Text('Name: ${pet.name}', overflow: TextOverflow.ellipsis),
                                      Text('Type: ${pet.type}', overflow: TextOverflow.ellipsis),
                                      Text('Breed: ${pet.breed}', overflow: TextOverflow.ellipsis),
                                      Text('Age: ${pet.age}', overflow: TextOverflow.ellipsis),
                                      Text('Gender: ${pet.gender}', overflow: TextOverflow.ellipsis),
                                      Text('Vaccination Status: ${pet.vaccinationStatus}', overflow: TextOverflow.ellipsis),
                                      Text('Health Notes: ${pet.healthNotes}', overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 16),
                                      Text('Medical History:', style: Theme.of(context).textTheme.titleSmall),
                                      const SizedBox(height: 4),
                                      if (medicalHistories.isEmpty)
                                        const Text('No medical history available')
                                      else
                                        ...medicalHistories.map((history) => Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Date: ${history.date}', overflow: TextOverflow.ellipsis),
                                            Text('Diagnosis: ${history.diagnosis}', overflow: TextOverflow.ellipsis),
                                            Text('Treatment: ${history.treatment}', overflow: TextOverflow.ellipsis),
                                            Text('Notes: ${history.notes}', overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 8),
                                          ],
                                        )),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAppointment,
        child: const Icon(Icons.add),
      ),
  );
  }

  void _addAppointment() {
    _showAppointmentDialog();
  }

  void _editAppointment(Appointment appointment) {
    _showAppointmentDialog(appointment: appointment);
  }

  void _deleteAppointment(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: Text('Are you sure you want to delete ${appointment.reason}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AppointmentProvider>(context, listen: false).deleteAppointment(appointment.appointmentid!);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDialog({Appointment? appointment}) {
    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController(text: appointment?.reason ?? '');
    final dateController = TextEditingController(text: appointment?.date ?? '');
    final timeController = TextEditingController(text: appointment?.time ?? '');
    final petNameController = TextEditingController();
    final petDescriptionController = TextEditingController();
    final medicalHistoryController = TextEditingController();
    String status = appointment?.status ?? 'scheduled';
    int? assignedUserId = appointment?.assignedUserId;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final medicalHistoryProvider = Provider.of<MedicalHistoryProvider>(context, listen: false);

    // Load medical histories if not already loaded
    medicalHistoryProvider.loadMedicalHistories();

    final currentUser = userProvider.currentUser;
    final isCustomer = currentUser?.usertype == 'customer';
    int selectedUserId = appointment?.userid ?? currentUser?.userid ?? 0;

    // Ensure selectedUserId is a valid customer ID for the dropdown
    if (!isCustomer && appointment == null) {
      // For staff adding new appointment, default to first customer or null
      final customers = userProvider.users.where((user) => user.usertype == 'customer').toList();
      selectedUserId = customers.isNotEmpty ? customers.first.userid! : 0;
    }

    // Filter pets for selected user
    List<Pet> availablePets = petProvider.pets.where((pet) => pet.userid == selectedUserId).toList();

    // Pre-select pet for editing
    Pet? selectedPet;
    if (appointment != null) {
      for (var pet in availablePets) {
        if (pet.petid == appointment.petid) {
          selectedPet = pet;
          petNameController.text = selectedPet.name;
          break;
        }
      }
    }

    // Function to populate pet description and medical history
    void populatePetDetails(Pet? pet) {
      if (pet != null) {
        petDescriptionController.text = 'Type: ${pet.type}\nBreed: ${pet.breed}\nAge: ${pet.age}\nGender: ${pet.gender}\nVaccination Status: ${pet.vaccinationStatus}\nHealth Notes: ${pet.healthNotes}';

        // Load medical history for the pet
        List<MedicalHistory> medicalHistories = medicalHistoryProvider.medicalHistories
            .where((history) => history.petid == pet.petid)
            .toList();

        if (medicalHistories.isNotEmpty) {
          String medicalHistoryText = medicalHistories.map((history) =>
            'Date: ${history.date}\nDiagnosis: ${history.diagnosis}\nTreatment: ${history.treatment}\nNotes: ${history.notes}'
          ).join('\n\n');
          medicalHistoryController.text = medicalHistoryText;
        } else {
          medicalHistoryController.text = 'No medical history available';
        }
      } else {
        petDescriptionController.clear();
        medicalHistoryController.clear();
      }
    }

    // Populate details if editing an existing appointment
    if (selectedPet != null) {
      populatePetDetails(selectedPet);
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(appointment == null ? 'Book Appointment' : 'Edit Appointment'),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    if (!isCustomer) ...[
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: DropdownButtonFormField<int>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Select Customer',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: selectedUserId,
                            items: userProvider.users
                                .where((user) => user.usertype == 'customer')
                                .map((user) => DropdownMenuItem<int>(
                                      value: user.userid,
                                      child: Text(user.fullname),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedUserId = value!;
                                availablePets = petProvider.pets.where((pet) => pet.userid == selectedUserId).toList();
                                selectedPet = null;
                                petNameController.clear();
                                populatePetDetails(null);
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a customer';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                    // Allow entering pet name for both customers and staff
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextFormField(
                          controller: petNameController,
                          decoration: const InputDecoration(
                            labelText: 'Pet Name',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            // Find pet by name in available pets
                            try {
                              selectedPet = availablePets.firstWhere(
                                (pet) => pet.name.toLowerCase() == value.toLowerCase(),
                              );
                            } catch (e) {
                              // If pet not found, create a temporary pet object for booking
                              selectedPet = Pet(petid: null, userid: selectedUserId, name: value, type: '', breed: '', age: 0, gender: '', vaccinationStatus: '', healthNotes: '');
                            }
                            setState(() {
                              populatePetDetails(selectedPet);
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your pet name';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextFormField(
                          controller: petDescriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Pet Information',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            // Optional for new pets
                            return null;
                          },
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
                          maxLines: 3,
                          validator: (value) {
                            // Optional for new pets
                            return null;
                          },
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextFormField(
                          controller: dateController,
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            hintText: 'YYYY-MM-DD',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a date';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextFormField(
                          controller: timeController,
                          decoration: const InputDecoration(
                            labelText: 'Time',
                            hintText: 'HH:MM',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a time';
                            }
                            return null;
                          },
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
                            if (value == null || value.isEmpty) {
                              return 'Please enter a reason';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    if (!isCustomer || appointment != null) ...[
                      if (currentUser?.usertype == 'admin') ...[
                        Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                              child: DropdownButtonFormField<int?>(
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Assign to Staff/Vet',
                                  border: OutlineInputBorder(),
                                ),
                                initialValue: assignedUserId,
                                items: [
                                  const DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text('Unassigned'),
                                  ),
                                  ...userProvider.users
                                      .where((user) => user.usertype == 'staff' || user.usertype == 'veterinarian')
                                      .map((user) => DropdownMenuItem<int?>(
                                            value: user.userid,
                                            child: Text('${user.fullname} (${user.usertype})', overflow: TextOverflow.ellipsis),
                                          )),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    assignedUserId = value;
                                  });
                                },
                              ),
                          ),
                        ),
                      ],
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: status,
                            items: const [
                              DropdownMenuItem(value: 'scheduled', child: Text('Scheduled')),
                              DropdownMenuItem(value: 'completed', child: Text('Completed')),
                              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                status = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                    ],
                  ),
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
                if (formKey.currentState!.validate() && selectedPet != null) {
                  // For new appointments, ensure pet exists in database
                  if (appointment == null && selectedPet!.petid == null) {
                    // Parse pet description to update pet fields
                    final descriptionLines = petDescriptionController.text.split('\n');
                    String type = '', breed = '', gender = '', vaccinationStatus = '', healthNotes = '';
                    int age = 0;
                    for (var line in descriptionLines) {
                      if (line.startsWith('Type: ')) {
                        type = line.substring(6);
                      } else if (line.startsWith('Breed: ')) {
                        breed = line.substring(7);
                      } else if (line.startsWith('Age: ')) {
                        age = int.tryParse(line.substring(5)) ?? 0;
                      } else if (line.startsWith('Gender: ')) {
                        gender = line.substring(8);
                      } else if (line.startsWith('Vaccination Status: ')) {
                        vaccinationStatus = line.substring(20);
                      } else if (line.startsWith('Health Notes: ')) {
                        healthNotes = line.substring(14);
                      }
                    }
                    selectedPet = Pet(
                      petid: null,
                      userid: selectedPet!.userid,
                      name: selectedPet!.name,
                      type: type,
                      breed: breed,
                      age: age,
                      gender: gender,
                      vaccinationStatus: vaccinationStatus,
                      healthNotes: healthNotes,
                    );

                    // Create the pet first if it doesn't exist
                    final petProvider = Provider.of<PetProvider>(context, listen: false);
                    await petProvider.addPet(selectedPet!);
                    await petProvider.loadPets();
                    // Find the newly added pet
                    try {
                      selectedPet = petProvider.pets.firstWhere(
                        (pet) => pet.name.toLowerCase() == selectedPet!.name.toLowerCase() && pet.userid == selectedPet!.userid,
                      );
                    } catch (e) {
                      // If not found, keep the original
                    }
                  }

                  if (selectedPet!.petid == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to save pet. Please try again.')),
                    );
                    return;
                  }


                  final appointmentIdValue = appointment?.appointmentid;

                  final newAppointment = Appointment(
                    appointmentid: appointmentIdValue,
                    petid: selectedPet!.petid!,
                    userid: selectedUserId,
                    assignedUserId: assignedUserId,
                    date: dateController.text,
                    time: timeController.text,
                    reason: reasonController.text,
                    status: status,
                  );


                  int appointmentId;
                  if (appointment == null) {
                    appointmentId = await Provider.of<AppointmentProvider>(context, listen: false).addAppointment(newAppointment);
                  } else {
                    appointmentId = appointment.appointmentid!;
                    await Provider.of<AppointmentProvider>(context, listen: false).updateAppointment(newAppointment);
                  }

                  // Create medical history entry if there's medical information
                  if (medicalHistoryController.text.isNotEmpty) {
                    final medicalHistory = MedicalHistory(
                      historyid: null,
                      petid: selectedPet!.petid!,
                      appointmentid: appointmentId,
                      date: dateController.text,
                      diagnosis: reasonController.text,
                      treatment: petDescriptionController.text.isNotEmpty ? petDescriptionController.text : 'No specific treatment',
                      notes: medicalHistoryController.text,
                    );
                    await Provider.of<MedicalHistoryProvider>(context, listen: false).addMedicalHistory(medicalHistory);
                  }

                  if (!mounted) return;
                  Navigator.pop(context);

                }
              },
              child: Text(appointment == null ? 'Book' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}


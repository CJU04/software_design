import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetcare_connect/providers/auth_provider.dart';
import 'package:vetcare_connect/providers/firebase_user_provider.dart';
import 'package:vetcare_connect/providers/appointment_provider.dart';
import 'package:vetcare_connect/providers/pet_provider.dart';
import 'package:vetcare_connect/providers/medical_history_provider.dart';
import 'package:vetcare_connect/config/theme/app_theme.dart';
import 'package:vetcare_connect/views/widgets/drawer_widget.dart';
import 'package:vetcare_connect/models/appointment.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class VeterinarianDashboardScreen extends StatefulWidget {
  const VeterinarianDashboardScreen({super.key});

  @override
  State<VeterinarianDashboardScreen> createState() => _VeterinarianDashboardScreenState();
}

class _VeterinarianDashboardScreenState extends State<VeterinarianDashboardScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadData();
  }

  void _loadData() {
    Provider.of<AppointmentProvider>(context, listen: false).loadAppointments();
    Provider.of<PetProvider>(context, listen: false).loadPets();
    Provider.of<MedicalHistoryProvider>(context, listen: false).loadMedicalHistories();
  }

  List<Appointment> _getAppointmentsForDay(DateTime day, List<Appointment> appointments) {
    return appointments.where((appointment) {
      try {
        final appointmentDate = DateTime.parse(appointment.date);
        return appointmentDate.year == day.year &&
            appointmentDate.month == day.month &&
            appointmentDate.day == day.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final firebaseUserProvider = Provider.of<FirebaseUserProvider>(context);
    final currentUser = firebaseUserProvider.currentUser;
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);
    final medicalHistoryProvider = Provider.of<MedicalHistoryProvider>(context);

    // Get today's appointments assigned to this veterinarian
    final todayAppointments = appointmentProvider.appointments.where((appt) {
      final isAssignedToVet = appt.assignedUserId.toString() == currentUser?.uid;
      return isAssignedToVet && appt.status == 'scheduled';
    }).toList();

    final totalPets = petProvider.pets.length;
    final totalMedicalRecords = medicalHistoryProvider.medicalHistories.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Veterinarian Dashboard'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: const [],
      ),
      drawer: const AppDrawer(currentRoute: '/veterinarian'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          final maxWidth = isWide ? 1000.0 : double.infinity;
          final statCardWidth = isWide ? null : constraints.maxWidth;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Dr. ${auth.displayName ?? currentUser?.fullname ?? 'Veterinarian'} (Veterinarian)!',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Here\'s your schedule for today',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Stats
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        if (statCardWidth != null)
                          SizedBox(
                            width: (statCardWidth - 24) / 3,
                            child: _buildStatCard(
                              'Today\'s Appointments',
                              todayAppointments.length.toString(),
                              Icons.calendar_today,
                              Colors.blue,
                            ),
                          )
                        else
                          Expanded(
                            child: _buildStatCard(
                              'Today\'s Appointments',
                              todayAppointments.length.toString(),
                              Icons.calendar_today,
                              Colors.blue,
                            ),
                          ),
                        if (statCardWidth != null)
                          SizedBox(
                            width: (statCardWidth - 24) / 3,
                            child: _buildStatCard(
                              'Total Pets',
                              totalPets.toString(),
                              Icons.pets,
                              Colors.orange,
                            ),
                          )
                        else
                          Expanded(
                            child: _buildStatCard(
                              'Total Pets',
                              totalPets.toString(),
                              Icons.pets,
                              Colors.orange,
                            ),
                          ),
                        if (statCardWidth != null)
                          SizedBox(
                            width: (statCardWidth - 24) / 3,
                            child: _buildStatCard(
                              'Medical Records',
                              totalMedicalRecords.toString(),
                              Icons.medical_services,
                              Colors.purple,
                            ),
                          )
                        else
                          Expanded(
                            child: _buildStatCard(
                              'Medical Records',
                              totalMedicalRecords.toString(),
                              Icons.medical_services,
                              Colors.purple,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton(
                  context,
                  'Appointments',
                  Icons.calendar_today,
                  () => Navigator.pushNamed(context, '/appointment_management'),
                ),
                _buildActionButton(
                  context,
                  'Pet Records',
                  Icons.pets,
                  () => Navigator.pushNamed(context, '/pet_management'),
                ),
                _buildActionButton(
                  context,
                  'Medical History',
                  Icons.history,
                  () => Navigator.pushNamed(context, '/medical_history'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Today's Schedule
            Row(
              children: [
                const Icon(Icons.schedule, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                const Text(
                  'Today\'s Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (todayAppointments.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.event_available, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'No appointments scheduled for today',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todayAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = todayAppointments[index];
                  final pet = petProvider.pets.firstWhere(
                    (p) => p.petId == appointment.petId,
                    orElse: () => throw Exception('Pet not found'),
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(Icons.pets, color: AppTheme.primaryGreen),
                      ),
                      title: Text(
                        appointment.reason,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pet: ${pet.name} (${pet.type})'),
                          Text('Time: ${appointment.time}'),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(appointment.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          appointment.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(appointment.status),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/appointment_management');
                      },
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),

            // Recent Medical Records
            Row(
              children: [
                const Icon(Icons.history, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                const Text(
                  'Recent Medical Records',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: medicalHistoryProvider.medicalHistories.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No medical records found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : Column(
                      children: medicalHistoryProvider.medicalHistories
                          .take(3)
                          .map((history) => ListTile(
                                leading: const Icon(Icons.medical_services, color: AppTheme.primaryGreen),
                                title: Text(history.diagnosis),
                                subtitle: Text('Date: ${history.date}'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.pushNamed(context, '/medical_history');
                                },
                              ))
                          .toList(),
                    ),
            ),

            const SizedBox(height: 24),

            // Appointment Calendar
            const Text(
              'Appointment Calendar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  TableCalendar<Appointment>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: _calendarFormat,
                    eventLoader: (day) => _getAppointmentsForDay(day, appointmentProvider.appointments),
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: CalendarStyle(
                      markersMaxCount: 3,
                      markerDecoration: const BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primaryGreen),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appointments for ${_selectedDay != null ? DateFormat('MMMM d, yyyy').format(_selectedDay!) : 'Today'}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Builder(
                          builder: (context) {
                            final dayAppointments = _selectedDay != null
                                ? _getAppointmentsForDay(_selectedDay!, appointmentProvider.appointments)
                                : <Appointment>[];
                            if (dayAppointments.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'No appointments for this day',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }
                            return Column(
                              children: dayAppointments.map((appointment) {
                                return ListTile(
                                  leading: const Icon(Icons.calendar_today, color: AppTheme.primaryGreen),
                                  title: Text(appointment.reason),
                                  subtitle: Text('Time: ${appointment.time}'),
                                  trailing: Chip(
                                    label: Text(
                                      appointment.status,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(context, '/appointment_management');
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
},
),
);
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 28.0, color: color),
            const SizedBox(height: 8.0),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 28.0),
            const SizedBox(height: 8.0),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

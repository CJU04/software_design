import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetcare_connect/providers/user_provider.dart';
import 'package:vetcare_connect/providers/appointment_provider.dart';
import 'package:vetcare_connect/providers/pet_provider.dart';
import 'package:vetcare_connect/views/widgets/drawer_widget.dart';
import 'package:vetcare_connect/models/appointment.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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
    Provider.of<UserProvider>(context, listen: false).loadUsers();
    Provider.of<AppointmentProvider>(context, listen: false).loadAppointments();
    Provider.of<PetProvider>(context, listen: false).loadPets();
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
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);

    final totalUsers = userProvider.users.length;
    final totalAppointments = appointmentProvider.appointments.length;
    final totalPets = petProvider.pets.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(currentRoute: '/admin'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Color(0xFF7E57C2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${currentUser?.fullname ?? 'Administrator'} (Administrator)!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Manage your clinic from here',
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
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Users',
                    totalUsers.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Pets',
                    totalPets.toString(),
                    Icons.pets,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Appointments',
                    totalAppointments.toString(),
                    Icons.calendar_today,
                    Colors.green,
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
                  'Manage Users',
                  Icons.person_add,
                  () => Navigator.pushNamed(context, '/user_management'),
                ),
                _buildActionButton(
                  context,
                  'System Settings',
                  Icons.settings,
                  () => Navigator.pushNamed(context, '/settings'),
                ),
                _buildActionButton(
                  context,
                  'Reports',
                  Icons.analytics,
                  () => Navigator.pushNamed(context, '/reports'),
                ),
                _buildActionButton(
                  context,
                  'Appointments',
                  Icons.calendar_today,
                  () => Navigator.pushNamed(context, '/appointment_management'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Activity
            Row(
              children: [
                const Icon(Icons.history, color: Colors.deepPurple),
                const SizedBox(width: 8),
                const Text(
                  'Recent Activity',
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
              child: userProvider.users.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No recent activity',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : Column(
                      children: userProvider.users
                          .take(5)
                          .map((user) => ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
                                  child: const Icon(Icons.person, color: Colors.deepPurple),
                                ),
                                title: Text(user.fullname),
                                subtitle: Text(user.email),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getRoleColor(user.usertype ?? 'petOwner').withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Text(
                                    user.usertype ?? 'Pet Owner',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getRoleColor(user.usertype ?? 'petOwner'),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, '/user_management');
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
                      markerDecoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        border: Border.all(color: Colors.deepPurple),
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
                                  leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
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
          color: Colors.deepPurple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.deepPurple, size: 28.0),
            const SizedBox(height: 8.0),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.deepPurple;
      case 'veterinarian':
        return Colors.teal;
      case 'staff':
        return Colors.indigo;
      case 'petowner':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
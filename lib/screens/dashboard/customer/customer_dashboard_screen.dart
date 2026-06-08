import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:vetcare_connect/config/theme/app_theme.dart';
import 'package:vetcare_connect/models/appointment.dart';
import 'package:vetcare_connect/providers/appointment_provider.dart';
import 'package:vetcare_connect/providers/auth_provider.dart';
import 'package:vetcare_connect/providers/firebase_user_provider.dart';
import 'package:vetcare_connect/providers/pet_provider.dart';
import 'package:vetcare_connect/views/widgets/drawer_widget.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PetProvider>(context, listen: false).loadPets();
      Provider.of<AppointmentProvider>(context, listen: false).loadAppointments();
    });
  }

  List<Appointment> _getAppointmentsForDay(
    DateTime day,
    List<Appointment> appointments,
  ) {
    return appointments.where((appointment) {
      try {
        final appointmentDate = DateTime.parse(appointment.date);
        return appointmentDate.year == day.year &&
            appointmentDate.month == day.month &&
            appointmentDate.day == day.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final firebaseUserProvider = Provider.of<FirebaseUserProvider>(context);
    final currentUser = firebaseUserProvider.currentUser;

    final petProvider = context.watch<PetProvider>();
    final appointmentProvider = context.watch<AppointmentProvider>();

    final String? uid = currentUser?.uid;

    // Occupied appointments (calendar + day list)
    final List<Appointment> occupiedAppointments = uid == null
        ? <Appointment>[]
        : appointmentProvider.appointments
            .where((appt) => appt.ownerUid == uid && appt.status == 'scheduled')
            .toList();

    // Upcoming subset (future only)
    final String todayKey = DateTime.now().toString().split(' ')[0];
    final List<Appointment> upcomingAppointments = occupiedAppointments
        .where((appt) => appt.date.compareTo(todayKey) > 0)
        .toList();

    final int totalPets = petProvider.pets.length;
    final int totalAppointments = upcomingAppointments.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  (auth.displayName ?? currentUser?.fullname ?? 'C').isNotEmpty
                      ? (auth.displayName ?? currentUser?.fullname ?? 'C')[0].toUpperCase()
                      : 'C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/customer'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth > 600;
          final double maxWidth = isWide ? 1000.0 : double.infinity;
          final double? statCardWidth = isWide ? null : constraints.maxWidth;

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
                            'Welcome, ${auth.displayName ?? currentUser?.fullname ?? 'Customer'}!',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Manage your pets and appointments',
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
                            'My Pets',
                            totalPets.toString(),
                            Icons.pets,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Upcoming',
                            totalAppointments.toString(),
                            Icons.calendar_today,
                            Colors.blue,
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
                    SizedBox(
                      height: 140,
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.2,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildActionButton(
                            context,
                            'Add Pet',
                            Icons.add,
                            () => Navigator.pushNamed(context, '/add_pet'),
                          ),
                          _buildActionButton(
                            context,
                            'Appointments',
                            Icons.calendar_today,
                            () => Navigator.pushNamed(context, '/appointment_management'),
                          ),
                          _buildActionButton(
                            context,
                            'Product Catalog',
                            Icons.shopping_bag,
                            () => Navigator.pushNamed(context, '/product_catalog'),
                          ),
                          _buildActionButton(
                            context,
                            'Medical History',
                            Icons.medical_services,
                            () => Navigator.pushNamed(context, '/medical_history'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // My Pets Section
                    Row(
                      children: [
                        const Icon(Icons.pets, color: AppTheme.primaryGreen),
                        const SizedBox(width: 8),
                        const Text(
                          'My Pets',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (petProvider.pets.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.pets, size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            const Text(
                              'No pets added yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/add_pet'),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Your First Pet'),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: petProvider.pets.length,
                        itemBuilder: (context, index) {
                          final pet = petProvider.pets[index];
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
                                pet.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${pet.type} • ${pet.breed}'),
                                  Text('Age: ${pet.age} years'),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/pet_details',
                                  arguments: pet,
                                );
                              },
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 24),

                    // Upcoming Appointments Section
                    Row(
                      children: [
                        const Icon(Icons.schedule, color: AppTheme.primaryGreen),
                        const SizedBox(width: 8),
                        const Text(
                          'Upcoming Appointments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (upcomingAppointments.isEmpty)
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
                              'No upcoming appointments',
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
                        itemCount: upcomingAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = upcomingAppointments[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Icon(Icons.calendar_today, color: Colors.blue),
                              ),
                              title: Text(
                                appointment.reason,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date: ${appointment.date.toString().split(' ')[0]}'),
                                  Text('Time: ${appointment.time}'),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: const Text(
                                  'SCHEDULED',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
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

                    // Appointment Calendar (occupied)
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
                            eventLoader: (day) => _getAppointmentsForDay(day, occupiedAppointments),
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            calendarStyle: const CalendarStyle(
                              markersMaxCount: 3,
                              markerDecoration: BoxDecoration(
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
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_selectedDay == null)
                                  const Text(
                                    'Select a day to view occupied appointments',
                                    style: TextStyle(color: Colors.grey),
                                  )
                                else
                                  Builder(
                                    builder: (context) {
                                      final dayAppointments = _getAppointmentsForDay(
                                        _selectedDay!,
                                        occupiedAppointments,
                                      );

                                      if (dayAppointments.isEmpty) {
                                        return const Text(
                                          'No appointments for this day',
                                          style: TextStyle(color: Colors.grey),
                                        );
                                      }

                                      return Column(
                                        children: dayAppointments.map((appointment) {
                                          return ListTile(
                                            leading: const Icon(
                                              Icons.calendar_today,
                                              color: AppTheme.primaryGreen,
                                            ),
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
                                              Navigator.pushNamed(
                                                context,
                                                '/appointment_management',
                                              );
                                            },
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
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
}

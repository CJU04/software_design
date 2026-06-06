import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetcare_connect/providers/user_provider.dart';
import 'package:vetcare_connect/providers/pet_provider.dart';
import 'package:vetcare_connect/providers/appointment_provider.dart';
import 'package:vetcare_connect/providers/medical_history_provider.dart';
import 'package:vetcare_connect/providers/product_provider.dart';
import 'package:vetcare_connect/providers/sales_provider.dart';
import 'package:vetcare_connect/views/widgets/drawer_widget.dart';
import 'package:vetcare_connect/models/appointment.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    if (currentUser != null && currentUser.usertype == 'customer') {
      Provider.of<PetProvider>(context, listen: false).loadPetsForUser(currentUser.userid!);
      Provider.of<AppointmentProvider>(context, listen: false).loadAppointmentsForUser(currentUser.userid!);
      Provider.of<MedicalHistoryProvider>(context, listen: false).loadMedicalHistoriesForUser(currentUser.userid!);
    } else {
      Provider.of<PetProvider>(context, listen: false).loadPets();
      Provider.of<AppointmentProvider>(context, listen: false).loadAppointments();
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
      Provider.of<SalesProvider>(context, listen: false).loadSales();
    }
  }

  String _formatUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'staff':
        return 'Staff';
      case 'veterinarian':
        return 'Veterinarian';
      case 'customer':
        return 'Pet Owner';
      default:
        return role;
    }
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade100;
      case 'confirmed':
        return Colors.green.shade100;
      case 'completed':
        return Colors.blue.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final salesProvider = Provider.of<SalesProvider>(context);
    final currentUser = userProvider.currentUser;
    final isCustomer = currentUser?.usertype == 'customer';

    // Filter data for customers
    final filteredAppointments = isCustomer
        ? appointmentProvider.appointments.where((appt) => appt.userid == currentUser!.userid).toList()
        : appointmentProvider.appointments;
    final filteredPets = isCustomer
        ? petProvider.pets.where((pet) => pet.userid == currentUser!.userid && filteredAppointments.any((appt) => appt.petid == pet.petid)).toList()
        : petProvider.pets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: const AppDrawer(currentRoute: '/dashboard'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                ),
                children: [
                  const TextSpan(text: 'Welcome back, '),
                  TextSpan(
                    text: currentUser?.fullname ?? 'User',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' (${_formatUserRole(currentUser?.usertype ?? 'user')})',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const TextSpan(text: '!'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    isCustomer ? 'My Pets' : 'Total Pets',
                    filteredPets.length.toString(),
                    Icons.pets,
                    Colors.teal,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    isCustomer ? 'My Appointments' : 'Today\'s Appointments',
                    filteredAppointments.length.toString(),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!isCustomer)
              Row(
                children: [
                  if (currentUser?.usertype == 'admin' || currentUser?.usertype == 'staff')
                    Expanded(
                      child: _buildSummaryCard(
                        'Low Stock Products',
                        productProvider.products.where((p) => p.stockquantity < 10).length.toString(),
                        Icons.inventory,
                        Colors.orange,
                      ),
                    ),
                  if (currentUser?.usertype == 'admin' || currentUser?.usertype == 'staff')
                    const SizedBox(width: 16),
                  if (currentUser?.usertype == 'admin' || currentUser?.usertype == 'staff')
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Sales',
                        salesProvider.sales.length.toString(),
                        Icons.point_of_sale,
                        Colors.green,
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 32),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: isCustomer
                  ? [
                      _buildFeatureCard(
                        context,
                        'My Pets',
                        Icons.pets,
                        () => Navigator.pushNamed(context, '/pet_management'),
                      ),
                      _buildFeatureCard(
                        context,
                        'Book Appointment',
                        Icons.calendar_today,
                        () => Navigator.pushNamed(context, '/appointment_management'),
                      ),
                      _buildFeatureCard(
                        context,
                        'Medical History',
                        Icons.medical_services,
                        () => Navigator.pushNamed(context, '/medical_history'),
                      ),
                      _buildFeatureCard(
                        context,
                        'Products',
                        Icons.inventory,
                        () => Navigator.pushNamed(context, '/product_inventory'),
                      ),
                    ]
                  : currentUser?.usertype == 'admin'
                      ? [
                          _buildFeatureCard(
                            context,
                            'Manage Pets',
                            Icons.pets,
                            () => Navigator.pushNamed(context, '/pet_management'),
                          ),
                          _buildFeatureCard(
                            context,
                            'Appointments',
                            Icons.calendar_today,
                            () => Navigator.pushNamed(context, '/appointment_management'),
                          ),
                          _buildFeatureCard(
                            context,
                            'Medical Records',
                            Icons.medical_services,
                            () => Navigator.pushNamed(context, '/medical_history'),
                          ),
                          _buildFeatureCard(
                            context,
                            'Inventory',
                            Icons.inventory,
                            () => Navigator.pushNamed(context, '/product_inventory'),
                          ),
                          _buildFeatureCard(
                            context,
                            'Sales POS',
                            Icons.point_of_sale,
                            () => Navigator.pushNamed(context, '/sales_pos'),
                          ),
                          _buildFeatureCard(
                            context,
                            'Reports',
                            Icons.bar_chart,
                            () => Navigator.pushNamed(context, '/reports'),
                          ),
                        ]
                      : currentUser?.usertype == 'veterinarian'
                          ? [
                              _buildFeatureCard(
                                context,
                                'Manage Pets',
                                Icons.pets,
                                () => Navigator.pushNamed(context, '/pet_management'),
                              ),
                              _buildFeatureCard(
                                context,
                                'Appointments',
                                Icons.calendar_today,
                                () => Navigator.pushNamed(context, '/appointment_management'),
                              ),
                              _buildFeatureCard(
                                context,
                                'Medical Records',
                                Icons.medical_services,
                                () => Navigator.pushNamed(context, '/medical_history'),
                              ),
                            ]
                          : currentUser?.usertype == 'staff'
                              ? [
                                  _buildFeatureCard(
                                    context,
                                    'Products',
                                    Icons.inventory,
                                    () => Navigator.pushNamed(context, '/product_inventory'),
                                  ),
                                  _buildFeatureCard(
                                    context,
                                    'Sales POS',
                                    Icons.point_of_sale,
                                    () => Navigator.pushNamed(context, '/sales_pos'),
                                  ),
                                  _buildFeatureCard(
                                    context,
                                    'Reports',
                                    Icons.bar_chart,
                                    () => Navigator.pushNamed(context, '/reports'),
                                  ),
                                ]
                              : [],
            ),
            const SizedBox(height: 32),
            Text(
              'Appointment Calendar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4.0,
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
                    eventLoader: (day) => _getAppointmentsForDay(day, filteredAppointments),
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: CalendarStyle(
                      markersMaxCount: 3,
                      markerDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.primary),
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
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Builder(
                          builder: (context) {
                            final dayAppointments = _selectedDay != null
                                ? _getAppointmentsForDay(_selectedDay!, filteredAppointments)
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
                                  leading: Icon(
                                    Icons.calendar_today,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  title: Text(appointment.reason),
                                  subtitle: Text('Time: ${appointment.time}'),
                                  trailing: Chip(
                                    label: Text(
                                      appointment.status,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: _getStatusColor(appointment.status),
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
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isCustomer || currentUser?.usertype == 'staff' ? null : FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/pet_management'),
        tooltip: 'Add New Pet',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32.0, color: color),
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
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.0, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


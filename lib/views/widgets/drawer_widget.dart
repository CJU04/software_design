import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetcare_connect/providers/user_provider.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;


  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    final isCustomer = currentUser?.usertype == 'customer';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    // Web-safe: don't use dart:io FileImage here.
                    // If profileImagePath isn't available as an in-memory/URL source,
                    // fall back to initials.
                    backgroundImage: null,
                    backgroundColor: Colors.white,
                    child: currentUser?.profileImagePath == null
                        ? Text(
                            // Guard against empty names to avoid RangeError.
                            (currentUser?.fullname.trim().isNotEmpty == true)
                                ? currentUser!.fullname.trim()[0].toUpperCase()
                                : 'G',

                            style: TextStyle(
                              fontSize: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentUser?.fullname ?? 'Guest',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentUser?.email ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            'Dashboard',
            Icons.dashboard,
            '/dashboard',
          ),
          if (!isCustomer) ...[
            if (currentUser?.usertype == 'admin') ...[
              _buildDrawerItem(
                context,
                'User Management',
                Icons.people,
                '/user_management',
              ),
              _buildDrawerItem(
                context,
                'Pets',
                Icons.pets,
                '/pet_management',
              ),
              _buildDrawerItem(
                context,
                'Medical History',
                Icons.medical_services,
                '/medical_history',
              ),
              _buildDrawerItem(
                context,
                'Sales / POS',
                Icons.point_of_sale,
                '/sales_pos',
              ),
              _buildDrawerItem(
                context,
                'Inventory Logs',
                Icons.history,
                '/inventory_logs',
              ),
              _buildDrawerItem(
                context,
                'Reports',
                Icons.bar_chart,
                '/reports',
              ),
            ] else if (currentUser?.usertype == 'veterinarian') ...[
              _buildDrawerItem(
                context,
                'Pets',
                Icons.pets,
                '/pet_management',
              ),
              _buildDrawerItem(
                context,
                'Medical History',
                Icons.medical_services,
                '/medical_history',
              ),
            ] else if (currentUser?.usertype == 'staff') ...[
              _buildDrawerItem(
                context,
                'Sales / POS',
                Icons.point_of_sale,
                '/sales_pos',
              ),
              _buildDrawerItem(
                context,
                'Inventory Logs',
                Icons.history,
                '/inventory_logs',
              ),
              _buildDrawerItem(
                context,
                'Reports',
                Icons.bar_chart,
                '/reports',
              ),
            ],
          ],
          _buildDrawerItem(
            context,
            'Appointments',
            Icons.calendar_today,
            '/appointment_management',
          ),
          _buildDrawerItem(
            context,
            'Products',
            Icons.inventory,
            '/product_inventory',
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            'Settings',
            Icons.settings,
            '/settings',
          ),
          _buildDrawerItem(
            context,
            'Profile',
            Icons.person,
            '/profile_settings',
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _showLogoutDialog(context, userProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, String route) {
    final isSelected = currentRoute == route;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : null),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (currentRoute != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }

  static void _showLogoutDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                userProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }
}


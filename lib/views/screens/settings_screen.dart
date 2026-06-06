import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetcare_connect/providers/user_provider.dart';
import 'package:vetcare_connect/views/widgets/drawer_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      drawer: const AppDrawer(currentRoute: '/settings'),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            subtitle: Text(userProvider.currentUser?.fullname ?? 'No user'),
            onTap: () {
              Navigator.pushNamed(context, '/profile_settings');
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle dark mode theme'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              // Implement theme change
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme change coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('App version and information'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'FurfectCare',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2023 FurfectCare',
              );
            },
          ),
        ],
      ),
    );
  }
}


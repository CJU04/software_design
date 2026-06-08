import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetcare_connect/config/theme/app_theme.dart';
import 'package:vetcare_connect/providers/auth_provider.dart';
import 'package:vetcare_connect/providers/firebase_user_provider.dart';
import 'package:vetcare_connect/views/widgets/drawer_widget.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FirebaseUserProvider>(context, listen: false).loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // Only allow admin to access this screen
    if (auth.role != UserRole.admin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Admin privileges required'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(currentRoute: '/user_management'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth > 600 ? 800 : double.infinity;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Users',
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
              ),
              Expanded(
                child: Consumer<FirebaseUserProvider>(
                  builder: (context, userProvider, child) {
                    List<FirebaseUser> users = userProvider.users;

                    if (_searchQuery.isNotEmpty) {
                      users = users.where((user) {
                        final nameLower = user.name.toLowerCase();
                        final emailLower = user.email.toLowerCase();
                        final queryLower = _searchQuery.toLowerCase();
                        return nameLower.contains(queryLower) ||
                            emailLower.contains(queryLower);
                      }).toList();
                    }

                    if (users.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text(
                              'No users found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth > 600 ? (constraints.maxWidth - 800) / 2 : 0),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                                  child: Text(
                                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      color: AppTheme.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        user.email,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        user.role.value.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: user.approved
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user.approved ? 'Approved' : 'Pending',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: user.approved ? Colors.green.shade700 : Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20, color: AppTheme.primaryGreen),
                                  onPressed: () => _editUser(user),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                  onPressed: () => _deleteUser(user),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _addUser() {
    _showUserDialog();
  }

  void _editUser(FirebaseUser user) {
    _showUserDialog(user: user);
  }

  void _deleteUser(FirebaseUser user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleting ${user.name}...'),
                  duration: const Duration(seconds: 1),
                ),
              );
              try {
                await Provider.of<FirebaseUserProvider>(context, listen: false).deleteUser(user.uid);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${user.name} has been deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete ${user.name}. Please try again.'),
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

  void _showUserDialog({FirebaseUser? user}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final contactController = TextEditingController(text: user?.contactNumber ?? '');
    final addressController = TextEditingController(text: user?.address ?? '');
    UserRole selectedRole = user?.role ?? UserRole.customer;
    bool approved = user?.approved ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(user == null ? 'Add User' : 'Edit User'),
            content: Form(
              key: formKey,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter name';
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
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email';
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
                            controller: contactController,
                            decoration: const InputDecoration(
                              labelText: 'Contact Number',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextFormField(
                            controller: addressController,
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: DropdownButtonFormField<UserRole>(
                            value: selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'Role',
                              border: OutlineInputBorder(),
                            ),
                            items: UserRole.values.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role.value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedRole = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: SwitchListTile(
                            title: const Text('Approved'),
                            value: approved,
                            onChanged: (value) {
                              setState(() {
                                approved = value;
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
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final newUser = FirebaseUser(
                      uid: user?.uid ?? '',
                      name: nameController.text,
                      email: emailController.text,
                      role: selectedRole,
                      approved: approved,
                      contactNumber: contactController.text,
                      address: addressController.text,
                    );

                    final firebaseUserProvider =
                        Provider.of<FirebaseUserProvider>(
                      context,
                      listen: false,
                    );
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    if (user == null) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please use the Register page to add new users'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    } else {
                      navigator.pop();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                              'Updating ${nameController.text}...'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                      try {
                        await firebaseUserProvider.updateUser(newUser);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                                '${nameController.text} updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(
                            content:
                                Text('Failed to update ${nameController.text}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }
                  }
                },
                child: Text(user == null ? 'Add' : 'Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

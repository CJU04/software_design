import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetcare_connect/models/user.dart';
import 'package:vetcare_connect/providers/user_provider.dart';
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
    Provider.of<UserProvider>(context, listen: false).loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    // Only allow admin to access this screen
    if (currentUser?.usertype != 'admin') {
      return const Scaffold(
        body: Center(
          child: Text('Access Denied: Admin privileges required'),
        ),
      );
    }

    List<User> users = userProvider.users;

    if (_searchQuery.isNotEmpty) {
      users = users.where((user) => user.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                     user.fullname.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      drawer: const AppDrawer(currentRoute: '/user_management'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
          Expanded(
            child: users.isEmpty
                ? const Center(
                    child: Text('No users found'),
                  )
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(user.fullname),
                          subtitle: Text('${user.username} - ${user.usertype}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editUser(user),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteUser(user),
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
        onPressed: _addUser,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addUser() {
    _showUserDialog();
  }

  void _editUser(User user) {
    _showUserDialog(user: user);
  }

  void _deleteUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.fullname}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false).deleteUser(user.userid!);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showUserDialog({User? user}) {
    final formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController(text: user?.username ?? '');
    final passwordController = TextEditingController(text: user?.password ?? '');
    final fullnameController = TextEditingController(text: user?.fullname ?? '');
    final contactController = TextEditingController(text: user?.contactNumber ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final addressController = TextEditingController(text: user?.address ?? '');
    String selectedRole = user?.usertype ?? 'customer';
    String selectedStatus = user?.status ?? 'active';
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
        title: Text(user == null ? 'Add User' : 'Edit User'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: fullnameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'staff', child: Text('Staff/Veterinarian')),
                    DropdownMenuItem(value: 'customer', child: Text('Customer')),
                  ],
                  onChanged: (value) {
                    selectedRole = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: contactController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter contact number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  ],
                  onChanged: (value) {
                    selectedStatus = value!;
                  },
                ),
              ],
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
              if (formKey.currentState!.validate()) {
                final newUser = User(
                  userid: user?.userid,
                  username: usernameController.text,
                  password: passwordController.text,
                  fullname: fullnameController.text,
                  usertype: selectedRole,
                  contactNumber: contactController.text,
                  email: emailController.text,
                  address: addressController.text,
                  status: selectedStatus,
                );
                if (user == null) {
                  await Provider.of<UserProvider>(context, listen: false).addUser(newUser);
                } else {
                  await Provider.of<UserProvider>(context, listen: false).updateUser(newUser);
                }
                if (!mounted) return;
                Navigator.of(context).pop();

              }
            },
            child: Text(user == null ? 'Add User' : 'Update'),

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


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetcare_connect/models/user_role.dart';
import 'package:vetcare_connect/providers/auth_provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:vetcare_connect/config/admin_config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  UserRole _selectedRole = UserRole.petOwner;
  bool _isPasswordVisible = false;
  final _adminCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth > 600 ? 450 : double.infinity;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: SizedBox(
                  width: maxWidth,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Text(
                          'Join FurfectCare',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your account to get started',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Full Name
                        TextFormField(
                          controller: _fullnameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Contact Number
                        TextFormField(
                          controller: _contactNumberController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Contact Number',
                            prefixIcon: const Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your contact number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Address
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            prefixIcon: const Icon(Icons.home_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Role Selection
                        DropdownButtonFormField<UserRole>(
                          value: _selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Role',
                            prefixIcon: const Icon(Icons.group_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                          ),
                          items: UserRole.values.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role.value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Admin Code (only shown when Admin is selected)
                        if (_selectedRole == UserRole.admin) ...[
                          TextFormField(
                            controller: _adminCodeController,
                            decoration: InputDecoration(
                              labelText: 'Admin Verification Code',
                              prefixIcon: const Icon(Icons.security_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              helperText: 'Enter the admin code to register as administrator',
                            ),
                            validator: (value) {
                              if (_selectedRole == UserRole.admin) {
                                if (value == null || value.isEmpty) {
                                  return 'Admin verification code is required';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        const SizedBox(height: 24),

                        // Register Button
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already have an account? '),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              child: const Text('Sign In'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final messenger = ScaffoldMessenger.of(context);

      try {
        // If registering as admin, require correct verification code.
        if (_selectedRole == UserRole.admin) {
          final provided = _adminCodeController.text.trim();
          if (provided.isEmpty || provided != kAdminVerificationCode) {
            messenger.showSnackBar(
              const SnackBar(content: Text('Invalid admin verification code.')),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }

        // When admin is requested, register the user with a safe default role
        // (petOwner) and then call a callable function to request promotion.
        final registerRole = _selectedRole == UserRole.admin ? UserRole.petOwner : _selectedRole;

        await authProvider.registerWithEmailPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _fullnameController.text,
          role: registerRole,
        );

        // If admin was selected, call Cloud Function to request promotion.
        if (_selectedRole == UserRole.admin) {
          final uid = authProvider.firebaseUser?.uid;
          if (uid == null) throw Exception('User created but UID not available');

          final functions = FirebaseFunctions.instance;
          final callable = functions.httpsCallable('requestAdmin');
          final resp = await callable.call(<String, dynamic>{'uid': uid, 'code': _adminCodeController.text.trim()});
          final data = resp.data as Map<String, dynamic>?;
          if (data == null || data['success'] != true) {
            messenger.showSnackBar(const SnackBar(content: Text('Admin request submitted for review.')));
          } else {
            messenger.showSnackBar(const SnackBar(content: Text('Admin access granted.')));
          }
        }

        if (!mounted) return;

        messenger.showSnackBar(
          const SnackBar(content: Text('Registration successful! Please sign in.')),
        );
        Navigator.pushReplacementNamed(context, '/login');

      } on Exception catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Registration failed: $e')));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _fullnameController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }
}

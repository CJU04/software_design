import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  UserRole _selectedRole = UserRole.customer;
  bool _isPasswordVisible = false;
  final _adminCodeController = TextEditingController();
  bool _acceptPrivacyPolicy = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth > 600 ? 400 : double.infinity;
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
                        Text(
                          'Create Account',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          obscureText: !_isPasswordVisible,
                          maxLength: 128,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _fullnameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          maxLength: 100,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _contactNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Contact Number',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                          ),
                          maxLength: 20,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your contact number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          maxLength: 254,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            final emailRegex = RegExp(r'^[\w.%+-]+@[\w.-]+\.[a-zA-Z]{2,}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            prefixIcon: Icon(Icons.home),
                            border: OutlineInputBorder(),
                          ),
                          maxLength: 200,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<UserRole>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            prefixIcon: Icon(Icons.group),
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
                              _selectedRole = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        // Show admin access code field only when Admin is selected.
                        if (_selectedRole == UserRole.admin) ...[
                          TextFormField(
                            controller: _adminCodeController,
                            decoration: const InputDecoration(
                              labelText: 'Admin access code',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (_selectedRole == UserRole.admin) {
                                if (value == null || value.isEmpty) {
                                  return 'Admin access code is required';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 16),
                        // Data Privacy Act checkbox
                        CheckboxListTile(
                          value: _acceptPrivacyPolicy,
                          onChanged: (value) {
                            setState(() {
                              _acceptPrivacyPolicy = value ?? false;
                            });
                          },
                          title: Text(
                            'I agree to the Data Privacy Act of the Philippines (Republic Act No. 10173) and consent to the collection and processing of my personal data.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: (_acceptPrivacyPolicy && !_isLoading) ? _register : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Register'),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text('Already have an account? Login'),
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
      if (!_acceptPrivacyPolicy) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept the Data Privacy Act terms and conditions.')),
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final messenger = ScaffoldMessenger.of(context);

      try {
        // If registering as admin, require correct verification code.
        if (_selectedRole == UserRole.admin) {
          final configured = adminVerificationCode;
          // Fail closed: admin registration is disabled when no secret is configured.
          if (configured.isEmpty) {
            messenger.showSnackBar(
              const SnackBar(content: Text('Admin registration is not available.')),
            );
            return;
          }
          final provided = _adminCodeController.text.trim();
          if (provided.isEmpty || provided != configured) {
            messenger.showSnackBar(
              const SnackBar(content: Text('Invalid admin verification code.')),
            );
            return;
          }
        }

        // When admin is requested, register the user with a safe default role
        // (customer) and then call a callable function to request promotion.
        final registerRole = _selectedRole == UserRole.admin ? UserRole.customer : _selectedRole;

        await authProvider.registerWithEmailPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _fullnameController.text,
          role: registerRole,
          contactNumber: _contactNumberController.text.trim(),
          address: _addressController.text.trim(),
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
            messenger.showSnackBar(const SnackBar(content: Text('Admin request failed.')));
          } else {
            messenger.showSnackBar(const SnackBar(content: Text('Admin access granted.')));
          }
        }

        if (!mounted) return;

        messenger.showSnackBar(
          const SnackBar(content: Text('Registration successful! Please login.')),
        );
        Navigator.pushReplacementNamed(context, '/login');

      } on Exception {
        // Show a safe, user-friendly message without leaking system details.
        messenger.showSnackBar(
          const SnackBar(content: Text('Registration failed. Please try again.')),
        );
      } catch (_) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Registration failed. Please try again.')),
        );
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


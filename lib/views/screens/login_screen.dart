import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetcare_connect/providers/auth_provider.dart';
import '../../routes/app_router.dart';

import 'register_screen.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth > 600 ? 400 : double.infinity;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Center(
                    child: SizedBox(
                      width: maxWidth,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Image.asset(
                              'assets/logo.png',
                              height: 100,
                              width: 100,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'FurfectCare',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Veterinary Consultation & Product Inventory',
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 48),
                            TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(color: Colors.green),
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                labelStyle: TextStyle(color: Colors.green),
                                prefixIcon: Icon(Icons.person, color: Colors.green),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your username';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              style: const TextStyle(color: Colors.green),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: const TextStyle(color: Colors.green),
                                prefixIcon: const Icon(Icons.lock, color: Colors.green),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green, width: 2),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              obscureText: !_isPasswordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _login,
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
                                  : const Text('Login'),
                            ),
                            const SizedBox(height: 16),

                            // IMPORTANT: Your current login flow was missing the register entry point.
                            // This button ensures users can navigate to account creation.
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: const Text("Don't have an account? Register"),
                            ),

                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                );
                              },
                              icon: const Icon(Icons.person_add_alt_1),
                              label: const Text('Create account'),
                            ),
                          ],
                        ),
                      ),
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

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final messenger = ScaffoldMessenger.of(context);

      try {
        // IMPORTANT: This screen is using email/password Firebase Auth.
        // The "Username" text field is treated as email to avoid changing UI layout too much.
        await authProvider.signInWithEmailPassword(
          email: _usernameController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;

        // Navigate using role-based routes (must match AppRouter).
        final nextRoute = switch (authProvider.role) {
          UserRole.admin => AppRouter.adminDashboardRoute,
          UserRole.customer => AppRouter.customerDashboardRoute,
          UserRole.staff => AppRouter.staffDashboardRoute,
          UserRole.veterinarian => AppRouter.veterinarianDashboardRoute,
          null => AppRouter.loginRoute,
        };
        Navigator.pushReplacementNamed(context, nextRoute);

      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Login failed. Please check your credentials.'),
          ),
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
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}




import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_init_provider.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/app_loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  bool _hasNavigated = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
    _tryNavigate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final init = context.watch<AppInitProvider>();

    if (!init.isLoading && !_hasNavigated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryNavigate());
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    // App Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.pets,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // App Name
                    const Text(
                      'FurfectCare',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Veterinary Care & Pet Services',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1),
              // Loading indicator
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    if (init.isLoading) ...[
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Loading...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (init.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          init.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          // Retry initialization
                        },
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(flex: 1),
              // Footer
              const Text(
                '© 2024 FurfectCare',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _tryNavigate() async {
    if (_hasNavigated) return;

    final init = context.read<AppInitProvider>();
    if (init.isLoading) return;
    if (init.errorMessage != null) return;

    setState(() => _hasNavigated = true);

    final auth = context.read<AuthProvider>();
    await auth.syncCurrentUser();

    final route = auth.isSignedIn
        ? _dashboardRouteForRole(auth.role)
        : AppRouter.loginRoute;

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(route);
  }

  String _dashboardRouteForRole(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return AppRouter.adminDashboardRoute;
      case UserRole.petOwner:
        return AppRouter.petOwnerDashboardRoute;
      case UserRole.staff:
        return AppRouter.staffDashboardRoute;
      case UserRole.veterinarian:
        return AppRouter.veterinarianDashboardRoute;
      default:
        return AppRouter.loginRoute;
    }
  }
}
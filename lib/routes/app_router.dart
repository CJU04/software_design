import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../views/screens/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/dashboard/admin/admin_dashboard_screen.dart';
import '../screens/dashboard/pet_owner/pet_owner_dashboard_screen.dart';
import '../screens/dashboard/staff/staff_dashboard_screen.dart';
import '../screens/dashboard/veterinarian/veterinarian_dashboard_screen.dart';
import '../providers/auth_provider.dart';
import '../models/user_role.dart';
import '../views/screens/access_denied_screen.dart';

class AppRouter {
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot-password';

  static const String adminDashboardRoute = '/admin';
  static const String petOwnerDashboardRoute = '/pet-owner';
  static const String staffDashboardRoute = '/staff';
  static const String veterinarianDashboardRoute = '/veterinarian';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case registerRoute:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPasswordRoute:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case adminDashboardRoute:
        return MaterialPageRoute(builder: (context) {
          final auth = context.watch<AuthProvider>();
          if (!auth.isSignedIn) return const LoginScreen();
          if (auth.role != UserRole.admin) return const AccessDeniedScreen();
          return const AdminDashboardScreen();
        });
      case petOwnerDashboardRoute:
        return MaterialPageRoute(builder: (_) => const PetOwnerDashboardScreen());
      case staffDashboardRoute:
        return MaterialPageRoute(builder: (_) => const StaffDashboardScreen());
      case veterinarianDashboardRoute:
        return MaterialPageRoute(builder: (_) => const VeterinarianDashboardScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}


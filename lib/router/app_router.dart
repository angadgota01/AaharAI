import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../auth/forgot_password_screen.dart';
import '../auth/auth_service.dart';
import '../auth/auth_notifier.dart';
import '../features/dashboard/presentation/user_home.dart';
import '../consultation/nutritionist_list.dart';
import '../consultation/chat_screen.dart';
import '../features/scanner/presentation/add_meal_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = AuthNotifier();
  
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isAuthenticated = AuthService.isAuthenticated();
      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/signup';
      final isForgotPassword = state.matchedLocation == '/forgot-password';

      // If not authenticated and trying to access protected routes
      if (!isAuthenticated && !isLoggingIn && !isSigningUp && !isForgotPassword) {
        return '/login';
      }

      // If authenticated and trying to access login/signup, redirect to home
      if (isAuthenticated && (isLoggingIn || isSigningUp)) {
        return '/';
      }

      // No redirect needed
      return null;
    },
    routes: [
      // -------- AUTH --------
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // -------- HOME --------
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const UserHomeScreen(),
      ),

      // -------- CONSULTATION --------
      GoRoute(
        path: '/consultation',
        name: 'consultation',
        builder: (context, state) => const NutritionistListScreen(),
      ),

      // -------- CHAT --------
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) {
          final doctorName = state.extra as String;
          return ChatScreen(doctor: doctorName);
        },
      ),

      // -------- ADD MEAL --------
      GoRoute(
        path: '/add_meal',
        name: 'add_meal',
        builder: (context, state) => const AddMealScreen(),
      ),
    ],
  );
});

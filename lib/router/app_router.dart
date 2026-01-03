import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../features/dashboard/presentation/user_home.dart';
import '../consultation/nutritionist_list.dart';
import '../consultation/chat_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
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
    ],
  );
});

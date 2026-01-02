import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../features/dashboard/presentation/user_home.dart';
// import '../features/scanner/presentation/camera_screen.dart';
// import '../features/community/presentation/feed_screen.dart'; 

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const UserHomeScreen(),
      ),
      GoRoute(
        path: '/scanner',
        name: 'scanner',
        builder: (context, state) => const Scaffold(body: Center(child: Text("Scanner Placeholder"))),
      ),
       GoRoute(
        path: '/consultation',
        name: 'consultation',
        builder: (context, state) => const Scaffold(body: Center(child: Text("Consultation Placeholder"))),
      ),
    ],
  );
});
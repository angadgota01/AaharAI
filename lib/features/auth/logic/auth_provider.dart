import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/auth_service.dart';
import '../../../data/local/isar_service.dart';
import '../../../data/local/entities/user_profile.dart';

// Provider for Isar service
final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

// Stream provider for auth state changes
final authStateProvider = StreamProvider<AuthState>((ref) {
  return AuthService.authStateChanges;
});

// Provider for current user (from Supabase)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (state) => state.session?.user,
    orElse: () => null,
  );
});

// Provider for current user profile (from local Isar)
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final isarService = ref.watch(isarServiceProvider);
  var profile = await isarService.getUserProfile(user.id);

  // If profile doesn't exist locally, create it
  if (profile == null) {
    profile = UserProfile()
      ..userId = user.id
      ..email = user.email ?? ''
      ..displayName = user.userMetadata?['display_name']
      ..createdAt = DateTime.parse(user.createdAt)
      ..lastLoginAt = DateTime.now();

    await isarService.saveUserProfile(profile);
  } else {
    // Update last login time
    profile.lastLoginAt = DateTime.now();
    await isarService.saveUserProfile(profile);
  }

  return profile;
});

// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

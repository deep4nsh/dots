import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  // We don't watch the stream here to avoid rebuilding everything on every minor state change if only user data is needed
  // Instead, the UI can watch authStateProvider if it needs to react to login/logout
  return ref.watch(authRepositoryProvider).currentUser;
});

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final _client = Supabase.instance.client;

  // Sign Up
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'io.supabase.dots://login-callback',
      );
      return response;
    } catch (e) {
      print("❌ Error during sign up: $e");
      rethrow;
    }
  }

  // Sign In
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      print("❌ Error during sign in: $e");
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      print("❌ Error during sign out: $e");
      rethrow;
    }
  }

  // Get current session
  Session? get currentSession => _client.auth.currentSession;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Delete Account (Wipe data and sign out)
  Future<void> deleteAccount() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId != null) {
        // Wipe user notes
        await _client.from('notes').delete().eq('user_id', userId);
      }
      // Sign out
      await signOut();
    } catch (e) {
      print("❌ Error during account deletion: $e");
      rethrow;
    }
  }

  // Stream of auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}

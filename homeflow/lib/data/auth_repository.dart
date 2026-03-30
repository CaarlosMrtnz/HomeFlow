import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Stream que emite un evento cada vez que el usuario inicia sesión, cierra sesión, o si su token expira.
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Comprobación rápida del estado actual
  User? get currentUser => _supabase.auth.currentUser;

  // Login estándar
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // Si falla (contraseña incorrecta, etc.), lanzamos el error hacia arriba para que el BLoC lo capture y la UI pinte el mensaje en rojo.
      rethrow; 
    }
  }

  // Registro de nuevos usuarios
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Cerrar sesión (destruye el token de forma segura)
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositorio que encapsula la lógica de autenticación.
/// Actúa como capa de abstracción sobre el SDK de Supabase para desacoplarlo de los gestores de estado.
class AuthRepository {
  // Instancia directa del singleton para evitar inyectar el cliente por constructor si no hay tests unitarios complejos planeados.
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Expone el flujo reactivo de la sesión para que la capa de presentación o el enrutador reaccionen en tiempo real a los cambios de estado.
  // Stream que emite un evento cada vez que el usuario inicia sesión, cierra sesión, o si su token expira.
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Devuelve la sesión en memoria de forma síncrona, sin realizar peticiones de red.
  // Comprobación rápida del estado actual
  User? get currentUser => _supabase.auth.currentUser;

  /// Autentica al usuario contra la API de Supabase utilizando credenciales estándar.
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
      
      // Propaga la excepción (ej. AuthException) a la capa superior responsable del manejo de estado.
      rethrow; 
    }
  }

  /// Registra una nueva credencial. Dependiendo de la configuración del proyecto en Supabase, 
  /// puede requerir confirmación por correo electrónico antes de generar una sesión válida.
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

  /// Invalida el JWT actual en el backend y limpia el almacenamiento local del dispositivo.
  // Cierra sesión (destruye el token de forma segura)
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
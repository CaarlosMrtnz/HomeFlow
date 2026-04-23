import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/models/profile.dart';

/// Interfaz de acceso a datos para la tabla `profiles`.
/// Desacopla las operaciones de lectura y escritura de Supabase de la capa de presentación.
class ProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Recupera el perfil del usuario activo.
  /// Fuerza la devolución de un único objeto JSON mediante '.single()' para delegar el mapeo al modelo.
  Future<Profile> getProfile() async {
    try {
      // ID del usuario que tiene la sesión activa actualmente
      final userId = _supabase.auth.currentUser?.id;

      // Si por algún motivo se llama a esto sin sesión, cortamos.
      if (userId == null) {
        throw Exception('No hay ningún usuario autenticado en el sistema.');
      }

      // Se coge de la tabla 'profiles' la fila que coincida con el ID
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  /// Actualiza parcialmente los datos del perfil en base de datos.
  /// Construye el payload dinámicamente en función de los parámetros recibidos.
  Future<void> updateProfile({String? fullName, String? phoneNumber}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('No hay sesión activa.');

      // Solo enviamos los campos que no sean nulos para no machacar datos sin querer
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;

      await _supabase.from('profiles').update(updates).eq('id', userId);
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

}
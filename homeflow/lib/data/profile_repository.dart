import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/models/profile.dart';

class ProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Profile> getProfile() async {
    try {
      // ID del usuario que tiene la sesión activa actualmente
      final userId = _supabase.auth.currentUser?.id;

      // Si por algún motivo extraño se llama a esto sin sesión, cortamos.
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
}
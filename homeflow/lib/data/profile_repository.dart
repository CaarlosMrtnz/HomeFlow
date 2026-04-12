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
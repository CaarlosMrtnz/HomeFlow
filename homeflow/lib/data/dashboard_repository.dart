import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/reading.dart';

class DashboardRepository {
  final SupabaseClient _supabase;

  // Inyecta el cliente de Supabase. Si no se pasa, coge la instancia global.
  // Dejar esto opcional facilita inyectar un objeto simulado para tests unitarios sin tener que reescribir la forma en la que se llama en producción.
  DashboardRepository({SupabaseClient? supabaseClient}) 
      : _supabase = supabaseClient ?? Supabase.instance.client;

  /// Devuelve un flujo (Stream) de lecturas en tiempo real.
  Stream<List<Reading>> getRealtimeReadings() {

    final userId = _supabase.auth.currentUser?.id;
    
    if (userId == null) {
      return const Stream.empty(); // Si no hay sesión, no abrimos el canal
    }
    
    return _supabase
        .from('readings')
        // El primaryKey es lo que permite al SDK conciliar los eventos del WebSocket (inserts, updates, deletes) para mantener la caché del stream actualizada y sin duplicados.
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        // Lecturas más recientes primero
        .order('created_at', ascending: false)
        // Limite de los últimos 100 registros para no saturar la memoria del móvil
        .limit(100)
        .map((listOfMaps) {
          // Cada fila de la base de datos se convierte en un objeto Dart 'Reading'
          return listOfMaps.map((json) => Reading.fromJson(json)).toList();
        });
  }

  Future<List<dynamic>> getWeeklySummary() async {
    final userId = _supabase.auth.currentUser?.id;
    
    if (userId == null) {
      return []; // Cortafuegos, sin usuario no hay datos
    }

    final response = await _supabase
        .from('weekly_usage_summary')
        .select()
        .eq('user_id', userId); 
        
    return response;
  }

  // Obtiene los dispositivos globales y los propios del usuario
  Future<List<Map<String, dynamic>>> getDevices() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase.from('devices').select('*');
    return response;
  }

  /// Inserta un nuevo dispositivo personalizado
  Future<void> createDevice(String name, int supplyTypeId, String iconName) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    await _supabase.from('devices').insert({
      'name': name,
      'supply_type_id': supplyTypeId,
      'user_id': userId, 
      'icon_name': iconName,
    });
  }

  // Elimina un dispositivo personalizado
  Future<void> deleteDevice(int deviceId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    // Doble validación: borra el ID exacto, pero solo si pertenece a este usuario
    await _supabase
        .from('devices')
        .delete()
        .eq('id', deviceId)
        .eq('user_id', userId);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
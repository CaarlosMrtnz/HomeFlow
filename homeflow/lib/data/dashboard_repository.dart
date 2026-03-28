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
    return _supabase
        .from('readings')
        // El primaryKey es lo que permite al SDK conciliar los eventos del WebSocket (inserts, updates, deletes) para mantener la caché del stream actualizada y sin duplicados.
        .stream(primaryKey: ['id'])
        // Lecturas más recientes primero
        .order('created_at', ascending: false)
        // Limite de los últimos 100 registros para no saturar la memoria del móvil
        .limit(100)
        .map((listOfMaps) {
          // Cada fila de la base de datos se convierte en un objeto Dart 'Reading'
          return listOfMaps.map((json) => Reading.fromJson(json)).toList();
        });
  }

  /// Pide a la base de datos el resumen semanal ya calculado por la Vista SQL.
  /// Retorna un Future porque las vistas con SUM/GROUP BY no soportan webhooks en tiempo real.
  Future<List<dynamic>> getWeeklySummary() async {
    // Se pide los datos a la vista que creamos.
    final response = await _supabase
        .from('weekly_usage_summary')
        .select();
        
    return response;
  }

}
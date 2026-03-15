import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/reading.dart';

class DashboardRepository {
  final SupabaseClient _supabase;

  // Inyectamos el cliente de Supabase. Si no se pasa, coge la instancia global.
  DashboardRepository({SupabaseClient? supabaseClient}) 
      : _supabase = supabaseClient ?? Supabase.instance.client;

  /// Devuelve un flujo (Stream) de lecturas en tiempo real.
  Stream<List<Reading>> getRealtimeReadings() {
    return _supabase
        .from('readings')
        .stream(primaryKey: ['id'])
        // Ordenamos para tener siempre las lecturas más recientes primero
        .order('created_at', ascending: false)
        // Limitamos a los últimos 100 registros para no saturar la memoria del móvil
        .limit(100)
        .map((listOfMaps) {
          // Convertimos cada fila de la base de datos en nuestro objeto Dart 'Reading'
          return listOfMaps.map((json) => Reading.fromJson(json)).toList();
        });
  }
}
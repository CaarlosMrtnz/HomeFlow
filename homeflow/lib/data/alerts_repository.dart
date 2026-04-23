import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/alert.dart';

/// Repositorio que centraliza las operaciones de red relacionadas con la tabla de alertas.
/// Aisla la capa de datos de la UI y del gestor de estado, facilitando la mantenibilidad.
class AlertsRepository {
  final SupabaseClient _supabase;

  /// Inyección de dependencias a través del constructor. 
  /// Permite inyectar un cliente mockeado para tests unitarios; si no se pasa nada, usa el singleton por defecto.
  AlertsRepository({SupabaseClient? supabaseClient}) 
      : _supabase = supabaseClient ?? Supabase.instance.client;

  /// Stream de alertas en tiempo real que priorizan las no leídas
  Stream<List<Alert>> getRealtimeAlerts() {

    final userId = _supabase.auth.currentUser?.id;
    
    // Si no hay sesión, cerramos el flujo
    if (userId == null) {
      return const Stream.empty();
    }
    
    // Abre un canal de WebSockets. Supabase emitirá una nueva lista completa cada vez que haya un INSERT, UPDATE o DELETE en la tabla.
    return _supabase
        .from('alerts')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        // Mapea la lista de PostgreSQL a nuestros modelos de dominio fuertemente tipados.
        .map((listOfMaps) => listOfMaps.map((json) => Alert.fromJson(json)).toList());
  }

  /// Método para marcar una alerta como leída cuando el usuario pinche en ella
  Future<void> markAsRead(int alertId) async {
    // Al ejecutar el update, el trigger interno de Supabase enviará el cambio por WebSocket, 
    // lo que provocará que getRealtimeAlerts emita un nuevo estado automáticamente.
    await _supabase
        .from('alerts')
        .update({'is_read': true})
        .eq('id', alertId);
  }
}
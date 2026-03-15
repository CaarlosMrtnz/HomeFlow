import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/alert.dart';

class AlertsRepository {
  final SupabaseClient _supabase;

  AlertsRepository({SupabaseClient? supabaseClient}) 
      : _supabase = supabaseClient ?? Supabase.instance.client;

  /// Stream de alertas en tiempo real que priorizan las no leídas
  Stream<List<Alert>> getRealtimeAlerts() {
    return _supabase
        .from('alerts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((listOfMaps) => listOfMaps.map((json) => Alert.fromJson(json)).toList());
  }

  /// Método para marcar una alerta como leída cuando el usuario pinche en ella
  Future<void> markAsRead(int alertId) async {
    await _supabase
        .from('alerts')
        .update({'is_read': true})
        .eq('id', alertId);
  }
}
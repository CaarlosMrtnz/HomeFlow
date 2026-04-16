import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ¡OJO! Necesitas este import para conectarte al stream directamente
import 'package:supabase_flutter/supabase_flutter.dart'; 

import '../../core/models/alert.dart';
import '../../data/alerts_repository.dart';

part 'alerts_event.dart';
part 'alerts_state.dart';

class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  final AlertsRepository _alertsRepository;
  
  // 1. Instancia de Supabase y nuestra Caché en memoria RAM para los iconos
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _devicesCache = [];

  AlertsBloc({required AlertsRepository alertsRepository})
      : _alertsRepository = alertsRepository,
        super(AlertsInitial()) {
    on<StartListeningAlerts>(_onStartListeningAlerts);
    on<MarkAlertAsRead>(_onMarkAlertAsRead);
  }

  // 2. Función privada para descargar los iconos una sola vez
  Future<void> _refreshDeviceCache() async {
    try {
      final response = await _supabase.from('devices').select('id, icon_name');
      _devicesCache = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error recargando caché de iconos en alertas: $e');
    }
  }

  Future<void> _onStartListeningAlerts(
    StartListeningAlerts event,
    Emitter<AlertsState> emit,
  ) async {
    emit(AlertsLoading());

    // Llenamos la caché antes de empezar a escuchar
    await _refreshDeviceCache();

    // Usamos el stream directo para poder cruzar los datos
    await emit.forEach(
      _supabase.from('alerts').stream(primaryKey: ['id']),
      onData: (List<Map<String, dynamic>> rawAlerts) {
        
        final List<Alert> alertasEnriquecidas = rawAlerts.map((json) {
          // Buscamos el ID en nuestra caché
          final deviceId = json['device_id']?.toString();
          
          final deviceInfo = _devicesCache.firstWhere(
            (d) => d['id'].toString() == deviceId,
            orElse: () => {'icon_name': 'notifications'} // Campanita por defecto
          );

          // Le inyectamos el icono para que el fromJson del modelo lo pueda leer
          json['devices'] = {
            'icon_name': deviceInfo['icon_name'],
          };

          return Alert.fromJson(json);
        }).toList();

        // IMPORTANTE: Ordenamos las alertas para que las más recientes salgan arriba
        alertasEnriquecidas.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return AlertsLoaded(alertasEnriquecidas);
      },
      onError: (error, stackTrace) {
        return AlertsError(error.toString());
      },
    );
  }

  Future<void> _onMarkAlertAsRead(
    MarkAlertAsRead event,
    Emitter<AlertsState> emit,
  ) async {
    try {
      await _alertsRepository.markAsRead(event.alertId);
    } catch (e) {
      print("Error marcando alerta como leída: $e");
    }
  }
}
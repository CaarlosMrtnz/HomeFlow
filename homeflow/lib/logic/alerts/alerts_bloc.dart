import 'dart:developer' as developer;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Importación explícita del cliente de Supabase para exponer el método de extensión .stream() requerido por los WebSockets.
import 'package:supabase_flutter/supabase_flutter.dart'; 

import '../../core/models/alert.dart';
import '../../data/alerts_repository.dart';

part 'alerts_event.dart';
part 'alerts_state.dart';

/// Gestor de estado reactivo para las alertas del sistema.
/// Mantiene la sincronización en tiempo real con Supabase e inyecta metadatos estáticos (iconos) para sortear la limitación de los JOINs en webSockets.
class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  final AlertsRepository _alertsRepository;
  
  // Cliente de Supabase y caché en memoria para mitigar consultas N+1 al inyectar iconos en las alertas.
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _devicesCache = [];

  /// Inicializa el BLoC y enlaza los eventos de la UI con sus manejadores asíncronos.
  AlertsBloc({required AlertsRepository alertsRepository})
      : _alertsRepository = alertsRepository,
        super(AlertsInitial()) {
    on<StartListeningAlerts>(_onStartListeningAlerts);
    on<MarkAlertAsRead>(_onMarkAlertAsRead);
  }

  // Poblamiento inicial de la caché de dispositivos. Precarga la relación id-icono para cruzarla sincrónicamente con el stream.
  /// Extrae un mapa ligero de identificadores y nombres visuales de la tabla devices.
  Future<void> _refreshDeviceCache() async {
    try {
      final response = await _supabase.from('devices').select('id, icon_name');
      _devicesCache = List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
        developer.log(
          'Error recargando caché de iconos en alertas.',
          name: 'AlertsBloc',
          error: e,
          stackTrace: stackTrace,
        );
    }
  }

  /// Abre el canal WebSocket y procesa el flujo entrante de alertas.
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

        // Ordenación en cliente, ya que el stream reactivo de Supabase no respeta el .order() del backend en tiempo real.
        alertasEnriquecidas.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return AlertsLoaded(alertasEnriquecidas);
      },
      onError: (error, stackTrace) {
        return AlertsError(error.toString());
      },
    );
  }

  /// Solicita el cambio de estado 'leído' sobre un registro específico.
  Future<void> _onMarkAlertAsRead(
    MarkAlertAsRead event,
    Emitter<AlertsState> emit,
  ) async {
    try {
      await _alertsRepository.markAsRead(event.alertId);
    } catch (e, stackTrace) {
      developer.log(
        'Fallo al recargar la caché de iconos',
        name: 'AlertsBloc',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
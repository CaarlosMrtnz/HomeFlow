import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

import '../../core/models/reading.dart';
import '../../data/dashboard_repository.dart'; 

part 'dashboard_event.dart';
part 'dashboard_state.dart';

/// Gestor de estado principal para la vista del Dashboard.
/// Coordina la carga reactiva de lecturas, el resumen semanal y las mutaciones sobre los dispositivos del usuario.
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;
  
  // Instancia de Supabase y Caché en memoria RAM
  /// Cliente directo inyectado para manejar los streams.
  final _supabase = Supabase.instance.client;
  /// Almacén temporal para resolver localmente la ausencia de JOINs en el stream de Supabase.
  List<Map<String, dynamic>> _devicesCache = [];

  /// Inicializa el BLoC, inyecta el repositorio y registra los manejadores de eventos.
  DashboardBloc({required DashboardRepository repository}) 
      : _repository = repository,
        super(DashboardInitial()) {
    on<StartListeningReadings>(_onStartListeningReadings);
    on<AddDeviceRequested>(_onAddDeviceRequested);
    on<DeleteDeviceRequested>(_onDeleteDeviceRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  // Sincroniza la caché local de dispositivos para resolver las relaciones del stream
  /// Descarga un snapshot ligero de los dispositivos y lo vuelca en la caché local.
  Future<void> _refreshDeviceCache() async {
    try {
      final response = await _supabase.from('devices').select('id, name, icon_name');
      _devicesCache = List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
        developer.log(
          'Error recargando caché de dispositivos.',
          name: 'DashboardBloc',
          error: e,
          stackTrace: stackTrace,
        );
    }
  }

  /// Orquesta la carga inicial del cuadro de mandos y abre el canal de WebSockets para las lecturas.
  Future<void> _onStartListeningReadings(
    StartListeningReadings event, 
    Emitter<DashboardState> emit,
  ) async {
    // Llenado de la caché al arrancar
    await _refreshDeviceCache();
    
    // Obtenemos los datos iniciales
    final initialSummary = await _repository.getWeeklySummary();
    final initialDevices = await _repository.getDevices();

    /// Transforma el flujo de base de datos en estados de interfaz listos para renderizar.
    await emit.forEach(
      _supabase.from('readings').stream(primaryKey: ['id']),
      onData: (List<Map<String, dynamic>> rawReadings) {
        
        List<dynamic> activeDevices = initialDevices;
        List<dynamic> activeSummary = initialSummary;
        
        // Preserva los datos contextuales (dispositivos y resumen) entre emisiones del stream.
        if (state is DashboardLoaded) {
          activeDevices = (state as DashboardLoaded).devices;
          activeSummary = (state as DashboardLoaded).weeklySummary;
        }

        final List<Reading> lecturasEnriquecidas = rawReadings.map((json) {

          final deviceId = json['device_id'];
          
          // Cruza el ID de la lectura entrante con la caché para inyectar metadatos visuales.
          final deviceInfo = _devicesCache.firstWhere(
            (d) => d['id'].toString() == deviceId.toString(), 
            orElse: () => {'name': 'Unknown Device', 'icon_name': 'device_unknown'}
          );

          json['devices'] = {
            'name': deviceInfo['name'],
            'icon_name': deviceInfo['icon_name'],
          };

          return Reading.fromJson(json);
        }).toList();

        // Estado con las lecturas nuevas y las listas actualizadas
        return DashboardLoaded(
          readings: lecturasEnriquecidas,
          weeklySummary: activeSummary,
          devices: activeDevices,
        );
      },
      onError: (error, stackTrace) => DashboardError(error.toString()),
    );
  }

  /// Ejecuta la inserción de un dispositivo delegando en el repositorio y reconstruye el estado del dashboard.
  Future<void> _onAddDeviceRequested(
    AddDeviceRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      try {
        // Solo llamamos al repositorio. Él ya se encarga de hacer el insert en Supabase.
        await _repository.createDevice(event.name, event.supplyTypeId, event.iconName);
        
        final newDevices = await _repository.getDevices();
        final currentState = state as DashboardLoaded;
        
        // Refrescamos la caché para que el Stream reconozca al nuevo dispositivo
        await _refreshDeviceCache();

        emit(DashboardLoaded(
          readings: currentState.readings,
          weeklySummary: currentState.weeklySummary,
          devices: newDevices,
        ));

      } catch (e) {
        emit(DashboardError(e.toString()));
      }
    }
  }

  /// Solicita el borrado de un dispositivo y actualiza la lista disponible en la vista.
  Future<void> _onDeleteDeviceRequested(DeleteDeviceRequested event, Emitter<DashboardState> emit) async {
    if (state is DashboardLoaded) {
      try {
        // Aquí le pasamos el ID que viene dentro del evento
        await _repository.deleteDevice(event.deviceId);
        
        final newDevices = await _repository.getDevices();
        final currentState = state as DashboardLoaded;
        
        await _refreshDeviceCache();

        emit(DashboardLoaded(
          readings: currentState.readings,
          weeklySummary: currentState.weeklySummary,
          devices: newDevices,
        ));
      } catch (e) {
        emit(DashboardError(e.toString()));
      }
    }
  }

  /// Propaga la orden de cierre de sesión hacia el repositorio.
  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<DashboardState> emit,
  ) async {
    await _repository.signOut();
    emit(DashboardInitial()); 
  }
}
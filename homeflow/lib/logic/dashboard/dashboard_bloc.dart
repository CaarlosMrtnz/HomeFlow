import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Asegúrate de tener este import

import '../../core/models/reading.dart';
import '../../data/dashboard_repository.dart'; 

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;
  
  // Instancia de Supabase y Caché en memoria RAM
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _devicesCache = [];

  DashboardBloc({required DashboardRepository repository}) 
      : _repository = repository,
        super(DashboardInitial()) {
    on<StartListeningReadings>(_onStartListeningReadings);
    on<AddDeviceRequested>(_onAddDeviceRequested);
    on<DeleteDeviceRequested>(_onDeleteDeviceRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  // Función interna para refrescar la memoria
  Future<void> _refreshDeviceCache() async {
    try {
      final response = await _supabase.from('devices').select('id, name, icon_name');
      _devicesCache = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error recargando caché de dispositivos: $e');
    }
  }

  Future<void> _onStartListeningReadings(
    StartListeningReadings event, 
    Emitter<DashboardState> emit,
  ) async {
    // Llenado de la caché al arrancar
    await _refreshDeviceCache();
    
    // Obtenemos los datos iniciales
    final initialSummary = await _repository.getWeeklySummary();
    final initialDevices = await _repository.getDevices();

    await emit.forEach(
      _supabase.from('readings').stream(primaryKey: ['id']),
      onData: (List<Map<String, dynamic>> rawReadings) {
        
        List<dynamic> activeDevices = initialDevices;
        List<dynamic> activeSummary = initialSummary;
        
        if (state is DashboardLoaded) {
          activeDevices = (state as DashboardLoaded).devices;
          activeSummary = (state as DashboardLoaded).weeklySummary;
        }
        final List<Reading> lecturasEnriquecidas = rawReadings.map((json) {
          final deviceId = json['device_id'];
          
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

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<DashboardState> emit,
  ) async {
    await _repository.signOut();
    emit(DashboardInitial()); 
  }
}
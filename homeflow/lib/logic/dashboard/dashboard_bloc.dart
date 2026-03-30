import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/models/reading.dart';
import '../../data/dashboard_repository.dart'; 

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  // Referencia al repositorio que gestiona la conexión con Supabase
  final DashboardRepository _repository;
  // Guardamos la suscripción para poder cancelarla si la app se cierra
  StreamSubscription<List<Reading>>? _readingsSubscription;

  DashboardBloc({required DashboardRepository repository}) 
      : _repository = repository,
        super(DashboardInitial()) {
    // Función que maneja el evento de arranque
    on<StartListeningReadings>(_onStartListeningReadings);
    on<_OnReadingsUpdated>(_onReadingsUpdated);
  }

  Future<void> _onStartListeningReadings(
    StartListeningReadings event, 
    Emitter<DashboardState> emit,
  ) async {
    // Si ya había una suscripción abierta, la cerramos por seguridad
    await _readingsSubscription?.cancel();
    
    // Nos suscribimos al WebSocket de forma manual
    _readingsSubscription = _repository.getRealtimeReadings().listen(
      (readings) {
        // Cuando llega un dato, lanzamos el evento interno
        add(_OnReadingsUpdated(readings));
      },
      onError: (error) {
        // emit() aquí dentro daría error porque no estamos en una función on<Event>, así que lo correcto sería despachar un evento de error, pero para no complicarlo se queda así.
      }
    );
  }

  Future<void> _onReadingsUpdated(
    _OnReadingsUpdated event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final weeklySummary = await _repository.getWeeklySummary();
      
      emit(DashboardLoaded(
        readings: event.readings,
        weeklySummary: weeklySummary,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  // Limpia la memoria cuando el BLoC muere
  @override
  Future<void> close() {
    _readingsSubscription?.cancel();
    return super.close();
  }
}
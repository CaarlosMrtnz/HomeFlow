import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/models/reading.dart';
import '../../data/dashboard_repository.dart'; 

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  // Referencia al repositorio que gestiona la conexión con Supabase
  final DashboardRepository _repository;

  DashboardBloc({required DashboardRepository repository}) 
      : _repository = repository,
        super(DashboardInitial()) {
    // Función que maneja el evento de arranque
    on<StartListeningReadings>(_onStartListeningReadings);
  }

  Future<void> _onStartListeningReadings(
    StartListeningReadings event, 
    Emitter<DashboardState> emit,
  ) async {
    // emit avisa a la UI para que pinte la animación de carga
    emit(DashboardLoading());
    
    // emit.forEach gestiona automáticamente la suscripción y la cierra si el BLoC se destruye
    await emit.forEach<List<Reading>>(
      _repository.getRealtimeReadings(),
      // Cada vez que el simulador de Python inserta un dato, entra por aquí.
      onData: (readings) => DashboardLoaded(readings),
      onError: (error, stackTrace) => DashboardError(error.toString()),
    );
  }
}
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/models/alert.dart';
import '../../data/alerts_repository.dart';

part 'alerts_event.dart';
part 'alerts_state.dart';

class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {

    // Referencia al repositorio que gestiona la conexión con Supabase
    final AlertsRepository _alertsRepository;

    AlertsBloc({required AlertsRepository alertsRepository})
        : _alertsRepository = alertsRepository,

        super(AlertsInitial()) {
            // Función que maneja el evento de arranque
            on<StartListeningAlerts>(_onStartListeningAlerts);
            on<MarkAlertAsRead>(_onMarkAlertAsRead);
        }

    Future<void> _onStartListeningAlerts(
        StartListeningAlerts event,
        Emitter<AlertsState> emit,
    ) async {
        // emit avisa a la UI para que pinte la animación de carga
        emit(AlertsLoading());

        // emit.forEach gestiona automáticamente la suscripción y la cierra si el BLoC se destruye
        await emit.forEach<List<Alert>>(
            _alertsRepository.getRealtimeAlerts(),
            // Cada vez que el simulador de Python inserta un dato, entra por aquí. 
            onData: (alertsList) {
            return AlertsLoaded(alertsList);
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
            
            // No se emite un estado de éxito tras actualizar. Al estar enganchados al stream en tiempo real, el update en BD disparará el onData de arriba automáticamente.
            await _alertsRepository.markAsRead(event.alertId);

        } catch (e) {
            print("Error marcando alerta como leída: $e");
        }
    }
}
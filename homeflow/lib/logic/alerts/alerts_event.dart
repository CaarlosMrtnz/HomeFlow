part of 'alerts_bloc.dart';

// Clase base para todas las acciones que le vamos a pedir al BLoC desde la interfaz.
/// Define la jerarquía cerrada de eventos para el BLoC de alertas utilizando el modificador `sealed`.
/// Esto fuerza al compilador a exigir un manejo exhaustivo (pattern matching) en los switch del bloc o de la UI con Dart 3.
sealed class AlertsEvent extends Equatable {
  const AlertsEvent();
  @override
  List<Object> get props => [];
}

// Cerrar las clases con 'final' evita herencias indeseadas, pues un evento representa una intención única y plana de la UI, no necesitamos sub-eventos.
/// Dispara la suscripción al stream de Supabase para iniciar la escucha de alertas en tiempo real.
final class StartListeningAlerts extends AlertsEvent {}

/// Acción para actualizar el estado de lectura de una alerta específica en la base de datos.
final class MarkAlertAsRead extends AlertsEvent {
  final int alertId;
  const MarkAlertAsRead(this.alertId);
  @override
  List<Object> get props => [alertId];
}
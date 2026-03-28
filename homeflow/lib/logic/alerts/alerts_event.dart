part of 'alerts_bloc.dart';

// Clase base para todas las acciones que le vamos a pedir al BLoC desde la interfaz.
sealed class AlertsEvent extends Equatable {
  const AlertsEvent();
  @override
  List<Object> get props => [];
}

// Cerrar las clases con 'final' evita herencias indeseadas, pues un evento representa una intención única y plana de la UI, no necesitamos sub-eventos.
final class StartListeningAlerts extends AlertsEvent {}

final class MarkAlertAsRead extends AlertsEvent {
  final int alertId;
  const MarkAlertAsRead(this.alertId);
  @override
  List<Object> get props => [alertId];
}
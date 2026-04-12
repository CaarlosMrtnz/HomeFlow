part of 'dashboard_bloc.dart';

// Clase base para todas las acciones que se le piden al BLoC desde la interfaz.
sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

// Evento que lanzamos desde el initState de la pantalla principal para arrancar la suscripción al Stream de la base de datos.
final class StartListeningReadings extends DashboardEvent {}

// Evento interno que salta cuando el stream escupe datos
class _OnReadingsUpdated extends DashboardEvent {
  final List<Reading> readings;

  const _OnReadingsUpdated(this.readings);

  @override
  List<Object> get props => [readings];
}

class AddDeviceRequested extends DashboardEvent {
  final String name;
  final int supplyTypeId;
  final String iconName;

  const AddDeviceRequested(this.name, this.supplyTypeId, this.iconName);

  @override
  List<Object> get props => [name, supplyTypeId, iconName];
}

class DeleteDeviceRequested extends DashboardEvent {
  final int deviceId;

  const DeleteDeviceRequested(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}
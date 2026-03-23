part of 'dashboard_bloc.dart';

// Clase base para todas las acciones que le vamos a pedir al BLoC desde la interfaz.
sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

// Evento que lanzamos desde el initState de la pantalla principal para arrancar la suscripción al Stream de la base de datos.
final class StartListeningReadings extends DashboardEvent {}
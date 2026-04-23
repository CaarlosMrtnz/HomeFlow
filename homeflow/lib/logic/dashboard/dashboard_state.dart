part of 'dashboard_bloc.dart';

/// Clase base inmutable para el árbol de estados de la pantalla principal.
// Con 'sealed class' se obliga a la UI a manejar todos los estados en un switch.
sealed class DashboardState extends Equatable {
  const DashboardState();
  
  @override
  List<Object> get props => [];
}

/// Representa el momento previo a la inicialización de la suscripción de datos.
// Estado de arranque. La app acaba de abrirse y aún no hemos pedido datos.
final class DashboardInitial extends DashboardState {}

/// Indicador de proceso asíncrono en curso (ej. primer volcado de base de datos).
// Estado de espera. Le indica a la UI que debe mostrar un CircularProgressIndicator.
final class DashboardLoading extends DashboardState {}

/// Encapsula el modelo de datos renderizable tras una lectura exitosa o actualización del stream.
// El estado principal. Aquí guardamos las lecturas que llegan desde Supabase.
final class DashboardLoaded extends DashboardState {
  final List<Reading> readings; // Para las tarjetas en tiempo real
  final List<dynamic> weeklySummary; 
  final List<dynamic> devices;
  
  const DashboardLoaded({
    required this.readings,
    required this.weeklySummary,
    required this.devices,
  });

  // Pasamos las listas a props para que Equatable sepa cuándo repintar la pantalla.
  @override
  List<Object> get props => [readings, weeklySummary, devices];
}

/// Contenedor genérico para excepciones de red, parseo o permisos capturadas en el BLoC.
final class DashboardError extends DashboardState {
  final String message;
  
  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
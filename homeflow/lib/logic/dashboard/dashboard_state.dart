part of 'dashboard_bloc.dart';

// Con 'sealed class' se obliga a la UI a manejar todos los estados en un switch.
sealed class DashboardState extends Equatable {
  const DashboardState();
  
  @override
  List<Object> get props => [];
}

// Estado de arranque. La app acaba de abrirse y aún no hemos pedido datos.
final class DashboardInitial extends DashboardState {}

// Estado de espera. Le indica a la UI que debe mostrar un CircularProgressIndicator.
final class DashboardLoading extends DashboardState {}

// El estado principal. Aquí guardamos las lecturas que llegan desde Supabase
final class DashboardLoaded extends DashboardState {
  final List<Reading> readings;
  
  const DashboardLoaded(this.readings);

  // Se pasa de 'readings' a props para que Equatable compare si la lista ha cambiado realmente. Si es igual, Flutter no repinta la pantalla (ahorro de recursos).
  @override
  List<Object> get props => [readings];
}

// Estado en caso de fallo de la conexión con el repositorio o por una caída de internet.
final class DashboardError extends DashboardState {
  final String message;
  
  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
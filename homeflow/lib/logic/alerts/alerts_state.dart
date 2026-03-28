part of 'alerts_bloc.dart';

// Con 'sealed class' se obliga a la UI a manejar todos los estados en un switch.
sealed class AlertsState extends Equatable {
  const AlertsState();

  @override
  List<Object> get props => [];
}

// Bloquear estos estados con 'final' evita que otro desarrollador extienda de ellos fuera de este archivo.
// Estado de arranque. La app acaba de abrirse y aún no hemos pedido datos.
final class AlertsInitial extends AlertsState {}

// Estado de espera. Le indica a la UI que debe mostrar un CircularProgressIndicator.
final class AlertsLoading extends AlertsState {}

// El estado principal. Aquí guardamos las lecturas que llegan desde Supabase.
final class AlertsLoaded extends AlertsState {
  final List<Alert> alerts;
  const AlertsLoaded(this.alerts);
  // Se pasa de 'alerts' a props para que Equatable compare si la lista ha cambiado realmente. Si es igual, Flutter no repinta la pantalla (ahorro de recursos).
  // Al ser una lista, Equatable hace una comparación profunda (elemento a elemento). Esto funciona de forma transparente porque nuestro modelo Alert también implementa Equatable
  @override
  List<Object> get props => [alerts];
}

// Estado en caso de fallo de la conexión con el repositorio o por una caída de internet.
final class AlertsError extends AlertsState {
  final String message;
  const AlertsError(this.message);
  @override
  List<Object> get props => [message];
}
part of 'auth_bloc.dart';

/// Clase base inmutable para los eventos de autenticación.
/// Al usar `sealed`, el compilador de Dart obliga a manejar exhaustivamente todos los casos posibles en el BLoC, evitando estados huérfanos.
sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

/// Dispara la inicialización del BLoC y la suscripción al flujo reactivo de sesión de Supabase.
final class AuthSubscriptionRequested extends AuthEvent {}

/// Solicita la destrucción del token local y el cierre de sesión en el backend.
final class AuthLogoutRequested extends AuthEvent {}
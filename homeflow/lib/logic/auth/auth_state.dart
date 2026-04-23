part of 'auth_bloc.dart';

/// Clase base inmutable que representa los diferentes estados de la sesión del usuario.
/// Al ser `sealed`, el compilador fuerza a que cualquier `switch` o `bloc builder` en la UI maneje todos los casos posibles.
sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// Estado de transición inicial mientras el BLoC comprueba la caché local o valida el token.
final class AuthInitial extends AuthState {}

/// Representa una sesión activa y verificada.
/// Almacena el objeto de usuario de Supabase para que la UI pueda acceder rápidamente a su ID o metadatos básicos sin reconsultar al repositorio.
final class Authenticated extends AuthState {
  final spb.User user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

/// Indica que no hay sesión activa, el token expiró o el usuario cerró sesión voluntariamente.
final class Unauthenticated extends AuthState {}
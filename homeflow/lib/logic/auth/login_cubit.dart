import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';

/// Clase base para los estados del formulario de autenticación.
abstract class LoginState {}
/// Estado inicial, el formulario está a la espera de interacción.
class LoginInitial extends LoginState {}
/// Indica que hay una petición de red en curso. Deshabilita botones en la UI para evitar doble envío.
class LoginLoading extends LoginState {}
/// Autenticación o registro completado con éxito.
class LoginSuccess extends LoginState {}
/// Fallo en la petición. Encapsula el mensaje de error para pintarlo en la UI (ej. SnackBar).
class LoginFailure extends LoginState {
  final String error;
  LoginFailure(this.error);
}

/// Cubit que gestiona la lógica de presentación exclusiva para la pantalla de Login/Registro.
/// A diferencia de un BLoC completo, usa métodos directos en lugar de eventos por la simplicidad de la acción.
class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  /// Inyecta la dependencia del repositorio por constructor.
  LoginCubit({required AuthRepository authRepository}) 
      : _authRepository = authRepository, 
        super(LoginInitial());

  /// Intenta iniciar sesión con credenciales existentes en Supabase.
  Future<void> signIn(String email, String password) async {
    emit(LoginLoading());
    try {
      await _authRepository.signInWithEmail(email: email, password: password);
      emit(LoginSuccess());
    } catch (e) {
      // Supabase devuelve errores legibles (ej. "Invalid login credentials")
      emit(LoginFailure(e.toString()));
    }
  }

  /// Registra un nuevo usuario mediante correo y contraseña.
  Future<void> signUp(String email, String password) async {
    emit(LoginLoading());
    try {
      await _authRepository.signUpWithEmail(email: email, password: password);
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
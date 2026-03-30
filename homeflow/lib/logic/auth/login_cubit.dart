import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';

abstract class LoginState {}
class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginSuccess extends LoginState {}
class LoginFailure extends LoginState {
  final String error;
  LoginFailure(this.error);
}

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit({required AuthRepository authRepository}) 
      : _authRepository = authRepository, 
        super(LoginInitial());

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
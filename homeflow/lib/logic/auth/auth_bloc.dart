import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as spb;

import '../../data/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthSubscriptionRequested>(_onAuthSubscriptionRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Pausa por diseño para lucir el logo y eslogan de la 'marca' 
    await Future.delayed(const Duration(milliseconds: 3500));
    // Comprobación inicial nada más abrir la app
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      emit(Authenticated(currentUser));
    } else {
      emit(Unauthenticated());
    }

    // Suscripción a los cambios en tiempo real
    await emit.forEach<spb.AuthState>(
      _authRepository.authStateChanges,
      onData: (supabaseAuthState) {
        final session = supabaseAuthState.session;
        if (session != null) {
          // Si hay sesión válida, entra
          return Authenticated(session.user);
        } else {
          // Si el token expira o la sesión es nula, te echamos
          return Unauthenticated();
        }
      },
      onError: (error, stackTrace) => Unauthenticated(), // Ante cualquier fallo de seguridad, cerramos la puerta
    );
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Le decimos al repositorio que destruya el token. Al destruir el token, el Stream de arriba reaccionará solo y lo emitirá por nosotros.
    await _authRepository.signOut();
  }
}
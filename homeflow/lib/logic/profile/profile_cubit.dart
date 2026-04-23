import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/profile_repository.dart';
import '../../core/models/profile.dart';

/// Clase base para representar el estado de la vista del perfil.
abstract class ProfileState {}
/// Estado de inicialización antes de realizar peticiones de red.
class ProfileInitial extends ProfileState {}
/// Operación asíncrona en curso. Útil para mostrar skeletons o bloqueadores de pantalla.
class ProfileLoading extends ProfileState {}
/// Estado de éxito que encapsula la entidad del usuario lista para pintarse.
class ProfileLoaded extends ProfileState {
  final Profile profile;
  ProfileLoaded(this.profile);
}
/// Contenedor de excepciones capturadas para delegar su renderizado (ej. SnackBar).
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

/// Cubit que orquesta las operaciones de lectura y escritura del perfil del usuario,
/// separando la lógica de negocio de la interfaz gráfica.
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  /// Inyecta la dependencia del repositorio.
  ProfileCubit({required ProfileRepository repository})
      : _repository = repository,
        super(ProfileInitial());

  /// Solicita el perfil al backend y gestiona las transiciones de estado de carga.
  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final profile = await _repository.getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  /// Envía la actualización parcial de los datos al servidor.
  Future<void> updateProfile(String fullName, String phoneNumber) async {
    try {
      await _repository.updateProfile(fullName: fullName, phoneNumber: phoneNumber);
      await loadProfile(); // Si va bien, recargamos y emitimos el nuevo perfil
    } catch (e) {
      rethrow; // Lanzamos el error para que lo capture el botón en la UI
    }
  }
}
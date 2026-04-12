import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/profile_repository.dart';
import '../../core/models/profile.dart';

abstract class ProfileState {}
class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final Profile profile;
  ProfileLoaded(this.profile);
}
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit({required ProfileRepository repository})
      : _repository = repository,
        super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final profile = await _repository.getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile(String fullName, String phoneNumber) async {
    try {
      await _repository.updateProfile(fullName: fullName, phoneNumber: phoneNumber);
      await loadProfile(); // Si va bien, recargamos y emitimos el nuevo perfil
    } catch (e) {
      rethrow; // Lanzamos el error para que lo capture el botón en la UI
    }
  }
}
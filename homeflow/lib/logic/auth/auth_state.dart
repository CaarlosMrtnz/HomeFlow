part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {}

final class Authenticated extends AuthState {
  final spb.User user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

final class Unauthenticated extends AuthState {}
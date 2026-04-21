part of 'auth_cubit.dart';

sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String userId;
  AuthSuccess(this.userId);
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

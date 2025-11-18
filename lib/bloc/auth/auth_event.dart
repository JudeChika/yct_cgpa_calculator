part of 'auth_bloc.dart'; // This connects the files

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

// Event triggered when the auth state changes (e.g., login, logout)
class _AuthUserChanged extends AuthEvent {
  final User? user;
  const _AuthUserChanged(this.user);
}

// Event triggered when the user taps the "Logout" button
class AuthSignOutRequested extends AuthEvent {}
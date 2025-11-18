import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription<User?> _userSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.unknown()) {

    // Subscribe to the auth repository's user stream
    _userSubscription = _authRepository.user.listen((user) {
      // Add an event to the bloc when the user changes
      add(_AuthUserChanged(user));
    });

    // Define event handlers
    on<_AuthUserChanged>(_onAuthUserChanged);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  // Handle the user change
  void _onAuthUserChanged(_AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthState.authenticated(event.user!));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  // Handle the sign-out request
  void _onSignOutRequested(AuthSignOutRequested event, Emitter<AuthState> emit) {
    _authRepository.signOut();
  }

  @override
  Future<void> close() {
    _userSubscription.cancel(); // Always cancel subscriptions!
    return super.close();
  }
}
import 'package:bloc/bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for the exception

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit(this._authRepository) : super(const LoginState());

  void emailChanged(String value) {
    emit(state.copyWith(email: value));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value));
  }

  Future<void> logInWithCredentials() async {
    if (state.status == LoginStatus.loading) return;

    emit(state.copyWith(status: LoginStatus.loading));

    try {
      await _authRepository.signIn(
        email: state.email,
        password: state.password,
      );
      // We don't need to emit success, because the
      // AuthBloc will see the user change and the Wrapper
      // will navigate us to the DashboardScreen automatically.

      // But for completeness, we can emit success
      emit(state.copyWith(status: LoginStatus.success));

    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      String message = 'An unknown error occurred.';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid credentials. Please check your email and password.';
      }
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: message));
    } catch (_) {
      // Handle any other errors
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: 'An error occurred. Please try again.'));
    }
  }
}
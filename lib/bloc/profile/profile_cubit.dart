import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yct_cgpa_calculator/bloc/profile/profile_state.dart';

import '../../domain/models/profiles.dart';
import '../../domain/repositories/user_repositories.dart';


/// ProfileCubit loads and updates the current user's profile using UserRepository.
/// It also listens to FirebaseAuth state changes to react when user signs in/out.
class ProfileCubit extends Cubit<ProfileState> {
  final UserRepository _userRepository;
  late final StreamSubscription<User?> _authSub;

  ProfileCubit({required UserRepository userRepository, required Stream<User?> authStream})
      : _userRepository = userRepository,
        super(const ProfileState.initial()) {
    // Listen to auth state changes
    _authSub = authStream.listen((user) {
      if (user != null) {
        loadProfile(user.uid);
      } else {
        emit(const ProfileState.unauthenticated());
      }
    });
  }

  Future<void> loadProfile(String uid) async {
    emit(const ProfileState.loading());
    try {
      final profile = await _userRepository.getProfile(uid);
      if (profile != null) {
        emit(ProfileState.loaded(profile));
      } else {
        emit(const ProfileState.notFound());
      }
    } catch (e, st) {
      emit(ProfileState.failure('Failed to load profile: $e'));
    }
  }

  Future<void> updateProfile(Profile profile) async {
    emit(ProfileState.saving(profile));
    try {
      await _userRepository.updateProfile(profile);
      emit(ProfileState.loaded(profile));
    } catch (e) {
      emit(ProfileState.failure('Failed to update profile: $e'));
    }
  }

  @override
  Future<void> close() {
    _authSub.cancel();
    return super.close();
  }
}
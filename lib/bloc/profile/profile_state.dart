import 'package:equatable/equatable.dart';
import '../../domain/models/profiles.dart';

enum ProfileStatus { initial, loading, loaded, notFound, saving, failure, unauthenticated }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final Profile? profile;
  final String? message;

  const ProfileState._({this.status = ProfileStatus.initial, this.profile, this.message});

  const ProfileState.initial() : this._();

  const ProfileState.loading() : this._(status: ProfileStatus.loading);

  const ProfileState.notFound() : this._(status: ProfileStatus.notFound);

  const ProfileState.unauthenticated() : this._(status: ProfileStatus.unauthenticated);

  const ProfileState.failure(String message) : this._(status: ProfileStatus.failure, message: message);

  const ProfileState.loaded(Profile profile) : this._(status: ProfileStatus.loaded, profile: profile);

  const ProfileState.saving(Profile profile) : this._(status: ProfileStatus.saving, profile: profile);

  @override
  List<Object?> get props => [status, profile, message];
}
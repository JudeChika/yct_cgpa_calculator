// Interface for user/profile storage. Implemented by FirebaseUserRepository.
import '../models/profiles.dart';

abstract class UserRepository {
  Future<void> createProfile(Profile profile);
  Future<Profile?> getProfile(String uid);
  Future<void> updateProfile(Profile profile);
}
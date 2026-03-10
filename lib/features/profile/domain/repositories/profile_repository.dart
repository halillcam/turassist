import '../../../../core/models/user_model.dart';

abstract class ProfileRepository {
  Future<UserModel?> getCurrentProfile();
  Future<void> updateProfile({required String fullName, required String email});
  Future<void> changePassword({required String currentPassword, required String newPassword});
}

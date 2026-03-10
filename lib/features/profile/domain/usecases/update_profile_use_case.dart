import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> execute({required String fullName, required String email}) {
    return _repository.updateProfile(fullName: fullName, email: email);
  }
}

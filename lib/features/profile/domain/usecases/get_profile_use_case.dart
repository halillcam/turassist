import '../../../../core/models/user_model.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  const GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<UserModel?> execute() {
    return _repository.getCurrentProfile();
  }
}

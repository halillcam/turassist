import '../../../../core/models/user_model.dart';
import '../repositories/tours_repository.dart';

class GetCurrentProfileUseCase {
  const GetCurrentProfileUseCase(this._repository);

  final ToursRepository _repository;

  Future<UserModel?> execute() {
    return _repository.getCurrentUserProfile();
  }
}

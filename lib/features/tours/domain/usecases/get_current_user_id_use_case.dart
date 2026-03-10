import '../repositories/tours_repository.dart';

class GetCurrentUserIdUseCase {
  const GetCurrentUserIdUseCase(this._repository);

  final ToursRepository _repository;

  String execute() {
    return _repository.getCurrentUserId();
  }
}

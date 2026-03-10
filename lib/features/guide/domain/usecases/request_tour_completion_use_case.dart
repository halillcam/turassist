import '../repositories/guide_repository.dart';

class RequestTourCompletionUseCase {
  RequestTourCompletionUseCase(this._repository);

  final GuideRepository _repository;

  Future<void> execute({required String tourId, required String guideId}) {
    return _repository.requestTourCompletion(tourId: tourId, guideId: guideId);
  }
}

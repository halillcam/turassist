import '../entities/guide_participant_entity.dart';
import '../repositories/guide_repository.dart';

class GetGuideParticipantsUseCase {
  GetGuideParticipantsUseCase(this._repository);

  final GuideRepository _repository;

  Future<List<GuideParticipantEntity>> execute({required String tourId}) {
    return _repository.getParticipants(tourId: tourId);
  }
}

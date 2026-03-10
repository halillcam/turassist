import '../repositories/tours_repository.dart';

class GetTourSlotCountsUseCase {
  const GetTourSlotCountsUseCase(this._repository);

  final ToursRepository _repository;

  Future<Map<String, int>> execute(String tourId, List<String> slotIds) {
    return _repository.getSlotTicketCounts(tourId, slotIds);
  }
}

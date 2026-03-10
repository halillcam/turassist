import '../../../../core/models/tour_program_model.dart';
import '../repositories/tours_repository.dart';

class GetTourProgramUseCase {
  const GetTourProgramUseCase(this._repository);

  final ToursRepository _repository;

  Future<List<TourProgramDay>> execute(String tourId) {
    return _repository.getTourProgram(tourId);
  }
}

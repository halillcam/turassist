import '../../../../core/models/tour_model.dart';
import '../repositories/tours_repository.dart';

class GetToursUseCase {
  const GetToursUseCase(this._repository);

  final ToursRepository _repository;

  Future<List<TourModel>> execute({String? city}) {
    return _repository.getTours(city: city);
  }
}

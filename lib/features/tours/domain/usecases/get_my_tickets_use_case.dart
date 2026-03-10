import '../../../../core/models/ticket_model.dart';
import '../repositories/tours_repository.dart';

class GetMyTicketsUseCase {
  const GetMyTicketsUseCase(this._repository);

  final ToursRepository _repository;

  Future<List<TicketModel>> execute() {
    return _repository.getUserTickets();
  }
}

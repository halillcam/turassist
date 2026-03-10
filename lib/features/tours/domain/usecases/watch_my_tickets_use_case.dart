import '../../../../core/models/ticket_model.dart';
import '../repositories/tours_repository.dart';

class WatchMyTicketsUseCase {
  const WatchMyTicketsUseCase(this._repository);

  final ToursRepository _repository;

  Stream<List<TicketModel>> execute() {
    return _repository.watchUserTickets();
  }
}

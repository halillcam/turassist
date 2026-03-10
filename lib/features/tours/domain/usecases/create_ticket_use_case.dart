import '../../../../core/models/ticket_model.dart';
import '../repositories/tours_repository.dart';

class CreateTicketUseCase {
  const CreateTicketUseCase(this._repository);

  final ToursRepository _repository;

  Future<({String ticketId, String qrToken})> execute(TicketModel ticket) {
    return _repository.createTicket(ticket);
  }
}

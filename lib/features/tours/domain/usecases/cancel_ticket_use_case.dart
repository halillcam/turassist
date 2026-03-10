import '../repositories/tours_repository.dart';

class CancelTicketUseCase {
  const CancelTicketUseCase(this._repository);

  final ToursRepository _repository;

  Future<bool> execute(String ticketId) {
    return _repository.updateTicketStatus(ticketId, 'cancelled');
  }
}

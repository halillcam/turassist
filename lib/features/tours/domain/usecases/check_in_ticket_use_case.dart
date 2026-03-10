import '../repositories/tours_repository.dart';

class CheckInTicketUseCase {
  const CheckInTicketUseCase(this._repository);

  final ToursRepository _repository;

  Future<bool> execute(String ticketId) {
    return _repository.updateTicketQrStatus(ticketId);
  }
}

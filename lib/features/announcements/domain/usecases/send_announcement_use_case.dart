import '../repositories/announcement_repository.dart';

class SendAnnouncementUseCase {
  SendAnnouncementUseCase(this._repository);

  final AnnouncementRepository _repository;
  static const int maxLength = 280;

  Future<void> execute({required String tourId, required String message}) async {
    final normalizedMessage = message.trim();
    if (tourId.trim().isEmpty) {
      throw Exception('Tur bulunamadı.');
    }
    if (normalizedMessage.isEmpty) {
      throw Exception('Duyuru mesajı boş olamaz.');
    }
    if (normalizedMessage.length > maxLength) {
      throw Exception('Duyuru en fazla $maxLength karakter olabilir.');
    }

    await _repository.sendAnnouncementToCheckedInParticipants(
      tourId: tourId,
      message: normalizedMessage,
    );
  }
}

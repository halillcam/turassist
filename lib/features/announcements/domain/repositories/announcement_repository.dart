import '../entities/announcement_entity.dart';

abstract class AnnouncementRepository {
  Stream<List<AnnouncementEntity>> watchAnnouncements(String tourId);

  Future<void> sendAnnouncementToCheckedInParticipants({
    required String tourId,
    required String message,
  });
}

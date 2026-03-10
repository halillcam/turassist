import '../entities/announcement_entity.dart';
import '../repositories/announcement_repository.dart';

class ObserveAnnouncementsUseCase {
  ObserveAnnouncementsUseCase(this._repository);

  final AnnouncementRepository _repository;

  Stream<List<AnnouncementEntity>> execute(String tourId) {
    return _repository.watchAnnouncements(tourId);
  }
}

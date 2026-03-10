import 'dart:async';

import '../../domain/entities/announcement_entity.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../datasources/announcement_remote_data_source.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  AnnouncementRepositoryImpl({AnnouncementRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? AnnouncementRemoteDataSource();

  final AnnouncementRemoteDataSource _remoteDataSource;

  @override
  Stream<List<AnnouncementEntity>> watchAnnouncements(String tourId) {
    final controller = StreamController<List<AnnouncementEntity>>();
    StreamSubscription<List<AnnouncementEntity>>? primarySubscription;
    StreamSubscription<List<AnnouncementEntity>>? fallbackSubscription;

    Future<void> start() async {
      final userId = await _remoteDataSource.getCurrentUserId();
      primarySubscription = _remoteDataSource
          .watchTourAnnouncements(tourId)
          .map((items) => items.map((item) => item.toEntity()).toList())
          .listen(
            controller.add,
            onError: (error) {
              final message = error.toString().toLowerCase();
              final hasPermissionError =
                  message.contains('permission_denied') ||
                  message.contains('missing or insufficient permissions');

              if (!hasPermissionError || userId.isEmpty) {
                controller.addError(error);
                return;
              }

              fallbackSubscription?.cancel();
              fallbackSubscription = _remoteDataSource
                  .watchUserAnnouncements(userId, tourId)
                  .map((items) => items.map((item) => item.toEntity()).toList())
                  .listen(controller.add, onError: controller.addError);
            },
          );
    }

    start();
    controller.onCancel = () async {
      await primarySubscription?.cancel();
      await fallbackSubscription?.cancel();
    };
    return controller.stream;
  }

  @override
  Future<void> sendAnnouncementToCheckedInParticipants({
    required String tourId,
    required String message,
  }) {
    return _remoteDataSource.sendAnnouncementToCheckedInParticipants(
      tourId: tourId,
      message: message,
    );
  }
}

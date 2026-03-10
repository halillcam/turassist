import '../../../../core/models/tour_model.dart';
import '../../domain/entities/guide_dashboard_entity.dart';
import '../../domain/entities/guide_participant_entity.dart';
import '../../domain/entities/guide_qr_scan_result_entity.dart';
import '../../domain/repositories/guide_repository.dart';
import '../datasources/guide_local_data_source.dart';
import '../datasources/guide_remote_data_source.dart';

class GuideRepositoryImpl implements GuideRepository {
  GuideRepositoryImpl({
    GuideLocalDataSource? localDataSource,
    GuideRemoteDataSource? remoteDataSource,
  }) : _localDataSource = localDataSource ?? GuideLocalDataSource(),
       _remoteDataSource = remoteDataSource ?? GuideRemoteDataSource();

  final GuideLocalDataSource _localDataSource;
  final GuideRemoteDataSource _remoteDataSource;

  @override
  Future<GuideDashboardEntity> getDashboard() async {
    final cachedGuideId = await _localDataSource.getGuideId();
    final cachedGuideName = await _localDataSource.getGuideName();
    final currentUserId = await _remoteDataSource.getCurrentUserId();
    final currentUserRole = (await _remoteDataSource.getCurrentUserRole() ?? '').trim();
    final currentUserName = (await _remoteDataSource.getCurrentUserName() ?? '').trim();
    final isGuideSession = await _localDataSource.getIsGuideSession();
    final isGuideUser = isGuideSession || currentUserRole.toLowerCase() == 'guide';

    final guideId = cachedGuideId.isNotEmpty ? cachedGuideId : currentUserId;
    final nameSeed = currentUserName.isNotEmpty
        ? currentUserName
        : (cachedGuideName.isNotEmpty ? cachedGuideName : 'Tur Sorumlusu');
    final guideName = guideId.isEmpty
        ? nameSeed
        : await _remoteDataSource.resolveGuideName(guideId, defaultName: nameSeed);

    if (!isGuideUser || guideId.isEmpty) {
      return GuideDashboardEntity(guideId: guideId, guideName: guideName, isGuideUser: isGuideUser);
    }

    final assignedTour = await _remoteDataSource.getAssignedTourForGuide(guideId) as TourModel?;
    if (assignedTour == null) {
      return GuideDashboardEntity(guideId: guideId, guideName: guideName, isGuideUser: true);
    }

    final assignedSlotId = _resolveAssignedSlotId(assignedTour);
    final participants = await _remoteDataSource.getTourParticipants(assignedTour.id);
    final activeParticipants = participants.where((item) {
      final status = item['status']?.toString().toLowerCase() ?? '';
      if (status == 'cancelled') {
        return false;
      }
      final slotId = item['slotId']?.toString() ?? '';
      final isDateSlot = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(slotId);
      return !(isDateSlot && assignedSlotId != null && assignedSlotId != slotId);
    }).toList();

    final checkedInCount = activeParticipants.where((item) {
      final status = item['status']?.toString().toLowerCase() ?? '';
      return item['isScanned'] == true || status == 'checked_in';
    }).length;

    bool hasPendingCompletionRequest = false;
    try {
      hasPendingCompletionRequest = await _remoteDataSource.hasPendingTourCompletionRequest(
        tourId: assignedTour.id,
        guideId: guideId,
      );
    } catch (_) {
      hasPendingCompletionRequest = false;
    }

    return GuideDashboardEntity(
      guideId: guideId,
      guideName: guideName,
      isGuideUser: true,
      tourId: assignedTour.id,
      tourTitle: assignedTour.title,
      companyId: assignedTour.companyId,
      totalParticipants: activeParticipants.length,
      checkedInParticipants: checkedInCount,
      assignedSlotId: assignedSlotId,
      hasPendingCompletionRequest: hasPendingCompletionRequest,
    );
  }

  @override
  Future<List<GuideParticipantEntity>> getParticipants({required String tourId}) async {
    final dashboard = await getDashboard();
    if (tourId.trim().isEmpty) {
      tourId = dashboard.tourId;
    }
    if (tourId.trim().isEmpty) {
      return const [];
    }

    final participants = await _remoteDataSource.getTourParticipants(tourId);
    return participants
        .where((item) {
          final status = item['status']?.toString().toLowerCase() ?? '';
          if (status == 'cancelled') {
            return false;
          }
          final slotId = item['slotId']?.toString() ?? '';
          final isDateSlot = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(slotId);
          return !(isDateSlot &&
              dashboard.assignedSlotId != null &&
              dashboard.assignedSlotId != slotId);
        })
        .map((item) {
          final status = item['status']?.toString().toLowerCase() ?? '';
          final arrived = item['isScanned'] == true || status == 'checked_in';
          final name = item['passengerName']?.toString().trim();
          final tcNo = item['tcNo']?.toString().trim();
          return GuideParticipantEntity(
            id: item['id']?.toString() ?? '',
            name: name == null || name.isEmpty ? 'İsimsiz Katılımcı' : name,
            subtitle: tcNo == null || tcNo.isEmpty ? 'Kimlik bilgisi yok' : 'TC: $tcNo',
            arrived: arrived,
          );
        })
        .toList();
  }

  @override
  Future<void> requestTourCompletion({required String tourId, required String guideId}) {
    return _remoteDataSource.requestTourCompletion(tourId: tourId, guideId: guideId);
  }

  @override
  Future<GuideQrScanResultEntity> scanQr({
    required String qrToken,
    required String expectedTourId,
    String? expectedDate,
  }) async {
    final result = await _remoteDataSource.scanQr(
      qrToken: qrToken,
      expectedTourId: expectedTourId,
      expectedDate: expectedDate,
    );
    return GuideQrScanResultEntity(
      success: result.success,
      code: result.code,
      message: result.message,
      passengerName: result.passengerName,
    );
  }

  String? _resolveAssignedSlotId(TourModel tour) {
    final departureDate = tour.departureDate;
    if (departureDate != null) {
      return _formatDate(departureDate);
    }
    final departureDates = tour.departureDates;
    if (departureDates != null && departureDates.isNotEmpty) {
      return _formatDate(departureDates.first);
    }
    return null;
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

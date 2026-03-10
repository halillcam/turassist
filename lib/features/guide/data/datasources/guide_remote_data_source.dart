import '../../../../core/services/auth_service.dart';
import '../../../../core/services/ticket_service.dart';
import '../../../../core/services/tour_service.dart';

class GuideRemoteDataSource {
  GuideRemoteDataSource({
    AuthService? authService,
    TourService? tourService,
    TicketService? ticketService,
  }) : _authService = authService ?? AuthService(),
       _tourService = tourService ?? TourService(),
       _ticketService = ticketService ?? TicketService();

  final AuthService _authService;
  final TourService _tourService;
  final TicketService _ticketService;

  Future<String> getCurrentUserId() async {
    return _authService.getCurrentUserId().trim();
  }

  Future<String> resolveGuideName(String guideId, {String defaultName = 'Tur Sorumlusu'}) {
    return _authService.getGuideFullName(guideId, defaultName: defaultName);
  }

  Future<String?> getCurrentUserRole() async {
    final profile = await _authService.getUserProfile();
    return profile?.role;
  }

  Future<String?> getCurrentUserName() async {
    final profile = await _authService.getUserProfile();
    return profile?.fullName;
  }

  Future<dynamic> getAssignedTourForGuide(String guideId) {
    return _tourService.getAssignedTourForGuide(guideId);
  }

  Future<List<Map<String, dynamic>>> getTourParticipants(String tourId) {
    return _tourService.getTourParticipants(tourId);
  }

  Future<bool> hasPendingTourCompletionRequest({required String tourId, required String guideId}) {
    return _tourService.hasPendingTourCompletionRequest(tourId: tourId, guideId: guideId);
  }

  Future<void> requestTourCompletion({required String tourId, required String guideId}) {
    return _tourService.requestTourCompletion(tourId: tourId, guideId: guideId);
  }

  Future<QrConsumeResult> scanQr({
    required String qrToken,
    required String expectedTourId,
    String? expectedDate,
  }) {
    return _ticketService.consumeTicketByQrTokenDetailed(
      qrToken: qrToken,
      expectedTourId: expectedTourId,
      expectedDate: expectedDate,
    );
  }
}

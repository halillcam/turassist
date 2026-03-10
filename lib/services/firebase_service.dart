import '../models/announcement_model.dart';
import '../models/chat_model.dart';
import '../models/ticket_model.dart';
import '../models/tour_model.dart';
import '../models/tour_program_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'chat_service.dart';
import 'ticket_service.dart';
import 'tour_service.dart';

// QrConsumeResult bu dosyayı import edenler için re-export edilir
export 'ticket_service.dart' show QrConsumeResult;

/// Firebase işlemleri için geriye dönük uyumlu facade sınıfı.
///
/// Bu sınıf, domain bazlı 4 ayrı servise delege ederek çalışır:
/// - [AuthService]    Kimlik doğrulama ve kullanıcı işlemleri
/// - [TourService]    Tur listeleme ve yönetimi
/// - [TicketService]  Bilet oluşturma ve QR doğrulama
/// - [ChatService]    Sohbet mesajları ve duyurular
///
/// ### Geliştirme notu
/// Yeni yazılan controller ve servisler doğrudan ilgili domain
/// servisini import etmelidir. Bu sınıf, eski kodların kademeli
/// olarak güncellenmesi sürecinde ara katman görevi görür.
class FirebaseService {
  final AuthService _authService = AuthService();
  final TourService _tourService = TourService();
  final TicketService _ticketService = TicketService();
  final ChatService _chatService = ChatService();

  //  AuthService delegates

  /// Şu anki kullanıcının UID'sini döndürür.
  String getCurrentUserId() => _authService.getCurrentUserId();

  /// Kullanıcı profilini Firestore'dan getirir.
  Future<UserModel?> getUserProfile() => _authService.getUserProfile();

  /// Yeni müşteri hesabı oluşturur.
  Future<UserModel?> registerUser({
    required String email,
    required String password,
    required String name,
    required String surname,
  }) => _authService.registerUser(email: email, password: password, name: name, surname: surname);

  /// E-posta ve şifre ile giriş yapar; admin rolü kontrolü uygular.
  Future<UserModel?> loginAndCheckAuth(String email, String password, String companyId) =>
      _authService.loginAndCheckAuth(email, password, companyId);

  Future<UserModel?> customerLogin(String email, String password) =>
      _authService.customerLogin(email, password);

  /// Tur sorumlusu (rehber) girişi.
  Future<UserModel?> guideLogin(String guideId, String password) =>
      _authService.guideLogin(guideId, password);

  /// Firebase oturumunu kapatır.
  Future<void> logout() => _authService.logout();

  /// Şifre sıfırlama e-postası gönderir.
  Future<void> resetPassword(String email) => _authService.resetPassword(email);

  /// Kullanıcının belirtilen şirkete erişim yetkisini doğrular.
  Future<bool> isAuthorizedForCompany(String userId, String companyId) =>
      _authService.isAuthorizedForCompany(userId, companyId);

  //  TourService delegates

  /// Silinmemiş tüm aktif turları getirir.
  Future<List<TourModel>> getActiveTours() => _tourService.getActiveTours();

  /// Belirtilen şehre ait turları getirir.
  Future<List<TourModel>> getToursByCity(String city) => _tourService.getToursByCity(city);

  /// Tüm şehir isimlerini getirir.
  Future<List<String>> getAllCities() => _tourService.getAllCities();

  /// ID'ye göre tur getirir.
  Future<TourModel?> getTourById(String tourId) => _tourService.getTourById(tourId);

  /// Rehbere atanmış aktif turu getirir.
  Future<TourModel?> getAssignedTourForGuide(String guideId) =>
      _tourService.getAssignedTourForGuide(guideId);

  /// Tur programını sıralı getirir.
  Future<List<TourProgramDay>> getTourProgram(String tourId) => _tourService.getTourProgram(tourId);

  /// Turu Firestore'da günceller.
  Future<void> updateTour(String tourId, TourModel tour) => _tourService.updateTour(tourId, tour);

  /// Tur katılımcılarını getirir.
  Future<List<Map<String, dynamic>>> getTourParticipants(String tourId) =>
      _tourService.getTourParticipants(tourId);

  /// Rehberin bekleyen tur bitirme talebini kontrol eder.
  Future<bool> hasPendingTourCompletionRequest({required String tourId, required String guideId}) =>
      _tourService.hasPendingTourCompletionRequest(tourId: tourId, guideId: guideId);

  /// Tur bitirme onay talebi oluşturur.
  Future<void> requestTourCompletion({required String tourId, required String guideId}) =>
      _tourService.requestTourCompletion(tourId: tourId, guideId: guideId);

  /// Tur bitirme talebi oluşturur.
  Future<void> finishTour(String tourId, String guideId) =>
      _tourService.requestTourCompletion(tourId: tourId, guideId: guideId);

  //  TicketService delegates

  /// Tek slot için satılmış bilet sayısını döndürür.
  Future<int> getSlotTicketCount(String tourId, String slotId) =>
      _ticketService.getSlotTicketCount(tourId, slotId);

  /// Birden fazla slot için toplu kapasite sorgular.
  Future<Map<String, int>> getSlotTicketCounts(String tourId, List<String> slotIds) =>
      _ticketService.getSlotTicketCounts(tourId, slotIds);

  /// Bilet oluşturur ve QR token döndürür.
  Future<({String ticketId, String qrToken})> createTicket(TicketModel ticket) =>
      _ticketService.createTicket(ticket);

  /// Kullanıcının tüm biletlerini getirir.
  Future<List<TicketModel>> getUserTickets() => _ticketService.getUserTickets();

  /// Kullanıcı biletlerini gerçek zamanlı dinler.
  Stream<List<TicketModel>> getUserTicketsStream() => _ticketService.getUserTicketsStream();

  /// Benzersiz QR token üretir.
  Future<String> generateQRToken({
    required String ticketId,
    required String tourId,
    required String userId,
  }) => _ticketService.generateQRToken(ticketId: ticketId, tourId: tourId, userId: userId);

  /// Bilete QR token yazar.
  Future<void> updateTicketQRToken(String ticketId, String qrToken) =>
      _ticketService.updateTicketQRToken(ticketId, qrToken);

  /// Bilet ID'si ile QR okutma işlemi yapar.
  Future<bool> updateTicketQRStatus(String ticketId) =>
      _ticketService.updateTicketQRStatus(ticketId);

  /// QR token ile check-in yapar; bool döner.
  Future<bool> consumeTicketByQrToken({required String qrToken, required String expectedTourId}) =>
      _ticketService.consumeTicketByQrToken(qrToken: qrToken, expectedTourId: expectedTourId);

  /// QR token ile check-in yapar; detaylı sonuç döner.
  Future<QrConsumeResult> consumeTicketByQrTokenDetailed({
    required String qrToken,
    required String expectedTourId,
    String? expectedDate,
  }) => _ticketService.consumeTicketByQrTokenDetailed(
    qrToken: qrToken,
    expectedTourId: expectedTourId,
    expectedDate: expectedDate,
  );

  /// Bilet durumunu günceller.
  Future<bool> updateTicketStatus(String ticketId, String newStatus) =>
      _ticketService.updateTicketStatus(ticketId, newStatus);

  //  ChatService delegates

  /// Sohbet mesajı gönderir.
  Future<void> sendChatMessage(String tourId, ChatModel message) =>
      _chatService.sendChatMessage(tourId, message);

  /// Sohbet mesajlarını anlık dinler.
  Stream<List<ChatModel>> getChatMessages(String tourId) => _chatService.getChatMessages(tourId);

  /// Tüm mesajları tek seferlik getirir.
  Future<List<ChatModel>> getAllChatMessages(String tourId) =>
      _chatService.getAllChatMessages(tourId);

  /// Sohbet mesajını siler.
  Future<void> deleteChatMessage(String tourId, String messageId) =>
      _chatService.deleteChatMessage(tourId, messageId);

  /// Duyuru oluşturur.
  Future<void> createAnnouncement(String tourId, AnnouncementModel announcement) =>
      _chatService.createAnnouncement(tourId, announcement);

  /// Duyuruları anlık dinler.
  Stream<List<AnnouncementModel>> getAnnouncements(String tourId) =>
      _chatService.getAnnouncements(tourId);

  /// Kullanıcının bildirim koleksiyonundan tura ait bildirimleri dinler (fallback).
  Stream<List<AnnouncementModel>> getUserTourNotifications(String userId, String tourId) =>
      _chatService.getUserTourNotifications(userId, tourId);

  /// Tüm duyuruları tek seferlik getirir.
  Future<List<AnnouncementModel>> getAllAnnouncements(String tourId) =>
      _chatService.getAllAnnouncements(tourId);

  /// Duyuruyu siler.
  Future<void> deleteAnnouncement(String tourId, String announcementId) =>
      _chatService.deleteAnnouncement(tourId, announcementId);

  /// QR okutan katılımcılara Firestore bildirimi gönderir.
  Future<void> sendNotificationToTourParticipants(String tourId, String message) =>
      _chatService.sendNotificationToTourParticipants(tourId, message);
}

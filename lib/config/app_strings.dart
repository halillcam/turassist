/// Uygulama içindeki tüm UI string sabitleri.
///
/// Ekranlarda hardcoded string yerine bu sınıftaki sabitler kullanılır;
/// böylece içerik güncellemeleri ve gelecekteki çeviri çalışmaları
/// tek yerden yönetilebilir.
abstract class AppStrings {
  // ── Genel ──────────────────────────────────────────────────────────────────
  static const String appName = 'TurAssist';
  static const String loading = 'Yükleniyor...';
  static const String processing = 'İşlem yapılıyor...';
  static const String retry = 'Tekrar dene';
  static const String cancel = 'İptal';
  static const String save = 'Kaydet';
  static const String confirm = 'Onayla';
  static const String close = 'Kapat';
  static const String seeAll = 'Tümünü Gör';
  static const String error = 'Hata';
  static const String success = 'Başarılı';
  static const String warning = 'Uyarı';
  static const String noData = 'Veri bulunamadı.';
  static const String unknownError = 'Beklenmeyen bir hata oluştu.';

  // ── Auth ───────────────────────────────────────────────────────────────────
  static const String login = 'Giriş Yap';
  static const String logout = 'Çıkış Yap';
  static const String signup = 'Kayıt Ol';
  static const String forgotPassword = 'Şifremi Unuttum';
  static const String resetPassword = 'Şifreyi Sıfırla';
  static const String email = 'E-posta';
  static const String password = 'Şifre';
  static const String fullName = 'Ad Soyad';
  static const String loginRequired = 'Giriş Yapın';
  static const String loginRequiredMsg = 'Rezervasyon yapmak için giriş yapmalısınız.';

  // ── Tour Manager ───────────────────────────────────────────────────────────
  static const String tourManager = 'Tur Sorumlusu';
  static const String tourManagerLogin = 'Tur Sorumlusu Girişi';
  static const String scanQr = 'QR Kodu Tara';
  static const String scanQrTitle = 'Bilet Tara';
  static const String scanActive = 'AKTİF';
  static const String qrNotFound = 'Tur Bulunamadı';
  static const String qrNotFoundMsg = 'Tarama için önce tur sorumlusuna atanmış aktif tur gerekli.';
  static const String qrInvalid = 'Geçersiz QR';
  static const String qrSuccessTitle = 'Başarılı ✓';
  static const String qrSuccessSuffix = '— QR doğrulandı, bilet girişe açıldı.';
  static const String finishTour = 'Turu Bitir';
  static const String finishTourWarning =
      'Turu bitirdiğinizde katılımcılardan değerlendirme istenir.';
  static const String managementTools = 'Yönetim Araçları';
  static const String viewParticipants = 'Katılımcıları Gör';
  static const String makeAnnouncement = 'Duyuru Yap';
  static const String viewChat = 'Sohbete Göz At';
  static const String chatWithParticipants = 'Katılımcılar ile sohbet';
  static const String tourAssignRequired = 'Önce tur ataması gerekli';
  static const String noAssignedTour = 'Atanmış tur bulunamadı';
  static const String checkInStatus = 'Giriş Durumu';
  static const String guestsWaiting = 'misafir bekleniyor';
  static const String totalParticipants = 'TOPLAM KATILIMCI';
  static const String checkedIn = 'GİRİŞ YAPILDI';
  static const String notifyAllParticipants = 'Tüm katılımcılara bildirim gönder';
  static const String atAssignedTour = 'Atanmış tur yok';

  // ── Participants ───────────────────────────────────────────────────────────
  static const String participantList = 'Katılımcı Listesi';
  static const String statTotal = 'TOPLAM';
  static const String statArrived = 'GELEN';
  static const String statPending = 'BEKLENEN';
  static const String tabAll = 'Tümü';
  static const String tabArrived = 'Gelenler';
  static const String tabNotArrived = 'Gelmeyenler';
  static const String searchParticipant = 'Katılımcı ara...';
  static const String arrivedLabel = 'Geldi';
  static const String notArrivedLabel = 'Gelmedi';
  static const String noIdInfo = 'Kimlik bilgisi yok';
  static const String unknownParticipant = 'İsimsiz Katılımcı';
  static const String tcPrefix = 'TC: ';

  // ── Announcements ──────────────────────────────────────────────────────────
  static const String sendAnnouncement = 'Duyuru Gönder';
  static const String newAnnouncement = 'YENİ DUYURU';
  static const String liveBroadcast = 'CANLI YAYIN';
  static const String previousAnnouncements = 'Önceki Duyurular';
  static const String noAnnouncements = 'Henüz duyuru yok.';
  static const String sendToCheckedIn = 'QR Okutan Katılımcılara Gönder';
  static const String announcementHint =
      'Mesajınızı buraya yazın... (Örn: Otobüs 5 dakika içinde kalkıyor)';

  // ── Tour Detail ────────────────────────────────────────────────────────────
  static const String aboutTour = 'Tur Hakkında';
  static const String tourProgram = 'Tur Programı';
  static const String tourExtras = 'Tur Ekstraları';
  static const String reserveNow = 'Hemen Rezerve Et';
  static const String readMore = 'Daha fazla oku';
  static const String showLess = 'Daha az göster';
  static const String chooseDepartureDate = 'Çıkış Tarihi Seçin';
  static const String noUpcomingDeparture = 'Yaklaşan çıkış tarihi yok.';
  static const String noProgramYet = 'Henüz program eklenmemiş.';
  static const String capacity = 'KAPASİTE';
  static const String tourCompany = 'TUR FİRMASI';
  static const String pricePerPerson = 'KİŞİ BAŞI FİYAT';
  static const String full = 'Dolu';
  static const String spotsAvailable = ' kişilik yer mevcut';
  static const String departureTime = 'Kalkış saati: ';

  // ── My Tours ───────────────────────────────────────────────────────────────
  static const String myTours = 'Turlarım';
  static const String upcomingTours = 'Yaklaşan Turlar';
  static const String pastTours = 'Geçmiş Turlar';
  static const String noUpcomingTours = 'Yaklaşan turunuz bulunmuyor.';
  static const String noPastTours = 'Geçmiş turunuz bulunmuyor.';
  static const String showQr = 'QR Göster';
  static const String backToList = 'Listeye Dön';
  static const String purchaseDate = 'Satın alım: ';
  static const String departurePrefix = 'Çıkış: ';

  // ── Tour List ──────────────────────────────────────────────────────────────
  static const String popularTours = 'Popüler Turlar';
  static const String searchTour = 'Tur ara...';
  static const String regions = 'Bölgeler';

  // ── Profile ────────────────────────────────────────────────────────────────
  static const String profile = 'Profil';
  static const String editProfile = 'Profili Düzenle';
  static const String changePassword = 'Şifre Değiştir';

  // ── Chat ───────────────────────────────────────────────────────────────────
  static const String chat = 'Sohbet';
  static const String sendMessage = 'Mesaj gönder...';
  static const String noMessages = 'Henüz mesaj yok.';

  // ── Settings ───────────────────────────────────────────────────────────────
  static const String settings = 'Ayarlar';

  // ── Türkçe Ay İsimleri (indeks 1'den başlar) ──────────────────────────────
  static const List<String> monthNames = [
    '',
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  /// Ay numarasından (1–12) Türkçe ay adı döndürür.
  static String monthName(int month) => (month >= 1 && month <= 12) ? monthNames[month] : '';
}

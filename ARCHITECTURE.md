# TurAssist - Turizm Rehberlik Uygulaması

## Proje Mimarisi

TurAssist, GetX state management ve Firebase entegrasyonu kullanarak geliştirilmiş bir turizm rehberlik ve bilet satış uygulamasıdır.

### Teknoloji Stack
- **Frontend Framework**: Flutter
- **State Management**: GetX
- **Backend**: Firebase (Firestore, Firebase Auth)
- **QR Code**: qr_flutter, mobile_scanner
- **Lokalizasyon**: intl

## Proje Yapısı

```
lib/
├── config/
│   ├── colors.dart           # Renkler ve tema tanımlamaları
│   └── app_routes.dart       # GetX routing tanımlamaları
├── controllers/
│   ├── home_controller.dart      # Ana ekran controller
│   ├── tour_controller.dart      # Tur listesi controller
│   ├── booking_controller.dart   # Satın alma controller
│   ├── profile_controller.dart   # Profil ve sohbet controller
│   └── guide_controller.dart     # Tur sorumlusu paneli controller
├── models/
│   ├── user_model.dart           # Kullanıcı model
│   ├── tour_model.dart           # Tur model
│   ├── ticket_model.dart         # Bilet model
│   ├── company_model.dart        # Firma model
│   ├── chat_model.dart           # Sohbet model
│   └── announcement_model.dart   # Bildirim model
├── services/
│   └── firebase_service.dart     # Firebase operasyonları
└── screens/
    ├── login_screen.dart         # Giriş ekranı
    ├── register_screen.dart      # Kayıt ekranı
    ├── forgot_password_screen.dart # Şifre sıfırlama
    ├── city_selection_screen.dart  # Şehir seçim ekranı
    ├── tour_list_screen.dart       # Tur listesi ekranı
    ├── tour_detail_screen.dart     # Tur detayları ve satın alma
    ├── profile_screen.dart         # Profil ve QR kodlar
    ├── tour_chat_screen.dart       # Tur sohbeti ekranı
    ├── guide_login_screen.dart     # Tur sorumlusu girişi
    ├── guide_dashboard_screen.dart # Tur sorumlusu paneli
    └── qr_scanner_screen.dart      # QR kod tarayıcı
```

## Firestore Veritabanı Yapısı

### Collections

#### **users**
```dart
{
  'uid': string,
  'fullName': string,
  'email': string,
  'phone': string,
  'role': string,        // 'customer', 'guide', 'admin'
  'companyId': string,
  'profileImage': string (nullable),
  'isActive': boolean,
  'createdAt': timestamp
}
```

#### **companies**
```dart
{
  'id': string,
  'name': string,
  'ownerUid': string,
  'logo': string (nullable),
  'description': string (nullable),
  'serviceCities': array<string>,
  'createdAt': timestamp
}
```

#### **tours**
```dart
{
  'id': string,
  'title': string,
  'description': string,
  'price': number,
  'companyId': string,
  'guideId': string,
  'guideName': string (nullable),
  'availableDates': array<timestamp>,
  'capacity': number,
  'departureCity': string,
  'destinationCity': string,
  'busInfo': {
    'driverName': string,
    'phoneNumber': string,
    'plate': string,
    'capacity': number
  },
  'createdAt': timestamp,
  'isActive': boolean,
  
  // Subcollections:
  // - messages/   (chat messages)
  // - announcements/  (tour announcements)
}
```

#### **tickets**
```dart
{
  'id': string,
  'tourId': string,
  'userId': string,
  'passengerName': string,
  'tcNo': string,
  'selectedDate': timestamp,
  'pricePaid': number,
  'status': string,      // 'active', 'completed', 'cancelled'
  'qrCode': string (nullable),
  'qrScanned': boolean,
  'purchaseDate': timestamp,
  'scanDate': timestamp (nullable)
}
```

## Kullanıcı Akışı (User Flow)

### Müşteri Akışı
1. **Giriş/Kayıt** (`LoginScreen`, `RegisterScreen`)
2. **Şehir Seçimi** (`CitySelectionScreen`)
3. **Tur Listesi** (`TourListScreen`)
4. **Tur Detayları & Satın Alma** (`TourDetailScreen`)
   - Tarih seçimi
   - Yolcu bilgisi girişi
   - QR kod oluşturma ve bilet satın alma
5. **Profil & QR Kodlar** (`ProfileScreen`)
   - Satın alınan turlar
   - QR kodları görüntüleme
6. **Tur Sohbeti** (`TourChatScreen`)
   - Bildirimler
   - Diğer yolcular ve tur sorumlusuyla chat

### Tur Sorumlusu Akışı
1. **Giriş** (`GuideLoginScreen`)
   - ID ve şifre girişi
2. **Panel** (`GuideDashboardScreen`)
   - **Yolcular**: Kayıtlı yolcuların listesi
   - **Bildirim**: Duyuru gönderme
   - **QR Tara**: Biletlerin QR kodlarını tarama
   - **Tur Bitir**: Tur tamamlama

## GetX Controllers Kullanımı

### HomeController
```dart
final homeController = Get.put(HomeController());

// Properties
homeController.selectedCity      // Seçilen şehir
homeController.availableCities   // Mevcut şehirler
homeController.isLoading         // Yükleme durumu

// Methods
homeController.loadAvailableCities()
homeController.selectCity(city)
```

### TourController
```dart
final tourController = Get.put(TourController());

// Methods
tourController.loadToursByCity(city)
tourController.getTourDetails(tourId)
```

### BookingController
```dart
final bookingController = Get.put(BookingController());

// Methods
bookingController.setTour(tour)
bookingController.setDate(date)
bookingController.setPassengerInfo(name, tc)
bookingController.bookTour(userId, userName)
```

### ProfileController
```dart
final profileController = Get.put(ProfileController());

// Methods
profileController.loadUserTickets(userId)
profileController.selectTicket(ticket)
profileController.loadChatMessages(tourId)
profileController.sendMessage(...)
```

### GuideController
```dart
final guideController = Get.put(GuideController());

// Methods
guideController.loadTourDetails(tourId)
guideController.createAnnouncement(...)
guideController.scanQRCode(ticketId, qrCode)
```

## QR Kod Sistemi

### QR Kod Oluşturma
- Format: `{tourId}_{userId}_{selectedDate}`
- Örnek: `tour123_user456_2026-01-15T10:30:00.000Z`

### QR Kod Tarama Akışı
1. Yolcu tur gününde QR kodunu okuttuğunda
2. `ticket.qrScanned = true` ve `ticket.scanDate` güncellenir
3. Kullanıcının chat bölümü açılır
4. Tur bilgileri güncellenir

## Bildirim Sistemi

- Sadece QR kodu taranmış kişilere bildirim gider
- Tur sorumlusu "Acil" veya "Normal" bildirim seçebilir
- Bildirimler `announcements` subcollection'ında tutulur

## Chat Sistemi

- Tur başında kayıtlı tüm yolcular birbirleriyle chat yapabilir
- Tur sorumlusu da sohbete katılabilir
- Mesajlar `messages` subcollection'ında tutulur

## Renkler (AppColors)

```dart
// Primary
primary: #FFf48525 (Turuncu)
primaryDark: #FFd66e12
primaryLight: #FFFF8A5B

// Dark Theme
darkBackground: #FF221810
darkSurface: #FF2c241b
darkCard: #FF3A3A3A

// Text
textPrimary: #FFFFFFFF
textSecondary: #FFCCCCCC
textTertiary: #FF999999

// Semantic
success: #FF4CAF50
warning: #FFFFC107
error: #FFFF E91E63
```

## Kurulum & Çalıştırma

### Gereksinimler
- Flutter 3.10+
- Dart 3.0+
- Firebase Project

### Adımlar
1. Projeyi klonlayın
2. `flutter pub get` çalıştırın
3. Android/iOS setup'ını tamamlayın
4. `flutter run` komutu ile çalıştırın

## API Endpoints (Firebase Firestore)

### Tur Operasyonları
- `getToursByCity(city)` - Şehire göre turları getir
- `getTourById(tourId)` - Tur detaylarını getir
- `getServiceCities()` - Hizmet verilen şehirleri getir

### Bilet Operasyonları
- `createTicket(ticket)` - Bilet oluştur
- `getUserTickets(userId)` - Kullanıcı biletlerini getir
- `getTourTickets(tourId)` - Tur biletlerini getir (QR taranmış)
- `updateTicketQRStatus(ticketId, qrCode, scanned)` - QR durumunu güncelle

### Chat & Bildirim
- `sendChatMessage(message)` - Mesaj gönder
- `getChatMessages(tourId)` - Mesajları getir (Stream)
- `createAnnouncement(announcement)` - Bildirim oluştur
- `getAnnouncements(tourId)` - Bildirimleri getir (Stream)

## Çoklu Dil Desteği

Uygulama şu anda Türkçe dilinde geliştirilmiştir. `intl` paketinden faydalanarak kolayca çoklu dil desteği eklenebilir.

## Güvenlik Notları

1. Firebase Security Rules yapılandırılmalıdır
2. Tur sorumlusu ID/PW backend'de tutulmalıdır
3. QR kodlar güvenli bir şekilde şifrelenmelidir
4. Kullanıcı ve tur sorumlusu yetkilendirmesi yapılmalıdır

## Gelecek Geliştirmeler

- [ ] Push notifications
- [ ] Ödeme integrasyon (Stripe/PayTR)
- [ ] İnsan Yönetim Paneli
- [ ] Gerçek zamanlı konum takibi
- [ ] Yıldız değerlendirme sistemi
- [ ] Çoklu dil desteği
- [ ] Offline mode
- [ ] İstatistikler ve raporlar

## Destek

Sorular veya sorunlar için lütfen proje yöneticisiyle iletişime geçiniz.

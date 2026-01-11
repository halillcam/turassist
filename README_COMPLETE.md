# 🎫 TurAssist - Turizm Rehberlik & Bilet Satış Uygulaması

## 📱 Proje Tanıtımı

TurAssist, modern bir turizm şirketi için geliştirilen, müşterilerin turları görmesi, satın alması ve QR kodu ile giriş yapması, tur sorumlusunun yolcuları yönetmesi için tasarlanmış bir Flutter uygulamasıdır.

### 🎯 Temel Özellikler

#### 👨‍💼 Müşteri Tarafı
- ✅ Giriş/Kayıt Sistemi (Firebase Auth)
- ✅ Şehir Seçimi
- ✅ Tur Listesi ve Detayları
- ✅ Tarih Seçimi ve Satın Alma
- ✅ **QR Kod Oluşturma** (Bilet doğrulama için)
- ✅ Profil ve Bilet Yönetimi
- ✅ **Gerçek Zamanlı Sohbet** (Tur sorumlusuyla ve diğer yolcularla)
- ✅ **Bildirim Sistemi** (Tur sorumlusundan duyurular)

#### 🧑‍✈️ Tur Sorumlusu Tarafı
- ✅ ID/PW ile Giriş
- ✅ Turdaki Yolcuların Listesi
- ✅ **QR Kod Tarama** (Bilet doğrulaması)
- ✅ **Bildirim Gönderme** (Sadece taranmış kişilere)
- ✅ **Gerçek Zamanlı Chat** (Turdaki herkesle)
- ✅ Tur Tamamlama

---

## 🏗️ Mimari & Teknoloji

### Tech Stack
```
Frontend:   Flutter 3.10+ / Dart 3.0+
State:      GetX 4.7.3 (Reactive Programming)
Backend:    Firebase Firestore + Auth
Scanning:   mobile_scanner 7.1.4
QR:         qr_flutter 4.1.0
Lokalizasyon: intl 0.19.0
```

### Klasik MVC Deseni
```
Models (Data Layer)
    ↓
Services (Firebase)
    ↓
Controllers (GetX - State Management)
    ↓
Screens (UI - GetX Widgets)
```

---

## 📂 Proje Yapısı

```
turassist/
│
├── lib/
│   ├── config/
│   │   ├── colors.dart              # 🎨 Dark theme renkler
│   │   └── app_routes.dart          # 🛣️ GetX routing
│   │
│   ├── models/
│   │   ├── user_model.dart          # 👤 Kullanıcı
│   │   ├── tour_model.dart          # 🚌 Tur bilgileri
│   │   ├── ticket_model.dart        # 🎫 Bilet ve QR
│   │   ├── company_model.dart       # 🏢 Firma
│   │   ├── chat_model.dart          # 💬 Sohbet
│   │   └── announcement_model.dart  # 📢 Duyurular
│   │
│   ├── services/
│   │   └── firebase_service.dart    # 🔥 Firebase operasyonları
│   │
│   ├── controllers/
│   │   ├── home_controller.dart     # 🏠 Şehir seçim
│   │   ├── tour_controller.dart     # 🎫 Tur listesi
│   │   ├── booking_controller.dart  # 💳 Satın alma
│   │   ├── profile_controller.dart  # 👤 Profil & chat
│   │   └── guide_controller.dart    # 🧑‍✈️ Tur sorumlusu
│   │
│   ├── screens/
│   │   ├── city_selection_screen.dart      # Şehir seçim
│   │   ├── tour_list_screen.dart           # Tur listesi
│   │   ├── tour_detail_screen.dart         # Detay & satın al
│   │   ├── profile_screen.dart             # Profil & QR
│   │   ├── tour_chat_screen.dart           # Sohbet
│   │   ├── guide_login_screen.dart         # Guide giriş
│   │   ├── guide_dashboard_screen.dart     # Guide paneli
│   │   └── qr_scanner_screen.dart          # QR tarayıcı
│   │
│   ├── firebase_options.dart       # Firebase config
│   └── main.dart                   # App entry point
│
├── android/                         # Android native code
├── ios/                             # iOS native code
├── web/                             # Web version (gelecek)
│
├── pubspec.yaml                    # Dependencies
├── analysis_options.yaml           # Dart linting
│
└── docs/
    ├── ARCHITECTURE.md             # Proje mimarisi
    ├── API_REFERENCE.md            # Firebase API
    ├── IMPLEMENTATION_GUIDE.md     # Uygulama kılavuzu
    ├── DEVELOPMENT_SUMMARY.md      # Özet
    └── FINAL_CHECKLIST.md          # Kontrol listesi
```

---

## 🗄️ Firestore Veritabanı Yapısı

### Collections

#### **users** (Tüm kullanıcılar)
```json
{
  "uid": "user_123",
  "fullName": "Ahmet Yılmaz",
  "email": "ahmet@example.com",
  "phone": "+905551234567",
  "role": "customer",        // "customer" | "guide" | "admin"
  "companyId": "firma_1",
  "profileImage": "url",
  "isActive": true,
  "createdAt": "2026-01-11T10:30:00Z"
}
```

#### **companies** (Turizm şirketleri)
```json
{
  "id": "firma_1",
  "name": "Dost Turizm",
  "ownerUid": "admin_123",
  "serviceCities": ["İstanbul", "Ankara", "İzmir"],
  "createdAt": "2026-01-10T14:30:00Z"
}
```

#### **tours** (Turlar) + Subcollections
```json
{
  "id": "tour_1",
  "title": "Lüks Karadeniz Turu 4 Gece 5 Gün",
  "description": "Rize, Trabzon ve Erzincan...",
  "price": 7500,
  "companyId": "firma_1",
  "guideId": "guide_1",
  "departureCity": "İstanbul",
  "destinationCity": "Rize",
  "availableDates": ["2026-02-15", "2026-03-01"],
  "capacity": 36,
  "busInfo": {
    "driverName": "Halil Çam",
    "phoneNumber": "0555 555 5555",
    "plate": "46 KM 500",
    "capacity": 36
  },
  "isActive": true,
  "createdAt": "2026-01-11T10:30:00Z",
  
  // Subcollections:
  "messages/": {          // 💬 Tur sohbeti
    "message_1": {
      "senderId": "user_1",
      "senderName": "Ahmet",
      "message": "Merhaba",
      "timestamp": "2026-01-15T08:00:00Z"
    }
  },
  "announcements/": {     // 📢 Duyurular
    "announce_1": {
      "guideId": "guide_1",
      "title": "Kalkış Saati Değişti",
      "content": "08:00'den 08:30'a alındı",
      "isUrgent": true,
      "createdAt": "2026-01-15T07:00:00Z"
    }
  }
}
```

#### **tickets** (Satın alınan biletler)
```json
{
  "id": "ticket_1",
  "tourId": "tour_1",
  "userId": "user_123",
  "passengerName": "Ahmet Yılmaz",
  "tcNo": "12345678901",
  "selectedDate": "2026-02-15",
  "pricePaid": 7500,
  "status": "active",        // "active" | "completed" | "cancelled"
  "qrCode": "tour_1_user_123_2026-02-15T08:00:00Z",
  "qrScanned": false,
  "purchaseDate": "2026-01-11T10:30:00Z",
  "scanDate": null           // Tarama zamanı
}
```

---

## 🚀 Kullanıcı Akışları

### 1️⃣ Müşteri Satın Alma Akışı

```
┏━━━━━━━━━━━━┓
┃ Giriş Yap  ┃
┗━━━━━┬━━━━━┛
      │
      ▼
┏━━━━━━━━━━━━━━━┓
┃ Şehir Seç     ┃   City Selection Screen
┃ (Grid View)   ┃
┗━━━━━┬━━━━━━━━┛
      │
      ▼
┏━━━━━━━━━━━━━━━┓
┃ Turları Gör   ┃   Tour List Screen
┃ (ListView)    ┃
┗━━━━━┬━━━━━━━━┛
      │ [Tur Tıkla]
      ▼
┏━━━━━━━━━━━━━━━┓
┃ Tur Detayı    ┃   Tour Detail Screen
┃ - Tarih Seç   ┃   - Tarih seçim scroll
┃ - Yolcu Info  ┃   - Yolcu bilgisi textfield
┃ - Satın Al    ┃   - Satın Al butonu
┗━━━━━┬━━━━━━━━┛
      │ [Satın Al]
      ▼
┏━━━━━━━━━━━━━━━┓
┃ QR Oluştur    ┃   Backend: ticket + QR
┃ & Kaydet      ┃
┗━━━━━┬━━━━━━━━┛
      │
      ▼
┏━━━━━━━━━━━━━━━┓
┃ Profilde QR   ┃   Profile Screen
┃ (Sakla)       ┃   - Tab: Turlarım + QR
┗━━━━━━━━━━━━━━━┛
```

### 2️⃣ Tur Günü Akışı

```
┏━━━━━━━━━━━━━━┓
┃ Yolcu Profile┃
┃ Tur Seçimi   ┃
┗━━━━━┬━━━━━━┛
      │ [QR Okut]
      ▼
┏━━━━━━━━━━━━━━────┐
┃ Tur Sorumlusu    │  ← Guide Dashboard
┃ QR Scanner Aç    │     - QR Tara tabı
└──────┬──────────┘
       │ [QR Oku]
       ▼
  QR Tarandı ✓
       │
       ├─ ticket.qrScanned = true
       ├─ ticket.scanDate = DateTime.now()
       │
       ▼
  Yolcu Chat Aç
  - Duyurular göster
  - Sohbete katıl
  - Tur bilgisi güncelle
```

### 3️⃣ Tur Sorumlusu Operasyonları

```
┏━━━━━━━━━━━━┓
┃ ID/PW Gir  ┃   Guide Login Screen
┣━━━━━━━━━━━┫
┗━━━━━┬━━━━━┛
      │
      ▼
┏━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  Guide Dashboard (Tabbed)  ┃
├────┬────┬────┬──────────┤
│ 1  │ 2  │ 3  │    4     │
├────┴────┴────┴──────────┤
│                          │
│ 1. Yolcular             │
│    - Lista              │
│    - Status (tarandı?)  │
│                          │
│ 2. Bildirim             │
│    - Başlık input       │
│    - İçerik input       │
│    - Acil/Normal        │
│    - Gönder             │
│                          │
│ 3. QR Tara              │
│    - Mobile Scanner     │
│    - Kamera             │
│    - Torch toggle       │
│                          │
│ 4. Tur Bitir            │
│    - Onay dialog        │
│    - Turu Tamamla       │
│                          │
└──────────────────────────┘
```

---

## 🎨 UI/UX Tasarım

### Renkler (Dark Theme)
- **Primary**: #FFf48525 (Turuncu) ← Accent
- **Dark Background**: #FF221810 ← Ana background
- **Dark Card**: #FF3A3A3A ← Card backgrounds
- **Success**: #FF4CAF50 (Yeşil)
- **Warning**: #FFFFC107 (Sarı)
- **Error**: #FFE91E63 (Kırmızı)

### Komponetler
- **Gradients**: Tur kartları, butonlar
- **TabBar**: Profil ekranında sekmeler
- **Modal**: Bottom sheet detay gösterimi
- **ListView**: Sonsuz kaydırma
- **GridView**: Şehir seçimi

---

## 🔐 Güvenlik & Kimlik Doğrulama

### Firebase Security Rules Örneği
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Kullanıcı: Yalnız kendi verilerine erişim
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Turlar: Herkese oku
    match /tours/{tourId} {
      allow read: if request.auth != null;
      
      // Mesajlar: Kaydı olan herkese yazı
      match /messages/{document=**} {
        allow read, write: if request.auth != null;
      }
      
      // Duyurular: Sadece guide yazı
      match /announcements/{document=**} {
        allow read: if request.auth != null;
        allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'guide';
      }
    }
    
    // Biletler: Kendi biletlerine erişim
    match /tickets/{ticketId} {
      allow read: if resource.data.userId == request.auth.uid;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 🚀 Kurulum & Çalıştırma

### Prerequisite
```bash
- Flutter 3.10+
- Dart 3.0+
- Android Studio / Xcode
- Firebase Project
```

### Adımlar

1. **Projeyi klonlayın**
```bash
git clone <repo-url>
cd turassist
```

2. **Paketleri yükleyin**
```bash
flutter pub get
```

3. **Firebase Kurulumu**
```bash
# iOS
cd ios && pod install && cd ..

# Android
# google-services.json dosyasını android/app/ dizinine kopyalayın
```

4. **Uygulamayı çalıştırın**
```bash
flutter run

# Veya spesifik cihaz için
flutter run -d <device-id>
```

5. **APK/IPA Build**
```bash
# Android APK
flutter build apk --release

# iOS IPA
flutter build ios --release
```

---

## 📖 GetX Kullanımı

### Basic Usage
```dart
// 1. Controller oluştur
class MyController extends GetxController {
  var count = 0.obs;
  
  void increment() => count++;
}

// 2. Initialize et
Get.put(MyController());

// 3. Kullan
Obx(() => Text('Count: ${controller.count}'));

// 4. Navigate
Get.toNamed('/next-screen');
```

### Controllers Bu Projede
```dart
final homeController = Get.put(HomeController());
homeController.loadAvailableCities();

final tourController = Get.put(TourController());
tourController.loadToursByCity('İstanbul');

final bookingController = Get.put(BookingController());
bookingController.bookTour(userId: 'user_1', userName: 'Ahmet');

final profileController = Get.put(ProfileController());
profileController.loadUserTickets('user_1');

final guideController = Get.put(GuideController());
guideController.loadTourDetails('tour_1');
```

---

## 🔥 Firebase Operasyonları

### Example: Tur Satın Alma
```dart
// 1. Booking Controller'da
final success = await bookingController.bookTour(
  userId: 'user_123',
  userName: 'Ahmet Yılmaz',
);

// 2. Firebase Service'de
final ticket = TicketModel(
  tourId: 'tour_1',
  userId: 'user_123',
  passengerName: 'Ahmet Yılmaz',
  // ... other fields
);

final ticketId = await firebaseService.createTicket(ticket);
// QR Code: tour_1_user_123_2026-02-15T08:00:00Z
```

### Example: Bildirim Gönderme
```dart
// 1. Guide Dashboard'dan
guideController.createAnnouncement(
  tourId: 'tour_1',
  guideId: 'guide_1',
  isUrgent: false,
);

// 2. Firebase'e kaydedilir
// tours/tour_1/announcements/{docId}
```

---

## 🧪 Test Etme

### Unit Test
```dart
test('HomeController loadCities', () async {
  final controller = HomeController();
  await controller.loadAvailableCities();
  expect(controller.availableCities.isNotEmpty, true);
});
```

### Widget Test
```dart
testWidgets('Tour List shows tours', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  expect(find.byType(TourCard), findsWidgets);
});
```

---

## 📚 Dokümantasyon

- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - Detaylı mimari
- **[API_REFERENCE.md](./API_REFERENCE.md)** - Firebase API
- **[IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)** - Ekran-ekran kılavuz
- **[FINAL_CHECKLIST.md](./FINAL_CHECKLIST.md)** - Pre-launch kontrolü

---

## 🎯 Gelecek Geliştirmeler (Roadmap)

### Phase 1: MVP ✅ Tamamlandı
- [x] Müşteri: Tur görüntüleme ve satın alma
- [x] Müşteri: QR kod
- [x] Guide: Yolcu yönetimi ve QR tarama
- [x] Chat ve bildirim sistemi

### Phase 2: 1-2 Hafta
- [ ] Push Notifications (FCM)
- [ ] Ödeme sistemi (Stripe/PayTR)
- [ ] İnsan Yönetim Paneli
- [ ] Email notifications

### Phase 3: 1-2 Ay
- [ ] Gerçek zamanlı konum takibi
- [ ] Video call (Agora SDK)
- [ ] Yıldız değerlendirme sistemi
- [ ] İstatistikler dashboard

### Phase 4: 2-3 Ay
- [ ] Web admin panel
- [ ] Çoklu dil (EN, DE, FR)
- [ ] Offline mode (Hive)
- [ ] Advanced analytics

---

## 🐛 Bilinen Sorunlar

- QR kod büyüklüğü iOS'te şekil değiştirebilir (Fix: QrImage widget'ını scale et)
- Chat scroll performance (Pagination impl. gerekli)
- Firestore rate limiting (Batch operations kullan)

---

## 📞 İletişim & Destek

**Email**: dev@turassist.com  
**Discord**: [Community Link]  
**Issues**: GitHub Issues  

---

## 📄 Lisans

MIT License - Telif hakkı 2026

---

## 👏 Katkıda Bulunanlar

- Lead Developer: Copilot AI
- Firebase Setup: DevOps Team
- Design: UI/UX Team

---

## 🙏 Teşekkürler

Flutter, Firebase, GetX ve tüm açık kaynak kütüphanelerin geliştiricilerine teşekkür ederiz.

---

**Son Güncelleme**: 11 Ocak 2026  
**Versiyon**: 1.0.0  
**Durum**: Production Ready ✅

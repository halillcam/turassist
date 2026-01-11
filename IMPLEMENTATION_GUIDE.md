# TurAssist - Uygulama Kılavuzu

## Hızlı Başlangıç

### 1. Proje Kurulumu

```bash
# Projeyi klonlayın
git clone <proje-url>

# Dizine gidin
cd turassist

# Paketleri yükleyin
flutter pub get

# iOS pods'ları güncelleyin (macOS üzerinde)
cd ios
pod install
cd ..
```

### 2. Firebase Konfigürasyonu

1. Firebase Console'da proje oluşturun
2. Android ve iOS uygulamasını ekleyin
3. `google-services.json` dosyasını `android/app/` dizinine kopyalayın
4. `GoogleService-Info.plist` dosyasını `ios/Runner/` dizinine kopyalayın
5. `lib/firebase_options.dart` dosyası otomatik oluşturulacaktır

### 3. Firestore Koleksiyonlarını Ayarlayın

Firestore'da aşağıdaki koleksiyonları oluşturun:

```
collections:
  - companies
  - users
  - tours
  - tickets
```

### 4. Test Verilerini Ekleyin

```dart
// Firma ekle
{
  "id": "firma_1",
  "name": "Dost Turizm",
  "ownerUid": "admin_123",
  "serviceCities": ["İstanbul", "Ankara", "İzmir"],
  "createdAt": timestamp
}

// Tur ekle
{
  "id": "tour_1",
  "title": "Lüks Karadeniz Turu 4 Gece 5 Gün",
  "description": "Rize, Trabzon ve Erzincan'ı ziyaret edeceğiz",
  "price": 7500,
  "companyId": "firma_1",
  "guideId": "guide_1",
  "departureCity": "İstanbul",
  "destinationCity": "Rize",
  "availableDates": [timestamp, timestamp],
  "capacity": 36,
  "busInfo": {
    "driverName": "Halil Çam",
    "phoneNumber": "0555 555 5555",
    "plate": "46 KM 500",
    "capacity": 36
  },
  "isActive": true,
  "createdAt": timestamp
}
```

---

## Akış Diyagramları

### Müşteri Satın Alma Akışı

```
┌─────────────┐
│   Giriş Yap │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ Şehir Seç       │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Turları Gör     │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Tur Detayı      │
│ & Tarih Seç     │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Satın Al        │
│ (QR Oluştur)    │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Profilde QR     │
│ Sakla           │
└─────────────────┘
```

### Tur Günü Akışı

```
┌─────────────────┐
│ Tur Sorumlusu   │
│ ID/PW Girişi    │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Panel Aç        │
└──────┬──────────┘
       │
       ├──────────────────┬──────────────────┬──────────────┐
       │                  │                  │              │
       ▼                  ▼                  ▼              ▼
  ┌────────┐         ┌────────┐       ┌──────────┐   ┌────────┐
  │Yolcuları│        │Bildirim│       │QR Tara   │   │Tur Bitir│
  │Listele │        │Gönder  │       │          │   │         │
  └────────┘        └────────┘       └──────────┘   └────────┘
       │                  │                  │              │
       └──────────────────┴──────────────────┴──────────────┘
                          │
                          ▼
                 ┌─────────────────┐
                 │ Yolcu QR Kod    │
                 │ Okuttuğunda:    │
                 │ - Chat Aç       │
                 │ - Bildirim Al   │
                 └─────────────────┘
```

---

## Önemli Sınıflar ve Metodlar

### FirebaseService

```dart
class FirebaseService {
  // Tours
  Future<List<TourModel>> getToursByCity(String city)
  Future<TourModel?> getTourById(String tourId)
  Future<List<String>> getServiceCities()
  
  // Tickets
  Future<String?> createTicket(TicketModel ticket)
  Future<List<TicketModel>> getUserTickets(String userId)
  Future<List<TicketModel>> getTourTickets(String tourId)
  Future<bool> updateTicketQRStatus(...)
  
  // Chat & Announcements
  Future<void> sendChatMessage(ChatMessage message)
  Stream<List<ChatMessage>> getChatMessages(String tourId)
  Future<void> createAnnouncement(AnnouncementModel announcement)
  Stream<List<AnnouncementModel>> getAnnouncements(String tourId)
}
```

### Controllers

```dart
// HomeController: Şehir seçim yönetimi
HomeController().loadAvailableCities()
HomeController().selectCity(city)

// TourController: Tur listesi yönetimi
TourController().loadToursByCity(city)
TourController().getTourDetails(tourId)

// BookingController: Satın alma yönetimi
BookingController().setTour(tour)
BookingController().setDate(date)
BookingController().bookTour(userId, userName)

// ProfileController: Profil ve chat yönetimi
ProfileController().loadUserTickets(userId)
ProfileController().sendMessage(...)

// GuideController: Tur sorumlusu paneli
GuideController().loadTourDetails(tourId)
GuideController().createAnnouncement(...)
GuideController().scanQRCode(ticketId, qrCode)
```

---

## Ekran Implementasyon Adımları

### 1. City Selection Screen ✅

**Amaç**: Hizmet verilen şehirleri göster ve seç

**Adımlar**:
1. HomeController initialize et
2. `loadAvailableCities()` çağır
3. Grid view ile şehirleri göster
4. Tıklanınca `tour-list` route'a git

---

### 2. Tour List Screen ✅

**Amaç**: Seçilen şehirdeki turları listele

**Adımlar**:
1. Route parametresinden şehir al
2. TourController initialize et
3. `loadToursByCity()` çağır
4. Tour kartlarını ListView'da göster
5. Tıklanınca `tour-detail` route'a git

---

### 3. Tour Detail Screen ✅

**Amaç**: Tur detaylarını göster ve satın alma

**Adımlar**:
1. Route parametresinden tour al
2. BookingController initialize et
3. Tarih seçim dropdown göster
4. Yolcu bilgileri textfield'ları göster
5. Satın Al butonu: `bookTour()` çağır
6. Başarılı: QR code göster, profile kaydet

---

### 4. Profile Screen ✅

**Amaç**: Kullanıcının biletleri ve QR kodlarını göster

**Adımlar**:
1. ProfileController initialize et
2. TabBar: "Turlarım" ve "QR Kodlarım"
3. Turlarım: `loadUserTickets()` ile biletleri listele
4. QR Kodlarım: `qr_flutter` ile QR göster
5. Bilete tıklanınca: `selectTicket()` ve chat aç

---

### 5. Tour Chat Screen ✅

**Amaç**: Tur duyuruları ve sohbet

**Adımlar**:
1. ProfileController'dan mesajları al
2. Duyuruları horizontal liste olarak göster
3. Mesajları ListView'da göster
4. Message input ve send button
5. `sendMessage()` çağır

---

### 6. Guide Login Screen ✅

**Amaç**: Tur sorumlusu girişi

**Adımlar**:
1. ID ve şifre textfield'ları
2. Giriş Yap butonu
3. Doğrulama: Firebase Auth veya custom logic
4. Başarılı: `guide-dashboard` route'a git

---

### 7. Guide Dashboard Screen ✅

**Amaç**: Tur sorumlusu paneli

**Adımlar**:
1. GuideController initialize et
2. 4 Tab: Yolcular, Bildirim, QR Tara, Tur Bitir
3. **Yolcular**: `getTourTickets()` ile listeyi göster
4. **Bildirim**: `createAnnouncement()` ile bildirim gönder
5. **QR Tara**: `qr-scanner` route'a git
6. **Tur Bitir**: Onay dialog ve tur bitir

---

### 8. QR Scanner Screen ✅

**Amaç**: QR kod tarama

**Adımlar**:
1. MobileScannerController initialize et
2. Kamera akışını göster
3. QR kod algılanınca: `scanQRCode()` çağır
4. Başarılı: Success dialog ve liste güncelle

---

## GetX Best Practices

### 1. Controller Initialization

```dart
// Bir kere initialize et
final controller = Get.put(MyController());

// Lazy initialization
Get.lazyPut(() => MyController());

// Kullanırken
final controller = Get.find<MyController>();
```

### 2. Reactive Variables

```dart
var count = 0.obs;
var name = ''.obs;
var users = <UserModel>[].obs;

// Obx widget'ıyla otomatik rebuild
Obx(() => Text(controller.count.toString()))
```

### 3. Navigation

```dart
// Basit navigation
Get.to(() => NextScreen());

// Route adı ile
Get.toNamed('/tour-detail', arguments: tour);

// Geri dönüş
Get.back();

// Önceki tüm route'ları temizle
Get.offAllNamed('/login');
```

### 4. Snackbar

```dart
Get.snackbar(
  'Başlık',
  'Mesaj',
  backgroundColor: Colors.red,
  colorText: Colors.white,
);
```

---

## Debugging Tips

### 1. Firebase Debug

```dart
// Firestore debug modunu aç (development)
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
);
```

### 2. GetX Debug

```dart
// GetX loglarını aç
Get.log('Debug mesajı');
```

### 3. Print Statements

```dart
print('Şehir: ${controller.selectedCity.value}');
print('Turlar: ${controller.tours.length}');
```

---

## Testing

### Unit Test Örneği

```dart
import 'package:test/test.dart';
import 'package:turassist/controllers/home_controller.dart';

void main() {
  group('HomeController', () {
    late HomeController controller;

    setUp(() {
      controller = HomeController();
    });

    test('Şehir seçilmesi', () {
      controller.selectCity('İstanbul');
      expect(controller.selectedCity.value, 'İstanbul');
    });
  });
}
```

---

## Performans Optimizasyon

### 1. Lazy Loading

```dart
// Büyük listeler için lazy loading
ListView.builder(
  itemCount: controller.tours.length,
  itemBuilder: (context, index) {
    if (index == controller.tours.length - 1) {
      controller.loadMoreTours();
    }
    return TourCard(tour: controller.tours[index]);
  },
)
```

### 2. Image Caching

```dart
// Firebase Storage'dan resim cache'le
CachedNetworkImage(
  imageUrl: tour.imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### 3. Pagination

```dart
// Firestore pagination
Query ref = FirebaseFirestore.instance
    .collection('tours')
    .limit(10);

// Sonraki sayfa
ref.startAfterDocument(lastDoc).limit(10);
```

---

## Yaygın Sorunlar ve Çözümleri

### Problem: Firebase Connection Hatası

**Çözüm**:
```dart
// internet_connection_checker paketini kullan
final isConnected = await InternetConnectionChecker().hasConnection;
if (!isConnected) {
  Get.snackbar('Hata', 'İnternet bağlantısı yok');
}
```

### Problem: QR Kod Oluşturma Hatası

**Çözüm**:
```dart
// Geçerli QR veri formatı
String qrData = '${tourId}_${userId}_${selectedDate.toIso8601String()}';
// Maksimum karakter kontrolü (QR version bağlıdır)
if (qrData.length > 2953) {
  Get.snackbar('Hata', 'QR kod verisi çok uzun');
}
```

### Problem: Chat Mesajları Yüklenmedi

**Çözüm**:
```dart
// Firestore kurallarını kontrol et
// Koleksiyonun belirtilen dökümanın altında olup olmadığını kontrol et
// getAnnouncements() çağrısında tourId'yi kontrol et
```

---

## Sonraki Adımlar

1. **Push Notifications** - Firebase Cloud Messaging (FCM)
2. **Ödeme Entegrasyonu** - Stripe veya PayTR
3. **Gerçek Zamanlı Konum** - Google Maps ve Firebase
4. **Offline Mode** - Hive cache
5. **Çoklu Dil** - Internationalization (i18n)
6. **Backend Admin Panel** - Flask/Node.js

---

## Desteklenen Versiyon Gereksinimleri

- Flutter: 3.10+
- Dart: 3.0+
- iOS: 12+
- Android: 21+

---

## Kaynaklar

- [Flutter Documentation](https://flutter.dev/docs)
- [GetX Documentation](https://github.com/jonataslaw/getx)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)

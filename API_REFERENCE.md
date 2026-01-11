# TurAssist - API Referansı

## Firebase Service API Dökümantasyonu

Tüm Firebase operasyonları `FirebaseService` sınıfı aracılığıyla gerçekleştirilir.

---

## Tour (Tur) Operasyonları

### getToursByCity(String city)
**Açıklama**: Belirtilen şehirde bulunan aktif turları getirir.

**Parametreler**:
- `city` (String): Şehir adı

**Dönüş Türü**: `Future<List<TourModel>>`

**Örnek Kullanım**:
```dart
final tours = await firebaseService.getToursByCity('İstanbul');
```

**Firestore Sorgusu**:
```
tours collection
  where('departureCity', isEqualTo: 'İstanbul')
  where('isActive', isEqualTo: true)
```

---

### getTourById(String tourId)
**Açıklama**: Belirtilen ID'ye sahip turu getirir.

**Parametreler**:
- `tourId` (String): Tur ID'si

**Dönüş Türü**: `Future<TourModel?>`

**Örnek Kullanım**:
```dart
final tour = await firebaseService.getTourById('tour_123');
```

---

### getServiceCities()
**Açıklama**: Firma tarafından hizmet verilen tüm şehirleri getirir.

**Dönüş Türü**: `Future<List<String>>`

**Örnek Kullanım**:
```dart
final cities = await firebaseService.getServiceCities();
// ['İstanbul', 'Ankara', 'İzmir', ...]
```

---

## Ticket (Bilet) Operasyonları

### createTicket(TicketModel ticket)
**Açıklama**: Yeni bir bilet oluşturur ve Firestore'a kaydeder.

**Parametreler**:
- `ticket` (TicketModel): Bilet nesnesi

**Dönüş Türü**: `Future<String?>` (Bilet ID'si veya null)

**Örnek Kullanım**:
```dart
final ticket = TicketModel(
  id: '',
  tourId: 'tour_123',
  userId: 'user_456',
  passengerName: 'Ahmet Yılmaz',
  tcNo: '12345678901',
  selectedDate: DateTime.now(),
  pricePaid: 500,
  status: 'active',
  qrCode: 'tour_123_user_456_2026-01-15T10:30:00Z',
  qrScanned: false,
  purchaseDate: DateTime.now(),
);

final ticketId = await firebaseService.createTicket(ticket);
```

---

### getUserTickets(String userId)
**Açıklama**: Kullanıcının aktif biletlerini getirir.

**Parametreler**:
- `userId` (String): Kullanıcı ID'si

**Dönüş Türü**: `Future<List<TicketModel>>`

**Örnek Kullanım**:
```dart
final tickets = await firebaseService.getUserTickets('user_456');
```

**Firestore Sorgusu**:
```
tickets collection
  where('userId', isEqualTo: 'user_456')
  where('status', isEqualTo: 'active')
```

---

### getTourTickets(String tourId)
**Açıklama**: Turdaki QR kodu taranmış (kayıtlı) yolcuların biletlerini getirir.

**Parametreler**:
- `tourId` (String): Tur ID'si

**Dönüş Türü**: `Future<List<TicketModel>>`

**Örnek Kullanım**:
```dart
final registeredPassengers = await firebaseService.getTourTickets('tour_123');
```

**Firestore Sorgusu**:
```
tickets collection
  where('tourId', isEqualTo: 'tour_123')
  where('qrScanned', isEqualTo: true)
```

---

### updateTicketQRStatus(String ticketId, String qrCode, bool scanned)
**Açıklama**: Biletin QR tarama durumunu günceller.

**Parametreler**:
- `ticketId` (String): Bilet ID'si
- `qrCode` (String): QR kod verisi
- `scanned` (Boolean): Tarama durumu

**Dönüş Türü**: `Future<bool>`

**Örnek Kullanım**:
```dart
final success = await firebaseService.updateTicketQRStatus(
  'ticket_789',
  'tour_123_user_456_2026-01-15T10:30:00Z',
  true,
);
```

**Güncellemeler**:
```
qrCode: String
qrScanned: true
scanDate: DateTime.now()
```

---

## Chat Operasyonları

### sendChatMessage(ChatMessage message)
**Açıklama**: Tura ait sohbet mesajı gönderir.

**Parametreler**:
- `message` (ChatMessage): Mesaj nesnesi

**Örnek Kullanım**:
```dart
final message = ChatMessage(
  id: '',
  tourId: 'tour_123',
  senderId: 'user_456',
  senderName: 'Ahmet Yılmaz',
  message: 'Merhaba herkese!',
  timestamp: DateTime.now(),
);

await firebaseService.sendChatMessage(message);
```

**Firestore Yapısı**:
```
tours/tour_123/messages/
```

---

### getChatMessages(String tourId)
**Açıklama**: Turun sohbet mesajlarını gerçek zamanlı akışta getirir.

**Parametreler**:
- `tourId` (String): Tur ID'si

**Dönüş Türü**: `Stream<List<ChatMessage>>`

**Örnek Kullanım**:
```dart
firebaseService.getChatMessages('tour_123').listen((messages) {
  print('Mesaj sayısı: ${messages.length}');
  for (var msg in messages) {
    print('${msg.senderName}: ${msg.message}');
  }
});
```

**Firestore Sorgusu**:
```
tours/tour_123/messages
  orderBy('timestamp', descending: false)
```

---

## Announcement (Bildirim) Operasyonları

### createAnnouncement(AnnouncementModel announcement)
**Açıklama**: Tur sorumlusu tarafından duyuru oluşturur.

**Parametreler**:
- `announcement` (AnnouncementModel): Duyuru nesnesi

**Örnek Kullanım**:
```dart
final announcement = AnnouncementModel(
  id: '',
  tourId: 'tour_123',
  guideId: 'guide_789',
  title: 'Kalkış Saati Değişti',
  content: 'Kalkış saati saat 8.00\'den saat 8.30\'a alındı.',
  createdAt: DateTime.now(),
  isUrgent: true,
);

await firebaseService.createAnnouncement(announcement);
```

**Firestore Yapısı**:
```
tours/tour_123/announcements/
```

---

### getAnnouncements(String tourId)
**Açıklama**: Turun duyurularını gerçek zamanlı akışta getirir.

**Parametreler**:
- `tourId` (String): Tur ID'si

**Dönüş Türü**: `Stream<List<AnnouncementModel>>`

**Örnek Kullanım**:
```dart
firebaseService.getAnnouncements('tour_123').listen((announcements) {
  for (var ann in announcements) {
    print('${ann.title}: ${ann.content}');
  }
});
```

**Firestore Sorgusu**:
```
tours/tour_123/announcements
  orderBy('createdAt', descending: true)
```

---

## User (Kullanıcı) Operasyonları

### getUserById(String userId)
**Açıklama**: Kullanıcı bilgilerini getirir.

**Parametreler**:
- `userId` (String): Kullanıcı ID'si

**Dönüş Türü**: `Future<UserModel?>`

**Örnek Kullanım**:
```dart
final user = await firebaseService.getUserById('user_456');
```

---

### updateUser(String userId, Map<String, dynamic> data)
**Açıklama**: Kullanıcı bilgilerini günceller.

**Parametreler**:
- `userId` (String): Kullanıcı ID'si
- `data` (Map): Güncellenecek alanlar

**Dönüş Türü**: `Future<bool>`

**Örnek Kullanım**:
```dart
await firebaseService.updateUser('user_456', {
  'fullName': 'Mehmet Yılmaz',
  'phone': '+905551234567',
});
```

---

## Company (Firma) Operasyonları

### getCompanyById(String companyId)
**Açıklama**: Firma bilgilerini getirir.

**Parametreler**:
- `companyId` (String): Firma ID'si

**Dönüş Türü**: `Future<CompanyModel?>`

**Örnek Kullanım**:
```dart
final company = await firebaseService.getCompanyById('firma_1');
```

---

## Error Handling (Hata Yönetimi)

Tüm metodlar hata durumunda `try-catch` içinde aşağıdakileri gerçekleştirir:

1. Hata konsola yazdırılır
2. Null değeri döndürülür (uygun türde)
3. Kullanıcıya GetX Snackbar ile hata mesajı gösterilir

**Örnek**:
```dart
try {
  final tour = await firebaseService.getTourById('invalid_id');
} catch (e) {
  print('Hata: $e');
}
```

---

## Best Practices

### 1. Controller'da Kullanım
```dart
class TourController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  
  var tours = <TourModel>[].obs;
  var isLoading = false.obs;
  
  Future<void> loadTours(String city) async {
    isLoading.value = true;
    try {
      tours.value = await _firebaseService.getToursByCity(city);
    } finally {
      isLoading.value = false;
    }
  }
}
```

### 2. Stream Dinleme
```dart
class ProfileController extends GetxController {
  @override
  void onInit() {
    _firebaseService.getChatMessages(tourId).listen((messages) {
      chatMessages.value = messages;
    });
    super.onInit();
  }
}
```

### 3. Hata Yönetimi
```dart
if (tourId == null || tourId.isEmpty) {
  Get.snackbar('Hata', 'Tur ID boş olamaz');
  return;
}
```

---

## Firestore Security Rules Örneği

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users: Yalnız kendi verilerine erişim
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Tours: Herkese oku, sadece admin yazı
    match /tours/{tourId} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.admin == true;
      
      // Messages: Turda kayıtlı herkese yazı
      match /messages/{document=**} {
        allow read, write: if request.auth != null;
      }
      
      // Announcements: Sadece guide yazı
      match /announcements/{document=**} {
        allow read: if request.auth != null;
        allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'guide';
      }
    }
    
    // Tickets: Kendi biletlerine erişim
    match /tickets/{ticketId} {
      allow read: if resource.data.userId == request.auth.uid;
      allow write: if request.auth != null;
    }
  }
}
```

---

## Changelog

### v1.0.0 (2026-01-11)
- İlk versiyon yayınlandı
- Temel CRUD operasyonları eklendi
- Chat ve bildirim sistemi entegre edildi

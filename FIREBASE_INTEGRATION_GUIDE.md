## Firebase + TurAssist Entegrasyon Kılavuzu

Tüm Firebase entegrasyonu tamamlandı. İşte özetli bir rehber:

---

### 📋 **Veritabanı Yapısı (Firestore)**

```
users/
├── {userId}
│   ├── uid: string
│   ├── email: string
│   ├── name: string
│   ├── role: "customer" | "guide" | "admin"
│   ├── companyId: string
│   ├── createdAt: timestamp
│   ├── updatedAt: timestamp
│   └── isActive: boolean

tours/
├── {tourId}
│   ├── id: string
│   ├── title: string
│   ├── price: number
│   ├── rating: number
│   ├── imageUrl: string
│   ├── location: string
│   ├── date: string
│   ├── duration: string
│   ├── busInfo:
│   │   ├── plate: string (otobüs plakası)
│   │   └── ...
│   ├── createdAt: timestamp
│   └── messages/ (sub-collection)
│       ├── {messageId}
│       │   ├── userId: string
│       │   ├── message: string
│       │   └── timestamp: timestamp

tickets/
├── {userId}_{tourId}  ← DOKUMENt ID ÖNEMLİ!
│   ├── userId: string
│   ├── tourId: string
│   ├── quantity: number
│   ├── totalPrice: number
│   ├── status: "active" | "checked_in" | "cancelled"
│   ├── purchasedAt: timestamp
│   └── checkedInAt: timestamp (null başlangıçta)
```

---

### 🔐 **Firebase Security Rules** (Firestore)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users - Sadece kendi verisini okuyabilir
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow create: if request.auth.uid == resource.data.uid;
      allow update: if request.auth.uid == userId;
    }
    
    // Tours - Herkes okuyabilir
    match /tours/{tourId} {
      allow read: if true;
      
      // Messages sub-collection - Sadece check-in olmuşlar yazabilir
      match /messages/{messageId} {
        allow read: if true;
        allow create: if request.auth != null && 
                       exists(/databases/$(database)/documents/tickets/$(request.auth.uid)_$(tourId)) &&
                       get(/databases/$(database)/documents/tickets/$(request.auth.uid)_$(tourId)).data.status == "checked_in";
      }
    }
    
    // Tickets - Ticket ID'si userId_tourId formatı kontrol et
    match /tickets/{ticketId} {
      allow read: if ticketId.split('_')[0] == request.auth.uid;
      allow create: if ticketId.split('_')[0] == request.auth.uid;
      allow update: if ticketId.split('_')[0] == request.auth.uid;
    }
  }
}
```

---

### 🔧 **FirebaseService Sınıfı Kullanımı**

#### **Auth (Giriş/Kayıt)**

```dart
final firebaseService = FirebaseService();

// Giriş
final loginResult = await firebaseService.loginUser(
  email: 'user@example.com',
  password: 'password123',
);

if (loginResult['success']) {
  print('Role: ${loginResult['role']}'); // 'customer' veya 'guide'
  print('CompanyId: ${loginResult['companyId']}');
}

// Kayıt
final registerResult = await firebaseService.registerUser(
  email: 'newuser@example.com',
  password: 'password123',
  name: 'Ahmet Yılmaz',
  role: 'customer', // veya 'guide'
  companyId: 'company_123',
);

// Çıkış
await firebaseService.logout();
```

---

#### **Tour Listesi (StreamBuilder ile)**

```dart
StreamBuilder<List<Map<String, dynamic>>>(
  stream: firebaseService.getToursList(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    
    final tours = snapshot.data ?? [];
    return ListView.builder(
      itemCount: tours.length,
      itemBuilder: (context, index) {
        final tour = tours[index];
        return Text(
          '${tour['title']} - ${tour['price']}',
        );
      },
    );
  },
)
```

---

#### **Bilet Operasyonları**

```dart
// Bilet ID'si oluşturma (userId_tourId formatında)
String ticketId = firebaseService.generateTicketDocId(userId, tourId);

// Bilet oluşturma (Tur satın alma)
final ticketResult = await firebaseService.createTicket(
  userId: userId,
  tourId: tourId,
  quantity: 2,
  totalPrice: 16000.0,
);

// Kullanıcının biletini kontrol etme
final ticket = await firebaseService.getUserTicket(userId, tourId);
if (ticket != null) {
  print('Status: ${ticket['status']}'); // active, checked_in, cancelled
}

// Check-in yapma
final checkInResult = await firebaseService.checkInTicket(userId, tourId);

// Check-in durumunu kontrol etme
bool isCheckedIn = await firebaseService.isUserCheckedIn(userId, tourId);
```

---

#### **Chat & Messaging**

```dart
// Sadece check-in olmuş kullanıcılar mesaj gönderebilir
final messageResult = await firebaseService.sendTourMessage(
  tourId: tourId,
  userId: userId,
  message: 'Merhaba herkese!',
);

// Tur mesajlarını stream olarak dinle
StreamBuilder<List<Map<String, dynamic>>>(
  stream: firebaseService.getTourMessagesStream(tourId),
  builder: (context, snapshot) {
    final messages = snapshot.data ?? [];
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return Text(message['message']);
      },
    );
  },
)

// Chat butonunun aktif/pasif olup olmayacağını kontrol et
bool canChat = await firebaseService.canUserChat(userId, tourId);
// Eğer false ise: Kullanıcı check-in olmamış
// Eğer true ise: Chat butonu aktif
```

---

### 🎯 **Entegre Sayfalar**

#### **1. Login Screen (`login_screen.dart`)**
✅ Firebase Auth entegrasyonu yapıldı
✅ Role ve companyId kontrolü yapılıyor
✅ Error handling

```dart
final result = await _firebaseService.loginUser(email, password);
// Başarılıysa TourDiscoveryScreen'e yönlendir
```

---

#### **2. Register Screen (`register_screen.dart`)**
✅ Kullanıcı kaydı Firebase'e
✅ Role seçimi (Gezgin/Rehber)
✅ Users koleksiyonuna otomatik kaydediliyor

---

#### **3. Tour Discovery Screen (`tour_discovery_screen.dart`)**
✅ StreamBuilder ile tours koleksiyonundan gerçek zamanlı veri çekme
✅ Tour kartları Firestore verilerini gösteriyor
✅ Chat butonu check-in durumuna göre aktif/pasif

```dart
// Her kartta:
- Firestore'dan gelen title, price, rating gösteriliyor
- busInfo.plate bilgisi kullanılabiliyor
- Chat butonu: isUserCheckedIn() çağrılıyor
  - True ise: Buton aktif (yeşil)
  - False ise: Buton pasif (gri, tıklanamaz)
```

---

### ⚡ **Kritik Noktalar**

1. **Ticket Dokuman ID'si Format**: `userId_tourId`
   - Security rules buna göre yazılmıştır
   - Değiştirilmemesi gerekir!

2. **Check-in & Chat**:
   - Sadece `tickets` koleksiyonunda `status == "checked_in"` olan kullanıcılar mesaj gönderebilir
   - `sendTourMessage()` bunu otomatik kontrol ediyor

3. **Messages Sub-collection**:
   - `tours/{tourId}/messages/` şeklinde saklanıyor
   - Security rule ile korunuyor

4. **CompanyId**:
   - Şu anda tüm kullanıcılara `default_company` atanıyor
   - İhtiyaç durumunda `registerUser()` çağrısında güncellenebilir

---

### 📱 **Sayfalar Arası Navigate Etme**

```dart
// main.dart'a routing ekle:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    MaterialApp(
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/tour-discovery': (context) => const TourDiscoveryScreen(),
      },
      home: const LoginScreen(),
    ),
  );
}

// Giriş başarılıysa:
Navigator.pushReplacementNamed(context, '/tour-discovery');

// Çıkış:
await _firebaseService.logout();
Navigator.pushReplacementNamed(context, '/login');
```

---

### 🧪 **Test Verileri Oluşturma**

Firebase Console'de şu koleksiyonları ve belgeleri manuel oluştur:

```javascript
// users koleksiyonuna:
{
  uid: "user123",
  email: "gezgin@test.com",
  name: "Test Gezgin",
  role: "customer",
  companyId: "default_company",
  createdAt: now(),
  isActive: true
}

// tours koleksiyonuna:
{
  id: "tour001",
  title: "Karadeniz Turu",
  price: 8500,
  rating: 4.9,
  imageUrl: "https://...",
  location: "Rize",
  date: "Mayıs 12-15",
  duration: "4 Gün",
  busInfo: { plate: "34 ABC 1234" },
  createdAt: now()
}

// tickets koleksiyonuna:
{
  userId: "user123",
  tourId: "tour001",
  quantity: 2,
  totalPrice: 17000,
  status: "active",
  purchasedAt: now(),
  checkedInAt: null
}
// Dokuman ID'si: user123_tour001
```

---

### 🚀 **Sonraki Adımlar**

1. **Chat Screen**: Mesaj gönderme/alma ekranı yapılabilir
2. **Ticket Detail**: Bilet detayları ve check-in ekranı
3. **User Profile**: Profil düzenleme
4. **Notification**: Gerçek zamanlı bildirimler (Cloud Messaging)

---

### ❓ **Sık Sorulan Sorular**

**S**: Chat butonunun neden griyse?
**C**: Kullanıcı check-in olmamıştır. Turda check-in yapması lazım.

**S**: Bilet nasıl oluşturulur?
**C**: Detaylar sayfasında (yapılacak) "Bilet Satın Al" butonuyla

**S**: Role neden önemli?
**C**: Rehbiler turları yönetebilir, müşteriler sadece satın alıp chatleyebilir (gelecek)

---

Bu entegrasyon hazır! Backend verilerini gönder, Firestore'a import et, test et! 🎉

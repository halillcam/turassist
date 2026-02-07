# TurAssist - Mimari Belgelendirmesi

## 📱 Mobile App (Flutter - TurAssist)
**Amaç:** Müşteri, misafir ve tur sorumlusu (rehber) için mobil deneyim

### Kullanıcı Türleri
#### 1. Guest (Misafir) [cite: 30]
- Giriş yapmadan turları görüntüleyebilir
- Erişim: Login Page → City Selection → Tour List → Tour Detail
- Bilet satın alma sayfasına erişemez
- SecuredSharedPreferences ile şehir seçimi kaydedilir [cite: 30]

#### 2. Customer (Müşteri) [cite: 31]
- Email/şifre ile kayıt olur ve giriş yapar [cite: 31]
- Şehir seçimi yapması gerekir [cite: 30]
- Turları filtreler, detaylarını görür [cite: 32, 34]
- Bilet satın alabilir (3D Secure ödeme) [cite: 35]
- **Ödeme başarılı olunca 2 yeni tab açılır:** [cite: 36]
  - **"Turlarım"** - Satın aldığı turlar, rehber/tur sorumlusu bilgileri, chat, iptal et
  - **"QR'larım"** - Token gömülü QR kodlar
- QR kodu tur günü rehbere okutuvuzundur [cite: 12, 13]
- QR okuttuktan sonra chat tab'ı aktif olur [cite: 13]
- Belirlenen tarihten önce iptal edilebilir [cite: 16]

#### 3. Guide (Tur Sorumlusu/Rehber) [cite: 18, 21]
- **Web Admin Panel'de** şirket admin tarafından oluşturulur
- **Kimlik Bilgileri:** ID (G-timestamp) + PW (8 karakter) [cite: 18]
- Mobile App'te bu info ile giriş yapar
- `/guide-dashboard` açılır, app arayüzü değişir [cite: 18, 21]
- **Yetkiler:**
  - Katılımcıları göster (yeşil/kırmızı renk) [cite: 22, 23]
  - QR okuttuğunda kullanıcı adı-soyadı Alert Dialog'da görünür [cite: 24, 25]
  - Bildirim gönder (sadece QR okutan katılımcılara) [cite: 26, 27]
  - Chat yapabilir [cite: 28]
  - Turu bitir → Şirket admin paneline bildirim gider [cite: 29, 32]

### Roller (Mobile App'te Sadece 3):
- ✅ **customer** - Tur satın alan kullanıcılar
- ✅ **guest** - Kayıtsız ziyaretçiler
- ✅ **guide** - Web panel'den oluşturulan tur sorumluları

### KESINLIKLE ENGELLENEN Roller:
- ❌ **admin** - Şirket yöneticileri (Web Admin Panel'de)
- ❌ **super_admin** - Sistem yöneticileri (Web Admin Panel'de)

### Güvenlik Katmanları:
1. `FirebaseService.loginAndCheckAuth()` - Admin/Super Admin'i engeller
2. `LoginController._navigateBasedOnRole()` - Sadece 3 rol kabul eder
3. Firebase Firestore Security Rules (yapılacak)

---

## 🌐 Web Admin Panelleri (Ayrı Projeler)

### 1. Şirket Admin Paneli [cite: 40, 41]
**Amaç:** Tur ve katılımcı yönetimi

**İşlemler:**
- Tur İşlemleri:
  - ✅ Tur ekle (şehir, başlık, açıklama, kontenjan, tarih/saatler, araç, rehber, fiyat, **region seçimi**) [cite: 44]
  - ✅ Tur sil (katılımcılı turda otomatik para iadesi) [cite: 49]
  - ✅ Tur güncelle [cite: 46]
  - ✅ Tur sorumlusu oluştur (ID/PW otomatik) [cite: 47, 18]
  - ✅ Katılımcı ekle/görüntüle [cite: 54]
  - ✅ Geçmiş turları görüntüle
  - ✅ QR güncelle

- Ticket İşlemleri:
  - ✅ Ticket oluştur [cite: 51]
  - ✅ Ticket listesi

- İletişim:
  - ✅ Bildirimler [cite: 41]
  - ✅ Ticket destek (Super Admin'e gider) [cite: 51, 52]

- Ayarlar:
  - ✅ Ödeme bilgileri (vergi no, IBAN vb.) [cite: 55, 57]
  - ✅ Kimlik bilgileri güncelle (id/pw) [cite: 41]

### 2. Super Admin Paneli [cite: 58, 59]
**Amaç:** Sistem ve şirket yönetimi

**İşlemler:**
- ✅ Şirket oluştur (ad, id, pw otomatik) [cite: 60]
- ✅ Şirket güncelle [cite: 61]
- ✅ Kayıtlı şirketleri göster
- ✅ Tur oluştur (şirket seçerek, **region seçimi ile**) [cite: 62]
- ✅ Tur sorumlusu oluştur [cite: 64]
- ✅ Tur katılımcısı oluştur [cite: 64]
- ✅ Şirketlere bildirim gönder [cite: 65]
- ✅ Ticket desteği yönet
- ✅ QR güncelle [cite: 63]

---

## 💳 Ödeme Sistemi [cite: 56, 57, 58]

### Pazar Yeri Modeli
- **3D Secure ödeme** kullanılır [cite: 35, 58]
- Şirket kaydında İban, Vergi No gibi bilgiler girilir [cite: 56]
- Ödeme altyapısı **SubMerchantKey** verir (şirkete özel ID)
- Ödeme başarılı olunca:
  1. Komisyon ketiyaşı Sub Merchant'ın hesabına otomatik geçer
  2. **QR Token gömülü QR kod oluşturulur** [cite: 18, 59]

### QR Token [cite: 59]
```
Token = ticketId + timestamp + random
- Unique (her bilet farklı)
- Gömülü (QR koda veri olarak)
- Tur bittiğinde pasif hale geçer [cite: 19]
- Aynı QR 2 kez okunamaz [cite: 19, 59]
```

---

## 🔗 Sistem Mimarisi

```
┌─────────────────────────────────────────────────────────┐
│          Shared Firebase Database                       │
│  (Cloud Firestore + Authentication)                    │
└─────────────────────────────────────────────────────────┘
                          ↓
        ┌─────────────────┼─────────────────┐
        ↓                 ↓                 ↓
   
  Mobile App          Admin Panel      Super Admin Panel
  (TurAssist)      (Şirket Admin)    (Sistem Admin)
  
  ├─ Customer       ├─ Tur CRUD       ├─ Şirket CRUD
  ├─ Guest          ├─ Rehber Oluş.   ├─ Tur CRUD
  └─ Guide          ├─ Ticket İşl.    ├─ Tüm Rehber İşl.
                    ├─ Ödeme Bilg.    ├─ Ticket Yönet.
                    └─ Bildirim       └─ Şirket Bildir.
```

---

## 📋 Tur Sorumlusu Akışı

### 1. Web Admin Panel'de (Şirket Admin)
```
1. İlgili tur seçilir
2. Rehber adı, soyadı, telefon girilir
3. "Tur Sorumlusu Oluştur" butonu → ID/PW otomatik
4. Sistem Alert'te gösterir: "ID: G-xxx | PW: ABC12345"
5. Admin, rehbere bu bilgileri güvenli şekilde iletir
```

### 2. Mobile App'te (Rehber/Guide)
```
1. App açılır → "Guide Login" sekmesi seçilir
2. ID ve PW girilir
3. FirebaseService.guideLogin() → guides collection'dan doğrulama
4. Başarılı ise /guide-dashboard açılır
5. Hub sayfası:
   - Katılımcıları göster (yeşil/kırmızı) [cite: 22, 23]
   - QR okut (kamera açılır) [cite: 24]
   - Bildirim gönder [cite: 26]
   - Chat yap [cite: 28]
   - Turu bitir (şirket paneline bildirim gider) [cite: 29]
```

### 3. Tur Bitirme Süreci
```
Rehber "Turu Bitir" → 
  Şirket Admin Paneli'ne bildirim → 
    Admin onaylar/reddeder → 
      Onay: QR'lar silinir + Rehber ID/PW silinir [cite: 19]
```

---

## 🔐 Firestore Collections

### users
```json
{
  "uid": "user_id",
  "fullName": "Ad Soyad",
  "email": "email@example.com",
  "phone": "",
  "role": "customer" | "guest" | "guide",
  "selectedCity": "İstanbul",
  "companyId": "",
  "registeredCompanies": [],
  "tcNo": "",
  "profileImage": null,
  "isDeleted": false,
  "createdAt": "timestamp"
}
```

### guides (Web Panel tarafından oluşturulur)
```json
{
  "guideId": "G-1707227400000",  // timestamp tabanlı unique
  "fullName": "Rehber Adı",
  "phone": "05xxxxxxxxx",
  "role": "guide",
  "tourId": "tour_id",
  "companyId": "company_id",
  "password": "8-char-pwd",  // Sadece giriş için, sonra sil
  "createdAt": "timestamp"
}
```

### tours
```json
{
  "id": "tour_id",
  "title": "Boğaz Turu",
  "description": "Boğaz'ın tarihi...",
  "city": "İstanbul",
  "price": 150.0,
  "imageUrl": "url...",
  "companyId": "company_id",
  "guideId": "guide_id",
  "guideName": "Rehber Adı",
  "capacity": 30,
  "region": "Marmara",
  "busInfo": {
    "driverName": "Şoför Adı",
    "phoneNumber": "05xxxxxxxxx",
    "plate": "34ABC1234",
    "capacity": 45
  },
  "createdAt": "timestamp",
  "isDeleted": false,
  "status": "active" | "finish_requested"
}
```

### Region Kategorileri
Turlar aşağıdaki bölgelere göre kategorize edilecektir:

**Coğrafi Bölgeler:**
- Akdeniz
- Karadeniz
- Marmara
- Ege
- İç Anadolu
- Doğu Anadolu
- Güneydoğu Anadolu

**Özel Kategoriler:**
- Günü Birlik
- Yurtdışı

### tickets
```json
{
  "id": "ticket_id",
  "userId": "user_id",
  "tourId": "tour_id",
  "companyId": "company_id",
  "slotId": "slot_id",  // Tarih/saat bilgisi
  "passengerName": "Yolcu Adı",
  "tcNo": "12345678901",
  "pricePaid": 150.0,
  "status": "active" | "checked_in" | "cancelled",
  "qrToken": "ticket_id-timestamp-random",  // Token gömülü
  "isScanned": false,
  "purchaseDate": "timestamp",
  "scannedAt": null
}
```

### messages (Tour → messages subcollection)
```json
{
  "id": "msg_id",
  "senderId": "user_id",
  "senderName": "Ad Soyad",  // Sadece ad-soyad görünür [cite: 15]
  "text": "Mesaj içeriği",
  "timestamp": "timestamp"
}
```

### announcements (Tour → announcements subcollection)
```json
{
  "id": "ann_id",
  "notification": "Duyuru metni",
  "createdAt": "timestamp"
}
```

---

## ✅ Kontrol Listesi

**Mobile App Güvenliği:**
- [x] Admin/Super Admin engellenmesi
- [x] Guest sadece listeleme görebilir
- [x] Customer bilet satın alabilir
- [x] Guide Web Panel'den oluşturulur, app'te sadece giriş yapar
- [x] QR token unique (ticketId + timestamp + random)
- [x] Chat'te kullanıcı bilgileri gizli (sadece ad-soyad)

**Web Admin Panelleri (Yapılacak):**
- [ ] Şirket Admin Panel oluştur
- [ ] Super Admin Panel oluştur
- [ ] Firestore Rules yazılır
- [ ] API Rate Limiting
- [ ] CORS yapılandırması
- [ ] Log sistemi (opsiyonel) [cite: 66]

**Ödeme:**
- [x] 3D Secure entegrasyonu (iyzico vb.)
- [x] SubMerchantKey yönetimi
- [x] Para iade otomasyonu (tur silinirse) [cite: 49]

---

## 📂 Proje Dosyaları

```
turassist/
├── lib/
│   ├── controllers/
│   │   ├── login_controller.dart       ✅ Done
│   │   ├── booking_controller.dart     ✅ Done
│   │   ├── tour_controller.dart        ✅ Done
│   │   ├── guide_controller.dart       ✅ Done
│   │   ├── chat_controller.dart        ✅ Done
│   │   ├── announcement_controller.dart ✅ Done
│   │   ├── city_controller.dart        ✅ Done
│   │   └── tour_setup_controller.dart  ✅ Placeholder (Web Panel için)
│   ├── models/
│   ├── services/
│   │   └── firebase_service.dart       ✅ Done
│   └── screens/
│
├── ARCHITECTURE.md                      ✅ This file

Web Projects (Ayrı):
├── turassist-admin-panel/               🚀 TODO
│   └── Şirket Admin Panel (Vue/React)
├── turassist-super-admin/               🚀 TODO
│   └── Super Admin Panel (Vue/React)
└── turassist-backend/ (opsiyonel)       🚀 TODO
    └── Cloud Functions / API
```

---

## 🚀 Sonraki Adımlar

1. **Screens/UI Geliştirme (Mobile)**
   - Guest → Tour List Page
     - **Görünüş:** Bölgelere göre kategorize edilmiş turlar
     - **Örnek:**
       ```
       📌 KARADENIZ
       ├── Tur 1: Rize Çay Bahçesi Turu
       ├── Tur 2: Uzungöl Turu
       └── Tur 3: Sumela Manastırı Turu
       
       📌 EGE
       ├── Tur 1: Efes Antik Şehir
       ├── Tur 2: Pamukkale Turu
       └── Tur 3: Bodrum Tekne Turu
       
       📌 GÜNÜ BİRLİK
       ├── Tur 1: Kısa Getaway
       └── Tur 2: Half Day Tour
       
       📌 YURTDIŞI
       ├── Tur 1: Yunanistan Adalar Turu
       └── Tur 2: Kıbrıs Hamamı Turu
       ```
   - Customer → My Tours, QR's, Profile Pages
   - Guide → Dashboard, QR Reader, Chat, Announcement Pages

2. **Web Admin Panel Geliştirme**
   - Şirket Admin Dashboard
   - Super Admin Dashboard
   - Guide ID/PW oluşturma

3. **Firestore Security Rules**
   - Role-based erişim kontrolü
   - Guest/Customer/Guide izinleri

4. **İyzico Entegrasyonu**
   - 3D Secure ödeme akışı
   - SubMerchantKey yönetimi

5. **Push Notifications**
   - Firebase Cloud Messaging (FCM)
   - Rehberden katılımcılara bildirim

6. **QR Code Generation**
   - flutter_qr_code gibi kütüphane
   - Token gömme

---

## 📞 İletişim & Destek

**Şirket Destek Talebi:
- Customer/Guide → Mobile App'te Ticket oluştur
- Sistem → Super Admin Panel'e gider
- Super Admin → Çözer/Yanıtlar

---

*Son Güncelleme: 6 Şubat 2026*
*Proje Durumu: Kontroller Tamamlandi ✅, Web Panelleri Beklemede 🚀*

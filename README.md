# TurAssist Mobil Uygulama

TurAssist Mobil Uygulaması, tur sorumlularının ve Müşterilerin tur süreçlerini sahada kolay ve hızlı bir şekilde yönetebilmesi için geliştirilmiş mobil tabanlı bir uygulamadır.

Uygulama, web panel ile entegre çalışarak tur operasyonlarının mobil cihazlar üzerinden yönetilmesini sağlar.

## Genel Bakış

TurAssist mobil uygulaması, tur günü yaşanan operasyonel karmaşıklığı azaltmak amacıyla geliştirilmiştir.

Tur sorumluları ve kullanıcılar uygulama üzerinden:

- Tur bilgilerine erişebilir
- Katılımcı süreçlerini yönetebilir
- Gerçek zamanlı operasyon takibi yapabilir

## Özellikler
- QR Kod ile Katılımcı Doğrulama
- Katılımcılar QR kod ile doğrulanır
- Manuel kontrol ihtiyacı azaltılır
- Hızlı ve güvenli giriş işlemi sağlanır
- Tur Operasyon Yönetimi
- Tur sorumluları aktif turları görüntüleyebilir
- Katılımcı listelerini kontrol edebilir
- Tur sürecini mobil cihaz üzerinden yönetebilir
- Kullanıcılar satın aldıkları turları görüntüleyebilir
- Katılımcı bilgileri mobil ortamda takip edilebilir
- Bildirim Sistemi
- Duyuru ve mesajlar anlık olarak iletilir
- Tur ile ilgili gelişmeler kullanıcıya doğrudan ulaşır
- Gerçek Zamanlı Senkronizasyon
- Web panel ile senkronize çalışır
- Tüm veriler anlık olarak güncellenir

## Mimari
Mobil uygulama, katmanlı mimari prensiplerine uygun olarak geliştirilmiştir:

- Presentation katmanı (UI ve state yönetimi)
- Domain katmanı 
- Data katmanı (veri erişimi ve servisler)

Bu yapı, kodun sürdürülebilirliğini ve test edilebilirliğini artırır.

## Kullanılan Teknolojiler
- Flutter
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging

Kullanıcı kimlik doğrulama işlemleri Firebase Authentication ile sağlanmaktadır.
Veri erişimi, Firestore Security Rules ile rol bazlı olarak kontrol edilmektedir.

Her kullanıcı yalnızca yetkili olduğu verilere erişebilir.

## Cloud Functions Deployment

1. Install Firebase CLI and login:
	- `npm install -g firebase-tools`
	- `firebase login`
2. From repository root install dependencies:
	- `cd functions`
	- `npm install`
3. Deploy:
	- `firebase deploy --only functions`

## Firebase config without committing keys

This project now reads Firebase options from `--dart-define` values instead of keeping them in `lib/firebase_options.dart`.

1. Create a local config file from the example:
	- `Copy-Item .env.firebase.example.json .env.firebase.json`
2. Fill `.env.firebase.json` with your real Firebase values.
3. Run the app with the file:
	- `flutter run --dart-define-from-file=.env.firebase.json`
4. Build with the same file:
	- `flutter build apk --dart-define-from-file=.env.firebase.json`
	- `flutter build web --dart-define-from-file=.env.firebase.json`
5. Or use the VS Code task for APK output:
	- `Terminal > Run Task > Flutter Build APK (release)`

Notes:

- `.env.firebase.json` is gitignored and should stay local.
- If these keys were ever pushed publicly before, rotate the API keys in Firebase Console / Google Cloud Console.
- Firebase client config is not a true secret for shipped mobile/web apps. This setup removes it from GitHub, but the values still exist in the built client. Protect the project with Firebase Security Rules, App Check, and API key restrictions.

## Demo

Uygulamanın demo videosuna aşağıdaki bağlantı üzerinden ulaşabilirsiniz:

 <img width="25" height="25" alt="image" src="https://github.com/user-attachments/assets/28709666-bc02-44a9-8910-de944bb10971" /> https://youtu.be/60JbPzEaCYA


## Not

Bu uygulama, tur operasyonlarının sahada daha hızlı, kontrollü ve dijital bir şekilde yönetilebilmesi amacıyla geliştirilmiştir.

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

## Demo

Uygulamanın demo videosuna aşağıdaki bağlantı üzerinden ulaşabilirsiniz:

 <img width="25" height="25" alt="image" src="https://github.com/user-attachments/assets/28709666-bc02-44a9-8910-de944bb10971" /> https://youtu.be/60JbPzEaCYA


## Not

Bu uygulama, tur operasyonlarının sahada daha hızlı, kontrollü ve dijital bir şekilde yönetilebilmesi amacıyla geliştirilmiştir.

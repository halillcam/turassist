# TEST_LOCAL_NOTIFICATION_FALLBACK

Bu dosya, Blaze planı olmadan bildirimleri test etmek için eklenen geçici local notification fallback mekanizmasını tanımlar.

## Amaç

- Rehber duyurusu Firestore'a yazıldığında,
- Kullanıcının `tickets` kaydında ilgili tur için `isScanned == true` ise,
- Uygulama açık/arka plandayken local notification göstermek.

## Nerede çalışıyor?

- Kod: `lib/services/local_notification_service.dart`
- Etiket: `TEST_LOCAL_NOTIFICATION_FALLBACK`
- Bildirim başlığı: `Tur Bildirim (Test)`

## Çalışma şekli

1. Kullanıcının `tickets` akışı stream ile dinlenir (`userId + isScanned == true`).
2. Aktif tur kimlikleri çıkarılır.
3. Her aktif turun `announcements` koleksiyonu stream ile dinlenir.
4. Yeni gelen duyurular local notification olarak gösterilir.

## Sınır

- Bu yapı gerçek push değildir.
- Uygulama tamamen kapalıysa garanti bildirim sağlamaz.

## Blaze'e geçince kaldırılacaklar

- `local_notification_service.dart` içindeki `TEST_LOCAL_NOTIFICATION_FALLBACK` bölümü.
- Bu doküman dosyası.

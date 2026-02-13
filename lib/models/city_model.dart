import '../config/city_image_urls.dart';

enum CityRegion { marmara, karadeniz, ege, icAnadolu, akdeniz, doguAnadolu, guneydoguAnadolu }

extension CityRegionName on CityRegion {
  String get displayName {
    switch (this) {
      case CityRegion.marmara:
        return 'Marmara Bölgesi';
      case CityRegion.karadeniz:
        return 'Karadeniz Bölgesi';
      case CityRegion.ege:
        return 'Ege Bölgesi';
      case CityRegion.icAnadolu:
        return 'İç Anadolu Bölgesi';
      case CityRegion.akdeniz:
        return 'Akdeniz Bölgesi';
      case CityRegion.doguAnadolu:
        return 'Doğu Anadolu Bölgesi';
      case CityRegion.guneydoguAnadolu:
        return 'Güneydoğu Anadolu Bölgesi';
    }
  }

  String get folderPath {
    switch (this) {
      case CityRegion.marmara:
        return 'assets/images/marmara';
      case CityRegion.karadeniz:
        return 'assets/images/karadeniz';
      case CityRegion.ege:
        return 'assets/images/ege';
      case CityRegion.icAnadolu:
        return 'assets/images/ic_anadolu';
      case CityRegion.akdeniz:
        return 'assets/images/akdeniz';
      case CityRegion.doguAnadolu:
        return 'assets/images/dogu_anadolu';
      case CityRegion.guneydoguAnadolu:
        return 'assets/images/guneydogu_anadolu';
    }
  }
}

class City {
  final String name;
  final String? imageAsset;
  final CityRegion region;
  final String? networkImageUrl;
  final bool isAvailable;

  City({
    required this.name,
    required this.region,
    this.imageAsset,
    String? networkImageUrl,
    this.isAvailable = true,
  }) : networkImageUrl = networkImageUrl ?? cityImageUrls[name];

  String get imagePath => imageAsset ?? '${region.folderPath}/$name.jpg';
}

// Tüm Türkiye Şehirleri - 81 Şehir (A-Z sıralı)
final List<City> cityList = [
  City(name: 'Adana', region: CityRegion.akdeniz),
  City(name: 'Adıyaman', region: CityRegion.guneydoguAnadolu),
  City(name: 'Afyonkarahisar', region: CityRegion.ege),
  City(name: 'Ağrı', region: CityRegion.doguAnadolu),
  City(name: 'Aksaray', region: CityRegion.icAnadolu),
  City(name: 'Amasya', region: CityRegion.karadeniz),
  City(name: 'Ankara', region: CityRegion.icAnadolu),
  City(name: 'Antalya', region: CityRegion.akdeniz),
  City(name: 'Ardahan', region: CityRegion.doguAnadolu),
  City(name: 'Artvin', region: CityRegion.karadeniz),
  City(name: 'Aydın', region: CityRegion.ege),
  City(name: 'Balıkesir', region: CityRegion.marmara),
  City(name: 'Bartın', region: CityRegion.karadeniz),
  City(name: 'Batman', region: CityRegion.guneydoguAnadolu),
  City(name: 'Bayburt', region: CityRegion.karadeniz),
  City(name: 'Bilecik', region: CityRegion.marmara),
  City(name: 'Bingöl', region: CityRegion.doguAnadolu),
  City(name: 'Bitlis', region: CityRegion.doguAnadolu),
  City(name: 'Bolu', region: CityRegion.marmara),
  City(name: 'Burdur', region: CityRegion.akdeniz),
  City(name: 'Bursa', region: CityRegion.marmara),
  City(name: 'Çanakkale', region: CityRegion.marmara),
  City(name: 'Çankırı', region: CityRegion.icAnadolu),
  City(name: 'Çorum', region: CityRegion.karadeniz),
  City(name: 'Denizli', region: CityRegion.ege),
  City(name: 'Diyarbakır', region: CityRegion.guneydoguAnadolu),
  City(name: 'Düzce', region: CityRegion.karadeniz),
  City(name: 'Edirne', region: CityRegion.marmara),
  City(name: 'Elazığ', region: CityRegion.doguAnadolu),
  City(name: 'Erzincan', region: CityRegion.doguAnadolu),
  City(name: 'Erzurum', region: CityRegion.doguAnadolu),
  City(name: 'Eskişehir', region: CityRegion.marmara),
  City(name: 'Gaziantep', region: CityRegion.guneydoguAnadolu),
  City(name: 'Giresun', region: CityRegion.karadeniz),
  City(name: 'Gümüşhane', region: CityRegion.karadeniz),
  City(name: 'Hakkâri', region: CityRegion.doguAnadolu),
  City(name: 'Hatay', region: CityRegion.akdeniz),
  City(name: 'Iğdır', region: CityRegion.doguAnadolu),
  City(name: 'Isparta', region: CityRegion.akdeniz),
  City(name: 'İstanbul', region: CityRegion.marmara),
  City(name: 'İzmir', region: CityRegion.ege),
  City(name: 'Kahramanmaraş', region: CityRegion.akdeniz),
  City(name: 'Karabük', region: CityRegion.karadeniz),
  City(name: 'Karaman', region: CityRegion.icAnadolu),
  City(name: 'Kars', region: CityRegion.doguAnadolu),
  City(name: 'Kastamonu', region: CityRegion.karadeniz),
  City(name: 'Kayseri', region: CityRegion.icAnadolu),
  City(name: 'Kırıkkale', region: CityRegion.icAnadolu),
  City(name: 'Kırklareli', region: CityRegion.marmara),
  City(name: 'Kırşehir', region: CityRegion.icAnadolu),
  City(name: 'Kilis', region: CityRegion.guneydoguAnadolu),
  City(name: 'Kocaeli', region: CityRegion.marmara),
  City(name: 'Konya', region: CityRegion.icAnadolu),
  City(name: 'Kütahya', region: CityRegion.ege),
  City(name: 'Malatya', region: CityRegion.doguAnadolu),
  City(name: 'Manisa', region: CityRegion.ege),
  City(name: 'Mardin', region: CityRegion.guneydoguAnadolu),
  City(name: 'Mersin', region: CityRegion.akdeniz),
  City(name: 'Muğla', region: CityRegion.ege),
  City(name: 'Muş', region: CityRegion.doguAnadolu),
  City(name: 'Nevşehir', region: CityRegion.icAnadolu),
  City(name: 'Niğde', region: CityRegion.icAnadolu),
  City(name: 'Ordu', region: CityRegion.karadeniz),
  City(name: 'Osmaniye', region: CityRegion.akdeniz),
  City(name: 'Rize', region: CityRegion.karadeniz),
  City(name: 'Sakarya', region: CityRegion.marmara),
  City(name: 'Samsun', region: CityRegion.karadeniz),
  City(name: 'Siirt', region: CityRegion.guneydoguAnadolu),
  City(name: 'Sinop', region: CityRegion.karadeniz),
  City(name: 'Sivas', region: CityRegion.icAnadolu),
  City(name: 'Şanlıurfa', region: CityRegion.guneydoguAnadolu),
  City(name: 'Şırnak', region: CityRegion.guneydoguAnadolu),
  City(name: 'Tekirdağ', region: CityRegion.marmara),
  City(name: 'Tokat', region: CityRegion.karadeniz),
  City(name: 'Trabzon', region: CityRegion.karadeniz),
  City(name: 'Tunceli', region: CityRegion.doguAnadolu),
  City(name: 'Uşak', region: CityRegion.ege),
  City(name: 'Van', region: CityRegion.doguAnadolu),
  City(name: 'Yalova', region: CityRegion.marmara),
  City(name: 'Yozgat', region: CityRegion.icAnadolu),
  City(name: 'Zonguldak', region: CityRegion.karadeniz),
];

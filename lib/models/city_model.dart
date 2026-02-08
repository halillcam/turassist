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
  final String? imageAsset; // Local asset path, null if not available yet
  final CityRegion region;
  final String? networkImageUrl; // Fallback network image
  final bool isAvailable;

  City({
    required this.name,
    required this.region,
    this.imageAsset,
    this.networkImageUrl,
    this.isAvailable = true,
  });

  String get imagePath => imageAsset ?? '${region.folderPath}/$name.jpg';
}

// Tüm Türkiye Şehirleri - 81 Şehir
final List<City> cityList = [
  // Marmara Bölgesi (13 Şehir)
  City(
    name: 'İstanbul',
    region: CityRegion.marmara,
    networkImageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCht0sREvGZBdQ4KdYxvrPxTWEXMOXupYwhc0VDI84L1mmFL43Krkc2fAUfSuch90ylMC5tSYCgesXsOUk6jI4P0_KkK-24lmk8vYxEXOlWCfbyBUtHx5n--avHb5BbxqA-PQrTKNQo92Vwkx9TM5D_XcrXdl4m8E4BpQVNn_h4guQORinBx8DL5AKSWTSHWreE6IAn90fpa49-ZfItJqofq0hOHwaBV_6-L-wC_yeTIvi54z-aiK4j0CY3jcYZbWcPWqzruGlVcU5A',
  ),
  City(name: 'Edirne', region: CityRegion.marmara),
  City(name: 'Kırklareli', region: CityRegion.marmara),
  City(name: 'Tekirdağ', region: CityRegion.marmara),
  City(name: 'Çanakkale', region: CityRegion.marmara),
  City(name: 'Balıkesir', region: CityRegion.marmara),
  City(name: 'Bursa', region: CityRegion.marmara),
  City(name: 'Eskişehir', region: CityRegion.marmara),
  City(name: 'Bilecik', region: CityRegion.marmara),
  City(name: 'Bolu', region: CityRegion.marmara),
  City(name: 'Sakarya', region: CityRegion.marmara),
  City(name: 'Kocaeli', region: CityRegion.marmara),
  City(name: 'Yalova', region: CityRegion.marmara),

  // Karadeniz Bölgesi (17 Şehir)
  City(name: 'Sinop', region: CityRegion.karadeniz),
  City(name: 'Samsun', region: CityRegion.karadeniz),
  City(name: 'Ordu', region: CityRegion.karadeniz),
  City(name: 'Giresun', region: CityRegion.karadeniz),
  City(name: 'Rize', region: CityRegion.karadeniz),
  City(
    name: 'Trabzon',
    region: CityRegion.karadeniz,
    networkImageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCga7KN5u2dGJCQLi5NXo2oiDzt7f5Jji1JWWxQrPEqcRHkQPEO9gDlTqOKEHy2mz_vNWJMG_0ifzR99bQdx8KmIuguhEITBfXL_FLaEDGt-LVB8_MSrfaAMTuCwtxIpIabjime5BAj-t8HzUxDe1XyDYdkHo7nFv_psYE8lQxTYmbE3Ws7PcGc88v7HEaQ_5TQ9m6Z64Zpj78zHPOgImElGSPp-N0l_5dUhhkA2-C7ZWPsCjDZrkdq-E5rPp_WsThkN6RH7O_DcCre',
  ),
  City(name: 'Gümüşhane', region: CityRegion.karadeniz),
  City(name: 'Kastamonu', region: CityRegion.karadeniz),
  City(name: 'Bartın', region: CityRegion.karadeniz),
  City(name: 'Zonguldak', region: CityRegion.karadeniz),
  City(name: 'Düzce', region: CityRegion.karadeniz),
  City(name: 'Amasya', region: CityRegion.karadeniz),
  City(name: 'Artvin', region: CityRegion.karadeniz),
  City(name: 'Bayburt', region: CityRegion.karadeniz),
  City(name: 'Karabük', region: CityRegion.karadeniz),
  City(name: 'Tokat', region: CityRegion.karadeniz),
  City(name: 'Çorum', region: CityRegion.karadeniz),

  // Ege Bölgesi (8 Şehir)
  City(
    name: 'İzmir',
    region: CityRegion.ege,
    networkImageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDlgON3lCmkiRkLT3L-7MlLcorudVPB85O6FpK0HMka1gSatupzdkaXSWvxgduVd6_oqJswEapYyRUBsp1vRIlK0yFYtFAOKSyETXSdN_y0tI5wKQSTCgvRkhVmWYWT6YRfOk0Sa1iecH8E7tVbRN2_Cjlc4Ln_tU8aAqVHfDxilxEDUPrBxQ1qK97V-3Y5DskIMmN27L5Wr481u81FBmxyZSN0hWk5S5PPzzrKUG7szcWEHl0JX6X-IAvulYgmvfSrwXHbubH9zA0a',
  ),
  City(name: 'Manisa', region: CityRegion.ege),
  City(name: 'Kütahya', region: CityRegion.ege),
  City(name: 'Denizli', region: CityRegion.ege),
  City(name: 'Aydın', region: CityRegion.ege),
  City(name: 'Muğla', region: CityRegion.ege),
  City(name: 'Afyonkarahisar', region: CityRegion.ege),
  City(name: 'Uşak', region: CityRegion.ege),

  // İç Anadolu Bölgesi (12 Şehir)
  City(name: 'Ankara', region: CityRegion.icAnadolu),
  City(name: 'Konya', region: CityRegion.icAnadolu),
  City(name: 'Kayseri', region: CityRegion.icAnadolu),
  City(name: 'Sivas', region: CityRegion.icAnadolu),
  City(name: 'Kırşehir', region: CityRegion.icAnadolu),
  City(name: 'Nevşehir', region: CityRegion.icAnadolu),
  City(name: 'Yozgat', region: CityRegion.icAnadolu),
  City(name: 'Aksaray', region: CityRegion.icAnadolu),
  City(name: 'Çankırı', region: CityRegion.icAnadolu),
  City(name: 'Karaman', region: CityRegion.icAnadolu),
  City(name: 'Kırıkkale', region: CityRegion.icAnadolu),
  City(name: 'Niğde', region: CityRegion.icAnadolu),

  // Akdeniz Bölgesi (8 Şehir)
  City(
    name: 'Antalya',
    region: CityRegion.akdeniz,
    networkImageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuD5woQ65jZ3W64V75qhxeUdZHai7BU9rpcxROJbGF2d_U7ZuhRfQMJEnPpVxyYHObbAUIIJF-UXmzYemjOyZI-QyhxI4rzXghsC6qswVQJrhq74IsQkfl_TX_-jDOx-24rtwNiBHnQXiUZS6bHj_CZ_eo4PIGXnOalmMm9x6agNjuWKYkuJ2eYvkyN7f0V9PG-j3zD9apmcCpKz7gCbktR1quFWaeoWv9XYMJ33a7iDsyHIodR2MhLDM33fP7mUxA9A-cwDr8mE_qnx',
  ),
  City(name: 'Mersin', region: CityRegion.akdeniz),
  City(name: 'Adana', region: CityRegion.akdeniz),
  City(name: 'Hatay', region: CityRegion.akdeniz),
  City(name: 'Burdur', region: CityRegion.akdeniz),
  City(name: 'Isparta', region: CityRegion.akdeniz),
  City(name: 'Kahramanmaraş', region: CityRegion.akdeniz),
  City(name: 'Osmaniye', region: CityRegion.akdeniz),

  // Doğu Anadolu Bölgesi (14 Şehir)
  City(name: 'Erzurum', region: CityRegion.doguAnadolu),
  City(name: 'Erzincan', region: CityRegion.doguAnadolu),
  City(name: 'Elazığ', region: CityRegion.doguAnadolu),
  City(name: 'Malatya', region: CityRegion.doguAnadolu),
  City(name: 'Van', region: CityRegion.doguAnadolu),
  City(name: 'Bitlis', region: CityRegion.doguAnadolu),
  City(name: 'Hakkâri', region: CityRegion.doguAnadolu),
  City(name: 'Ardahan', region: CityRegion.doguAnadolu),
  City(name: 'Kars', region: CityRegion.doguAnadolu),
  City(name: 'Iğdır', region: CityRegion.doguAnadolu),
  City(name: 'Tunceli', region: CityRegion.doguAnadolu),
  City(name: 'Ağrı', region: CityRegion.doguAnadolu),
  City(name: 'Bingöl', region: CityRegion.doguAnadolu),
  City(name: 'Muş', region: CityRegion.doguAnadolu),

  // Güneydoğu Anadolu Bölgesi (9 Şehir)
  City(name: 'Gaziantep', region: CityRegion.guneydoguAnadolu),
  City(name: 'Şanlıurfa', region: CityRegion.guneydoguAnadolu),
  City(name: 'Diyarbakır', region: CityRegion.guneydoguAnadolu),
  City(name: 'Mardin', region: CityRegion.guneydoguAnadolu),
  City(name: 'Batman', region: CityRegion.guneydoguAnadolu),
  City(name: 'Siirt', region: CityRegion.guneydoguAnadolu),
  City(name: 'Şırnak', region: CityRegion.guneydoguAnadolu),
  City(name: 'Adıyaman', region: CityRegion.guneydoguAnadolu),
  City(name: 'Kilis', region: CityRegion.guneydoguAnadolu),
];

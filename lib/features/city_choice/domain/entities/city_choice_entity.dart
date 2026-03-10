/// Şehir seçimi ekranında kullanılan domain varlığı.
class CityChoiceEntity {
  const CityChoiceEntity({
    required this.name,
    required this.regionName,
    required this.imagePath,
    required this.networkImageUrl,
    required this.isAvailable,
  });

  final String name;
  final String regionName;
  final String imagePath;
  final String? networkImageUrl;
  final bool isAvailable;
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/app_routes.dart';
import '../../config/colors.dart';
import '../../controllers/city_controller.dart';
import '../../controllers/tour_controller.dart';
import '../../models/city_model.dart';
import '../../models/tour_model.dart';
import '../../widgets/index.dart';

class TourListScreen extends StatefulWidget {
  const TourListScreen({super.key});

  @override
  State<TourListScreen> createState() => _TourListScreenState();
}

class _TourListScreenState extends State<TourListScreen> {
  final TourController _tourController = Get.put(TourController());
  final CityController _cityController = Get.put(CityController());
  late TextEditingController _searchController;
  late Rx<String> _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchQuery = Rx<String>('');
    _searchController.addListener(_onSearchChanged);

    // Sayfa yenilendiğinde turlar boşsa local'den şehir oku ve turları çek
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_tourController.tours.isEmpty) {
        // Önce controller'daki şehri kontrol et
        var city = _cityController.selectedCity.value;

        // Controller'da yoksa local'den oku
        if (city.isEmpty) {
          final savedCity = await _cityController.getSavedCity();
          if (savedCity != null && savedCity.isNotEmpty) {
            _cityController.selectedCity.value = savedCity;
            city = savedCity;
          }
        }

        if (city.isNotEmpty) {
          _tourController.filterByCity(city);
        } else {
          _tourController.fetchTours();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchQuery.value = _searchController.text.toLowerCase();
  }

  Map<String, List<TourModel>> _groupToursByRegion(List<TourModel> tours) {
    final grouped = <String, List<TourModel>>{};
    for (var tour in tours) {
      final region = tour.region.isEmpty ? 'Diğer' : tour.region;
      if (!grouped.containsKey(region)) {
        grouped[region] = [];
      }
      grouped[region]!.add(tour);
    }
    // Sabit sıralama
    final sorted = <String, List<TourModel>>{};
    for (var region in TourController.regionOrder) {
      if (grouped.containsKey(region)) {
        sorted[region] = grouped.remove(region)!;
      }
    }
    sorted.addAll(grouped);
    return sorted;
  }

  List<TourModel> _filterTours(List<TourModel> tours) {
    if (_searchQuery.value.isEmpty) {
      return tours;
    }
    return tours
        .where(
          (tour) =>
              tour.title.toLowerCase().contains(_searchQuery.value) ||
              tour.city.toLowerCase().contains(_searchQuery.value) ||
              tour.description.toLowerCase().contains(_searchQuery.value),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Obx(
              () => _tourController.isLoading.value
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        // Şehir bilgisi + arama (sticky)
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _StickyHeaderDelegate(
                            child: Container(
                              color: AppColors.backgroundDark,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildCitySelector(),
                                  const SizedBox(height: 8),
                                  _buildSearchBar(),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Boş sonuç
                        if (_filterTours(_tourController.tours).isEmpty)
                          SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.travel_explore, color: AppColors.slate500, size: 64),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Bu şehirde henüz tur bulunmuyor',
                                    style: TextStyle(color: AppColors.slate400, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          // Bölgelere göre tur listeleri
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                final filteredTours = _filterTours(_tourController.tours);
                                final groupedTours = _groupToursByRegion(filteredTours);
                                final regions = groupedTours.keys.toList();

                                if (index >= regions.length) {
                                  return const SizedBox.shrink();
                                }

                                final region = regions[index];
                                final tours = groupedTours[region]!;

                                return _buildRegionSection(region, tours);
                              },
                              childCount: _tourController.tours.isEmpty
                                  ? 0
                                  : _groupToursByRegion(_filterTours(_tourController.tours)).length,
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildCitySelector() {
    return Obx(() {
      final city = _cityController.selectedCity.value;
      return GestureDetector(
        onTap: _showCityChangeDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.slate800,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.slate700),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                city.isEmpty ? 'Şehir Seçin' : '$city çıkışlı turlar',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.keyboard_arrow_down, color: AppColors.slate400, size: 22),
            ],
          ),
        ),
      );
    });
  }

  void _showCityChangeDialog() {
    final searchCtrl = TextEditingController();
    final filtered = RxList<City>(cityList.where((c) => c.isAvailable).toList());

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          height: 500,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Şehir Değiştir',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Arama
              Container(
                decoration: BoxDecoration(
                  color: AppColors.slate800,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.slate700),
                ),
                child: TextField(
                  controller: searchCtrl,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (q) {
                    filtered.value = cityList
                        .where(
                          (c) => c.isAvailable && c.name.toLowerCase().contains(q.toLowerCase()),
                        )
                        .toList();
                  },
                  decoration: const InputDecoration(
                    hintText: 'Şehir ara...',
                    hintStyle: TextStyle(color: AppColors.slate400),
                    prefixIcon: Icon(Icons.search, color: AppColors.slate400),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Şehir listesi
              Expanded(
                child: Obx(
                  () => ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final city = filtered[index];
                      final isSelected = _cityController.selectedCity.value == city.name;
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? AppColors.primary : AppColors.slate500,
                          size: 20,
                        ),
                        title: Text(
                          city.name,
                          style: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.slate200,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          city.region.displayName,
                          style: const TextStyle(color: AppColors.slate500, fontSize: 11),
                        ),
                        onTap: () {
                          _cityController.updateCity(city.name);
                          Get.back();
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.slate800,
        border: Border.all(color: AppColors.slate700, width: 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppColors.white),
        decoration: const InputDecoration(
          hintText: 'Tur veya aktivite ara...',
          hintStyle: TextStyle(color: AppColors.slate400),
          prefixIcon: Icon(Icons.search, color: AppColors.slate400),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildRegionSection(String region, List<TourModel> tours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$region Turları',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 290,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tours.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TourCard(
                  tour: tours[index],
                  onTap: () {
                    Get.toNamed('/tour-detail', arguments: tours[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavBar(
      activeIndex: 0,
      onItemTapped: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            Get.offNamed(AppRoutes.myTours);
            break;
          case 2:
            Get.offNamed(AppRoutes.profile);
            break;
        }
      },
    );
  }
}

/// SliverPersistentHeader için delegate.
/// İçeriğe göre otomatik yükseklik hesaplar, overflow olmaz.
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 130;

  @override
  double get maxExtent => 130;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) => true;
}

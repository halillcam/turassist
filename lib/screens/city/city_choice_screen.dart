import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:turassist/config/colors.dart';
import 'package:turassist/config/app_routes.dart';
import 'package:turassist/models/city_model.dart';
import 'package:turassist/controllers/city_controller.dart';
import 'package:turassist/controllers/tour_controller.dart';
import 'dart:ui';

class CityChoiceScreen extends StatefulWidget {
  const CityChoiceScreen({Key? key}) : super(key: key);

  @override
  State<CityChoiceScreen> createState() => _CityChoiceScreenState();
}

class _CityChoiceScreenState extends State<CityChoiceScreen> with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late RxList<City> _filteredCities;
  late Rx<String?> _selectedCityName;
  late Map<String, AnimationController> _scaleControllers;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCities = RxList(cityList);
    _selectedCityName = Rx<String?>(null);
    _scaleControllers = {};
    _searchController.addListener(_filterCities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (var controller in _scaleControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredCities.value = cityList;
    } else {
      _filteredCities.value = cityList
          .where((city) => city.name.toLowerCase().contains(query))
          .toList();
    }
  }

  void _selectCity(City city) {
    if (!city.isAvailable) return;
    _selectedCityName.value = city.name;
  }

  AnimationController _getOrCreateController(String cityName) {
    if (!_scaleControllers.containsKey(cityName)) {
      _scaleControllers[cityName] = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
    }
    return _scaleControllers[cityName]!;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Dark background
          Container(color: AppColors.backgroundDark),
          // Dark overlay for better text contrast
          Container(color: AppColors.backgroundDark.withOpacity(0.3)),
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header with title and search
                _buildHeader(isDark),

                // City grid
                Expanded(
                  child: Obx(
                    () => _filteredCities.isEmpty
                        ? Center(
                            child: Text(
                              'Şehir bulunamadı',
                              style: TextStyle(color: AppColors.slate400, fontSize: 16),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 3 / 4,
                            ),
                            itemCount: _filteredCities.length,
                            itemBuilder: (context, index) {
                              final city = _filteredCities[index];
                              return _buildCityCard(city, isDark);
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _selectedCityName.value != null
                ? () {
                    // Seçilen şehri CityController'a gönder, o da TourController'ı tetikler
                    final cityController = Get.put(CityController());
                    Get.put(TourController()); // TourController'ı önceden register et
                    cityController.updateCity(_selectedCityName.value!);
                    Get.toNamed(AppRoutes.tourList);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.slate700,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Devam Et',
              style: TextStyle(
                color: _selectedCityName.value != null ? AppColors.white : AppColors.slate900,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: AppColors.backgroundDark.withOpacity(0.7),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                'Şehir Seçin',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSearchInput(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchInput(bool isDark) {
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
        decoration: InputDecoration(
          hintText: 'Şehir ara...',
          hintStyle: const TextStyle(color: AppColors.slate400),
          prefixIcon: const Icon(Icons.search, color: AppColors.slate400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildCityCard(City city, bool isDark) {
    final controller = _getOrCreateController(city.name);

    return Obx(() {
      final isSelected = _selectedCityName.value == city.name;

      return GestureDetector(
        onTapDown: city.isAvailable ? (_) => controller.forward() : null,
        onTapUp: city.isAvailable ? (_) => controller.reverse() : null,
        onTapCancel: city.isAvailable ? () => controller.reverse() : null,
        onTap: city.isAvailable ? () => _selectCity(city) : null,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 0.95).animate(controller),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 3)
                        : Border.all(color: Colors.transparent, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Network image
                        if (city.isAvailable && city.networkImageUrl != null)
                          Image.network(
                            city.networkImageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: AppColors.cardDark,
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder();
                            },
                          )
                        else
                          _buildPlaceholder(),

                        // Dark gradient overlay for text readability
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(city.isAvailable ? 0.4 : 0.6),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Selected overlay
                        if (isSelected)
                          Positioned.fill(
                            child: Container(
                              color: AppColors.primary.withOpacity(0.25),
                              child: Center(
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ),

                        // Unavailable overlay
                        if (!city.isAvailable)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                              child: Center(
                                child: Icon(
                                  Icons.lock_outline,
                                  color: Colors.white.withOpacity(0.6),
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                city.name,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.slate200,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.cardDark,
      child: const Center(
        child: Icon(Icons.location_city_rounded, color: AppColors.slate600, size: 28),
      ),
    );
  }
}

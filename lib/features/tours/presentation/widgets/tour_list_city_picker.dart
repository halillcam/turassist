import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/colors.dart';
import '../../../../core/models/city_model.dart';
import '../../../city_choice/presentation/controllers/city_choice_controller.dart';

class TourListCityPicker extends StatelessWidget {
  const TourListCityPicker({super.key, required this.cityController, required this.onCitySelected});

  final CityChoiceController cityController;
  final ValueChanged<String> onCitySelected;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final city = cityController.selectedCity.value;
      return GestureDetector(
        onTap: () => _showCityDialog(context),
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
              const Icon(Icons.keyboard_arrow_down, color: AppColors.slate400),
            ],
          ),
        ),
      );
    });
  }

  void _showCityDialog(BuildContext context) {
    final searchController = TextEditingController();
    final filtered = RxList<City>(cityList.where((city) => city.isAvailable).toList());
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
              TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (query) {
                  filtered.value = cityList
                      .where(
                        (city) =>
                            city.isAvailable &&
                            city.name.toLowerCase().contains(query.toLowerCase()),
                      )
                      .toList();
                },
                decoration: const InputDecoration(
                  hintText: 'Şehir ara...',
                  hintStyle: TextStyle(color: AppColors.slate400),
                  prefixIcon: Icon(Icons.search, color: AppColors.slate400),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(
                  () => ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final city = filtered[index];
                      final isSelected = cityController.selectedCity.value == city.name;
                      return ListTile(
                        onTap: () {
                          onCitySelected(city.name);
                          Get.back();
                        },
                        leading: Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? AppColors.primary : AppColors.slate500,
                        ),
                        title: Text(
                          city.name,
                          style: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.slate200,
                          ),
                        ),
                        subtitle: Text(
                          city.region.displayName,
                          style: const TextStyle(color: AppColors.slate500),
                        ),
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
}

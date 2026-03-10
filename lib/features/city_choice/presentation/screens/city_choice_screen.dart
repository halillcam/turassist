import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/colors.dart';
import '../controllers/city_choice_controller.dart';
import '../widgets/city_choice_grid.dart';
import '../widgets/city_choice_header.dart';
import '../widgets/city_continue_bar.dart';
import '../widgets/city_search_field.dart';

class CityChoiceScreen extends StatefulWidget {
  const CityChoiceScreen({super.key});

  @override
  State<CityChoiceScreen> createState() => _CityChoiceScreenState();
}

class _CityChoiceScreenState extends State<CityChoiceScreen> {
  final CityChoiceController _controller = Get.put(CityChoiceController());
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            CityChoiceHeader(
              searchField: CitySearchField(
                controller: _searchController,
                onChanged: _controller.searchCities,
              ),
            ),
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (_controller.filteredCities.isEmpty) {
                  return const Center(
                    child: Text('Şehir bulunamadı', style: TextStyle(color: AppColors.slate400)),
                  );
                }
                return CityChoiceGrid(
                  cities: _controller.filteredCities,
                  selectedCity: _controller.selectedCity.value,
                  onSelect: _controller.selectCity,
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => CityContinueBar(
          enabled: _controller.hasCitySelected,
          onPressed: _controller.continueWithSelection,
        ),
      ),
    );
  }
}

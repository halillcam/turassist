import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/app_routes.dart';
import '../../../../config/colors.dart';
import '../../../city_choice/presentation/controllers/city_choice_controller.dart';
import '../controllers/tour_list_controller.dart';
import '../widgets/tour_list_bottom_bar.dart';
import '../widgets/tour_list_city_picker.dart';
import '../widgets/tour_list_search_field.dart';
import '../widgets/tour_region_sections.dart';

class TourListScreen extends StatefulWidget {
  const TourListScreen({super.key});

  @override
  State<TourListScreen> createState() => _TourListScreenState();
}

class _TourListScreenState extends State<TourListScreen> {
  late final TourListController _controller;
  late final CityChoiceController _cityController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = Get.put(TourListController());
    _cityController = Get.put(CityChoiceController());
    _searchController.addListener(() => _controller.setSearchQuery(_searchController.text));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initialize(_cityController);
    });
  }

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
        child: Obx(() {
          if (_controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final filteredTours = _controller.filteredTours(_controller.displayTours);
          final groupedTours = _controller.groupByRegion(filteredTours);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    children: [
                      TourListCityPicker(
                        cityController: _cityController,
                        onCitySelected: (city) async {
                          await _cityController.updateCity(city);
                          await _controller.loadTours(city: city);
                        },
                      ),
                      const SizedBox(height: 8),
                      TourListSearchField(controller: _searchController),
                    ],
                  ),
                ),
              ),
              TourRegionSections(
                groupedTours: groupedTours,
                onTourTap: (tour) {
                  Get.toNamed(AppRoutes.tourDetail, arguments: _controller.getToursInSeries(tour));
                },
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: const TourListBottomBar(),
    );
  }
}

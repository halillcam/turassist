import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:turassist/config/colors.dart';
import 'package:turassist/controllers/tour_controller.dart';
import 'package:turassist/models/tour_model.dart';
import 'package:turassist/widgets/index.dart';

class TourListScreen extends StatefulWidget {
  const TourListScreen({Key? key}) : super(key: key);

  @override
  State<TourListScreen> createState() => _TourListScreenState();
}

class _TourListScreenState extends State<TourListScreen> {
  final TourController _tourController = Get.put(TourController());
  late TextEditingController _searchController;
  late Rx<String> _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchQuery = Rx<String>('');
    _searchController.addListener(_onSearchChanged);
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
      if (!grouped.containsKey(tour.region)) {
        grouped[tour.region] = [];
      }
      grouped[tour.region]!.add(tour);
    }
    return grouped;
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
                        // Header (sticky)
                        SliverAppBar(
                          floating: true,
                          pinned: true,
                          snap: true,
                          elevation: 0,
                          backgroundColor: AppColors.backgroundDark.withOpacity(0.8),
                          flexibleSpace: FlexibleSpaceBar(
                            background: Container(
                              color: AppColors.backgroundDark,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: _buildSearchBar(),
                            ),
                          ),
                          collapsedHeight: 84,
                        ),
                        // Tour sections
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

  Widget _buildSearchBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
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
                    hintText: 'Şehir, tur veya aktivite ara...',
                    hintStyle: const TextStyle(color: AppColors.slate400),
                    prefixIcon: const Icon(Icons.search, color: AppColors.slate400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8)],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // TODO: Filter dialog
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Icon(Icons.tune, color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ],
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
          height: 340,
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
      badges: {1: '2'},
      onItemTapped: (index) {
        // TODO: Handle navigation
      },
    );
  }
}

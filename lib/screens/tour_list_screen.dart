import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:turassist/config/colors.dart';
import 'package:turassist/controllers/tour_controller.dart';

class TourListScreen extends StatelessWidget {
  final TourController controller = Get.put(TourController());

  TourListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String city = Get.arguments['city'] ?? '';
    controller.loadToursByCity(city);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: Text(
          '$city - Turlar',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : controller.tours.isEmpty
            ? Center(
                child: Text(
                  'Bu şehirde tur bulunamadı',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: controller.tours.length,
                itemBuilder: (context, index) {
                  final tour = controller.tours[index];
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed('/tour-detail', arguments: tour);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkSurface,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.primary, AppColors.primaryDark],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.directions_bus,
                                size: 50,
                                color: AppColors.textPrimary.withOpacity(0.7),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tour.title,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  tour.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Fiyat',
                                          style: TextStyle(
                                            color: AppColors.textTertiary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₺${tour.price.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Kapasitesi',
                                          style: TextStyle(
                                            color: AppColors.textTertiary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${tour.capacity} kişi',
                                          style: const TextStyle(
                                            color: AppColors.success,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

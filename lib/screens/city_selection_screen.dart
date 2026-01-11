import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:turassist/config/colors.dart';
import 'package:turassist/controllers/home_controller.dart';

class CitySelectionScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  CitySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: const Text(
          'Şehir Seçin',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hizmet Verilen Şehirler',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      controller.availableCities.isEmpty
                          ? Center(
                              child: Text(
                                'Şehir bulunamadı',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                              ),
                              itemCount: controller.availableCities.length,
                              itemBuilder: (context, index) {
                                final city = controller.availableCities[index];
                                return GestureDetector(
                                  onTap: () {
                                    controller.selectCity(city);
                                    Get.toNamed('/tour_list', arguments: {'city': city});
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [AppColors.primary, AppColors.primaryDark],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 40,
                                          color: AppColors.textPrimary,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          city,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

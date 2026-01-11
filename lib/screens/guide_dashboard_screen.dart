import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:turassist/config/colors.dart';
import 'package:turassist/controllers/guide_controller.dart';

class GuideDashboardScreen extends StatefulWidget {
  const GuideDashboardScreen({super.key});

  @override
  _GuideDashboardScreenState createState() => _GuideDashboardScreenState();
}

class _GuideDashboardScreenState extends State<GuideDashboardScreen>
    with SingleTickerProviderStateMixin {
  final GuideController controller = Get.put(GuideController());
  late TabController tabController;
  final TextEditingController announcementTitleController = TextEditingController();
  final TextEditingController announcementContentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    // Load tour details for the guide
    // You should pass actual tour ID
    controller.loadTourDetails('current_tour_id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkCard,
        title: const Text(
          'Tur Sorumlusu Paneli',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () {
              Get.offAllNamed('/guide-login');
            },
          ),
        ],
      ),
      body: Obx(
        () => Column(
          children: [
            // Tab Bar
            Container(
              color: AppColors.darkCard,
              child: TabBar(
                controller: tabController,
                isScrollable: true,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textTertiary,
                tabs: const [
                  Tab(
                    child: Text('Yolcular', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Tab(
                    child: Text('Bildirim', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Tab(
                    child: Text('QR Tara', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Tab(
                    child: Text('Tur Bitir', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  // Passengers Tab
                  _buildPassengersTab(),
                  // Announcement Tab
                  _buildAnnouncementTab(),
                  // QR Scanner Tab
                  _buildQRScannerTab(),
                  // End Tour Tab
                  _buildEndTourTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengersTab() {
    return controller.tourTickets.isEmpty
        ? Center(
            child: Text(
              'Henüz yolcu kaydı yok',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: controller.tourTickets.length,
            itemBuilder: (context, index) {
              final ticket = controller.tourTickets[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ticket.qrScanned
                        ? AppColors.success.withOpacity(0.3)
                        : AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ticket.passengerName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: ticket.qrScanned ? AppColors.success : AppColors.warning,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            ticket.qrScanned ? '✓ Tarandı' : 'Beklemede',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'TC: ${ticket.tcNo}',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fiyat: ₺${ticket.pricePaid.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildAnnouncementTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bildirim Gönder',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: announcementTitleController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Bildirim Başlığı',
                hintStyle: TextStyle(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.darkCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: announcementContentController,
              maxLines: 5,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Bildirim İçeriği',
                hintStyle: TextStyle(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.darkCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.selectedTour.value != null) {
                        controller.createAnnouncement(
                          tourId: controller.selectedTour.value!.id,
                          guideId: 'current_guide_id',
                          isUrgent: false,
                        );
                        announcementTitleController.clear();
                        announcementContentController.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Gönder',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.selectedTour.value != null) {
                        controller.createAnnouncement(
                          tourId: controller.selectedTour.value!.id,
                          guideId: 'current_guide_id',
                          isUrgent: true,
                        );
                        announcementTitleController.clear();
                        announcementContentController.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'ACİL Gönder',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Gönderilen Bildirimler',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => controller.announcements.isEmpty
                  ? Text('Bildirim yok', style: TextStyle(color: AppColors.textSecondary))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.announcements.length,
                      itemBuilder: (context, index) {
                        final announcement = controller.announcements[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: announcement.isUrgent
                                ? AppColors.error.withOpacity(0.1)
                                : AppColors.darkCard,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: announcement.isUrgent
                                  ? AppColors.error
                                  : AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                announcement.title,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                announcement.content,
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRScannerTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.qr_code_scanner, size: 50, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          const Text(
            'QR Kod Tara',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Get.toNamed('/qr-scanner');
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Kamerayı Aç'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndTourTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.check_circle, size: 50, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          const Text(
            'Turu Bitir',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tur tamamlandığını işaretleyin',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: AppColors.darkCard,
                    title: const Text(
                      'Turu Bitir',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      'Turu bitirmek istediğinize emin misiniz?',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'İptal',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Get.snackbar('Başarılı', 'Tur başarıyla tamamlandı');
                        },
                        child: const Text('Bitir', style: TextStyle(color: AppColors.primary)),
                      ),
                    ],
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Turu Bitir',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    announcementTitleController.dispose();
    announcementContentController.dispose();
    super.dispose();
  }
}

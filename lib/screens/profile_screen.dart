import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:turassist/config/colors.dart';
import 'package:turassist/controllers/profile_controller.dart';
import 'package:turassist/models/ticket_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final ProfileController controller = Get.put(ProfileController());
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    // Load user tickets - you should pass actual userId
    controller.loadUserTickets('current_user_id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: const Text(
          'Profilim',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () {
              // Logout action
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Column(
                children: [
                  // Tab Bar
                  Container(
                    color: AppColors.darkCard,
                    child: TabBar(
                      controller: tabController,
                      indicatorColor: AppColors.primary,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textTertiary,
                      tabs: const [
                        Tab(
                          child: Text('Turlarım', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        Tab(
                          child: Text('QR Kodlarım', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        // Tours Tab
                        controller.userTickets.isEmpty
                            ? Center(
                                child: Text(
                                  'Henüz satın aldığınız tur yok',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(15),
                                itemCount: controller.userTickets.length,
                                itemBuilder: (context, index) {
                                  final ticket = controller.userTickets[index];
                                  return GestureDetector(
                                    onTap: () {
                                      controller.selectTicket(ticket);
                                      _showTourDetailsBottomSheet(context, ticket);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 15),
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: AppColors.darkCard,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.primary.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Bilet #${ticket.id.substring(0, 8)}',
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: ticket.qrScanned
                                                      ? AppColors.success
                                                      : AppColors.warning,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  ticket.qrScanned ? 'Tarandı' : 'Taranmadı',
                                                  style: const TextStyle(
                                                    color: AppColors.textPrimary,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Yolcu: ${ticket.passengerName}',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Tarih: ${ticket.selectedDate.day}/${ticket.selectedDate.month}/${ticket.selectedDate.year}',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Fiyat: ₺${ticket.pricePaid.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                        // QR Codes Tab
                        controller.selectedTicket.value == null
                            ? Center(
                                child: Text(
                                  'QR kodları görmek için bir tur seçiniz',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                ),
                              )
                            : ListView(
                                padding: const EdgeInsets.all(15),
                                children: [
                                  _buildQRCodeCard(controller.selectedTicket.value!),
                                  const SizedBox(height: 20),
                                  _buildTourInfoCard(controller.selectedTicket.value!),
                                ],
                              ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildQRCodeCard(TicketModel ticket) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'Giriş QR Kodu',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              width: 250,
              height: 250,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: Colors.black),
                ),
                child: Center(
                  child: Text(
                    'QR: ${ticket.qrCode}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tur Günü QR kodu Otobüse binerken\ntur sorumlusuna okutunuz',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: () {
              // Save/Share QR Code
            },
            icon: const Icon(Icons.download),
            label: const Text('İndir'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildTourInfoCard(TicketModel ticket) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tur Bilgileri',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Bilet Numarası', ticket.id.substring(0, 8)),
          _buildInfoRow('Yolcu Adı', ticket.passengerName),
          _buildInfoRow('TC No', ticket.tcNo),
          _buildInfoRow(
            'Tarih',
            '${ticket.selectedDate.day}/${ticket.selectedDate.month}/${ticket.selectedDate.year}',
          ),
          _buildInfoRow('Fiyat', '₺${ticket.pricePaid.toStringAsFixed(0)}'),
          _buildInfoRow('Durum', ticket.status),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showTourDetailsBottomSheet(BuildContext context, TicketModel ticket) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkBackground,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tur Detayları',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Bilet ID', ticket.id.substring(0, 12)),
              _buildInfoRow(
                'Satın Alma Tarihi',
                '${ticket.purchaseDate.day}.${ticket.purchaseDate.month}.${ticket.purchaseDate.year}',
              ),
              _buildInfoRow(
                'QR Tarama Tarihi',
                ticket.scanDate != null
                    ? '${ticket.scanDate!.day}.${ticket.scanDate!.month}.${ticket.scanDate!.year} - ${ticket.scanDate!.hour}:${ticket.scanDate!.minute.toString().padLeft(2, '0')}'
                    : 'Taranmadı',
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.chat),
                label: const Text('Sohbet Aç'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}

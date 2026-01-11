import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:turassist/config/colors.dart';
import 'package:turassist/controllers/booking_controller.dart';
import 'package:turassist/models/tour_model.dart';

class TourDetailScreen extends StatefulWidget {
  const TourDetailScreen({super.key});

  @override
  _TourDetailScreenState createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  final BookingController controller = Get.put(BookingController());
  late TourModel tour;
  DateTime? selectedDate;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController tcController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tour = Get.arguments as TourModel;
    controller.setTour(tour);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: const Text(
          'Tur Detayları',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tour Header
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Icon(
                    Icons.directions_bus,
                    size: 80,
                    color: AppColors.textPrimary.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tour Title
              Text(
                tour.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Tour Description
              Text(
                tour.description,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 20),

              // Tour Info Cards
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.attach_money,
                      title: 'Fiyat',
                      value: '₺${tour.price.toStringAsFixed(0)}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.people,
                      title: 'Kapasite',
                      value: '${tour.capacity}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Bus Info
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🚌 Otobüs Bilgileri',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildBusInfoRow('Şoför', tour.busInfo.driverName),
                    _buildBusInfoRow('Telefon', tour.busInfo.phoneNumber),
                    _buildBusInfoRow('Plaka', tour.busInfo.plate),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Date Selection
              const Text(
                'Tarih Seçin',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tour.availableDates.length,
                  itemBuilder: (context, index) {
                    final date = tour.availableDates[index];
                    final isSelected = selectedDate == date;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                          controller.setDate(date);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.darkCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              date.day.toString().padLeft(2, '0'),
                              style: TextStyle(
                                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _getMonthName(date.month),
                              style: TextStyle(
                                color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Passenger Info
              const Text(
                'Yolcu Bilgileri',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: nameController,
                hint: 'Adı Soyadı',
                onChanged: (value) {
                  controller.setPassengerInfo(value, tcController.text);
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: tcController,
                hint: 'TC Kimlik No',
                onChanged: (value) {
                  controller.setPassengerInfo(nameController.text, value);
                },
              ),
              const SizedBox(height: 30),

              // Book Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: controller.isProcessing.value
                        ? null
                        : () {
                            // Login kontrolü - Önce kullanıcı girişini kontrol et
                            _showLoginRequiredDialog();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: controller.isProcessing.value
                        ? const SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Satın Al - QR Kod Al',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textTertiary, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Ocak',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
    ];
    return months[month - 1];
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.darkCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.login, size: 48, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'Tur Satın Al',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tur satın almak için lütfen giriş yapın veya yeni bir hesap oluşturun.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkBackground,
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        child: const Text('İptal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Get.toNamed('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Giriş Yap'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    tcController.dispose();
    super.dispose();
  }
}

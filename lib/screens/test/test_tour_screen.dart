import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../config/colors.dart';
import '../../models/tour_model.dart';
import '../../services/test_tour_service.dart';

/// Test amaçlı tur verisi ekleme ekranı.
/// Üretim ortamında kullanılmayacak, test sonrası silinecektir.
class TestTourScreen extends StatefulWidget {
  const TestTourScreen({super.key});

  @override
  State<TestTourScreen> createState() => _TestTourScreenState();
}

class _TestTourScreenState extends State<TestTourScreen> {
  final TestTourService _service = TestTourService();
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _cityController = TextEditingController();
  final _capacityController = TextEditingController();
  final _guideNameController = TextEditingController();

  // Bus Info Controllers
  final _driverNameController = TextEditingController();
  final _driverPhoneController = TextEditingController();
  final _plateController = TextEditingController();
  final _busCapacityController = TextEditingController();

  // Departure
  final _departureTimeController = TextEditingController();
  final _selectedDepartureDays = <int>[].obs;
  final _selectedDates = <DateTime>[].obs;

  // State
  final _isLoading = false.obs;
  final _selectedRegion = 'Marmara'.obs;
  final _logMessages = <String>[].obs;

  static const _weekDayLabels = {
    1: 'Pzt',
    2: 'Sal',
    3: 'Çar',
    4: 'Per',
    5: 'Cum',
    6: 'Cmt',
    7: 'Paz',
  };

  // Tur Programı - Dinamik günler ve aktiviteler
  // Her eleman: { 'title': TextEditingController, 'activities': [TextEditingController, ...] }
  final _programDays = <Map<String, dynamic>>[].obs;

  final List<String> _regions = [
    'Akdeniz',
    'Karadeniz',
    'Marmara',
    'Ege',
    'İç Anadolu',
    'Doğu Anadolu',
    'Güneydoğu Anadolu',
    'Günü Birlik',
    'Yurtdışı',
  ];

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (date == null) return;

    // Aynı günü tekrar ekleme
    if (_selectedDates.any((d) => _isSameDay(d, date))) return;

    _selectedDates.add(DateTime(date.year, date.month, date.day));
  }

  void _removeSelectedDate(DateTime date) {
    _selectedDates.removeWhere((d) => _isSameDay(d, date));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _cityController.dispose();
    _capacityController.dispose();
    _guideNameController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _plateController.dispose();
    _busCapacityController.dispose();
    _departureTimeController.dispose();
    // Program controller'larını dispose et
    for (final day in _programDays) {
      (day['title'] as TextEditingController).dispose();
      for (final ctrl in day['activities'] as List<TextEditingController>) {
        ctrl.dispose();
      }
    }
    super.dispose();
  }

  void _addProgramDay() {
    _programDays.add({
      'title': TextEditingController(text: '${_programDays.length + 1}. gün'),
      'activities': <TextEditingController>[TextEditingController()],
    });
  }

  void _removeProgramDay(int index) {
    final day = _programDays.removeAt(index);
    (day['title'] as TextEditingController).dispose();
    for (final ctrl in day['activities'] as List<TextEditingController>) {
      ctrl.dispose();
    }
  }

  void _addActivity(int dayIndex) {
    (_programDays[dayIndex]['activities'] as List<TextEditingController>).add(
      TextEditingController(),
    );
    _programDays.refresh();
  }

  void _removeActivity(int dayIndex, int activityIndex) {
    final activities = _programDays[dayIndex]['activities'] as List<TextEditingController>;
    if (activities.length > 1) {
      activities.removeAt(activityIndex).dispose();
      _programDays.refresh();
    }
  }

  List<Map<String, dynamic>> _buildProgramData() {
    final result = <Map<String, dynamic>>[];
    for (int i = 0; i < _programDays.length; i++) {
      final day = _programDays[i];
      final title = (day['title'] as TextEditingController).text.trim();
      final activities = (day['activities'] as List<TextEditingController>)
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      if (activities.isNotEmpty) {
        result.add({
          'title': title.isEmpty ? '${i + 1}. gün' : title,
          'day': i + 1,
          'order': i + 1,
          'activities': activities,
        });
      }
    }
    return result;
  }

  void _addLog(String message, {bool isError = false}) {
    final prefix = isError ? '❌' : '✅';
    _logMessages.insert(0, '$prefix ${DateTime.now().toString().substring(11, 19)} - $message');
  }

  Future<void> _submitTour() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;

    try {
      final programData = _buildProgramData();

      // Önümüzdeki 1 ay için tarih listesi: haftalık günler VEYA özel tarihler
      List<DateTime> datesToCreate = [];
      if (_selectedDates.isNotEmpty) {
        datesToCreate = _selectedDates.map((d) => DateTime(d.year, d.month, d.day)).toList();
        datesToCreate.sort((a, b) => a.compareTo(b));
      } else if (_selectedDepartureDays.isNotEmpty) {
        final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        for (var i = 0; i < 31; i++) {
          final d = today.add(Duration(days: i));
          if (_selectedDepartureDays.contains(d.weekday)) {
            datesToCreate.add(DateTime(d.year, d.month, d.day));
          }
        }
      }

      final baseTour = TourModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0,
        imageUrl: _imageUrlController.text.trim(),
        companyId: 'test_company',
        guideId: 'test_guide',
        guideName: _guideNameController.text.trim().isEmpty
            ? null
            : _guideNameController.text.trim(),
        capacity: int.tryParse(_capacityController.text) ?? 0,
        city: _cityController.text.trim(),
        region: _selectedRegion.value,
        busInfo: BusInfo(
          driverName: _driverNameController.text.trim(),
          phoneNumber: _driverPhoneController.text.trim(),
          plate: _plateController.text.trim(),
          capacity: int.tryParse(_busCapacityController.text) ?? 0,
        ),
        createdAt: DateTime.now(),
        isDeleted: false,
        extraDetail: '',
        departureDays: [],
        departureTime: _departureTimeController.text.trim(),
      );

      if (datesToCreate.isEmpty) {
        Get.snackbar(
          'Uyarı',
          'En az bir çıkış günü (Pzt, Sal...) veya özel tarih seçmelisin.',
          backgroundColor: AppColors.warning.withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
        );
        _isLoading.value = false;
        return;
      }

      final seriesId = 'series_${DateTime.now().microsecondsSinceEpoch}';
      final results = await _service.addToursForDates(baseTour, datesToCreate, seriesId: seriesId);

      int successCount = 0;
      for (final result in results) {
        if (result.success && result.docId != null) {
          successCount++;
          if (programData.isNotEmpty) {
            await _service.addTourProgram(result.docId!, programData);
          }
        }
      }

      _addLog('$successCount tur eklendi (seri: $seriesId)');
      Get.snackbar(
        'Başarılı',
        '$successCount tarih için tur oluşturuldu. UI\'da tek kart görünecek.',
        backgroundColor: AppColors.success.withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );

      _clearForm();
    } on TestTourException catch (e) {
      _addLog('Hata: ${e.message}', isError: true);
      Get.snackbar(
        'Hata',
        e.message,
        backgroundColor: AppColors.error.withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    } catch (e) {
      _addLog('Beklenmeyen hata: $e', isError: true);
      Get.snackbar(
        'Hata',
        'Beklenmeyen bir hata oluştu: $e',
        backgroundColor: AppColors.error.withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _addSampleTours() async {
    _isLoading.value = true;

    final sampleTours = [
      TourModel(
        id: '',
        title: 'Boğaz Turu',
        description:
            'İstanbul Boğazı\'nın eşsiz manzarası eşliğinde unutulmaz bir tekne turu. Rumeli Hisarı, Bebek, Ortaköy ve daha fazlası...',
        price: 250.0,
        imageUrl: '',
        companyId: 'test_company',
        guideId: 'test_guide',
        guideName: 'Ahmet Yılmaz',
        capacity: 40,
        city: 'İstanbul',
        region: 'Marmara',
        busInfo: BusInfo(
          driverName: 'Mehmet Demir',
          phoneNumber: '05321234567',
          plate: '34 ABC 123',
          capacity: 45,
        ),
        createdAt: DateTime.now(),
        isDeleted: false,
        extraDetail: '',
        departureDays: [1, 3, 5], // Pzt, Çar, Cum
        departureTime: '09:00',
      ),
      TourModel(
        id: '',
        title: 'Kapadokya Balon Turu',
        description:
            'Peri bacaları üzerinde balonla süzülün. Göreme, Ürgüp ve Avanos\'u kuşbakışı görün.',
        price: 1500.0,
        imageUrl: '',
        companyId: 'test_company',
        guideId: 'test_guide',
        guideName: 'Fatma Kaya',
        capacity: 20,
        city: 'Nevşehir',
        region: 'İç Anadolu',
        busInfo: BusInfo(
          driverName: 'Ali Güneş',
          phoneNumber: '05339876543',
          plate: '50 DEF 456',
          capacity: 30,
        ),
        createdAt: DateTime.now(),
        isDeleted: false,
        extraDetail: '',
        departureDays: [6, 7], // Cmt, Paz
        departureTime: '06:00',
      ),
      TourModel(
        id: '',
        title: 'Efes Antik Kenti Turu',
        description:
            'Dünyanın en iyi korunmuş antik kentlerinden Efes\'i keşfedin. Celsus Kütüphanesi, Büyük Tiyatro ve daha fazlası.',
        price: 350.0,
        imageUrl: '',
        companyId: 'test_company',
        guideId: 'test_guide',
        guideName: 'Elif Çelik',
        capacity: 35,
        city: 'İzmir',
        region: 'Ege',
        busInfo: BusInfo(
          driverName: 'Hasan Yıldız',
          phoneNumber: '05351112233',
          plate: '35 GHI 789',
          capacity: 50,
        ),
        createdAt: DateTime.now(),
        isDeleted: false,
        extraDetail: '',
        departureDays: [2, 4, 6], // Sal, Per, Cmt
        departureTime: '08:30',
      ),
      TourModel(
        id: '',
        title: 'Antalya Tekne Turu',
        description:
            'Antalya\'nın turkuaz sularında tekne turu. Düden Şelalesi, Karpuzkaldıran ve koylar.',
        price: 200.0,
        imageUrl: '',
        companyId: 'test_company',
        guideId: 'test_guide',
        guideName: 'Murat Öz',
        capacity: 30,
        city: 'Antalya',
        region: 'Akdeniz',
        busInfo: BusInfo(
          driverName: 'Kemal Aydın',
          phoneNumber: '05364445566',
          plate: '07 JKL 012',
          capacity: 40,
        ),
        createdAt: DateTime.now(),
        isDeleted: false,
        extraDetail: '',
        departureDays: [1, 2, 3, 4, 5, 6, 7], // Her gün
        departureTime: '10:00',
      ),
      TourModel(
        id: '',
        title: 'Uzungöl Doğa Turu',
        description: 'Trabzon Uzungöl\'ün büyüleyici doğasında yürüyüş ve fotoğraf turu.',
        price: 300.0,
        imageUrl: '',
        companyId: 'test_company',
        guideId: 'test_guide',
        guideName: 'Zeynep Korkmaz',
        capacity: 25,
        city: 'Trabzon',
        region: 'Karadeniz',
        busInfo: BusInfo(
          driverName: 'Osman Kara',
          phoneNumber: '05377778899',
          plate: '61 MNO 345',
          capacity: 35,
        ),
        createdAt: DateTime.now(),
        isDeleted: false,
        extraDetail: '',
        departureDays: [5, 6], // Cum, Cmt
        departureTime: '07:00',
      ),
      TourModel(
        id: '',
        title: 'Pamukkale Travertenleri',
        description:
            'Beyaz cennet Pamukkale travertenlerini ve Hierapolis antik kentini ziyaret edin.',
        price: 400.0,
        imageUrl: '',
        companyId: 'test_company',
        guideId: 'test_guide',
        guideName: 'Deniz Acar',
        capacity: 30,
        city: 'Denizli',
        region: 'Ege',
        busInfo: BusInfo(
          driverName: 'Yusuf Şahin',
          phoneNumber: '05381234567',
          plate: '20 PQR 678',
          capacity: 45,
        ),
        createdAt: DateTime.now(),
        isDeleted: false,
        extraDetail: '',
        departureDays: [3, 7], // Çar, Paz
        departureTime: '08:00',
      ),
      TourModel(
        id: '',
        title: 'Nemrut Dağı Gün Doğumu',
        description: 'Nemrut Dağı zirvesinde muhteşem gün doğumunu izleyin. UNESCO Dünya Mirası.',
        price: 500.0,
        imageUrl: '',
        companyId: 'test_company',
        guideId: 'test_guide',
        guideName: 'Hüseyin Polat',
        capacity: 20,
        city: 'Adıyaman',
        region: 'Doğu Anadolu',
        busInfo: BusInfo(
          driverName: 'İbrahim Tan',
          phoneNumber: '05399876543',
          plate: '02 STU 901',
          capacity: 30,
        ),
        createdAt: DateTime.now(),
        isDeleted: false,
        extraDetail: '',
        departureDays: [6], // Cmt
        departureTime: '04:00',
      ),
      TourModel(
        id: '',
        title: 'Sapanca Günübirlik Tur',
        description: 'Sapanca Gölü etrafında doğa yürüyüşü, at binme ve mangal keyfi.',
        price: 150.0,
        imageUrl: '',
        companyId: 'test_company',
        guideId: 'test_guide',
        guideName: 'Seda Arslan',
        capacity: 40,
        city: 'Sakarya',
        region: 'Günü Birlik',
        busInfo: BusInfo(
          driverName: 'Emre Koç',
          phoneNumber: '05401112233',
          plate: '54 VWX 234',
          capacity: 50,
        ),
        createdAt: DateTime.now(),
        isDeleted: false,
        extraDetail: '',
        departureDays: [6, 7], // Cmt, Paz
        departureTime: '09:30',
      ),
      TourModel(
        id: '',
        title: 'Yunanistan Adaları Turu',
        description: 'Santorini ve Mykonos adalarında 3 günlük tatil turu. Konaklama dahil.',
        price: 5000.0,
        imageUrl: '',
        companyId: 'test_company',
        guideId: 'test_guide',
        guideName: 'Caner Doğan',
        capacity: 25,
        city: 'Atina',
        region: 'Yurtdışı',
        busInfo: BusInfo(
          driverName: 'Transfer dahil',
          phoneNumber: '05411234567',
          plate: '-',
          capacity: 25,
        ),
        createdAt: DateTime.now(),
        isDeleted: false,
        extraDetail: '',
        departureDays: [1], // Pzt
        departureTime: '11:00',
      ),
      TourModel(
        id: '',
        title: 'Göbeklitepe Tarih Turu',
        description: 'Dünyanın en eski tapınağı Göbeklitepe\'yi ziyaret edin. 12.000 yıllık tarih.',
        price: 450.0,
        imageUrl: '',
        companyId: 'test_company',
        guideId: 'test_guide',
        guideName: 'Burak Eren',
        capacity: 30,
        city: 'Şanlıurfa',
        region: 'Güneydoğu Anadolu',
        busInfo: BusInfo(
          driverName: 'Serkan Demir',
          phoneNumber: '05429876543',
          plate: '63 YZA 567',
          capacity: 40,
        ),
        createdAt: DateTime.now(),
        isDeleted: false,
        extraDetail: '',
        departureDays: [4, 5], // Per, Cum
        departureTime: '07:30',
      ),
    ];

    try {
      final results = await _service.addMultipleTours(sampleTours);

      int successCount = 0;
      for (final result in results) {
        if (result.success) {
          successCount++;
          _addLog('Eklendi: "${result.tourTitle}" (${result.docId})');
        } else {
          _addLog('Başarısız: "${result.tourTitle}" - ${result.error}', isError: true);
        }
      }

      Get.snackbar(
        'Toplu Ekleme Tamamlandı',
        '$successCount / ${sampleTours.length} tur başarıyla eklendi',
        backgroundColor: successCount == sampleTours.length
            ? AppColors.success.withValues(alpha: 0.9)
            : AppColors.warning.withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    } catch (e) {
      _addLog('Toplu ekleme hatası: $e', isError: true);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _deleteTestTours() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Test Turlarını Sil', style: TextStyle(color: Colors.white)),
        content: const Text(
          'companyId = "test_company" olan tüm turlar silinecek.\nEmin misiniz?',
          style: TextStyle(color: AppColors.slate300),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('İptal')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Sil', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    _isLoading.value = true;

    try {
      final deletedCount = await _service.deleteTestTours();
      _addLog('$deletedCount test turu silindi');

      Get.snackbar(
        'Silindi',
        '$deletedCount test turu başarıyla silindi',
        backgroundColor: AppColors.success.withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    } on TestTourException catch (e) {
      _addLog('Silme hatası: ${e.message}', isError: true);
    } finally {
      _isLoading.value = false;
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _imageUrlController.clear();
    _cityController.clear();
    _capacityController.clear();
    _guideNameController.clear();
    _driverNameController.clear();
    _driverPhoneController.clear();
    _plateController.clear();
    _busCapacityController.clear();
    // Program controller'larını temizle
    for (final day in _programDays) {
      (day['title'] as TextEditingController).dispose();
      for (final ctrl in day['activities'] as List<TextEditingController>) {
        ctrl.dispose();
      }
    }
    _programDays.clear();
    _departureTimeController.clear();
    _selectedDepartureDays.clear();
    _selectedDates.clear();
    _selectedRegion.value = 'Marmara';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('🧪 Test Tur Ekle', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.slate900,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Toplu örnek tur ekle
          Obx(
            () => IconButton(
              onPressed: _isLoading.value ? null : _addSampleTours,
              icon: const Icon(Icons.playlist_add, color: AppColors.success),
              tooltip: 'Örnek Turları Ekle (10 adet)',
            ),
          ),
          // Test turlarını sil
          Obx(
            () => IconButton(
              onPressed: _isLoading.value ? null : _deleteTestTours,
              icon: const Icon(Icons.delete_sweep, color: AppColors.error),
              tooltip: 'Test Turlarını Sil',
            ),
          ),
        ],
      ),
      body: Obx(
        () => _isLoading.value
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text('İşlem yapılıyor...', style: TextStyle(color: AppColors.slate400)),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.info, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bu ekran yalnızca test amaçlıdır. Sağ üstteki butonlarla örnek tur ekleyebilir veya test turlarını toplu silebilirsiniz.',
                              style: TextStyle(color: AppColors.slate300, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Manuel Tur Ekleme Formu
                    _buildSectionTitle('Tur Bilgileri'),
                    const SizedBox(height: 12),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _titleController,
                            label: 'Tur Başlığı',
                            icon: Icons.title,
                            validator: (v) => v == null || v.isEmpty ? 'Başlık gerekli' : null,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _descriptionController,
                            label: 'Açıklama',
                            icon: Icons.description,
                            maxLines: 3,
                            validator: (v) => v == null || v.isEmpty ? 'Açıklama gerekli' : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _priceController,
                                  label: 'Fiyat (₺)',
                                  icon: Icons.attach_money,
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Fiyat gerekli';
                                    if (double.tryParse(v) == null) return 'Geçerli sayı girin';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _capacityController,
                                  label: 'Kontenjan',
                                  icon: Icons.people,
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Kontenjan gerekli';
                                    if (int.tryParse(v) == null) return 'Geçerli sayı girin';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _cityController,
                            label: 'Şehir',
                            icon: Icons.location_city,
                            validator: (v) => v == null || v.isEmpty ? 'Şehir gerekli' : null,
                          ),
                          const SizedBox(height: 12),
                          _buildRegionDropdown(),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _imageUrlController,
                            label: 'Görsel URL (Opsiyonel)',
                            icon: Icons.image,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _guideNameController,
                            label: 'Rehber Adı (Opsiyonel)',
                            icon: Icons.person,
                          ),

                          const SizedBox(height: 20),
                          _buildSectionTitle('Çıkış Takvimi'),
                          const SizedBox(height: 8),
                          _buildDepartureDaysSelector(),
                          const SizedBox(height: 12),
                          _buildSelectedDatesSection(),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _departureTimeController,
                            label: 'Çıkış Saati (ör: 09:00)',
                            icon: Icons.access_time,
                          ),

                          const SizedBox(height: 20),
                          _buildSectionTitle('Tur Programı'),
                          const SizedBox(height: 8),
                          _buildProgramSection(),

                          const SizedBox(height: 20),
                          _buildSectionTitle('Araç Bilgileri'),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _driverNameController,
                            label: 'Şoför Adı',
                            icon: Icons.drive_eta,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _driverPhoneController,
                            label: 'Şoför Telefonu',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _plateController,
                                  label: 'Plaka',
                                  icon: Icons.confirmation_number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _busCapacityController,
                                  label: 'Araç Kapasitesi',
                                  icon: Icons.airline_seat_recline_normal,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton.icon(
                      onPressed: _isLoading.value ? null : _submitTour,
                      icon: const Icon(Icons.cloud_upload, color: Colors.white),
                      label: const Text(
                        'Turu Firestore\'a Ekle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Log Alanı
                    if (_logMessages.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle('İşlem Logları'),
                          TextButton(
                            onPressed: _logMessages.clear,
                            child: const Text(
                              'Temizle',
                              style: TextStyle(color: AppColors.slate400, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.slate900,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.slate700),
                        ),
                        child: ListView.builder(
                          itemCount: _logMessages.length,
                          itemBuilder: (context, index) {
                            final msg = _logMessages[index];
                            final isError = msg.startsWith('❌');
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                msg,
                                style: TextStyle(
                                  color: isError ? AppColors.error : AppColors.success,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.slate400),
        prefixIcon: Icon(icon, color: AppColors.slate500, size: 20),
        filled: true,
        fillColor: AppColors.slate800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.slate700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.slate700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildProgramSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mevcut günler
        ..._programDays.asMap().entries.map((entry) {
          final dayIndex = entry.key;
          final day = entry.value;
          final titleCtrl = day['title'] as TextEditingController;
          final activities = day['activities'] as List<TextEditingController>;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.slate900,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.slate700),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gün başlığı satırı
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: titleCtrl,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: '${dayIndex + 1}. Gün başlığı',
                          hintStyle: TextStyle(color: AppColors.slate500, fontSize: 14),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    // Günü sil
                    IconButton(
                      onPressed: () => _removeProgramDay(dayIndex),
                      icon: const Icon(Icons.close, color: AppColors.error, size: 18),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      tooltip: 'Günü sil',
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Aktiviteler
                ...activities.asMap().entries.map((actEntry) {
                  final actIndex = actEntry.key;
                  final actCtrl = actEntry.value;

                  return Padding(
                    padding: const EdgeInsets.only(left: 18, bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.slate500,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: actCtrl,
                            style: const TextStyle(color: AppColors.slate300, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Aktivite ${actIndex + 1}',
                              hintStyle: TextStyle(color: AppColors.slate600, fontSize: 13),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              filled: true,
                              fillColor: AppColors.slate800,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Aktivite sil
                        if (activities.length > 1)
                          GestureDetector(
                            onTap: () => _removeActivity(dayIndex, actIndex),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.remove_circle_outline,
                                color: AppColors.error,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),

                // Aktivite ekle butonu
                Padding(
                  padding: const EdgeInsets.only(left: 18, top: 4),
                  child: GestureDetector(
                    onTap: () => _addActivity(dayIndex),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add_circle_outline, color: AppColors.primary, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Aktivite Ekle',
                          style: TextStyle(color: AppColors.primary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        // Gün ekle butonu
        OutlinedButton.icon(
          onPressed: _addProgramDay,
          icon: const Icon(Icons.add, color: AppColors.primary, size: 18),
          label: Text(
            _programDays.isEmpty ? 'Program Günü Ekle' : 'Yeni Gün Ekle',
            style: const TextStyle(color: AppColors.primary, fontSize: 13),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDepartureDaysSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.slate800,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: AppColors.slate500, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Haftalık Çıkış Günleri',
                style: TextStyle(color: AppColors.slate400, fontSize: 14),
              ),
              const Spacer(),
              if (_selectedDepartureDays.isNotEmpty)
                GestureDetector(
                  onTap: _selectedDepartureDays.clear,
                  child: const Text(
                    'Temizle',
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _weekDayLabels.entries.map((entry) {
              final dayNum = entry.key;
              final label = entry.value;
              final isSelected = _selectedDepartureDays.contains(dayNum);

              return GestureDetector(
                onTap: () {
                  if (isSelected) {
                    _selectedDepartureDays.remove(dayNum);
                  } else {
                    _selectedDepartureDays.add(dayNum);
                  }
                },
                child: Container(
                  width: 44,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.slate900,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.slate600),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.slate400,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedDepartureDays.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Seçilen günler turun çıkış tarihleri olur. Satın alırken bu tarihlerden seçilir.',
                style: TextStyle(color: AppColors.slate500, fontSize: 11),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Yaklaşan ${_selectedDepartureDays.length} gün için tarih seçenekleri gösterilecek.',
                style: const TextStyle(color: AppColors.primary, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedDatesSection() {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.slate800,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event, color: AppColors.slate500, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Özel Tekil Tarihler',
                style: TextStyle(color: AppColors.slate400, fontSize: 14),
              ),
              const Spacer(),
              if (_selectedDates.isNotEmpty)
                GestureDetector(
                  onTap: _selectedDates.clear,
                  child: const Text(
                    'Temizle',
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_selectedDates.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedDates.map((date) {
                final label = dateFormat.format(date);
                return Chip(
                  backgroundColor: AppColors.slate900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.primary.withOpacity(0.6)),
                  ),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _removeSelectedDate(date),
                        child: const Icon(Icons.close, size: 14, color: AppColors.slate400),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            const Text(
              '"Tarih Ekle" ile özel çıkış tarihleri ekleyebilirsin. Satın alırken listeden seçilir.',
              style: TextStyle(color: AppColors.slate500, fontSize: 11),
            ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.add, color: AppColors.primary, size: 18),
            label: const Text(
              'Tarih Ekle',
              style: TextStyle(color: AppColors.primary, fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRegion.value,
      dropdownColor: AppColors.slate800,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Bölge',
        labelStyle: const TextStyle(color: AppColors.slate400),
        prefixIcon: const Icon(Icons.map, color: AppColors.slate500, size: 20),
        filled: true,
        fillColor: AppColors.slate800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.slate700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.slate700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: _regions.map((region) {
        return DropdownMenuItem(value: region, child: Text(region));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          _selectedRegion.value = value;
        }
      },
    );
  }
}

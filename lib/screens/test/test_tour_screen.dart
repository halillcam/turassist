import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  // State
  bool _isLoading = false;
  String _selectedRegion = 'Marmara';
  final List<String> _logMessages = [];

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
    super.dispose();
  }

  void _addLog(String message, {bool isError = false}) {
    setState(() {
      final prefix = isError ? '❌' : '✅';
      _logMessages.insert(0, '$prefix ${DateTime.now().toString().substring(11, 19)} - $message');
    });
  }

  Future<void> _submitTour() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final tour = TourModel(
        id: '', // Firestore otomatik oluşturacak
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
        region: _selectedRegion,
        busInfo: BusInfo(
          driverName: _driverNameController.text.trim(),
          phoneNumber: _driverPhoneController.text.trim(),
          plate: _plateController.text.trim(),
          capacity: int.tryParse(_busCapacityController.text) ?? 0,
        ),
        createdAt: DateTime.now(),
        isDeleted: false,
      );

      final docId = await _service.addTour(tour);
      _addLog('Tur eklendi: "${tour.title}" (ID: $docId)');

      Get.snackbar(
        'Başarılı',
        'Tur başarıyla eklendi!',
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
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addSampleTours() async {
    setState(() => _isLoading = true);

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
      setState(() => _isLoading = false);
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

    setState(() => _isLoading = true);

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
      setState(() => _isLoading = false);
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
    setState(() => _selectedRegion = 'Marmara');
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
          IconButton(
            onPressed: _isLoading ? null : _addSampleTours,
            icon: const Icon(Icons.playlist_add, color: AppColors.success),
            tooltip: 'Örnek Turları Ekle (10 adet)',
          ),
          // Test turlarını sil
          IconButton(
            onPressed: _isLoading ? null : _deleteTestTours,
            icon: const Icon(Icons.delete_sweep, color: AppColors.error),
            tooltip: 'Test Turlarını Sil',
          ),
        ],
      ),
      body: _isLoading
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
                    onPressed: _isLoading ? null : _submitTour,
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
                          onPressed: () => setState(() => _logMessages.clear()),
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

  Widget _buildRegionDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRegion,
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
          setState(() => _selectedRegion = value);
        }
      },
    );
  }
}

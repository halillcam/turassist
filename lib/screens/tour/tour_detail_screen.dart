import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../config/app_routes.dart';
import '../../config/colors.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/my_tours_controller.dart';
import '../../models/tour_model.dart';
import '../../models/tour_program_model.dart';
import '../../services/firebase_service.dart';

class TourDetailScreen extends StatefulWidget {
  /// Serideki tüm turlar (aynı turun farklı tarihleri). İlk eleman display için kullanılır.
  final List<TourModel> toursInSeries;

  const TourDetailScreen({super.key, required this.toursInSeries});

  TourModel get _displayTour => toursInSeries.first;

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  bool _isDescriptionExpanded = false;
  List<TourProgramDay> _programDays = [];
  bool _isProgramLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTourProgram();
  }

  Future<void> _loadTourProgram() async {
    final days = await FirebaseService().getTourProgram(widget._displayTour.id);
    if (mounted) {
      setState(() {
        _programDays = days;
        _isProgramLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tour = widget._displayTour;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero image
                _buildHeroImage(tour),

                // Info card (overlapping image)
                _buildInfoCard(tour),

                // Tur Hakkında
                _buildAboutSection(tour),

                // Tur Programı
                _buildProgramSection(),

                // Tur Ekstraları
                if (tour.extraDetail.isNotEmpty) _buildExtrasSection(tour),
              ],
            ),
          ),

          // Floating back button
          _buildBackButton(),

          // Bottom price bar
          _buildBottomBar(tour),
        ],
      ),
    );
  }

  /// Test amaçlı hızlı rezervasyon: ödeme atlayarak bilet oluşturur.
  Future<void> _handleReservation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        'Giriş Yapın',
        'Rezervasyon yapmak için giriş yapmalısınız.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    // Serideki turların departureDate'lerinden tarih seçtir (her tarih = ayrı tur doc)
    if (widget.toursInSeries.isEmpty) return;
    final selected = await _showDepartureDatePicker(widget.toursInSeries);
    if (selected == null) return;

    final profile = await FirebaseService().getUserProfile();
    final profileName = profile?.fullName.trim() ?? '';
    final displayName = user.displayName?.trim() ?? '';
    final emailFallback = (user.email ?? '').split('@').first.trim();
    final passengerName = profileName.isNotEmpty
        ? profileName
        : (displayName.isNotEmpty
              ? displayName
              : (emailFallback.isNotEmpty ? emailFallback : 'Yolcu'));

    final slotId = DateFormat('yyyy-MM-dd').format(selected.date);
    final bookingController = Get.put(BookingController());
    await bookingController.purchaseTicket(
      tourId: selected.tour.id,
      slotId: slotId,
      companyId: selected.tour.companyId,
      passengerName: passengerName,
      tcNo: '00000000000',
      price: selected.tour.price,
      subMerchantKey: '',
      departureDate: selected.date,
    );

    // MyToursController'u sil ki yeniden oluşturulup loadData çağrılsın
    if (Get.isRegistered<MyToursController>()) {
      Get.delete<MyToursController>();
    }

    // Turlarım sayfasına yönlendir
    Get.offNamed(AppRoutes.myTours);
  }

  /// Serideki turların tarihlerini gösterir. Her tarih = ayrı tur doc ise o doc'un ID'si ile bilet oluşur.
  /// Legacy tek tur (departureDays/departureDates) ise aynı tour.id, slotId ile ayrışır.
  Future<({TourModel tour, DateTime date})?> _showDepartureDatePicker(List<TourModel> toursInSeries) async {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    var options = <({TourModel tour, DateTime date})>[];

    final withDate = toursInSeries.where((t) => t.departureDate != null).toList();
    if (withDate.isNotEmpty) {
      for (final t in withDate) {
        final d = t.departureDate!;
        final date = DateTime(d.year, d.month, d.day);
        if (!date.isBefore(today)) options.add((tour: t, date: date));
    final tourIds = options.map((o) => o.tour.id).toSet().toList();
      }
    } else {
      final first = toursInSeries.first;
      final upcoming = first.getUpcomingDepartures(count: 12);
      for (final date in upcoming) {
        options.add((tour: first, date: date));
      }
    }
    options.sort((a, b) => a.date.compareTo(b.date));
    if (options.isEmpty) return null;

    final slotIds = options.map((o) => DateFormat('yyyy-MM-dd').format(o.date)).toList();
    final counts = <String, int>{};
    for (var i = 0; i < options.length; i++) {
      final c = await FirebaseService().getSlotTicketCounts(options[i].tour.id, [slotIds[i]]);
      counts[slotIds[i]] = c[slotIds[i]] ?? 0;
    }

    if (!mounted) return null;

    return showModalBottomSheet<({TourModel tour, DateTime date})>(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.slate500,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Çıkış Tarihi Seçin',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (options.isNotEmpty && options.first.tour.departureTime.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Kalkış saati: ${options.first.tour.departureTime}',
                      style: const TextStyle(color: AppColors.slate400, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ...options.map((opt) {
                    final sid = DateFormat('yyyy-MM-dd').format(opt.date);
                    final sold = counts[sid] ?? 0;
                    final remaining = opt.tour.capacity - sold;
                    final isFull = remaining <= 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: isFull ? null : () => Navigator.of(ctx).pop(opt),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isFull
                                  ? AppColors.slate800.withOpacity(0.5)
                                  : AppColors.slate800,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isFull
                                    ? AppColors.slate700
                                    : AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: isFull ? AppColors.slate600 : AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatDateTurkish(opt.date),
                                        style: TextStyle(
                                          color: isFull ? AppColors.slate500 : AppColors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isFull ? 'Dolu' : '$remaining kişilik yer mevcut',
                                        style: TextStyle(
                                          color: isFull ? AppColors.error : AppColors.slate400,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isFull)
                                  const Icon(
                                    Icons.chevron_right,
                                    color: AppColors.slate400,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Tarih formatlama: "Pazartesi, 14 Temmuz 2025"
  String _formatDateTurkish(DateTime date) {
    const days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildHeroImage(TourModel tour) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          tour.imageUrl.isNotEmpty
              ? Image.network(
                  tour.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.slate800,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.slate500,
                        size: 48,
                      ),
                    ),
                  ),
                )
              : Container(
                  color: AppColors.slate800,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.slate500,
                      size: 48,
                    ),
                  ),
                ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.backgroundDark.withOpacity(0.8)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(TourModel tour) {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate800),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Tour title
              Text(
                tour.title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Divider
              Container(height: 1, color: AppColors.slate800),
              const SizedBox(height: 20),

              // Capacity & Company info
              Row(
                children: [
                  // Kapasite
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(Icons.group, color: AppColors.primary, size: 24),
                        const SizedBox(height: 6),
                        Text(
                          'KAPASİTE',
                          style: TextStyle(
                            color: AppColors.slate500,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${tour.capacity} Kişi',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Ayırıcı
                  Container(width: 1, height: 60, color: AppColors.slate800),
                  // Tur Firması
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(Icons.business, color: AppColors.primary, size: 24),
                        const SizedBox(height: 6),
                        Text(
                          'TUR FİRMASI',
                          style: TextStyle(
                            color: AppColors.slate500,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tour.companyId,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Çıkış günleri / tarihler bilgisi
              if (tour.departureDays.isNotEmpty ||
                  (tour.departureDates != null && tour.departureDates!.isNotEmpty) ||
                  widget.toursInSeries.any((t) => t.departureDate != null)) ...[
                const SizedBox(height: 20),
                Container(height: 1, color: AppColors.slate800),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tour.departureDays.isNotEmpty
                            ? 'Çıkış günleri: ${tour.departureDaysText}'
                            : tour.departureDates != null && tour.departureDates!.isNotEmpty
                                ? 'Özel tarihler: ${tour.departureDates!.length} tarih'
                                : '${widget.toursInSeries.where((t) => t.departureDate != null).length} farklı tarihte çıkış',
                        style: const TextStyle(
                          color: AppColors.slate300,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (tour.departureTime.isNotEmpty) ...[
                      Icon(Icons.access_time, color: AppColors.primary, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        tour.departureTime,
                        style: const TextStyle(
                          color: AppColors.slate300,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection(TourModel tour) {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tur Hakkında',
              style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              tour.description,
              style: const TextStyle(color: AppColors.slate400, fontSize: 14, height: 1.6),
              maxLines: _isDescriptionExpanded ? null : 5,
              overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
            ),
            if (tour.description.length > 150)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isDescriptionExpanded = !_isDescriptionExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isDescriptionExpanded ? 'Daha az göster' : 'Daha fazla oku',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isDescriptionExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtrasSection(TourModel tour) {
    final extras = tour.extraDetail
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Transform.translate(
      offset: const Offset(0, -12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: const [
                Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Tur Ekstraları',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.slate800),
              ),
              padding: const EdgeInsets.all(16),
              child: extras.length > 1
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: extras
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Icon(
                                      Icons.star_rounded,
                                      color: AppColors.primary,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        color: AppColors.slate300,
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    )
                  : Text(
                      tour.extraDetail,
                      style: const TextStyle(color: AppColors.slate300, fontSize: 14, height: 1.6),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramSection() {
    return Transform.translate(
      offset: const Offset(0, -8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Tur Programı',
              style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            if (_isProgramLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
                ),
              )
            else if (_programDays.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Henüz program eklenmemiş.',
                  style: TextStyle(color: AppColors.slate500, fontSize: 14),
                ),
              )
            else
              ..._programDays.map(_buildDayItem),
          ],
        ),
      ),
    );
  }

  Widget _buildDayItem(TourProgramDay day) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          Column(
            children: [
              // Day dot
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              // Line
              if (day != _programDays.last)
                Container(
                  width: 2,
                  height: day.activities.length * 32.0 + 16,
                  color: AppColors.slate800,
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Day content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day title
                Transform.translate(
                  offset: const Offset(0, -3),
                  child: Text(
                    day.title.isNotEmpty ? '${day.day}. Gün' : '${day.day}. Gün',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Activities
                ...day.activities.map(
                  (activity) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.slate500,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            activity.trim(),
                            style: const TextStyle(
                              color: AppColors.slate300,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: const Center(
            child: Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(TourModel tour) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark.withOpacity(0.9),
          border: const Border(top: BorderSide(color: AppColors.slate800)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Price section
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KİŞİ BAŞI FİYAT',
                  style: TextStyle(
                    color: AppColors.slate500,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₺${tour.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),

            // Reservation button
            GestureDetector(
              onTap: _handleReservation,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Hemen Rezervasyon Yap',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

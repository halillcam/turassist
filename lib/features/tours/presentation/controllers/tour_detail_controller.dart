import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../config/app_routes.dart';
import '../../../../core/models/ticket_model.dart';
import '../../../../core/models/tour_model.dart';
import '../../../../core/models/tour_program_model.dart';
import '../../data/repositories/tours_repository_impl.dart';
import '../../domain/usecases/create_ticket_use_case.dart';
import '../../domain/usecases/get_current_profile_use_case.dart';
import '../../domain/usecases/get_current_user_id_use_case.dart';
import '../../domain/usecases/get_tour_program_use_case.dart';

class TourDetailController extends GetxController {
  TourDetailController({
    GetTourProgramUseCase? getTourProgramUseCase,
    GetCurrentProfileUseCase? getCurrentProfileUseCase,
    GetCurrentUserIdUseCase? getCurrentUserIdUseCase,
    CreateTicketUseCase? createTicketUseCase,
  }) : _getTourProgramUseCase =
           getTourProgramUseCase ?? GetTourProgramUseCase(ToursRepositoryImpl()),
       _getCurrentProfileUseCase =
           getCurrentProfileUseCase ?? GetCurrentProfileUseCase(ToursRepositoryImpl()),
       _getCurrentUserIdUseCase =
           getCurrentUserIdUseCase ?? GetCurrentUserIdUseCase(ToursRepositoryImpl()),
       _createTicketUseCase = createTicketUseCase ?? CreateTicketUseCase(ToursRepositoryImpl());

  final GetTourProgramUseCase _getTourProgramUseCase;
  final GetCurrentProfileUseCase _getCurrentProfileUseCase;
  final GetCurrentUserIdUseCase _getCurrentUserIdUseCase;
  final CreateTicketUseCase _createTicketUseCase;

  final RxList<TourProgramDay> programDays = <TourProgramDay>[].obs;
  final RxBool isProgramLoading = true.obs;
  final RxBool isDescriptionExpanded = false.obs;
  final RxString companyName = ''.obs;
  final RxBool isReserving = false.obs;

  Future<void> loadTourContext(TourModel tour) async {
    isProgramLoading.value = true;
    programDays.assignAll(await _getTourProgramUseCase.execute(tour.id));
    companyName.value = (tour.companyName ?? '').trim();
    isProgramLoading.value = false;
  }

  void toggleDescription() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }

  Future<void> reserve(List<TourModel> toursInSeries) async {
    final userId = _getCurrentUserIdUseCase.execute();
    if (userId.isEmpty) {
      Get.snackbar('Giriş Yapın', 'Rezervasyon yapmak için giriş yapmalısınız.');
      return;
    }

    final selected = await selectDeparture(toursInSeries);
    if (selected == null) return;

    final profile = await _getCurrentProfileUseCase.execute();
    final passengerName = (profile?.fullName.trim().isNotEmpty ?? false)
        ? profile!.fullName.trim()
        : 'Yolcu';

    isReserving.value = true;
    try {
      final slotId = DateFormat('yyyy-MM-dd').format(selected.date);
      await _createTicketUseCase.execute(
        TicketModel(
          id: '',
          tourId: selected.tour.id,
          userId: userId,
          companyId: selected.tour.companyId,
          slotId: slotId,
          passengerName: passengerName,
          tcNo: profile?.tcNo ?? '00000000000',
          pricePaid: selected.tour.price,
          status: 'active',
          qrToken: '',
          isScanned: false,
          purchaseDate: DateTime.now(),
          departureDate: selected.date,
        ),
      );
      Get.offNamed(AppRoutes.myTours);
      Get.snackbar('Başarılı', 'Bilet başarıyla satın alındı!');
    } catch (error) {
      Get.snackbar('Hata', error.toString().replaceFirst('Exception: ', ''));
    } finally {
      isReserving.value = false;
    }
  }

  Future<({TourModel tour, DateTime date})?> selectDeparture(List<TourModel> toursInSeries) async {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final options = <({TourModel tour, DateTime date})>[];
    final withDate = toursInSeries.where((tour) => tour.departureDate != null).toList();
    if (withDate.isNotEmpty) {
      for (final tour in withDate) {
        final date = DateTime(
          tour.departureDate!.year,
          tour.departureDate!.month,
          tour.departureDate!.day,
        );
        if (!date.isBefore(today)) {
          options.add((tour: tour, date: date));
        }
      }
    } else if (toursInSeries.isNotEmpty) {
      for (final date in toursInSeries.first.getUpcomingDepartures(count: 12)) {
        options.add((tour: toursInSeries.first, date: date));
      }
    }
    options.sort((left, right) => left.date.compareTo(right.date));
    if (options.isEmpty) return null;

    return Get.bottomSheet<({TourModel tour, DateTime date})>(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF1E2430),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Çıkış Tarihi Seçin',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...options.map((option) {
                final isFull = option.tour.capacity <= 0;
                return ListTile(
                  onTap: isFull ? null : () => Get.back(result: option),
                  leading: const Icon(Icons.calendar_today, color: Colors.white),
                  title: Text(
                    DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(option.date),
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    isFull ? 'Dolu' : '${option.tour.capacity} kişilik yer mevcut',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: isFull
                      ? const Icon(Icons.block, color: Colors.redAccent)
                      : const Icon(Icons.chevron_right, color: Colors.white70),
                );
              }),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

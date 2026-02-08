import 'package:flutter/material.dart';
import 'package:turassist/config/colors.dart';
import 'package:turassist/models/tour_model.dart';
import 'package:turassist/widgets/included_item.dart';

class TourDetailScreen extends StatefulWidget {
  final TourModel tour;

  const TourDetailScreen({super.key, required this.tour});

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final tour = widget.tour;

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

                // Neler dahil
                _buildIncludedSection(),
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

  Widget _buildIncludedSection() {
    return Transform.translate(
      offset: const Offset(0, -8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Neler dahil',
              style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 3.5,
              children: const [
                IncludedItem(icon: Icons.check_circle, label: 'Profesyonel rehber'),
                IncludedItem(icon: Icons.restaurant, label: 'Geleneksel öğle yemeği'),
                IncludedItem(icon: Icons.confirmation_number, label: 'Giriş ücretleri'),
                IncludedItem(icon: Icons.directions_bus, label: 'Otelden alma'),
              ],
            ),
          ],
        ),
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
              onTap: () {
                // TODO: Rezervasyon işlemi
              },
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

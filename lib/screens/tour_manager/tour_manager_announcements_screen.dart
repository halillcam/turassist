import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:turassist/config/colors.dart';

class TourManagerAnnouncementsScreen extends StatefulWidget {
  const TourManagerAnnouncementsScreen({super.key});

  @override
  State<TourManagerAnnouncementsScreen> createState() => _TourManagerAnnouncementsScreenState();
}

class _TourManagerAnnouncementsScreenState extends State<TourManagerAnnouncementsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final int _maxLength = 280;

  // Örnek önceki duyurular
  final List<Map<String, String>> _previousAnnouncements = [
    {
      'time': 'BUGÜN, 14:20',
      'message':
          '"Müze gezimiz tamamlanmıştır. Herkesin 10 dakika içinde otopark alanındaki 34 ABC 123 plakalı otobüste olmasını rica ederim."',
    },
    {
      'time': 'BUGÜN, 12:45',
      'message': '"Öğle yemeği molası başlamıştır. Toplanma yerimiz restoran girişidir."',
    },
    {
      'time': 'BUGÜN, 09:00',
      'message': '"Turumuz başlıyor! Lütfen yaka kartlarınızı takmayı unutmayın."',
    },
  ];

  // Hazır mesaj şablonları
  final List<Map<String, String>> _quickMessages = [
    {
      'emoji': '🚌',
      'label': 'Otobüs Kalkış',
      'text': 'Otobüs 5 dakika içinde kalkıyor. Lütfen yerinize geçin.',
    },
    {'emoji': '📍', 'label': 'Girişte Buluşma', 'text': 'Lütfen giriş noktasında toplanın.'},
    {
      'emoji': '🍽️',
      'label': 'Yemek Molası',
      'text': 'Yemek molası başlamıştır. Toplanma yerimiz restoran girişidir.',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _appendQuickMessage(String text) {
    final current = _messageController.text;
    if (current.isNotEmpty && !current.endsWith(' ')) {
      _messageController.text = '$current $text';
    } else {
      _messageController.text = '$current$text';
    }
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: _messageController.text.length),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Yeni duyuru bölümü
                    _buildNewAnnouncementSection(),
                    // Hazır mesaj butonları
                    _buildQuickMessages(),
                    const SizedBox(height: 16),
                    // Önceki duyurular
                    _buildPreviousAnnouncements(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ──
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(bottom: BorderSide(color: AppColors.slate800, width: 1)),
      ),
      child: Row(
        children: [
          // Geri butonu
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.slate800.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Duyuru Gönder',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Antik Kent Turu • Grup A',
                  style: TextStyle(color: AppColors.slate500, fontSize: 12),
                ),
              ],
            ),
          ),
          // More button
          GestureDetector(
            onTap: () {
              // TODO: More options
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Icon(Icons.more_horiz, color: AppColors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  // ── Yeni Duyuru Bölümü ──
  Widget _buildNewAnnouncementSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.slate900.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate800),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'YENİ DUYURU',
                  style: TextStyle(
                    color: AppColors.slate300,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10b981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'CANLI YAYIN',
                      style: TextStyle(
                        color: Color(0xFF10b981),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Text input
            Stack(
              children: [
                TextField(
                  controller: _messageController,
                  maxLines: 5,
                  maxLength: _maxLength,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: AppColors.white, fontSize: 16, height: 1.5),
                  decoration: InputDecoration(
                    hintText: 'Mesajınızı buraya yazın... (Örn: Otobüs 5 dakika içinde kalkıyor)',
                    hintStyle: TextStyle(color: AppColors.slate500, fontSize: 15),
                    filled: true,
                    fillColor: AppColors.slate800.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    counterText: '',
                  ),
                ),
                // Karakter sayacı
                Positioned(
                  bottom: 8,
                  right: 12,
                  child: Text(
                    '${_messageController.text.length} / $_maxLength',
                    style: TextStyle(
                      color: AppColors.slate600,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Gönder butonu
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _messageController.text.trim().isEmpty
                    ? null
                    : () {
                        // TODO: Send announcement
                        setState(() {
                          _previousAnnouncements.insert(0, {
                            'time': 'AZ ÖNCE',
                            'message': '"${_messageController.text.trim()}"',
                          });
                          _messageController.clear();
                        });
                      },
                icon: const Icon(Icons.send, size: 22),
                label: const Text(
                  'Tüm Katılımcılara Gönder',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                  foregroundColor: AppColors.white,
                  disabledForegroundColor: AppColors.white.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 6,
                  shadowColor: AppColors.primary.withOpacity(0.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hazır Mesaj Butonları ──
  Widget _buildQuickMessages() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _quickMessages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final msg = _quickMessages[index];
          return GestureDetector(
            onTap: () => _appendQuickMessage(msg['text']!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.slate800.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.slate800),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(msg['emoji']!, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    msg['label']!,
                    style: const TextStyle(
                      color: AppColors.slate400,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Önceki Duyurular ──
  Widget _buildPreviousAnnouncements() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Önceki Duyurular',
                style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Show all
                },
                child: const Text(
                  'Tümünü Gör',
                  style: TextStyle(
                    color: AppColors.slate500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Duyuru kartları
          ...List.generate(_previousAnnouncements.length, (index) {
            final announcement = _previousAnnouncements[index];
            final isFirst = index == 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Opacity(
                opacity: isFirst ? 1.0 : 0.7,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.slate900.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.slate800.withOpacity(0.6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement['time']!,
                        style: const TextStyle(
                          color: AppColors.slate500,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        announcement['message']!,
                        style: TextStyle(
                          color: isFirst ? AppColors.slate200 : AppColors.slate400,
                          fontSize: 14,
                          height: 1.5,
                          fontWeight: isFirst ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

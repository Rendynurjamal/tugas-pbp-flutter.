import 'package:flutter/material.dart';

import 'login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const Color background = Color(0xFF121214);
  static const Color surface = Color(0xFF1C1C22);
  static const Color gold = Color(0xFFD4AF37);
  static const Color textPrimary = Color(0xFFF5F3EF);
  static const Color textSecondary = Color(0xFFA6A6B2);

  final PageController _controller = PageController();
  int _index = 0;

  final List<Map<String, dynamic>> slides = [
    {
      'icon': Icons.calendar_month_outlined,
      'title': 'Booking Tanpa Ribet',
      'desc':
          'Pilih layanan servis yang kamu butuhkan dan atur jadwal kunjungan dalam hitungan detik.',
    },
    {
      'icon': Icons.history,
      'title': 'Pantau Riwayat Servis',
      'desc':
          'Semua riwayat servis kendaraan kamu tersimpan rapi dan bisa dicek kapan saja.',
    },
    {
      'icon': Icons.chat_outlined,
      'title': 'Chat Admin Langsung',
      'desc':
          'Ada pertanyaan? Hubungi admin BengkelKu langsung lewat WhatsApp dari dalam aplikasi.',
    },
  ];

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text(
                    'Lewati',
                    style: TextStyle(color: textSecondary),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (i) {
                  setState(() {
                    _index = i;
                  });
                },
                itemBuilder: (context, i) {
                  final slide = slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: gold.withOpacity(0.4)),
                          ),
                          child: Icon(
                            slide['icon'] as IconData,
                            color: gold,
                            size: 56,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          slide['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide['desc'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (i) {
                final bool active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active ? gold : const Color(0x1AFFFFFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (_index == slides.length - 1) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _index == slides.length - 1 ? 'Mulai' : 'Lanjut',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

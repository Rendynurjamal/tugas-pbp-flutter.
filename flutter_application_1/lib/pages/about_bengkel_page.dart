import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AboutBengkelPage extends StatelessWidget {
  const AboutBengkelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Tentang BengkelKu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        children: [
          // HERO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.surfaceAlt, AppColors.surface],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.gold.withOpacity(0.25)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 1.5),
                  ),
                  child: const CircleAvatar(
                    radius: 38,
                    backgroundColor: Color(0x1FD4AF37),
                    child: Icon(
                      Icons.workspace_premium,
                      color: AppColors.gold,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Bengkel',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: 'Ku',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Terverifikasi & Terpercaya sejak awal berdiri',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // STATISTIK / PENCAPAIAN
          Row(
            children: [
              Expanded(child: _statBox(value: '4.9', label: 'Rating', icon: Icons.star)),
              const SizedBox(width: 10),
              Expanded(child: _statBox(value: '350+', label: 'Ulasan', icon: Icons.reviews_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _statBox(value: '5+', label: 'Tahun', icon: Icons.calendar_month_outlined)),
            ],
          ),

          const SizedBox(height: 26),

          _title('Cerita Kami'),
          const SizedBox(height: 10),
          _card(
            child: const Text(
              'BengkelKu berawal dari sebuah bengkel kecil yang berkomitmen memberikan '
              'pelayanan servis kendaraan yang jujur, cepat, dan berkualitas. Seiring waktu, '
              'kepercayaan pelanggan membuat kami terus berkembang — kini melayani berbagai '
              'jenis kendaraan mulai dari mobil pribadi hingga kendaraan berat, dengan tim '
              'teknisi berpengalaman dan bersertifikat.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 13.5),
            ),
          ),

          const SizedBox(height: 26),

          _title('Perjalanan Kami'),
          const SizedBox(height: 14),
          _timelineItem(
            year: 'Awal Berdiri',
            title: 'BengkelKu Didirikan',
            description: 'Memulai usaha dengan fokus pada servis kendaraan roda empat.',
            isFirst: true,
          ),
          _timelineItem(
            year: 'Berkembang',
            title: 'Perluasan Layanan',
            description: 'Menambah layanan untuk truk, bus, dan alat berat.',
          ),
          _timelineItem(
            year: 'Digitalisasi',
            title: 'Peluncuran Aplikasi BengkelKu',
            description: 'Booking servis kini bisa dilakukan langsung dari aplikasi.',
          ),
          _timelineItem(
            year: 'Sekarang',
            title: 'Terus Melayani dengan Terpercaya',
            description: 'Berkomitmen menjaga kualitas dan kepuasan setiap pelanggan.',
            isLast: true,
          ),

          const SizedBox(height: 26),

          _title('Visi & Misi'),
          const SizedBox(height: 10),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.flag_outlined, color: AppColors.gold, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Visi', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                          SizedBox(height: 4),
                          Text(
                            'Menjadi bengkel pilihan utama yang terpercaya dan terjangkau bagi semua kalangan.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.rocket_launch_outlined, color: AppColors.gold, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Misi', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                          SizedBox(height: 4),
                          Text(
                            'Memberikan pelayanan servis yang jujur, cepat, dan berkualitas dengan harga yang wajar.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          _title('Mengapa Memilih Kami'),
          const SizedBox(height: 12),
          _benefitRow(Icons.verified_outlined, 'Teknisi berpengalaman dan bersertifikat'),
          _benefitRow(Icons.payments_outlined, 'Harga transparan, tanpa biaya tersembunyi'),
          _benefitRow(Icons.access_time, 'Estimasi waktu servis yang jelas'),
          _benefitRow(Icons.support_agent_outlined, 'Layanan konsultasi via WhatsApp'),
        ],
      ),
    );
  }

  Widget _title(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: child,
    );
  }

  Widget _statBox({required String value, required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.gold, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _timelineItem({
    required String year,
    required String title,
    required String description,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.gold.withOpacity(0.3)),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    year,
                    style: const TextStyle(color: AppColors.goldSoft, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14.5),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.gold, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

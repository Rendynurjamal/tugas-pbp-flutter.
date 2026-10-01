import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'login_page.dart';
import 'service_page.dart';
import 'detail_service_page.dart';
import '../models/booking_data.dart';
import '../models/mechanic_data.dart';
import '../models/vehicle_data.dart';
import '../theme/app_colors.dart';
import '../widgets/tap_scale.dart';
import 'about_bengkel_page.dart';

// ============================================================
// ROUTE TRANSISI HALUS (fade + slide)
// ============================================================

Route _fadeRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Alias supaya kode di bawah tetap ringkas (gold, surface, dll)
  // tanpa perlu tulis AppColors. di setiap tempat.
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color surfaceAlt = AppColors.surfaceAlt;
  static const Color gold = AppColors.gold;
  static const Color goldSoft = AppColors.goldSoft;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color borderSubtle = AppColors.borderSubtle;

  int selectedIndex = 0;

  final bool hasNotification = true;

  // Rating montir (statis dulu, belum ada sistem review sungguhan)
  final double mechanicRating = 4.8;
  final int mechanicReviewCount = 128;

  // Kendaraan yang sedang dipilih di "garasi" (kunci: plat nomor)
  String? activePlate;

  // Filter riwayat per kendaraan (kunci: plat nomor, 'Semua' = semua)
  String historyPlateFilter = 'Semua';

  // Promo carousel
  int bannerIndex = 0;
  final PageController _bannerController = PageController();

  final List<Map<String, dynamic>> promos = [
    {
      'title': 'Diskon 20% Ganti Oli',
      'subtitle': 'Berlaku untuk semua jenis kendaraan bulan ini',
      'icon': Icons.local_offer_outlined,
      'serviceTitle': 'Ganti Oli',
      'discountPercent': 0.20,
    },
    {
      'title': 'Cek Rem Gratis',
      'subtitle': 'Booking servis mesin, cek sistem rem tanpa biaya tambahan',
      'icon': Icons.verified_outlined,
      'serviceTitle': 'Servis Rem',
      'discountPercent': 1.0,
    },
    {
      'title': 'Member Baru',
      'subtitle': 'Daftar sekarang dan dapatkan voucher servis pertama',
      'icon': Icons.card_giftcard_outlined,
      'serviceTitle': null,
      'discountPercent': 0.0,
    },
  ];

  void _openPromo(Map<String, dynamic> promo) {
    final serviceTitle = promo['serviceTitle'] as String?;
    final discountPercent = promo['discountPercent'] as double? ?? 0.0;
    final promoLabel = promo['title'] as String;

    if (serviceTitle == null) {
      _openMemberRegistration();
      return;
    }

    final service = services.firstWhere(
      (s) => s['title'] == serviceTitle,
      orElse: () => services.first,
    );

    Navigator.push(
      context,
      _fadeRoute(
        DetailServicePage(
          serviceName: service['title'] as String,
          description: service['description'] as String,
          price: service['price'] as String,
          duration: service['duration'] as String,
          icon: service['icon'] as IconData,
          discountPercent: discountPercent,
          promoLabel: promoLabel,
        ),
      ),
    );
  }

  // ============================================================
  // PENDAFTARAN MEMBER BARU (VOUCHER 10% UNTUK BOOKING BERIKUTNYA)
  // ============================================================

  void _openMemberRegistration() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: borderSubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: gold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.card_giftcard, color: gold),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Daftar Member Baru',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Isi data singkat, dapatkan voucher 10% otomatis untuk booking berikutnya.',
                  style: TextStyle(color: textSecondary, fontSize: 12.5),
                ),
                const SizedBox(height: 20),
                _modalLabel('Nama Lengkap'),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: textPrimary),
                  decoration: _modalFieldDecoration('Masukkan nama kamu', Icons.person_outline),
                ),
                const SizedBox(height: 14),
                _modalLabel('Nomor WhatsApp'),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: textPrimary),
                  decoration: _modalFieldDecoration('Contoh: 08123456789', Icons.phone_outlined),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      final phone = phoneCtrl.text.trim();
                      if (name.isEmpty || phone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lengkapi nama dan nomor WhatsApp dulu ya!'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      Navigator.pop(context);

                      setState(() {
                        BookingData.pendingVoucherPercent = 0.10;
                        BookingData.pendingVoucherLabel = 'Voucher Member 10%';
                      });

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          title: const Row(
                            children: [
                              Icon(Icons.celebration, color: gold, size: 28),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Selamat Datang!',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
                                ),
                              ),
                            ],
                          ),
                          content: Text(
                            'Halo $name! Voucher diskon 10% sudah aktif dan akan otomatis dipakai di booking servis berikutnya.',
                            style: const TextStyle(color: textSecondary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() => selectedIndex = 1);
                              },
                              child: const Text(
                                'PILIH LAYANAN',
                                style: TextStyle(color: gold, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: background,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('DAFTAR & DAPATKAN VOUCHER', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Search
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Keranjang servis (multi-select di tab Layanan)
  final Set<String> cartTitles = {};

  // Data layanan generik (dipakai untuk tampilan & pencarian di tab Layanan;
  // harga akhir tetap dihitung ulang sesuai jenis kendaraan saat booking,
  // lewat vehicle_data.dart)
  final List<Map<String, dynamic>> services = [
    {
      'icon': Icons.oil_barrel_outlined,
      'title': 'Ganti Oli',
      'description':
          'Penggantian oli kendaraan dengan oli berkualitas dan pemeriksaan kondisi mesin.',
      'price': 'Mulai Rp50.000',
      'duration': '30 - 45 menit',
    },
    {
      'icon': Icons.settings_outlined,
      'title': 'Servis Mesin',
      'description':
          'Pemeriksaan dan perbaikan komponen mesin kendaraan secara menyeluruh.',
      'price': 'Mulai Rp100.000',
      'duration': '1 - 2 jam',
    },
    {
      'icon': Icons.car_repair_outlined,
      'title': 'Servis Rem',
      'description':
          'Pemeriksaan kampas rem, minyak rem, dan sistem pengereman kendaraan.',
      'price': 'Mulai Rp75.000',
      'duration': '45 - 60 menit',
    },
    {
      'icon': Icons.bolt_outlined,
      'title': 'Kelistrikan',
      'description':
          'Pemeriksaan aki, lampu, kabel, dan sistem kelistrikan kendaraan.',
      'price': 'Mulai Rp80.000',
      'duration': '45 - 90 menit',
    },
    {
      'icon': Icons.ac_unit_outlined,
      'title': 'Servis AC',
      'description':
          'Pemeriksaan dan perawatan sistem pendingin (AC) kendaraan agar tetap dingin optimal.',
      'price': 'Mulai Rp150.000',
      'duration': '1 - 2 jam',
    },
    {
      'icon': Icons.settings_applications_outlined,
      'title': 'Servis Transmisi',
      'description':
          'Pemeriksaan dan perawatan sistem transmisi kendaraan untuk perpindahan gigi yang halus.',
      'price': 'Mulai Rp300.000',
      'duration': '2 - 4 jam',
    },
  ];

  List<Map<String, dynamic>> get filteredServices {
    if (searchQuery.trim().isEmpty) return services;
    final q = searchQuery.toLowerCase();
    return services
        .where((s) => (s['title'] as String).toLowerCase().contains(q))
        .toList();
  }

  // ============================================================
  // DATA TURUNAN DARI BookingData (bukan lagi data karangan)
  // ============================================================

  /// Daftar kendaraan unik (plat + jenis) yang pernah dibooking user.
  List<Map<String, String>> get garageVehicles {
    final Map<String, Map<String, String>> unique = {};
    for (final b in BookingData.bookings) {
      unique[b.plateNumber] = {
        'plate': b.plateNumber,
        'type': b.vehicleType,
      };
    }
    return unique.values.toList();
  }

  Map<String, String>? get activeVehicle {
    if (garageVehicles.isEmpty) return null;
    return garageVehicles.firstWhere(
      (v) => v['plate'] == activePlate,
      orElse: () => garageVehicles.first,
    );
  }

  /// Booking yang masih berjalan (belum "Selesai"), paling baru duluan.
  BookingData? get activeBooking {
    final active =
        BookingData.bookings.where((b) => b.status != 'Selesai').toList();
    if (active.isEmpty) return null;
    active.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return active.first;
  }

  /// Booking yang sudah selesai paling baru (untuk hitung reminder servis).
  BookingData? get latestCompletedBooking {
    final completed =
        BookingData.bookings.where((b) => b.status == 'Selesai').toList();
    if (completed.isEmpty) return null;
    completed.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return completed.first;
  }

  int? get daysUntilNextService {
    final last = latestCompletedBooking;
    if (last == null) return null;
    final nextDue = last.createdAt.add(const Duration(days: 90));
    return nextDue.difference(DateTime.now()).inDays;
  }

  int _parsePrice(String price) {
    final digits = price.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? 0 : int.parse(digits);
  }

  String _formatRupiah(int value) {
    final str = value.toString();
    final reversed = str.split('').reversed.toList();
    final buffer = StringBuffer();
    for (int i = 0; i < reversed.length; i++) {
      buffer.write(reversed[i]);
      if ((i + 1) % 3 == 0 && i != reversed.length - 1) {
        buffer.write('.');
      }
    }
    return 'Rp${buffer.toString().split('').reversed.join()}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Selesai':
        return AppColors.success;
      case 'Sedang Dikerjakan':
        return gold;
      default:
        return textSecondary; // Menunggu Antrian
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  // ============================================================
  // WHATSAPP ADMIN
  // ============================================================

  Future<void> openWhatsApp() async {
    final Uri whatsappUrl = Uri.parse(
      'https://wa.me/6283840576034?text=Halo%20Admin%20BengkelKu%2C%20saya%20ingin%20bertanya%20tentang%20layanan%20bengkel.',
    );

    try {
      await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka WhatsApp.')),
      );
    }
  }

  // ============================================================
  // GOOGLE MAPS
  // ============================================================

  Future<void> openMaps() async {
    final Uri mapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=FF9V%2BG3G%2C+Becok%2C+Kartoharjo%2C+Kabupaten+Magetan%2C+Jawa+Timur+63395',
    );

    try {
      await launchUrl(
        mapsUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka Google Maps.')),
      );
    }
  }

  // ============================================================
  // BOOKING (SATU LAYANAN — DARI DETAIL)
  // ============================================================

  void openBooking() {
    Navigator.push(
      context,
      _fadeRoute(const ServicePage()),
    );
  }

  void openDetail(
    String serviceName,
    String description,
    String price,
    String duration,
    IconData icon,
  ) {
    Navigator.push(
      context,
      _fadeRoute(
        DetailServicePage(
          serviceName: serviceName,
          description: description,
          price: price,
          duration: duration,
          icon: icon,
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT (DENGAN KONFIRMASI)
  // ============================================================

  void logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Keluar Akun?',
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Kamu akan keluar dari akun ini.',
            style: TextStyle(color: textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(color: textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  _fadeRoute(const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text(
                'Keluar',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // NOTIFICATION
  // ============================================================

  void showNotification() {
    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: borderSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                'Notifikasi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.build_outlined, color: gold),
                ),
                title: const Text(
                  'Servis kendaraan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'Kendaraan kamu sedang dalam proses servis.',
                  style: TextStyle(color: textSecondary),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // NOTA / DETAIL BOOKING (DIPERBAIKI — bukan toString() lagi)
  // ============================================================

  Widget _notaRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showBookingDetail(BookingData booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: borderSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: gold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: gold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Nota Servis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _notaRow('Pemilik', booking.ownerName),
                    _notaRow('No. Polisi', booking.plateNumber),
                    _notaRow('Kendaraan', booking.vehicleType),
                    _notaRow('Layanan', booking.serviceName),
                    _notaRow('Harga', booking.price),
                    _notaRow('Estimasi Durasi', booking.duration),
                    _notaRow(
                      'Status',
                      booking.status,
                      valueColor: _statusColor(booking.status),
                    ),
                    if (booking.mechanicName != null)
                      _notaRow('Montir', booking.mechanicName!),
                    if (booking.status == 'Menunggu Antrian' &&
                        booking.queuePosition != null)
                      _notaRow(
                        'Posisi Antrian',
                        '#${booking.queuePosition}',
                      ),
                    if (booking.estimatedStart != null)
                      _notaRow(
                        'Estimasi Mulai',
                        booking.formattedEstimatedStart,
                      ),
                    if (booking.estimatedFinish != null)
                      _notaRow(
                        'Estimasi Selesai',
                        booking.formattedEstimatedFinish,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // HISTORY (FILTER PER KENDARAAN BERDASARKAN PLAT — AKURAT)
  // ============================================================

  Widget historyPage() {
    MechanicData.refresh();

    final allBookings = BookingData.bookings;
    final garage = garageVehicles;

    final displayedBookings = historyPlateFilter == 'Semua'
        ? allBookings
        : allBookings
            .where((b) => b.plateNumber == historyPlateFilter)
            .toList();

    final sortedBookings = List<BookingData>.from(displayedBookings)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        title: const Text(
          'Riwayat Servis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          if (garage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: garage.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final String key =
                        index == 0 ? 'Semua' : garage[index - 1]['plate']!;
                    final String label = index == 0
                        ? 'Semua'
                        : '${garage[index - 1]['type']} • ${garage[index - 1]['plate']}';
                    final active = key == historyPlateFilter;

                    return TapScale(
                      onTap: () {
                        setState(() {
                          historyPlateFilter = key;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: active ? gold.withOpacity(0.15) : surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color:
                                active ? gold.withOpacity(0.5) : borderSubtle,
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            color: active ? goldSoft : textSecondary,
                            fontWeight:
                                active ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          Expanded(
            child: allBookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: gold.withOpacity(0.25)),
                          ),
                          child: const Icon(
                            Icons.history,
                            size: 46,
                            color: gold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Belum Ada Riwayat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Riwayat booking kamu akan muncul di sini.',
                          style: TextStyle(color: textSecondary),
                        ),
                      ],
                    ),
                  )
                : sortedBookings.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada riwayat untuk kendaraan ini',
                          style: TextStyle(color: textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: sortedBookings.length,
                        itemBuilder: (context, index) {
                          final booking = sortedBookings[index];

                          return TapScale(
                            onTap: () => showBookingDetail(booking),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: borderSubtle),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: gold.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.build_outlined,
                                    color: gold,
                                  ),
                                ),
                                title: Text(
                                  booking.serviceName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  '${booking.vehicleType} • ${booking.plateNumber}',
                                  style:
                                      const TextStyle(color: textSecondary),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(booking.status)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    booking.status,
                                    style: TextStyle(
                                      color: _statusColor(booking.status),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE
  // ============================================================

  Widget profilePage() {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [surfaceAlt, surface],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: gold.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: gold.withOpacity(0.5), width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: gold.withOpacity(0.12),
                    child: const Icon(Icons.person, size: 46, color: gold),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Admin BengkelKu',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Pengelola BengkelKu',
                  style: TextStyle(color: textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _profileMenu(
            icon: Icons.settings_outlined,
            title: 'Pengaturan',
            onTap: () {},
          ),
          _profileMenu(
            icon: Icons.help_outline,
            title: 'Bantuan',
            onTap: () {},
          ),
          _profileMenu(
            icon: Icons.chat_outlined,
            title: 'Hubungi Admin via WhatsApp',
            onTap: openWhatsApp,
          ),
          _profileMenu(
            icon: Icons.logout,
            title: 'Keluar',
            onTap: logout,
            isDanger: true,
          ),
        ],
      ),
    );
  }

  Widget _profileMenu({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final Color accent = isDanger ? AppColors.danger : gold;

    return TapScale(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderSubtle),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDanger ? accent : textPrimary,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: textSecondary),
        ),
      ),
    );
  }

  // ============================================================
  // RATING & BADGE RESMI
  // ============================================================

  Widget _ratingBadgeCard() {
    return TapScale(
      onTap: () {
        Navigator.push(
          context,
          _fadeRoute(const AboutBengkelPage()),
        );
      },
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: gold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Bengkel Resmi',
                  style: TextStyle(color: textSecondary, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              5,
              (i) => const Padding(
                padding: EdgeInsets.only(right: 1),
                child: Icon(Icons.star, color: gold, size: 13),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '4.9 (350+ ulasan)',
            style: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
      ),
    );
  }

  // ============================================================
  // CONTACT CARD
  // ============================================================

  Widget _contactCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: gold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: gold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderSubtle),
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) => setState(() => searchQuery = value),
        style: const TextStyle(color: textPrimary),
        cursorColor: gold,
        decoration: InputDecoration(
          hintText: 'Cari layanan servis...',
          hintStyle: const TextStyle(color: textSecondary),
          prefixIcon: const Icon(Icons.search, color: gold),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: textSecondary, size: 18),
                  onPressed: () {
                    setState(() {
                      searchController.clear();
                      searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // ============================================================
  // PROMO CAROUSEL
  // ============================================================

  Widget _promoCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: promos.length,
            onPageChanged: (index) => setState(() => bannerIndex = index),
            itemBuilder: (context, index) {
              final promo = promos[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: TapScale(
                  onTap: () => _openPromo(promo),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [gold.withOpacity(0.16), surfaceAlt],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: gold.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: gold.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(promo['icon'] as IconData, color: gold, size: 30),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                promo['title'] as String,
                                style: const TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                promo['subtitle'] as String,
                                style: const TextStyle(color: textSecondary, fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Ketuk untuk klaim',
                                    style: TextStyle(color: goldSoft, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward, color: goldSoft, size: 13),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(promos.length, (index) {
            final bool active = index == bannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? gold : borderSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ============================================================
  // GARASI (DARI DATA BOOKING ASLI — BUKAN LAGI KARANGAN)
  // ============================================================

  Widget _garageSection() {
    final garage = garageVehicles;

    if (garage.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderSubtle),
        ),
        child: Column(
          children: [
            const Icon(Icons.directions_car_outlined, color: gold, size: 34),
            const SizedBox(height: 10),
            const Text(
              'Belum ada kendaraan terdaftar',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kendaraan otomatis terdaftar setelah kamu booking servis pertama.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 14),
            TapScale(
              onTap: openBooking,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Booking Sekarang',
                  style: TextStyle(color: background, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    }

    activePlate ??= garage.first['plate'];
    final active = activeVehicle!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: garage.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final v = garage[index];
              final bool isActive = v['plate'] == activePlate;
              return TapScale(
                onTap: () => setState(() => activePlate = v['plate']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? gold.withOpacity(0.15) : surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isActive ? gold.withOpacity(0.5) : borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_car_filled_outlined, size: 16, color: isActive ? gold : textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        v['type']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? goldSoft : textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [surfaceAlt, surface],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: gold.withOpacity(0.22)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: gold.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.directions_car_outlined, color: gold, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(active['type']!, style: const TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(active['plate']!, style: const TextStyle(color: textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // REMINDER SERVIS BERIKUTNYA (dari booking selesai asli)
  // ============================================================

  Widget? _reminderSection() {
    final days = daysUntilNextService;
    if (days == null) return null;

    final bool overdue = days < 0;
    final bool urgent = days <= 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Servis Berikutnya'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: urgent ? gold.withOpacity(0.5) : borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: gold.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.event_repeat_outlined, color: gold, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Servis Berikutnya', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      overdue
                          ? 'Sudah lewat ${days.abs()} hari dari jadwal — yuk servis lagi'
                          : 'Sekitar $days hari lagi (± 3 bulan dari servis terakhir)',
                      style: const TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (urgent || overdue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: gold.withOpacity(0.4)),
                  ),
                  child: Text(
                    overdue ? 'Terlambat' : 'Segera',
                    style: const TextStyle(color: goldSoft, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TIMELINE STATUS SERVIS (3 tahap nyata: Menunggu > Dikerjakan > Selesai)
  // ============================================================

  Widget _serviceTimeline(String status) {
    const stages = ['Menunggu', 'Dikerjakan', 'Selesai'];
    final int currentStage = status == 'Selesai'
        ? 2
        : status == 'Sedang Dikerjakan'
            ? 1
            : 0;

    return Row(
      children: List.generate(stages.length, (index) {
        final bool done = index < currentStage;
        final bool active = index == currentStage;
        final bool isLast = index == stages.length - 1;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: index == 0
                        ? const SizedBox()
                        : Container(height: 2, color: (done || active) ? gold.withOpacity(0.6) : borderSubtle),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? gold : surface,
                      border: Border.all(color: (done || active) ? gold : borderSubtle, width: 2),
                    ),
                    child: done
                        ? const Icon(Icons.check, size: 13, color: background)
                        : active
                            ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: gold, shape: BoxShape.circle))
                            : null,
                  ),
                  Expanded(
                    child: isLast
                        ? const SizedBox()
                        : Container(height: 2, color: done ? gold.withOpacity(0.6) : borderSubtle),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                stages[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: active ? goldSoft : (done ? textPrimary : textSecondary),
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ============================================================
  // STATUS SERVIS + MONTIR (DATA NYATA DARI BookingData/MechanicData)
  // ============================================================

  Widget _activeServiceSection() {
    final booking = activeBooking;

    if (booking == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderSubtle),
        ),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline, color: gold, size: 32),
            const SizedBox(height: 10),
            const Text(
              'Tidak ada servis yang sedang berjalan',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Booking layanan untuk mulai proses servis.',
              style: TextStyle(color: textSecondary, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(color: gold.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.build_circle_outlined, color: gold, size: 30),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.status, style: const TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text('${booking.serviceName} • ${booking.vehicleType} (${booking.plateNumber})', style: const TextStyle(color: textSecondary)),
                        const SizedBox(height: 4),
                        Text('${booking.duration} • ${booking.price}', style: const TextStyle(color: goldSoft, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _serviceTimeline(booking.status),
              const SizedBox(height: 10),
              Text(
                booking.status == 'Menunggu Antrian'
                    ? 'Antrean ke-${booking.queuePosition ?? '-'} • estimasi mulai ${booking.formattedEstimatedStart}'
                    : booking.status == 'Sedang Dikerjakan'
                        ? 'Estimasi selesai ${booking.formattedEstimatedFinish}'
                        : 'Servis selesai',
                textAlign: TextAlign.center,
                style: const TextStyle(color: textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _sectionTitle('Montir Bertugas'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: gold.withOpacity(0.4))),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: gold.withOpacity(0.12),
                  child: const Icon(Icons.engineering_outlined, color: gold, size: 26),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.mechanicName ?? 'Menunggu penugasan', style: const TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Teknisi BengkelKu', style: TextStyle(color: textSecondary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          IconData starIcon;
                          if (i < mechanicRating.floor()) {
                            starIcon = Icons.star;
                          } else if (i < mechanicRating) {
                            starIcon = Icons.star_half;
                          } else {
                            starIcon = Icons.star_border;
                          }
                          return Icon(starIcon, color: gold, size: 15);
                        }),
                        const SizedBox(width: 6),
                        Text('$mechanicRating ($mechanicReviewCount ulasan)', style: const TextStyle(color: textSecondary, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.verified_outlined, color: gold),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HOME
  // ============================================================

  Widget homePage() {
    MechanicData.refresh();
    final reminder = _reminderSection();

    return Scaffold(
      backgroundColor: background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openWhatsApp,
        backgroundColor: gold,
        foregroundColor: background,
        icon: const Icon(Icons.chat),
        label: const Text('Chat Admin', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: gold,
          backgroundColor: surface,
          onRefresh: () async {
            MechanicData.refresh();
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(children: [
                              TextSpan(text: 'Bengkel', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary)),
                              TextSpan(text: 'Ku', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: gold)),
                            ]),
                          ),
                          const SizedBox(height: 4),
                          const Text('Solusi servis kendaraan kamu', style: TextStyle(color: textSecondary)),
                        ],
                      ),
                    ),
                    TapScale(
                      onTap: showNotification,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(color: surface, shape: BoxShape.circle, border: Border.all(color: borderSubtle)),
                            padding: const EdgeInsets.all(10),
                            child: const Icon(Icons.notifications_none, color: gold, size: 22),
                          ),
                          if (hasNotification)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: surface, width: 1.5),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _searchBar(),
                const SizedBox(height: 20),
                _promoCarousel(),
                const SizedBox(height: 22),

                _sectionTitle('Menu Utama'),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _menuCard(icon: Icons.calendar_month_outlined, title: 'Booking', onTap: openBooking)),
                    const SizedBox(width: 12),
                    Expanded(child: _menuCard(icon: Icons.build_outlined, title: 'Layanan', onTap: () => setState(() => selectedIndex = 1))),
                    const SizedBox(width: 12),
                    Expanded(child: _menuCard(icon: Icons.history, title: 'Riwayat', onTap: () => setState(() => selectedIndex = 2))),
                    const SizedBox(width: 12),
                    Expanded(child: _menuCard(icon: Icons.person_outline, title: 'Profil', onTap: () => setState(() => selectedIndex = 3))),
                  ],
                ),

                const SizedBox(height: 26),
                _sectionTitle('Layanan Populer'),
                const SizedBox(height: 14),
                if (filteredServices.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderSubtle)),
                    child: const Column(
                      children: [
                        Icon(Icons.search_off, color: textSecondary, size: 30),
                        SizedBox(height: 10),
                        Text('Layanan tidak ditemukan', style: TextStyle(color: textSecondary)),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      for (int i = 0; i < filteredServices.length; i++) ...[
                        _serviceCard(
                          icon: filteredServices[i]['icon'] as IconData,
                          title: filteredServices[i]['title'] as String,
                          description: filteredServices[i]['description'] as String,
                          price: filteredServices[i]['price'] as String,
                          onTap: () => openDetail(
                            filteredServices[i]['title'] as String,
                            filteredServices[i]['description'] as String,
                            filteredServices[i]['price'] as String,
                            filteredServices[i]['duration'] as String,
                            filteredServices[i]['icon'] as IconData,
                          ),
                        ),
                        if (i != filteredServices.length - 1) const SizedBox(height: 12),
                      ],
                    ],
                  ),

                const SizedBox(height: 26),
                _sectionTitle('Lokasi & Rating'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _ratingBadgeCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _contactCard(icon: Icons.location_on_outlined, title: 'Map', value: 'Lokasi Bengkel', onTap: openMaps)),
                  ],
                ),

                const SizedBox(height: 26),
                _sectionTitle('Kendaraan Aktif'),
                const SizedBox(height: 12),
                _garageSection(),

                if (reminder != null) ...[
                  const SizedBox(height: 22),
                  reminder,
                ],

                const SizedBox(height: 22),
                _sectionTitle('Status Servis'),
                const SizedBox(height: 12),
                _activeServiceSection(),

                const SizedBox(height: 26),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [surfaceAlt, surface]),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: gold.withOpacity(0.2)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: gold),
                          SizedBox(width: 10),
                          Text('Informasi Bengkel', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'BengkelKu siap membantu kebutuhan servis kendaraan kamu dengan pelayanan yang nyaman dan terpercaya.',
                        style: TextStyle(color: textSecondary, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // KARTU LAYANAN BISA DIPILIH (KERANJANG)
  // ============================================================

  Widget _selectableServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required String price,
    required VoidCallback onOpenDetail,
  }) {
    final bool selected = cartTitles.contains(title);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? gold.withOpacity(0.08) : surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? gold.withOpacity(0.5) : borderSubtle),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (selected) {
                  cartTitles.remove(title);
                } else {
                  cartTitles.add(title);
                }
              });
            },
            child: Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? gold : Colors.transparent,
                border: Border.all(color: selected ? gold : textSecondary, width: 1.5),
              ),
              child: selected ? const Icon(Icons.check, size: 15, color: background) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TapScale(
              onTap: onOpenDetail,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(color: gold.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                    child: Icon(icon, color: gold, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 3),
                        Text(price, style: const TextStyle(color: goldSoft, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: gold, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CHECKOUT KERANJANG (INI YANG MEMPERBAIKI BUG "PILIH SERVIS LAGI")
  // ============================================================

  Widget _modalLabel(String text) {
    return Text(text, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13));
  }

  InputDecoration _modalFieldDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: textSecondary),
      prefixIcon: Icon(icon, color: gold),
      filled: true,
      fillColor: surfaceAlt,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: gold, width: 1.5)),
    );
  }

  void _submitCartBooking(String owner, String plate, String vehicleType) {
    final vehicle = vehicleList.firstWhere(
      (v) => v.name == vehicleType,
      orElse: () => vehicleList.first,
    );

    final bool voucherActive = BookingData.pendingVoucherPercent > 0;
    final String voucherLabel = BookingData.pendingVoucherLabel ?? 'Voucher';

    for (final title in cartTitles) {
      ServiceData? match;
      for (final s in vehicle.services) {
        if (s.name.toLowerCase() == title.toLowerCase()) {
          match = s;
          break;
        }
      }
      match ??= () {
        for (final s in vehicle.services) {
          if (s.name.toLowerCase().contains(title.toLowerCase().split(' ').first)) {
            return s;
          }
        }
        return null;
      }();

      final fallback = services.firstWhere(
        (s) => s['title'] == title,
        orElse: () => {'price': 'Harga menyesuaikan', 'duration': 'Menyesuaikan'},
      );

      String finalPrice = match?.price ?? fallback['price'] as String;
      final finalDuration = match?.duration ?? fallback['duration'] as String;

      if (voucherActive) {
        final discounted = (_parsePrice(finalPrice) * (1 - BookingData.pendingVoucherPercent)).round();
        finalPrice = _formatRupiah(discounted);
      }

      final newBooking = BookingData.save(
        owner: owner,
        plate: plate,
        vehicle: vehicleType,
        service: title,
        servicePrice: finalPrice,
        serviceDuration: finalDuration,
      );

      MechanicData.assignBooking(newBooking);
    }

    if (voucherActive) {
      BookingData.clearVoucher();
    }

    setState(() {
      cartTitles.clear();
      activePlate = plate;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: gold, size: 30),
              SizedBox(width: 10),
              Expanded(child: Text('Booking Berhasil', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$owner ($plate) berhasil booking. Cek statusnya di tab Riwayat.',
                style: const TextStyle(color: textSecondary),
              ),
              if (voucherActive) ...[
                const SizedBox(height: 8),
                Text(
                  '🎉 $voucherLabel diterapkan ke semua layanan!',
                  style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => selectedIndex = 2);
              },
              child: const Text('LIHAT RIWAYAT', style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _openCartCheckout() {
    final ownerController = TextEditingController();
    final plateController = TextEditingController();
    String? checkoutVehicleType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(color: borderSubtle, borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const Text('Konfirmasi Booking', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary)),
                    const SizedBox(height: 6),
                    Text('${cartTitles.length} layanan dipilih — nggak perlu pilih servis lagi', style: const TextStyle(color: textSecondary, fontSize: 12)),
                    const SizedBox(height: 18),
                    _modalLabel('Nama Pemilik'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: ownerController,
                      style: const TextStyle(color: textPrimary),
                      decoration: _modalFieldDecoration('Masukkan nama pemilik', Icons.person_outline),
                    ),
                    const SizedBox(height: 14),
                    _modalLabel('Nomor Polisi'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: plateController,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(color: textPrimary),
                      decoration: _modalFieldDecoration('Contoh: L 1234 AB', Icons.confirmation_number_outlined),
                    ),
                    const SizedBox(height: 14),
                    _modalLabel('Jenis Kendaraan'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: checkoutVehicleType,
                      dropdownColor: surfaceAlt,
                      style: const TextStyle(color: textPrimary),
                      decoration: _modalFieldDecoration('Pilih jenis kendaraan', Icons.directions_car_outlined),
                      items: vehicleList.map((v) => DropdownMenuItem(value: v.name, child: Text('${v.icon} ${v.name}'))).toList(),
                      onChanged: (value) => setModalState(() => checkoutVehicleType = value),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: surfaceAlt, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: cartTitles
                            .map((t) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: gold, size: 14),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(t, style: const TextStyle(color: textSecondary, fontSize: 13))),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          final owner = ownerController.text.trim();
                          final plate = plateController.text.trim().toUpperCase();
                          if (owner.isEmpty || plate.isEmpty || checkoutVehicleType == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Lengkapi semua data terlebih dahulu!'), backgroundColor: Colors.redAccent),
                            );
                            return;
                          }
                          Navigator.pop(context);
                          _submitCartBooking(owner, plate, checkoutVehicleType!);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: background, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: const Text('KONFIRMASI BOOKING', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _cartSummaryBar() {
    final total = services.where((s) => cartTitles.contains(s['title'])).fold<int>(0, (sum, s) => sum + _parsePrice(s['price'] as String));
    final bool voucherActive = BookingData.pendingVoucherPercent > 0;
    final int discountedTotal = voucherActive ? (total * (1 - BookingData.pendingVoucherPercent)).round() : total;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 250),
      offset: cartTitles.isEmpty ? const Offset(0, 1.3) : Offset.zero,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: surfaceAlt,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: gold.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, -6))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voucherActive
                        ? '${cartTitles.length} layanan • ${BookingData.pendingVoucherLabel} aktif 🎉'
                        : '${cartTitles.length} layanan dipilih (estimasi)',
                    style: const TextStyle(color: textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  if (voucherActive) ...[
                    Row(
                      children: [
                        Text(
                          _formatRupiah(total),
                          style: const TextStyle(color: textSecondary, fontSize: 12, decoration: TextDecoration.lineThrough),
                        ),
                        const SizedBox(width: 6),
                        Text(_formatRupiah(discountedTotal), style: const TextStyle(color: goldSoft, fontWeight: FontWeight.bold, fontSize: 17)),
                      ],
                    ),
                  ] else
                    Text(_formatRupiah(total), style: const TextStyle(color: goldSoft, fontWeight: FontWeight.bold, fontSize: 17)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _openCartCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: background,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Booking Semua', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SERVICE PAGE (TAB LAYANAN + KERANJANG)
  // ============================================================

  Widget servicePage() {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        title: const Text('Layanan Bengkel', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
            children: [
              _searchBar(),
              const SizedBox(height: 10),
              const Text('Harga final menyesuaikan jenis kendaraan saat konfirmasi', style: TextStyle(color: textSecondary, fontSize: 11)),
              const SizedBox(height: 12),
              if (filteredServices.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderSubtle)),
                  child: const Column(
                    children: [
                      Icon(Icons.search_off, color: textSecondary, size: 30),
                      SizedBox(height: 10),
                      Text('Layanan tidak ditemukan', style: TextStyle(color: textSecondary)),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    for (int i = 0; i < filteredServices.length; i++) ...[
                      _selectableServiceCard(
                        icon: filteredServices[i]['icon'] as IconData,
                        title: filteredServices[i]['title'] as String,
                        description: filteredServices[i]['description'] as String,
                        price: filteredServices[i]['price'] as String,
                        onOpenDetail: () => openDetail(
                          filteredServices[i]['title'] as String,
                          filteredServices[i]['description'] as String,
                          filteredServices[i]['price'] as String,
                          filteredServices[i]['duration'] as String,
                          filteredServices[i]['icon'] as IconData,
                        ),
                      ),
                      if (i != filteredServices.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                ),
            ],
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _cartSummaryBar()),
        ],
      ),
    );
  }

  // ============================================================
  // MENU CARD
  // ============================================================

  Widget _menuCard({required IconData icon, required String title, required VoidCallback onTap}) {
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderSubtle)),
        child: Column(
          children: [
            Icon(icon, color: gold, size: 25),
            const SizedBox(height: 9),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SERVICE CARD (DIPAKAI DI HOME — TANPA CHECKBOX)
  // ============================================================

  Widget _serviceCard({
    required IconData icon,
    required String title,
    required String description,
    required String price,
    required VoidCallback onTap,
  }) {
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderSubtle)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(color: gold.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: gold, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(description, style: const TextStyle(color: textSecondary, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text(price, style: const TextStyle(color: goldSoft, fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: gold),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _bottomNav() {
    final items = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
      {'icon': Icons.build_outlined, 'activeIcon': Icons.build, 'label': 'Layanan'},
      {'icon': Icons.history_outlined, 'activeIcon': Icons.history, 'label': 'Riwayat'},
      {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': 'Profil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: const Border(top: BorderSide(color: borderSubtle)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, -6))],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final bool active = selectedIndex == index;
            return InkWell(
              onTap: () => setState(() => selectedIndex = index),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: active ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        active ? items[index]['activeIcon'] as IconData : items[index]['icon'] as IconData,
                        color: active ? gold : textSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? gold : textSecondary),
                      child: Text(items[index]['label'] as String),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [homePage(), servicePage(), historyPage(), profilePage()];

    return Scaffold(
      backgroundColor: background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(key: ValueKey<int>(selectedIndex), child: pages[selectedIndex]),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }
}

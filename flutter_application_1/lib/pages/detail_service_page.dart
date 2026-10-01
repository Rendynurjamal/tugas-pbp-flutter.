import 'package:flutter/material.dart';
import 'service_page.dart';
import '../models/booking_data.dart';

class DetailServicePage extends StatelessWidget {
  final String serviceName;
  final String price;
  final String description;
  final String duration;
  final IconData icon;

  /// Diskon dari promo (0.0 - 1.0). 1.0 berarti gratis.
  /// Kalau 0 (default) tapi ada voucher member aktif, voucher itu
  /// yang dipakai sebagai gantinya.
  final double discountPercent;
  final String? promoLabel;

  const DetailServicePage({
    super.key,
    required this.serviceName,
    required this.price,
    required this.description,
    required this.duration,
    required this.icon,
    this.discountPercent = 0,
    this.promoLabel,
  });

  int _parsePriceValue(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
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

  double get _effectiveDiscount {
    if (discountPercent > 0) return discountPercent;
    if (BookingData.pendingVoucherPercent > 0) {
      return BookingData.pendingVoucherPercent;
    }
    return 0;
  }

  String get _effectiveLabel {
    if (discountPercent > 0) return promoLabel ?? 'Promo';
    if (BookingData.pendingVoucherPercent > 0) {
      return BookingData.pendingVoucherLabel ?? 'Voucher Member';
    }
    return '';
  }

  void goToBooking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServicePage(
          selectedService: serviceName,
          selectedPrice: price,
          selectedDuration: duration,
          discountPercent: discountPercent,
          promoLabel: promoLabel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF263238);
    const calm = Color(0xFF78909C);
    const cream = Color(0xFFF5F3EF);
    const gold = Color(0xFFD4AF37);

    final double effectiveDiscount = _effectiveDiscount;
    final bool hasDiscount = effectiveDiscount > 0;
    final int originalValue = _parsePriceValue(price);
    final bool isFree = effectiveDiscount >= 1.0;
    final int discountedValue =
        isFree ? 0 : (originalValue * (1 - effectiveDiscount)).round();
    final String displayPrice =
        isFree ? 'GRATIS' : _formatRupiah(discountedValue);

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: dark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detail Layanan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                25,
                30,
                25,
                35,
              ),
              decoration: const BoxDecoration(
                color: dark,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: calm,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      icon,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (hasDiscount)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: gold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isFree ? '🎉 GRATIS' : '🔥 ${_effectiveLabel}',
                        style: const TextStyle(
                          color: dark,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  Text(
                    serviceName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (hasDiscount) ...[
                    Text(
                      price,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 15,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayPrice,
                      style: const TextStyle(
                        color: gold,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else
                    Text(
                      price,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tentang Layanan',
                    style: TextStyle(
                      color: dark,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: infoBox(
                          icon: Icons.access_time,
                          title: 'Estimasi',
                          value: duration,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: infoBox(
                          icon: Icons.payments_outlined,
                          title: 'Harga',
                          value: hasDiscount ? displayPrice : price,
                          highlight: hasDiscount,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Yang Kamu Dapatkan',
                    style: TextStyle(
                      color: dark,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  benefitItem(
                    'Pemeriksaan kondisi kendaraan',
                  ),
                  benefitItem(
                    'Pengerjaan oleh teknisi',
                  ),
                  benefitItem(
                    'Pengecekan setelah servis',
                  ),
                  benefitItem(
                    'Informasi hasil pengerjaan',
                  ),

                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: calm.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: calm,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            hasDiscount
                                ? 'Harga di atas sudah termasuk potongan ${_effectiveLabel}. Harga final bisa menyesuaikan jenis kendaraan.'
                                : 'Harga dapat berubah tergantung kondisi kendaraan dan kebutuhan servis.',
                            style: const TextStyle(
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        goToBooking(context);
                      },
                      icon: const Icon(
                        Icons.calendar_month,
                      ),
                      label: Text(
                        hasDiscount
                            ? 'BOOKING SEKARANG (${isFree ? 'GRATIS' : displayPrice})'
                            : 'BOOKING SEKARANG',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoBox({
    required IconData icon,
    required String title,
    required String value,
    bool highlight = false,
  }) {
    const calm = Color(0xFF78909C);
    const gold = Color(0xFFD4AF37);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: highlight ? Border.all(color: gold, width: 1.5) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: highlight ? gold : calm,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: highlight ? const Color(0xFFB8860B) : const Color(0xFF263238),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget benefitItem(String text) {
    const calm = Color(0xFF78909C);

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 13,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: calm,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

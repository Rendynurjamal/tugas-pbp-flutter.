import 'package:flutter/material.dart';
import '../models/booking_data.dart';
import '../models/mechanic_data.dart';
import '../models/vehicle_data.dart';

class ServicePage extends StatefulWidget {
  final String? selectedService;
  final String? selectedPrice;
  final String? selectedDuration;

  /// Diskon dari promo (0.0 - 1.0). Kalau 0 dan ada voucher member
  /// aktif, voucher itu yang otomatis dipakai.
  final double discountPercent;
  final String? promoLabel;

  const ServicePage({
    super.key,
    this.selectedService,
    this.selectedPrice,
    this.selectedDuration,
    this.discountPercent = 0,
    this.promoLabel,
  });

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  String? selectedService;
  String? selectedVehicle;

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController plateController =
      TextEditingController();

  static const Color dark = Color(0xFF263238);
  static const Color calm = Color(0xFF78909C);
  static const Color cream = Color(0xFFF5F3EF);

  bool get hasPreselectedService {
    return widget.selectedService != null &&
        widget.selectedService!.trim().isNotEmpty;
  }

  // ==========================================
  // DISKON / VOUCHER
  // ==========================================

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

  bool get _usingVoucherFallback =>
      widget.discountPercent <= 0 && BookingData.pendingVoucherPercent > 0;

  double get _effectiveDiscount {
    if (widget.discountPercent > 0) return widget.discountPercent;
    if (BookingData.pendingVoucherPercent > 0) {
      return BookingData.pendingVoucherPercent;
    }
    return 0;
  }

  String get _effectiveLabel {
    if (widget.discountPercent > 0) return widget.promoLabel ?? 'Promo';
    if (BookingData.pendingVoucherPercent > 0) {
      return BookingData.pendingVoucherLabel ?? 'Voucher Member';
    }
    return '';
  }

  /// Mengembalikan harga akhir (String) setelah diskon diterapkan
  /// pada [basePrice]. Kalau tidak ada diskon aktif, kembalikan apa adanya.
  String _applyDiscount(String basePrice) {
    final discount = _effectiveDiscount;
    if (discount <= 0) return basePrice;
    if (discount >= 1.0) return 'GRATIS';

    final baseValue = _parsePriceValue(basePrice);
    final discountedValue = (baseValue * (1 - discount)).round();
    return _formatRupiah(discountedValue);
  }

  @override
  void initState() {
    super.initState();

    selectedService = widget.selectedService;
  }

  ServiceData? findServiceData() {
    if (selectedVehicle == null ||
        selectedService == null) {
      return null;
    }

    final vehicle = vehicleList.firstWhere(
      (vehicle) => vehicle.name == selectedVehicle,
      orElse: () => vehicleList.first,
    );

    // Cari berdasarkan nama persis terlebih dahulu.
    for (final service in vehicle.services) {
      if (service.name.toLowerCase() ==
          selectedService!.toLowerCase()) {
        return service;
      }
    }

    // Penyesuaian nama servis untuk beberapa kendaraan.
    final selectedName =
        selectedService!.toLowerCase();

    if (selectedName == 'ganti oli') {
      for (final service in vehicle.services) {
        if (service.name
            .toLowerCase()
            .contains('ganti oli')) {
          return service;
        }
      }
    }

    return null;
  }

  void booking() {
    final owner =
        nameController.text.trim();

    final plate =
        plateController.text.trim().toUpperCase();

    if (owner.isEmpty ||
        plate.isEmpty ||
        selectedVehicle == null ||
        selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lengkapi semua data terlebih dahulu!',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final serviceData = findServiceData();

    final basePrice =
        serviceData?.price ??
        widget.selectedPrice ??
        'Harga menyesuaikan';

    final finalDuration =
        serviceData?.duration ??
        widget.selectedDuration ??
        'Menyesuaikan';

    final bool voucherWasUsed = _usingVoucherFallback;
    final String discountLabel = _effectiveLabel;
    final finalPrice = _applyDiscount(basePrice);

    final newBooking = BookingData.save(
      owner: owner,
      plate: plate,
      vehicle: selectedVehicle!,
      service: selectedService!,
      servicePrice: finalPrice,
      serviceDuration: finalDuration,
    );

    // Menugaskan montir / memasukkan ke antrean secara otomatis.
    MechanicData.assignBooking(newBooking);

    // Voucher member cuma bisa dipakai sekali.
    if (voucherWasUsed) {
      BookingData.clearVoucher();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 30,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Booking Berhasil',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Data booking kamu berhasil disimpan.',
              ),
              const SizedBox(height: 18),
              Text(
                'Pemilik: $owner',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'No. Polisi: $plate',
              ),
              const SizedBox(height: 6),
              Text(
                'Kendaraan: $selectedVehicle',
              ),
              const SizedBox(height: 6),
              Text(
                'Servis: $selectedService',
              ),
              const SizedBox(height: 6),
              Text(
                'Montir: ${newBooking.mechanicName ?? '-'}',
              ),
              const SizedBox(height: 6),
              Text(
                'Total: $finalPrice',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (discountLabel.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '($discountLabel diterapkan)',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'SELESAI',
                style: TextStyle(
                  color: dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedData = findServiceData();

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: dark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Booking Servis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          30,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Servis 🔧',
              style: TextStyle(
                color: dark,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              hasPreselectedService
                  ? 'Lengkapi data kendaraan untuk melanjutkan booking.'
                  : 'Isi data kendaraan dan pilih layanan yang ingin dilakukan.',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nama Pemilik',
                    style: TextStyle(
                      color: dark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: nameController,
                    textInputAction:
                        TextInputAction.next,
                    decoration: InputDecoration(
                      hintText:
                          'Masukkan nama pemilik',
                      hintStyle: const TextStyle(
                        color: Colors.black38,
                      ),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: calm,
                      ),
                      filled: true,
                      fillColor: cream,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(
                          color: calm,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Nomor Polisi',
                    style: TextStyle(
                      color: dark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: plateController,
                    textCapitalization:
                        TextCapitalization.characters,
                    textInputAction:
                        TextInputAction.next,
                    decoration: InputDecoration(
                      hintText:
                          'Contoh: L 1234 AB',
                      hintStyle: const TextStyle(
                        color: Colors.black38,
                      ),
                      prefixIcon: const Icon(
                        Icons.confirmation_number_outlined,
                        color: calm,
                      ),
                      filled: true,
                      fillColor: cream,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(
                          color: calm,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Jenis Kendaraan',
                    style: TextStyle(
                      color: dark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    initialValue: selectedVehicle,
                    decoration: InputDecoration(
                      hintText:
                          'Pilih jenis kendaraan',
                      hintStyle: const TextStyle(
                        color: Colors.black38,
                      ),
                      prefixIcon: const Icon(
                        Icons.directions_car_outlined,
                        color: calm,
                      ),
                      filled: true,
                      fillColor: cream,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(
                          color: calm,
                          width: 1.5,
                        ),
                      ),
                    ),
                    items: vehicleList.map(
                      (vehicle) {
                        return DropdownMenuItem<String>(
                          value: vehicle.name,
                          child: Text(
                            '${vehicle.icon} ${vehicle.name}',
                          ),
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedVehicle = value;

                        // Kalau booking berasal dari detail,
                        // servis yang sudah dipilih jangan dihapus.
                        if (!hasPreselectedService) {
                          selectedService = null;
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Jenis Servis',
                    style: TextStyle(
                      color: dark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (hasPreselectedService)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cream,
                        borderRadius:
                            BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              calm.withOpacity(0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.build_circle_outlined,
                            color: calm,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        selectedService!,
                                        style: const TextStyle(
                                          color: dark,
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (_effectiveDiscount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          _effectiveLabel,
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Builder(builder: (context) {
                                  final basePrice = selectedData?.price ??
                                      widget.selectedPrice ??
                                      'Harga menyesuaikan kendaraan';

                                  if (_effectiveDiscount <= 0) {
                                    return Text(
                                      basePrice,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 13,
                                      ),
                                    );
                                  }

                                  return Row(
                                    children: [
                                      Text(
                                        basePrice,
                                        style: const TextStyle(
                                          color: Colors.black38,
                                          fontSize: 12,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _applyDiscount(basePrice),
                                        style: const TextStyle(
                                          color: Color(0xFFB8860B),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                                const SizedBox(height: 2),
                                Text(
                                  selectedData?.duration ??
                                      widget.selectedDuration ??
                                      'Durasi menyesuaikan',
                                  style:
                                      const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: selectedService,
                      decoration: InputDecoration(
                        hintText:
                            selectedVehicle == null
                                ? 'Pilih kendaraan terlebih dahulu'
                                : 'Pilih jenis servis',
                        hintStyle:
                            const TextStyle(
                          color: Colors.black38,
                        ),
                        prefixIcon: const Icon(
                          Icons.build_outlined,
                          color: calm,
                        ),
                        filled: true,
                        fillColor: cream,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide:
                              BorderSide.none,
                        ),
                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(
                            color: calm,
                            width: 1.5,
                          ),
                        ),
                      ),
                      items: selectedVehicle == null
                          ? []
                          : getServiceItems(
                              selectedVehicle!,
                            ),
                      onChanged:
                          selectedVehicle == null
                              ? null
                              : (value) {
                                  setState(() {
                                    selectedService =
                                        value;
                                  });
                                },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (hasPreselectedService)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: calm.withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        calm.withOpacity(0.25),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: dark,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Layanan sudah dipilih dari halaman sebelumnya. Kamu hanya perlu melengkapi data kendaraan.',
                        style: TextStyle(
                          color: dark,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: dark,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pastikan data kendaraan dan layanan yang dipilih sudah benar sebelum melakukan booking.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: booking,
                icon: const Icon(
                  Icons.check_circle_outline,
                ),
                label: const Text(
                  'KONFIRMASI BOOKING',
                  style: TextStyle(
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

            const SizedBox(height: 12),

            const Center(
              child: Text(
                'BengkelKu • Solusi servis kendaraan',
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> getServiceItems(
    String vehicle,
  ) {
    final selectedVehicleData =
        vehicleList.firstWhere(
      (item) => item.name == vehicle,
      orElse: () => vehicleList.first,
    );

    return selectedVehicleData.services.map(
      (service) {
        return DropdownMenuItem<String>(
          value: service.name,
          child: Text(service.name),
        );
      },
    ).toList();
  }
}

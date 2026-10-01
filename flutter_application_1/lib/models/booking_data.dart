class BookingData {
  final String ownerName;
  final String plateNumber;
  final String vehicleType;
  final String serviceName;
  final String price;
  final String duration;

  String status;

  // Nama montir yang menangani booking
  String? mechanicName;

  // Posisi booking dalam antrean
  int? queuePosition;

  // Perkiraan waktu mulai servis
  DateTime? estimatedStart;

  // Perkiraan waktu selesai servis
  DateTime? estimatedFinish;

  // Waktu booking dibuat
  DateTime createdAt;

  BookingData({
    required this.ownerName,
    required this.plateNumber,
    required this.vehicleType,
    required this.serviceName,
    required this.price,
    required this.duration,
    required this.status,
    this.mechanicName,
    this.queuePosition,
    DateTime? createdAt,
    this.estimatedStart,
    this.estimatedFinish,
  }) : createdAt = createdAt ?? DateTime.now();

  // ==========================================
  // MENGHITUNG DURASI SERVIS
  // ==========================================

  int get estimatedMinutes {
    final text = duration.toLowerCase();

    final numbers = RegExp(
      r'\d+',
    )
        .allMatches(text)
        .map(
          (match) =>
              int.tryParse(match.group(0)!) ?? 0,
        )
        .toList();

    if (numbers.isEmpty) {
      return 60;
    }

    // Menggunakan angka terbesar
    // Contoh:
    // 30 - 45 menit = 45 menit
    // 1 - 2 jam = 120 menit

    final biggestNumber = numbers.reduce(
      (a, b) => a > b ? a : b,
    );

    if (text.contains('jam')) {
      return biggestNumber * 60;
    }

    return biggestNumber;
  }

  // ==========================================
  // FORMAT WAKTU MULAI
  // ==========================================

  String get formattedEstimatedStart {
    if (estimatedStart == null) {
      return '-';
    }

    final hour = estimatedStart!.hour
        .toString()
        .padLeft(2, '0');

    final minute = estimatedStart!.minute
        .toString()
        .padLeft(2, '0');

    return '$hour:$minute';
  }

  // ==========================================
  // FORMAT WAKTU SELESAI
  // ==========================================

  String get formattedEstimatedFinish {
    if (estimatedFinish == null) {
      return '-';
    }

    final hour = estimatedFinish!.hour
        .toString()
        .padLeft(2, '0');

    final minute = estimatedFinish!.minute
        .toString()
        .padLeft(2, '0');

    return '$hour:$minute';
  }

  // ==========================================
  // TEMPAT MENYIMPAN SEMUA BOOKING
  // ==========================================

  static final List<BookingData> bookings = [];

  // Mengecek apakah sudah ada booking
  static bool get hasBooking {
    return bookings.isNotEmpty;
  }

  // Mengambil booking terakhir
  static BookingData? get latestBooking {
    if (bookings.isEmpty) {
      return null;
    }

    return bookings.last;
  }

  // ==========================================
  // VOUCHER MEMBER (otomatis dipakai di booking berikutnya)
  // ==========================================

  /// Persentase diskon voucher yang sedang aktif (0.0 - 1.0).
  /// Diisi saat user daftar "Member Baru", dan direset ke 0 setelah
  /// terpakai sekali di booking berikutnya.
  static double pendingVoucherPercent = 0.0;

  /// Label voucher yang sedang aktif, untuk ditampilkan di UI.
  static String? pendingVoucherLabel;

  static bool get hasActiveVoucher => pendingVoucherPercent > 0;

  static void clearVoucher() {
    pendingVoucherPercent = 0.0;
    pendingVoucherLabel = null;
  }

  // ==========================================
  // MENYIMPAN BOOKING BARU
  // ==========================================

  static BookingData save({
    required String owner,
    required String plate,
    required String vehicle,
    required String service,
    required String servicePrice,
    required String serviceDuration,
  }) {
    final booking = BookingData(
      ownerName: owner,
      plateNumber: plate,
      vehicleType: vehicle,
      serviceName: service,
      price: servicePrice,
      duration: serviceDuration,
      status: 'Menunggu Antrian',
    );

    bookings.add(booking);

    return booking;
  }

  // ==========================================
  // MENGHAPUS SEMUA BOOKING
  // ==========================================

  static void clear() {
    bookings.clear();
  }

  // ==========================================
  // MENGHAPUS SATU BOOKING
  // ==========================================

  static void remove(BookingData booking) {
    bookings.remove(booking);
  }
}

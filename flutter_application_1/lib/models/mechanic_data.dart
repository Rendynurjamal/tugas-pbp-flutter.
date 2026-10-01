import 'booking_data.dart';

class Mechanic {
  final String name;

  BookingData? currentBooking;
  DateTime? busyUntil;

  Mechanic({
    required this.name,
  });

  bool get isAvailable {
    if (busyUntil == null) {
      return true;
    }

    return DateTime.now().isAfter(busyUntil!) ||
        DateTime.now().isAtSameMomentAs(busyUntil!);
  }

  int get remainingMinutes {
    if (busyUntil == null) {
      return 0;
    }

    final difference =
        busyUntil!.difference(DateTime.now()).inMinutes;

    if (difference < 0) {
      return 0;
    }

    return difference;
  }
}

class MechanicData {
  // ==========================================
  // DAFTAR MONTIR
  // ==========================================

  static final List<Mechanic> mechanics = [
    Mechanic(name: 'Agus'),
    Mechanic(name: 'Gito'),
    Mechanic(name: 'Budi'),
  ];

  // ==========================================
  // MENGHITUNG MONTIR YANG TERSEDIA
  // ==========================================

  static int get availableCount {
    refresh();

    return mechanics
        .where((mechanic) => mechanic.isAvailable)
        .length;
  }

  // ==========================================
  // REFRESH STATUS MONTIR
  // ==========================================

  static void refresh() {
    final now = DateTime.now();

    for (final mechanic in mechanics) {
      if (mechanic.busyUntil != null &&
          !now.isBefore(mechanic.busyUntil!)) {
        if (mechanic.currentBooking != null) {
          mechanic.currentBooking!.status = 'Selesai';
        }

        mechanic.currentBooking = null;
        mechanic.busyUntil = null;
      }
    }

    assignWaitingBookings();
  }

  // ==========================================
  // MENENTUKAN MONTIR UNTUK BOOKING
  // ==========================================

  static void assignBooking(BookingData booking) {
    refresh();

    final availableMechanic = _findAvailableMechanic();

    // Kalau masih ada montir kosong
    if (availableMechanic != null) {
      _startBooking(
        availableMechanic,
        booking,
        DateTime.now(),
      );

      return;
    }

    // Kalau semua montir sibuk
    _putIntoQueue(booking);
  }

  // ==========================================
  // MENCARI MONTIR YANG TERSEDIA
  // ==========================================

  static Mechanic? _findAvailableMechanic() {
    for (final mechanic in mechanics) {
      if (mechanic.isAvailable) {
        return mechanic;
      }
    }

    return null;
  }

  // ==========================================
  // MEMULAI SERVIS
  // ==========================================

  static void _startBooking(
    Mechanic mechanic,
    BookingData booking,
    DateTime startTime,
  ) {
    final duration = booking.estimatedMinutes;

    mechanic.currentBooking = booking;

    mechanic.busyUntil =
        startTime.add(
      Duration(
        minutes: duration,
      ),
    );

    booking.status = 'Sedang Dikerjakan';

    booking.mechanicName = mechanic.name;

    booking.queuePosition = null;

    booking.estimatedStart = startTime;

    booking.estimatedFinish =
        mechanic.busyUntil;
  }

  // ==========================================
  // MASUK KE ANTRIAN
  // ==========================================

  static void _putIntoQueue(
    BookingData booking,
  ) {
    booking.status = 'Menunggu Antrian';

    // Mencari montir yang paling cepat selesai
    booking.mechanicName =
        _findNextMechanicName();

    // Menentukan perkiraan waktu mulai
    booking.estimatedStart =
        _findNextAvailableTime();

    // Menentukan perkiraan selesai
    booking.estimatedFinish =
        booking.estimatedStart!.add(
      Duration(
        minutes: booking.estimatedMinutes,
      ),
    );

    // Menentukan posisi antrian
    booking.queuePosition =
        _getWaitingBookings().length;
  }

  // ==========================================
  // MENGAMBIL SEMUA BOOKING YANG MENUNGGU
  // ==========================================

  static List<BookingData> _getWaitingBookings() {
    return BookingData.bookings
        .where(
          (booking) =>
              booking.status == 'Menunggu Antrian',
        )
        .toList();
  }

  // ==========================================
  // MENCARI MONTIR YANG PALING CEPAT TERSEDIA
  // ==========================================

  static String _findNextMechanicName() {
    Mechanic? fastestMechanic;

    for (final mechanic in mechanics) {
      if (fastestMechanic == null ||
          _mechanicAvailableTime(mechanic)
              .isBefore(
            _mechanicAvailableTime(
              fastestMechanic,
            ),
          )) {
        fastestMechanic = mechanic;
      }
    }

    return fastestMechanic?.name ?? 'Agus';
  }

  // ==========================================
  // MENCARI WAKTU MONTIR BERIKUTNYA TERSEDIA
  // ==========================================

  static DateTime _findNextAvailableTime() {
    DateTime? fastestTime;

    for (final mechanic in mechanics) {
      final time =
          _mechanicAvailableTime(mechanic);

      if (fastestTime == null ||
          time.isBefore(fastestTime)) {
        fastestTime = time;
      }
    }

    return fastestTime ?? DateTime.now();
  }

  // ==========================================
  // MENGHITUNG WAKTU MONTIR SELESAI
  // ==========================================

  static DateTime _mechanicAvailableTime(
    Mechanic mechanic,
  ) {
    if (mechanic.busyUntil == null ||
        mechanic.isAvailable) {
      return DateTime.now();
    }

    return mechanic.busyUntil!;
  }

  // ==========================================
  // MEMPROSES ANTRIAN
  // ==========================================

  static void assignWaitingBookings() {
    final waitingBookings =
        _getWaitingBookings();

    if (waitingBookings.isEmpty) {
      return;
    }

    // Urutkan berdasarkan waktu booking
    waitingBookings.sort(
      (a, b) =>
          a.createdAt.compareTo(
        b.createdAt,
      ),
    );

    for (final booking in waitingBookings) {
      final availableMechanic =
          _findAvailableMechanic();

      if (availableMechanic == null) {
        break;
      }

      _startBooking(
        availableMechanic,
        booking,
        DateTime.now(),
      );
    }

    _updateQueuePositions();
  }

  // ==========================================
  // UPDATE POSISI ANTRIAN
  // ==========================================

  static void _updateQueuePositions() {
    final waitingBookings =
        _getWaitingBookings();

    waitingBookings.sort(
      (a, b) =>
          a.createdAt.compareTo(
        b.createdAt,
      ),
    );

    for (int i = 0;
        i < waitingBookings.length;
        i++) {
      final booking =
          waitingBookings[i];

      booking.queuePosition = i + 1;

      booking.mechanicName =
          _findNextMechanicName();

      booking.estimatedStart =
          _findNextAvailableTime();

      booking.estimatedFinish =
          booking.estimatedStart!.add(
        Duration(
          minutes:
              booking.estimatedMinutes,
        ),
      );
    }
  }

  // ==========================================
  // RESET SEMUA MONTIR
  // ==========================================

  static void clearAll() {
    for (final mechanic in mechanics) {
      mechanic.currentBooking = null;
      mechanic.busyUntil = null;
    }
  }
}

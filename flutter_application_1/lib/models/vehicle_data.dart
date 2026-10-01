class VehicleData {
  final String name;
  final String icon;
  final String description;
  final List<ServiceData> services;

  VehicleData({
    required this.name,
    required this.icon,
    required this.description,
    required this.services,
  });
}

class ServiceData {
  final String name;
  final String price;
  final String duration;
  final String description;

  ServiceData({
    required this.name,
    required this.price,
    required this.duration,
    required this.description,
  });
}

// ==========================================
// DATA KENDARAAN BENGKELKU
// ==========================================

final List<VehicleData> vehicleList = [
  // =========================
  // MOBIL
  // =========================
  VehicleData(
    name: 'Mobil',
    icon: '🚗',
    description: 'Layanan servis untuk kendaraan mobil.',
    services: [
      ServiceData(
        name: 'Ganti Oli',
        price: 'Mulai Rp50.000',
        duration: '30 - 45 menit',
        description:
            'Penggantian oli mesin untuk menjaga performa kendaraan tetap optimal.',
      ),
      ServiceData(
        name: 'Servis Mesin',
        price: 'Mulai Rp100.000',
        duration: '1 - 2 jam',
        description:
            'Pemeriksaan dan perawatan komponen mesin kendaraan.',
      ),
      ServiceData(
        name: 'Servis Rem',
        price: 'Mulai Rp75.000',
        duration: '45 - 60 menit',
        description:
            'Pemeriksaan sistem pengereman kendaraan.',
      ),
      ServiceData(
        name: 'Kelistrikan',
        price: 'Mulai Rp80.000',
        duration: '45 - 90 menit',
        description:
            'Pemeriksaan aki, lampu, starter dan sistem kelistrikan.',
      ),
    ],
  ),

  // =========================
  // TRUK
  // =========================
  VehicleData(
    name: 'Truk',
    icon: '🚚',
    description: 'Layanan khusus untuk kendaraan truk.',
    services: [
      ServiceData(
        name: 'Ganti Oli Mesin',
        price: 'Mulai Rp350.000',
        duration: '1 - 2 jam',
        description:
            'Penggantian oli mesin kendaraan truk dengan pemeriksaan kondisi oli.',
      ),
      ServiceData(
        name: 'Servis Mesin',
        price: 'Mulai Rp750.000',
        duration: '2 - 4 jam',
        description:
            'Pemeriksaan dan perawatan mesin kendaraan truk.',
      ),
      ServiceData(
        name: 'Servis Rem',
        price: 'Mulai Rp500.000',
        duration: '2 - 3 jam',
        description:
            'Pemeriksaan sistem pengereman kendaraan truk.',
      ),
      ServiceData(
        name: 'Servis Transmisi',
        price: 'Mulai Rp900.000',
        duration: '3 - 5 jam',
        description:
            'Pemeriksaan dan perawatan sistem transmisi kendaraan truk.',
      ),
    ],
  ),

  // =========================
  // BUS
  // =========================
  VehicleData(
    name: 'Bus',
    icon: '🚌',
    description: 'Layanan servis untuk kendaraan bus.',
    services: [
      ServiceData(
        name: 'Ganti Oli',
        price: 'Mulai Rp450.000',
        duration: '1 - 2 jam',
        description:
            'Penggantian oli mesin kendaraan bus.',
      ),
      ServiceData(
        name: 'Servis Mesin',
        price: 'Mulai Rp900.000',
        duration: '3 - 5 jam',
        description:
            'Pemeriksaan dan perawatan mesin kendaraan bus.',
      ),
      ServiceData(
        name: 'Servis Rem',
        price: 'Mulai Rp650.000',
        duration: '2 - 4 jam',
        description:
            'Pemeriksaan sistem pengereman kendaraan bus.',
      ),
      ServiceData(
        name: 'Servis AC',
        price: 'Mulai Rp400.000',
        duration: '2 - 3 jam',
        description:
            'Pemeriksaan dan perawatan sistem pendingin kabin bus.',
      ),
    ],
  ),

  // =========================
  // ALAT BERAT
  // =========================
  VehicleData(
    name: 'Alat Berat',
    icon: '🚜',
    description: 'Layanan untuk kendaraan dan alat berat.',
    services: [
      ServiceData(
        name: 'Ganti Oli Mesin',
        price: 'Mulai Rp600.000',
        duration: '2 - 3 jam',
        description:
            'Penggantian oli mesin untuk kendaraan alat berat.',
      ),
      ServiceData(
        name: 'Oli Hidrolik',
        price: 'Mulai Rp800.000',
        duration: '2 - 4 jam',
        description:
            'Pemeriksaan dan penggantian oli sistem hidrolik.',
      ),
      ServiceData(
        name: 'Servis Mesin',
        price: 'Mulai Rp1.500.000',
        duration: '4 - 8 jam',
        description:
            'Pemeriksaan dan perawatan mesin kendaraan alat berat.',
      ),
      ServiceData(
        name: 'Servis Transmisi',
        price: 'Mulai Rp1.200.000',
        duration: '4 - 6 jam',
        description:
            'Pemeriksaan sistem transmisi kendaraan alat berat.',
      ),
    ],
  ),
];

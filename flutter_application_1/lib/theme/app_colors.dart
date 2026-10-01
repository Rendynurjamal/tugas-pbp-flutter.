import 'package:flutter/material.dart';

/// Palet warna terpusat untuk seluruh aplikasi BengkelKu (tema dark + gold).
/// Dipakai di login_page.dart, home_page.dart, splash_page.dart, dll,
/// supaya semua halaman konsisten dan warnanya cukup diganti di satu tempat.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF121214);
  static const Color surface = Color(0xFF1C1C22);
  static const Color surfaceAlt = Color(0xFF23232C);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldSoft = Color(0xFFE9D18B);
  static const Color textPrimary = Color(0xFFF5F3EF);
  static const Color textSecondary = Color(0xFFA6A6B2);
  static const Color borderSubtle = Color(0x1AFFFFFF); // putih 10%
  static const Color danger = Color(0xFFE07A6E);
  static const Color success = Color(0xFF7BC67E);
}

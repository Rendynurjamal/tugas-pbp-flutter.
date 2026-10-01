import 'package:flutter/material.dart';

import 'pages/splash_page.dart';

void main() {
  runApp(const BengkelKuApp());
}

class BengkelKuApp extends StatelessWidget {
  const BengkelKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BengkelKu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'Arial',
      ),
      home: const SplashPage(),
    );
  }
}

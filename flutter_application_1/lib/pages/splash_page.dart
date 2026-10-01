import 'dart:async';
import 'package:flutter/material.dart';

import 'onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const Color background = Color(0xFF121214);
  static const Color gold = Color(0xFFD4AF37);
  static const Color textPrimary = Color(0xFFF5F3EF);
  static const Color textSecondary = Color(0xFFA6A6B2);

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OnboardingPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
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
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: gold, width: 2),
                  ),
                  child: const Icon(
                    Icons.build_circle_outlined,
                    color: gold,
                    size: 54,
                  ),
                ),
                const SizedBox(height: 18),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Bengkel',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: 'Ku',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: gold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Solusi servis kendaraan kamu',
                  style: TextStyle(color: textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

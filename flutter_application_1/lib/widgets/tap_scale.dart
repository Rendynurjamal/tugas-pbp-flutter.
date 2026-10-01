import 'package:flutter/material.dart';

/// Widget pembungkus yang memberi efek "mengecil sedikit" saat ditekan.
/// Dipakai di banyak kartu (menu, layanan, kontak, dll) di seluruh app.
class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const TapScale({super.key, required this.child, this.onTap});

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  double _scale = 1;

  void _setScale(double value) => setState(() => _scale = value);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setScale(0.96),
      onTapCancel: () => _setScale(1),
      onTapUp: (_) => _setScale(1),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

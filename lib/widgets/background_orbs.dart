import 'package:flutter/material.dart';
import 'dart:math' as math;

class BackgroundOrbs extends StatefulWidget {
  const BackgroundOrbs({super.key});

  @override
  State<BackgroundOrbs> createState() => _BackgroundOrbsState();
}

class _BackgroundOrbsState extends State<BackgroundOrbs> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            _orb(400, 400, Colors.blueAccent.withOpacity(0.15), _controller.value * 2 * math.pi, 50, 100),
            _orb(350, 350, Colors.cyanAccent.withOpacity(0.1), (_controller.value + 0.5) * 2 * math.pi, -100, -80),
          ],
        );
      },
    );
  }

  Widget _orb(double w, double h, Color color, double angle, double dx, double dy) {
    return Positioned(
      left: 100 * math.cos(angle) + dx,
      top: 100 * math.sin(angle) + dy,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)]),
      ),
    );
  }
}
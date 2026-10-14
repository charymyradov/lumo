import 'package:flutter/material.dart';

/// Single reusable slot of the zero-allocation particle pool.
class MicroParticle {
  MicroParticle({
    this.x = 0,
    this.y = 0,
    this.vx = 0,
    this.vy = 0,
    this.color = Colors.white,
    this.isHeart = true,
    this.isShard = false,
    this.life = 0,
  });

  double x;
  double y;
  double vx;
  double vy;
  Color color;
  bool isHeart;
  bool isShard;
  double life;

  bool get isDead => life <= 0;
}

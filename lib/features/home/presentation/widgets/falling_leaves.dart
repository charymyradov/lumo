import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Home sahnesinde süzülen yapraklar + ışık zerrecikleri.
///
/// Performans tasarımı:
/// * Tek bir [CustomPaint] her karede yeniden çizilir; widget ağacı
///   ASLA rebuild olmaz (painter, animasyonu [CustomPainter.repaint]
///   üzerinden dinler).
/// * Blur, gölge, saveLayer yok — kare başına ~16 yaprak yolu + ~10 daire.
/// * Sekme gizlenince üstteki [TickerMode] tick'i keser, maliyet sıfırlanır.
class FallingLeaves extends StatefulWidget {
  final bool isNight;

  const FallingLeaves({super.key, required this.isNight});

  @override
  State<FallingLeaves> createState() => _FallingLeavesState();
}

class _LeafSpec {
  final double x0;
  final double speed;
  final double yOff;
  final double swayAmp;
  final double swayFreq;
  final double phase;
  final double size;
  final double rockFreq;
  final double rockAmp;
  final int shade;
  final double alpha;

  const _LeafSpec({
    required this.x0,
    required this.speed,
    required this.yOff,
    required this.swayAmp,
    required this.swayFreq,
    required this.phase,
    required this.size,
    required this.rockFreq,
    required this.rockAmp,
    required this.shade,
    required this.alpha,
  });
}

class _MoteSpec {
  final double x0;
  final double yOff;
  final double speed;
  final double phase;
  final double size;
  final double alpha;

  const _MoteSpec({
    required this.x0,
    required this.yOff,
    required this.speed,
    required this.phase,
    required this.size,
    required this.alpha,
  });
}

class _FallingLeavesState extends State<FallingLeaves>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_LeafSpec> _leaves;
  late final List<_MoteSpec> _motes;

  // Gündüz paleti: yeşiller + 1-2 sıcak sarı.
  static const _dayShades = [
    Color(0xFF5FCB54),
    Color(0xFF7FDB62),
    Color(0xFFA8E573),
    Color(0xFF3FAE4E),
    Color(0xFFE8B93E),
  ];

  // Gece tonu bir kez precompute edilir (per-frame Color.lerp yok).
  static final _nightShades = _dayShades
      .map((c) => Color.lerp(c, Colors.black, 0.45)!)
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    final rng = math.Random(7);
    _leaves = List.generate(16, (i) {
      return _LeafSpec(
        x0: rng.nextDouble(),
        speed: 0.7 + rng.nextDouble() * 0.6,
        yOff: rng.nextDouble(),
        swayAmp: 0.02 + rng.nextDouble() * 0.045,
        swayFreq: 1.0 + rng.nextDouble() * 2.0,
        phase: rng.nextDouble() * math.pi * 2,
        size: 5.5 + rng.nextDouble() * 8.0,
        rockFreq: 0.6 + rng.nextDouble() * 1.4,
        rockAmp: 0.35 + rng.nextDouble() * 0.35,
        // Son iki yaprak sıcak sarı olsun.
        shade: i >= 14 ? 4 : rng.nextInt(4),
        alpha: 0.55 + rng.nextDouble() * 0.35,
      );
    })
      ..sort((a, b) => a.size.compareTo(b.size)); // küçük (uzak) önce

    _motes = List.generate(10, (_) {
      return _MoteSpec(
        x0: rng.nextDouble(),
        yOff: rng.nextDouble(),
        speed: 0.04 + rng.nextDouble() * 0.08,
        phase: rng.nextDouble() * math.pi * 2,
        size: 1.2 + rng.nextDouble() * 2.2,
        alpha: 0.25 + rng.nextDouble() * 0.4,
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LeavesPainter(
        animation: _ctrl,
        leaves: _leaves,
        motes: _motes,
        isNight: widget.isNight,
      ),
      isComplex: true,
      willChange: true,
    );
  }
}

class _LeavesPainter extends CustomPainter {
  _LeavesPainter({
    required this.animation,
    required this.leaves,
    required this.motes,
    required this.isNight,
  }) : super(repaint: animation) {
    // Yaprak renkleri bir kez precompute edilir: per-frame Color.lerp ve
    // withValues alloc'u yok, paint() sadece tabloya bakar.
    _dayFills = List<Color>.generate(
      leaves.length,
      (i) => _FallingLeavesState._dayShades[leaves[i].shade]
          .withValues(alpha: leaves[i].alpha),
      growable: false,
    );
    _nightFills = List<Color>.generate(
      leaves.length,
      (i) => _FallingLeavesState._nightShades[leaves[i].shade]
          .withValues(alpha: leaves[i].alpha),
      growable: false,
    );
    _veinColors = List<Color>.generate(
      leaves.length,
      (i) => Colors.white.withValues(alpha: leaves[i].alpha * 0.55),
      growable: false,
    );
  }

  final Animation<double> animation;
  final List<_LeafSpec> leaves;
  final List<_MoteSpec> motes;
  final bool isNight;

  static const _twoPi = math.pi * 2;
  static const _moteNightBase = Color(0xFFFFE9A8);

  // Kare başına alloc yapmamak için reuse edilen nesneler.
  final Paint _motePaint = Paint()..style = PaintingStyle.fill;
  final Paint _fill = Paint()..style = PaintingStyle.fill;
  final Paint _vein = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0
    ..strokeCap = StrokeCap.round;
  final Path _leafPath = Path();

  late final List<Color> _dayFills;
  late final List<Color> _nightFills;
  late final List<Color> _veinColors;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final t = animation.value;
    final w = size.width;
    final h = size.height;

    // ── Işık zerrecikleri (gece ateş böceği gibi parlar) ──
    // Tek Paint reuse edilir; sadece .color yazılır.
    for (final m in motes) {
      final yFrac = (((m.yOff - t * m.speed) % 1.0) + 1.0) % 1.0;
      final x = (m.x0 + math.sin(t * _twoPi + m.phase) * 0.02) * w;
      final twinkle = 0.55 + 0.45 * math.sin(t * _twoPi * 2 + m.phase);
      _motePaint.color = isNight
          ? _moteNightBase.withValues(alpha: m.alpha * twinkle)
          : Colors.white.withValues(alpha: m.alpha * twinkle * 0.8);
      canvas.drawCircle(Offset(x, yFrac * h), m.size, _motePaint);
    }

    // ── Yapraklar ──
    // Renkler precomputed tablodan; tek Path reset'lenip reuse edilir.
    final fills = isNight ? _nightFills : _dayFills;
    for (var i = 0; i < leaves.length; i++) {
      final leaf = leaves[i];
      final fall = ((t * leaf.speed + leaf.yOff) % 1.15) - 0.075;
      if (fall < -0.06 || fall > 1.06) continue;
      final y = fall * h;
      final x = (leaf.x0 +
              math.sin(t * leaf.swayFreq * _twoPi + leaf.phase) *
                  leaf.swayAmp) *
          w;
      if (x < -24 || x > w + 24) continue;
      final rot = leaf.phase +
          math.sin(t * leaf.rockFreq * _twoPi + leaf.phase) * leaf.rockAmp;
      final s = leaf.size;

      _fill.color = fills[i];
      _vein.color = _veinColors[i];

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      // Sivri uçlu yaprak.
      _leafPath
        ..reset()
        ..moveTo(0, -s)
        ..quadraticBezierTo(s * 0.85, -s * 0.2, 0, s)
        ..quadraticBezierTo(-s * 0.85, -s * 0.2, 0, -s)
        ..close();
      canvas.drawPath(_leafPath, _fill);
      canvas.drawLine(Offset(0, -s * 0.65), Offset(0, s * 0.65), _vein);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_LeavesPainter old) => old.isNight != isNight;
}

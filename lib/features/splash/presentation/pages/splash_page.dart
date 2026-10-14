import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_typography.dart';
import 'package:lumo/core/constants/asset_paths.dart';

class SplashPage extends StatefulWidget {
  final VoidCallback onFinished;

  const SplashPage({super.key, required this.onFinished});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _shimmerController;
  late AnimationController _particleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;

  bool _disposed = false;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    // Test ortamında dispose sonrası sarkan Timer bırakmamak için
    // her adımda mounted + _disposed kontrolü yapılır.
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted || _disposed) return;
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted || _disposed) return;
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted || _disposed) return;
    widget.onFinished();
  }

  @override
  void dispose() {
    _disposed = true;
    _logoController.dispose();
    _textController.dispose();
    _shimmerController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            AssetPaths.splash1,
            fit: BoxFit.cover,
          ),

          // Subtle dark overlay for text readability
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0x66000000),
                ],
                stops: [0.5, 1.0],
              ),
            ),
          ),

          // Floating particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ParticlePainter(_particleController.value),
                size: Size.infinite,
              );
            },
          ),

          // Center content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo icon + wordmark
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      // Star/diamond icon
                      AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, child) {
                          return ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment(
                                    -1 + _shimmerController.value * 3, 0),
                                end: Alignment(
                                    0 + _shimmerController.value * 3, 0),
                                colors: const [
                                  Color(0xFFFFF9C4),
                                  Color(0xFFFFD700),
                                  Color(0xFFFFF9C4),
                                ],
                              ).createShader(bounds);
                            },
                            child: const Icon(
                              Icons.auto_awesome,
                              size: 72,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // "lumo" wordmark
                      FadeTransition(
                        opacity: _textOpacity,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Text(
                            'lumo',
                            style: AppTypography.displayLarge.copyWith(
                              fontSize: 56,
                              letterSpacing: 2,
                              shadows: [
                                const Shadow(
                                  color: Color(0x66000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Tagline
                FadeTransition(
                  opacity: _taglineOpacity,
                  child: SlideTransition(
                    position: _taglineSlide,
                    child: Text(
                      'Small steps, big happiness.',
                      style: AppTypography.taglineText.copyWith(
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Bottom bar
                FadeTransition(
                  opacity: _taglineOpacity,
                  child: Container(
                    width: 60,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 32, top: 16),
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final particles = [
      const _Particle(0.15, 0.2, 3.0, 0.0),
      const _Particle(0.75, 0.15, 2.0, 0.2),
      const _Particle(0.3, 0.35, 2.5, 0.4),
      const _Particle(0.85, 0.4, 3.5, 0.1),
      const _Particle(0.5, 0.1, 2.0, 0.6),
      const _Particle(0.1, 0.6, 1.5, 0.3),
      const _Particle(0.9, 0.7, 2.5, 0.7),
      const _Particle(0.4, 0.8, 1.8, 0.5),
      const _Particle(0.65, 0.25, 3.0, 0.8),
      const _Particle(0.2, 0.45, 2.2, 0.15),
    ];

    for (final p in particles) {
      final phase = (progress + p.phase) % 1.0;
      final opacity = (math.sin(phase * 2 * math.pi) * 0.5 + 0.5) * 0.6;
      final yOffset = math.sin(phase * 2 * math.pi) * 10;

      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(p.xFrac * size.width, p.yFrac * size.height + yOffset),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double xFrac;
  final double yFrac;
  final double radius;
  final double phase;
  const _Particle(this.xFrac, this.yFrac, this.radius, this.phase);
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/shared/widgets/glass_card.dart';

/// "Günlük İndirim" şeftali tonlu cam kart + geri sayım kutuları.
class DailyDealBanner extends StatefulWidget {
  const DailyDealBanner({super.key});

  @override
  State<DailyDealBanner> createState() => _DailyDealBannerState();
}

class _DailyDealBannerState extends State<DailyDealBanner> {
  static const _total = Duration(hours: 12, minutes: 34, seconds: 56);
  late Duration _left;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _left = _total;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_left.inSeconds <= 0) return;
      setState(() => _left = _left - const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = _left.inHours.toString().padLeft(2, '0');
    final m = (_left.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_left.inSeconds % 60).toString().padLeft(2, '0');

    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFFE3C2).withValues(alpha: 0.8),
          const Color(0xFFFFD3B3).withValues(alpha: 0.65),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Günlük İndirim',
                  style: GoogleFonts.nunito(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Text('⭐', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _timeBox(h),
              _colon(),
              _timeBox(m),
              _colon(),
              _timeBox(s),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeBox(String v) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Text(
        v,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Widget _colon() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        ':',
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

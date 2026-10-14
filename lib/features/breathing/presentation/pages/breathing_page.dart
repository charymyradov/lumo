import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/di/injection.dart';
import 'package:lumo/core/services/haptic_service.dart';
import 'package:lumo/features/breathing/presentation/bloc/breathing_bloc.dart';
import 'package:lumo/features/breathing/presentation/bloc/breathing_event.dart';
import 'package:lumo/features/breathing/presentation/pages/breathing_controller.dart';
import 'package:lumo/features/breathing/presentation/widgets/breathing_session_view.dart';

/// 7. Nefes Egzersizi — görseldeki gibi:
/// nefes.png • geri + başlık • cam küre (smooth nefes) •
/// "Nefes al / 4 saniye" • desen sırası • süre sırası • ses hapı.
/// Ödül ekonomisi [BreathingBloc]'te; animasyon/ses UI'da kalır.
///
/// Bu sayfa yalnızca composition yapar: oturum durumu
/// [BreathingController]'da, gövde [BreathingSessionView]'dadır.
class BreathingPage extends StatelessWidget {
  const BreathingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BreathingBloc>(),
      child: const _BreathingView(),
    );
  }
}

class _BreathingView extends StatefulWidget {
  const _BreathingView();

  @override
  State<_BreathingView> createState() => _BreathingViewState();
}

class _BreathingViewState extends State<_BreathingView>
    with SingleTickerProviderStateMixin {
  late final BreathingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BreathingController(
      vsync: this,
      onSessionCompleted: _completeSession,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _completeSession() {
    HapticService.success();
    context.read<BreathingBloc>().add(const BreathingSessionCompleted());
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session complete 🧘'),
        content: const Text(
            'Nice breathing! +15 coins, +8 XP earned. Lumi feels calmer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context)
              ..pop()
              ..pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BreathingSessionView(controller: _controller);
  }
}

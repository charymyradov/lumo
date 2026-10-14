import 'package:flutter/material.dart';
import 'package:lumo/core/di/injection.dart';
import 'package:lumo/core/repositories/wallet_repository.dart';

/// Streak rozeti cüzdan reposundan yüklenir.
mixin TasksStreakMixin<T extends StatefulWidget> on State<T> {
  int streak = 7;

  Future<void> loadStreak() async {
    final wallet = await sl<WalletRepository>().load();
    if (!mounted) return;
    setState(() => streak = wallet.streak);
  }
}

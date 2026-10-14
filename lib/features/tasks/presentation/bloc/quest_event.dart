import 'package:equatable/equatable.dart';
import 'package:lumo/features/tasks/domain/entities/quest.dart';

abstract class QuestEvent extends Equatable {
  const QuestEvent();
  @override
  List<Object?> get props => [];
}

/// İlk açılış: tamamlama seti + liste yüklenir.
class QuestLoadRequested extends QuestEvent {
  const QuestLoadRequested();
}

/// Yenile butonu: zorunlu ağ isteği, mevcut liste ekranda kalır.
class QuestRefreshRequested extends QuestEvent {
  const QuestRefreshRequested();
}

/// Görev kartına dokunma — ekonomi Bloc'ta (Widget'ta değil).
class QuestTaskToggled extends QuestEvent {
  final Quest task;
  const QuestTaskToggled(this.task);
  @override
  List<Object?> get props => [task];
}

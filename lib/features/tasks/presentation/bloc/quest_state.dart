import 'package:equatable/equatable.dart';
import 'package:lumo/features/tasks/domain/entities/quest.dart';

abstract class QuestState extends Equatable {
  const QuestState();

  @override
  List<Object?> get props => [];
}

class QuestInitial extends QuestState {
  const QuestInitial();
}

class QuestLoading extends QuestState {
  /// Arka planda tazelenirken eski listeyi ekranda tutmak için.
  final QuestBundle? current;

  const QuestLoading([this.current]);

  @override
  List<Object?> get props => [current];
}

class QuestLoaded extends QuestState {
  final QuestBundle bundle;

  /// Kullanıcıya gösterilecek kısa bilgi (örn. "Çevrimdışı liste").
  final String? notice;

  /// Bloc'un sahiplendiği tamamlama seti — Widget local state tutmaz.
  final Set<String> completedIds;

  /// Son toggle'da verilen ödül metni (snackbar için).
  /// Her toggle'da yeni değer yayılır; yüklemede sıfırlanır.
  final String? rewardMessage;

  const QuestLoaded(this.bundle,
      {this.notice, this.completedIds = const {}, this.rewardMessage});

  @override
  List<Object?> get props => [bundle, notice, completedIds, rewardMessage];
}

class QuestError extends QuestState {
  final String message;

  /// Hata anında ekranda tutulacak son liste (varsa).
  final QuestBundle? current;

  const QuestError(this.message, [this.current]);

  @override
  List<Object?> get props => [message, current];
}

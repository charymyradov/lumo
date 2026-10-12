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

  const QuestLoaded(this.bundle, {this.notice});

  @override
  List<Object?> get props => [bundle, notice];
}

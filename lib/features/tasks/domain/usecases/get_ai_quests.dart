import 'package:lumo/features/tasks/domain/entities/quest.dart';
import 'package:lumo/features/tasks/domain/repositories/quest_repository.dart';

/// AI görev demetini getirir. Önbellek/ağ/yedek kararı repository'dedir.
class GetAiQuests {
  final QuestRepository _repository;

  const GetAiQuests(this._repository);

  Future<QuestBundle> call(
      {bool forceRefresh = false,
      String promptContext = '',
      String profileKey = ''}) {
    return _repository.getQuests(
        forceRefresh: forceRefresh,
        promptContext: promptContext,
        profileKey: profileKey);
  }
}

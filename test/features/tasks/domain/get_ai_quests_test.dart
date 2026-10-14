import 'package:flutter_test/flutter_test.dart';
import 'package:lumo/features/tasks/domain/entities/quest.dart';
import 'package:lumo/features/tasks/domain/repositories/quest_repository.dart';
import 'package:lumo/features/tasks/domain/usecases/get_ai_quests.dart';

class _FakeRepo implements QuestRepository {
  final QuestBundle bundle;
  String lastPromptContext = '';
  _FakeRepo(this.bundle);

  @override
  Future<QuestBundle> getQuests(
      {bool forceRefresh = false,
      String promptContext = '',
      String profileKey = ''}) async {
    lastPromptContext = promptContext;
    return bundle;
  }
}

void main() {
  test('GetAiQuests forwards promptContext (not BuildContext)', () async {
    final bundle = QuestBundle(
      daily: const [],
      weekly: const [],
      source: QuestSource.fresh,
      fetchedAt: DateTime.now(),
    );
    final repo = _FakeRepo(bundle);
    final usecase = GetAiQuests(repo);

    final out =
        await usecase.call(promptContext: 'User context', profileKey: 'k');
    expect(out, bundle);
    expect(repo.lastPromptContext, 'User context');
  });
}

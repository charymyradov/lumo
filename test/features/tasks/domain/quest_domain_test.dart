import 'package:flutter_test/flutter_test.dart';
import 'package:lumo/features/home/domain/entities/cosmetic_item.dart';
import 'package:lumo/features/home/domain/entities/mascot_species.dart';
import 'package:lumo/features/tasks/data/models/quest_model.dart';
import 'package:lumo/features/tasks/domain/entities/quest.dart';

void main() {
  group('QuestModel', () {
    test('parses valid json', () {
      final m = QuestModel.fromJson(const {
        'title': 'Drink water',
        'subtitle': 'Stay hydrated',
        'reward': 20,
        'duration': '5 min',
        'category': 'water',
      }, 'daily_0');
      expect(m.title, 'Drink water');
      expect(m.reward, 20);
      expect(m.category, 'water');
    });

    test('throws on empty title', () {
      expect(
        () => QuestModel.fromJson(const {'title': '  '}, 'x'),
        throwsA(isA<FormatException>()),
      );
    });

    test('clamps reward and normalizes category', () {
      final m = QuestModel.fromJson(const {
        'title': 'Walk',
        'reward': 500,
        'category': 'unknown-cat',
      }, 'd1');
      expect(m.reward, 100);
      expect(m.category, 'health');
    });
  });

  group('Pure domain (no Flutter import)', () {
    test('CosmeticItem stores ARGB int', () {
      const item = CosmeticItem(
        id: 'x',
        nameTr: 'Test',
        price: 10,
        category: ShopCategory.outfit,
        iconKey: 'k',
        accentColorValue: 0xFFF472B6,
      );
      expect(item.accentColorValue, 0xFFF472B6);
    });

    test('MascotSpecies stores ARGB ints', () {
      expect(MascotSpecies.fox.primaryEarColorValue, 0xFF8B5CF6);
      expect(MascotSpecies.fromId('bunny'), MascotSpecies.bunny);
      expect(MascotSpecies.fromId('nope'), MascotSpecies.fox);
    });

    test('QuestBundle equality', () {
      const a = Quest(
          id: '1',
          title: 't',
          subtitle: 's',
          reward: 10,
          duration: '5 min',
          category: 'water');
      const b = Quest(
          id: '1',
          title: 't',
          subtitle: 's',
          reward: 10,
          duration: '5 min',
          category: 'water');
      expect(a, b);
    });
  });
}

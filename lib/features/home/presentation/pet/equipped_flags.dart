import 'package:lumo/features/home/domain/entities/cosmetic_item.dart';

/// Flattened "which cosmetics are active right now" flags so the painter does
/// not have to scan the whole inventory every frame.
class EquippedFlags {
  bool hasCloudBed = false;
  bool hasLantern = false;
  bool hasButterflyWings = false;
  bool hasCozyScarf = false;
  bool hasRibbonBow = false;
  bool hasCatHood = false;
  bool hasStarGlasses = false;
  bool hasCrown = false;
  bool hasMushroomHat = false;
  bool hasWizardHat = false;
  bool hasFlowerWreath = false;

  void updateFrom(List<CosmeticItem> items) {
    hasCloudBed = false;
    hasLantern = false;
    hasButterflyWings = false;
    hasCozyScarf = false;
    hasRibbonBow = false;
    hasCatHood = false;
    hasStarGlasses = false;
    hasCrown = false;
    hasMushroomHat = false;
    hasWizardHat = false;
    hasFlowerWreath = false;

    for (final item in items) {
      switch (item.id) {
        case 'item_cloud_bed':
          hasCloudBed = item.isPlacedOnStage;
        case 'item_lantern':
          hasLantern = item.isPlacedOnStage;
        case 'item_butterfly_wings':
          hasButterflyWings = item.isEquipped;
        case 'item_cozy_scarf':
          hasCozyScarf = item.isEquipped;
        case 'item_ribbon_bow':
          hasRibbonBow = item.isEquipped;
        case 'item_pink_cat_costume':
          hasCatHood = item.isEquipped;
        case 'item_star_glasses':
          hasStarGlasses = item.isEquipped;
        case 'item_crown':
          hasCrown = item.isEquipped;
        case 'item_mushroom_hat':
          hasMushroomHat = item.isEquipped;
        case 'item_wizard_hat':
          hasWizardHat = item.isEquipped;
        case 'item_flower_wreath':
          hasFlowerWreath = item.isEquipped;
      }
    }
  }
}

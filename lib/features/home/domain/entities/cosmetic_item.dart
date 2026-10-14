/// Shop / wardrobe category of a cosmetic.
///
/// Pure-Dart domain enum — no Flutter imports allowed here.
enum ShopCategory {
  outfit('Kıyafet', 'Outfit'),
  accessory('Aksesuar', 'Accessory'),
  furniture('Mobilya', 'Furniture'),
  background('Arka Plan', 'Background');

  const ShopCategory(this.labelTr, this.labelEn);

  final String labelTr;
  final String labelEn;
}

/// A cosmetic the pet can wear (equipped) or place on the stage (furniture).
///
/// Direct port of `CosmeticItem` from `lumo_kot/.../model/LumoModels.kt`.
/// The pet stage reads [isEquipped] / [isPlacedOnStage] to decide which
/// accessories and props have to be painted.
class CosmeticItem {
  const CosmeticItem({
    required this.id,
    required this.nameTr,
    required this.price,
    required this.category,
    required this.iconKey,
    required this.accentColorValue,
    this.isDailyDeal = false,
    this.isOwned = false,
    this.isEquipped = false,
    this.isPlacedOnStage = false,
  });

  final String id;
  final String nameTr;
  final int price;
  final ShopCategory category;
  final String iconKey;

  /// ARGB renk (örn. 0xFFF472B6). Domain saf Dart kalmalı diye [Color]
  /// yerine int tutulur; UI katmanındaki extension `accentColor`'a çevirir.
  final int accentColorValue;
  final bool isDailyDeal;
  final bool isOwned;

  /// True when the pet is currently wearing this item.
  final bool isEquipped;

  /// True when this furniture item is currently placed on the world stage.
  final bool isPlacedOnStage;

  CosmeticItem copyWith({
    bool? isDailyDeal,
    bool? isOwned,
    bool? isEquipped,
    bool? isPlacedOnStage,
  }) {
    return CosmeticItem(
      id: id,
      nameTr: nameTr,
      price: price,
      category: category,
      iconKey: iconKey,
      accentColorValue: accentColorValue,
      isDailyDeal: isDailyDeal ?? this.isDailyDeal,
      isOwned: isOwned ?? this.isOwned,
      isEquipped: isEquipped ?? this.isEquipped,
      isPlacedOnStage: isPlacedOnStage ?? this.isPlacedOnStage,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CosmeticItem &&
      other.id == id &&
      other.isDailyDeal == isDailyDeal &&
      other.isOwned == isOwned &&
      other.isEquipped == isEquipped &&
      other.isPlacedOnStage == isPlacedOnStage;

  @override
  int get hashCode =>
      Object.hash(id, isDailyDeal, isOwned, isEquipped, isPlacedOnStage);

  @override
  String toString() =>
      'CosmeticItem($id, equipped: $isEquipped, onStage: $isPlacedOnStage)';
}

/// Starter wardrobe used until a real repository is wired up.
///
/// Mirrors `defaultCosmeticItems()` from `LumoViewModel.kt`.
///
/// Not: `item_cloud_bed` (yumurta bulut) ve `item_lantern` (sarı sopa/peri
/// feneri) sahnede işlevsiz durduğu için varsayılanlardan çıkarıldı —
/// painter'daki `_drawStageCloudBed` / `_drawStageFairyLantern` korunuyor,
/// ileride mağazadan yerleştirildiklerinde yeniden devreye girer.
final List<CosmeticItem> defaultCosmeticItems =
    List.unmodifiable(<CosmeticItem>[
  const CosmeticItem(
    id: 'item_pink_cat_costume',
    nameTr: 'Pembe Kedi Kostümü',
    price: 180,
    category: ShopCategory.outfit,
    iconKey: 'pink_cat_hood',
    accentColorValue: 0xFFF472B6,
    isDailyDeal: true,
    isOwned: true,
  ),
  const CosmeticItem(
    id: 'item_mushroom_hat',
    nameTr: 'Mantar Şapka',
    price: 90,
    category: ShopCategory.outfit,
    iconKey: 'mushroom_hat',
    accentColorValue: 0xFFF87171,
    isOwned: true,
  ),
  const CosmeticItem(
    id: 'item_wizard_hat',
    nameTr: 'Büyücü Şapkası',
    price: 140,
    category: ShopCategory.outfit,
    iconKey: 'wizard_hat',
    accentColorValue: 0xFF60A5FA,
    isOwned: true,
  ),
  const CosmeticItem(
    id: 'item_crown',
    nameTr: 'Altın Taç',
    price: 210,
    category: ShopCategory.accessory,
    iconKey: 'gold_crown',
    accentColorValue: 0xFFFBBF24,
    isOwned: true,
    isEquipped: true,
  ),
  const CosmeticItem(
    id: 'item_butterfly_wings',
    nameTr: 'Kelebek Kanadı',
    price: 165,
    category: ShopCategory.accessory,
    iconKey: 'butterfly_wings',
    accentColorValue: 0xFF38BDF8,
    isOwned: true,
    isEquipped: false,
  ),
  const CosmeticItem(
    id: 'item_flower_wreath',
    nameTr: 'Çiçek Tacı',
    price: 110,
    category: ShopCategory.accessory,
    iconKey: 'flower_wreath',
    accentColorValue: 0xFFF472B6,
    isOwned: true,
  ),
  const CosmeticItem(
    id: 'item_star_glasses',
    nameTr: 'Yıldız Gözlük',
    price: 120,
    category: ShopCategory.accessory,
    iconKey: 'star_glasses',
    accentColorValue: 0xFFC084FC,
    isOwned: true,
  ),
  const CosmeticItem(
    id: 'item_ribbon_bow',
    nameTr: 'Pembe Fiyonk',
    price: 75,
    category: ShopCategory.accessory,
    iconKey: 'ribbon_bow',
    accentColorValue: 0xFFFB7185,
    isOwned: true,
  ),
  const CosmeticItem(
    id: 'item_cozy_scarf',
    nameTr: 'Sıcak Şal',
    price: 95,
    category: ShopCategory.outfit,
    iconKey: 'cozy_scarf',
    accentColorValue: 0xFFA78BFA,
    isOwned: true,
  ),
]);

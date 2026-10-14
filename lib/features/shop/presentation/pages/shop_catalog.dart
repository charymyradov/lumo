import 'package:flutter/material.dart';
import 'package:lumo/features/home/domain/entities/cosmetic_item.dart'
    show ShopCategory;

/// Mağaza ürün modeli. Sıra ShopCategory.values ile birebir eşleşir
/// (outfit, accessory, furniture, background).
class ShopItem {
  final String id;
  final String title;
  final int price;
  final String emoji;
  final List<Color> artColors;
  final ShopCategory category;

  const ShopItem({
    required this.id,
    required this.title,
    required this.price,
    required this.emoji,
    required this.artColors,
    required this.category,
  });
}

const shopCatalog = [
  ShopItem(
    id: 'pink_cat',
    title: 'Pink Cat Costume',
    price: 180,
    emoji: '🐱',
    artColors: [Color(0xFFFFE3EE), Color(0xFFFFC9DE)],
    category: ShopCategory.outfit,
  ),
  ShopItem(
    id: 'cloud_bed',
    title: 'Cloud Bed',
    price: 150,
    emoji: '☁️',
    artColors: [Color(0xFFE3F0FF), Color(0xFFC9E2FF)],
    category: ShopCategory.furniture,
  ),
  ShopItem(
    id: 'star_crown',
    title: 'Star Crown',
    price: 220,
    emoji: '👑',
    artColors: [Color(0xFFFFF3C4), Color(0xFFFFD97A)],
    category: ShopCategory.accessory,
  ),
  ShopItem(
    id: 'leaf_cape',
    title: 'Leaf Cape',
    price: 120,
    emoji: '🍃',
    artColors: [Color(0xFFDDF7E3), Color(0xFFA8E6B0)],
    category: ShopCategory.outfit,
  ),
];

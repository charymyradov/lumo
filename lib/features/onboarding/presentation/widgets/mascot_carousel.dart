import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/asset_paths.dart';

class MascotCarousel extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onMascotTap;

  static const List<MascotData> mascots = [
    MascotData(
      path: AssetPaths.petFox,
      name: 'Sparky',
      traits: 'Curious • Energetic • Playful',
    ),
    MascotData(
      path: AssetPaths.petCat,
      name: 'Luna',
      traits: 'Calm • Wise • Graceful',
    ),
    MascotData(
      path: AssetPaths.petDog,
      name: 'Buddy',
      traits: 'Loyal • Cheerful • Brave',
    ),
    MascotData(
      path: AssetPaths.petPanda,
      name: 'Mochi',
      traits: 'Gentle • Sweet • Peaceful',
    ),
    MascotData(
      path: AssetPaths.petFossa,
      name: 'Zara',
      traits: 'Bold • Adventurous • Free',
    ),
  ];

  const MascotCarousel({
    super.key,
    required this.selectedIndex,
    required this.onMascotTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selected mascot hero display
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim, child: ScaleTransition(scale: anim, child: child)),
          child: SizedBox(
            key: ValueKey(selectedIndex),
            width: 180,
            height: 180,
            child: Image.asset(
              mascots[selectedIndex].path,
              fit: BoxFit.contain,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Name
        Text(
          mascots[selectedIndex].name,
          style: AppText.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 4),

        // Traits
        Text(
          mascots[selectedIndex].traits,
          style: AppText.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Thumbnail row
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: mascots.length,
            itemBuilder: (context, index) {
              final isSelected = index == selectedIndex;
              return GestureDetector(
                onTap: () => onMascotTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      width: 2.5,
                    ),
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.6),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                            )
                          ]
                        : [],
                  ),
                  child: Image.asset(
                    mascots[index].path,
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class MascotData {
  final String path;
  final String name;
  final String traits;
  const MascotData(
      {required this.path, required this.name, required this.traits});
}

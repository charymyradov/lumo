import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/features/journal/presentation/widgets/ai_insight_panel.dart';
import 'package:lumo/features/journal/presentation/widgets/date_picker_field.dart';
import 'package:lumo/features/journal/presentation/widgets/journal_text_field.dart';
import 'package:lumo/features/journal/presentation/widgets/mood_selector.dart';
import 'package:lumo/features/journal/presentation/widgets/tag_chips.dart';

/// 4. Günlük (Journal) — görseldeki gibi:
/// mood seçici • tarih • metin • tagler • Kaydet • AI İçgörün.
class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  int _moodIndex = 0;
  final _controller = TextEditingController();
  final Set<int> _selectedTags = {};
  bool _saved = false;

  static const _tags = ['#minnet', '#sağlık', '#Aile', '#g', '#izrei'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Image.asset(
              AssetPaths.splash2Jpg,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.18, 0.45, 1.0],
              colors: [
                Color(0x40FFFFFF),
                Color(0x66FFFFFF),
                Color(0xB3FFFFFF),
                Color(0xD9FFFFFF),
              ],
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Bugün nasılsın?',
                  style: GoogleFonts.nunito(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                MoodSelector(
                  selectedIndex: _moodIndex,
                  onChanged: (i) => setState(() => _moodIndex = i),
                ),
                const SizedBox(height: 16),
                DatePickerField(
                  dateText: '7 Ekim 2025',
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                JournalTextField(controller: _controller),
                const SizedBox(height: 12),
                TagChips(
                  tags: _tags,
                  selected: _selectedTags,
                  onTap: (i) => setState(() {
                    if (!_selectedTags.add(i)) _selectedTags.remove(i);
                  }),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4FA8F0), Color(0xFF3E8FE0)],
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3E8FE0).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => setState(() => _saved = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Text(
                        _saved ? 'Kaydedildi ✓' : 'Kaydet',
                        style: GoogleFonts.nunito(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const AiInsightPanel(
                  message:
                      'Bugün kendine karşı çok naziksin. Bu dengeli ruh halin, yardım için de iyi bir temel oluşturuyor.',
                ),
                const SizedBox(height: 10),
                const AiPatternStrip(),
                const SizedBox(height: 110),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

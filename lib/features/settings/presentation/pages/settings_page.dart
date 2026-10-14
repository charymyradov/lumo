import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/app_typography.dart';

/// Basit, tamamen çalışan Ayarlar sayfası.
/// Bildirim/ses/hareket tercihleri + veri sıfırlama + sürüm bilgisi.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  bool _sounds = true;
  bool _reduceMotion = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notifications = prefs.getBool('settings_notifications_v1') ?? true;
      _sounds = prefs.getBool('settings_sounds_v1') ?? true;
      _reduceMotion = prefs.getBool('settings_reduce_motion_v1') ?? false;
      _loaded = true;
    });
  }

  Future<void> _set(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _resetProgress() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset all progress?'),
        content: const Text(
            'Coins, XP, journal, tasks and pet vitals will be cleared. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('Progress cleared. Restart the app for a fresh start.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppText.nunito(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFFF6F1FF),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _section('Preferences', [
                  SwitchListTile(
                    title: const Text('Notifications'),
                    subtitle: const Text('Daily quest & care reminders'),
                    value: _notifications,
                    onChanged: (v) {
                      setState(() => _notifications = v);
                      _set('settings_notifications_v1', v);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Sounds'),
                    subtitle: const Text('Pet sounds & breathing ambience'),
                    value: _sounds,
                    onChanged: (v) {
                      setState(() => _sounds = v);
                      _set('settings_sounds_v1', v);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Reduce motion'),
                    subtitle: const Text('Calmer animations'),
                    value: _reduceMotion,
                    onChanged: (v) {
                      setState(() => _reduceMotion = v);
                      _set('settings_reduce_motion_v1', v);
                    },
                  ),
                ]),
                const SizedBox(height: 16),
                _section('Data', [
                  ListTile(
                    leading: const Icon(Icons.refresh_rounded),
                    title: const Text('Reset all progress'),
                    subtitle: const Text('Clear coins, XP and journals'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _resetProgress,
                  ),
                ]),
                const SizedBox(height: 16),
                _section('About', [
                  const ListTile(
                    leading: Icon(Icons.info_outline_rounded),
                    title: Text('Lumo'),
                    subtitle:
                        Text('Version 1.0.0+1 · Small steps, big happiness.'),
                  ),
                ]),
              ],
            ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
            child: Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

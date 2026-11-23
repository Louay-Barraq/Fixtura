import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fixtura/l10n/app_localizations.dart';
import '../providers/tournament_provider.dart';
import '../providers/locale_provider.dart';
import '../services/backup_service.dart';
import '../utils/share_origin.dart';
import '../widgets/app_back_button.dart';
import '../widgets/main_appbar.dart';
import '../widgets/short_section_header.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  final String _appVersion = 'v1.1.0';
  static const List<String> _languages = ['English', 'Français', 'Español', 'العربية'];

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    try {
      final Uri uri = Uri.parse(urlString);
      // For mailto and market schemes, launch directly without canLaunchUrl check,
      // as canLaunchUrl can return false on Android 11+ if no default email app is registered yet.
      bool launched = false;
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        // Fallback for non-external or platform default mode
        launched = await launchUrl(uri);
      }

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.couldNotOpenLink(urlString)),
            backgroundColor: const Color(0xFFD71212),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.couldNotOpenLink(urlString)),
            backgroundColor: const Color(0xFFD71212),
          ),
        );
      }
    }
  }

  // ignore: unused_element
  void _shareApp(BuildContext context) {
    Share.share(
      'Check out Fixtura — the offline tournament generator, league standings, and team roulette drafting app for Android!\nhttps://play.google.com/store/apps/details?id=com.louaybarraq.fixtura',
      subject: 'Fixtura — Offline Tournament Manager',
      sharePositionOrigin: shareOrigin(context),
    );
  }

  void _showMessage(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFD71212) : Colors.black,
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context, AppLocalizations l10n) async {
    final provider = Provider.of<TournamentProvider>(context, listen: false);
    if (provider.tournaments.isEmpty) {
      _showMessage(context, l10n.noTournamentsToExport);
      return;
    }
    // Read before any await, while the screen is certainly still laid out
    final origin = shareOrigin(context);
    try {
      final json = await BackupService().exportJson();
      final date = DateTime.now().toIso8601String().substring(0, 10);
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, 'fixtura-backup-$date.json'));
      await file.writeAsString(json);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'Fixtura backup $date',
        sharePositionOrigin: origin,
      );
    } catch (e) {
      debugPrint('Backup export failed: $e');
      if (context.mounted) _showMessage(context, l10n.backupExportFailed, isError: true);
    }
  }

  Future<void> _importBackup(BuildContext context, AppLocalizations l10n) async {
    final provider = Provider.of<TournamentProvider>(context, listen: false);
    try {
      final picked = await FilePicker.pickFiles(withData: true);
      final file = picked?.files.single;
      if (file == null) return;
      final bytes = file.bytes ?? (file.path != null ? await File(file.path!).readAsBytes() : null);
      if (bytes == null) throw const InvalidBackupException('empty file');

      final count = await BackupService().importJson(utf8.decode(bytes));
      await provider.loadAllTournaments();
      if (!context.mounted) return;
      _showMessage(context, count == 0 ? l10n.backupNothingNew : l10n.backupImported(count));
    } catch (e) {
      debugPrint('Backup import failed: $e');
      if (context.mounted) _showMessage(context, l10n.backupInvalid, isError: true);
    }
  }

  void _confirmResetData(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          l10n.resetAllDataTitle,
          style: const TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 22,
            color: Color(0xFFD71212),
          ),
        ),
        content: Text(
          l10n.resetAllDataContent,
          style: const TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancel,
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = Provider.of<TournamentProvider>(context, listen: false);
              await provider.clearAllTournaments();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.allDataCleared),
                    backgroundColor: Colors.black,
                  ),
                );
              }
            },
            child: Text(
              l10n.resetEverything,
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                color: Color(0xFFD71212),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar with back button
            Stack(
              children: [
                const MainAppbar(showSettingsButton: false),
                const AppBackButton(),
              ],
            ),

            // Scrollable Settings Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    // Section 1: PREFERENCES
                    ShortSectionHeader(title: l10n.preferences),
                    const Gap(12),
                    _buildLanguageTile(context, localeProvider, l10n),
                    const Gap(24),

                    // Section 2: HELP & ONBOARDING
                    ShortSectionHeader(title: l10n.guideAndTutorial),
                    const Gap(12),
                    _buildSettingsTile(
                      context,
                      icon: Icons.menu_book_rounded,
                      title: l10n.viewAppTutorial,
                      subtitle: l10n.replayOnboarding,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnboardingScreen(isReplay: true),
                          ),
                        );
                      },
                    ),
                    const Gap(24),

                    // Section 3: ABOUT & SUPPORT
                    ShortSectionHeader(title: l10n.aboutAndSupport),
                    const Gap(12),
                    _buildSettingsTile(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: l10n.privacyPolicy,
                      subtitle: l10n.privacyPolicySubtitle,
                      onTap: () => _launchUrl(context, 'https://louay-barraq.github.io/Fixtura/'),
                    ),
                    const Gap(10),
                    _buildSettingsTile(
                      context,
                      icon: Icons.mail_outline_rounded,
                      title: l10n.contactDeveloper,
                      subtitle: l10n.contactDeveloperSubtitle,
                      onTap: () => _launchUrl(context, 'mailto:barraklouay@gmail.com?subject=Fixtura%20Feedback'),
                    ),
                    // const Gap(10),
                    // _buildSettingsTile(
                    //   context,
                    //   icon: Icons.star_border_rounded,
                    //   title: l10n.rateFixtura,
                    //   subtitle: l10n.rateFixturaSubtitle,
                    //   onTap: () => _launchUrl(context, 'market://details?id=com.louaybarraq.fixtura'),
                    // ),
                    // const Gap(10),
                    // _buildSettingsTile(
                    //   context,
                    //   icon: Icons.share_outlined,
                    //   title: l10n.shareWithFriends,
                    //   subtitle: l10n.shareSubtitle,
                    //   onTap: () => _shareApp(context),
                    // ),
                    const Gap(24),

                    // Section 4: BACKUP
                    ShortSectionHeader(title: l10n.dataSection),
                    const Gap(12),
                    _buildSettingsTile(
                      context,
                      icon: Icons.upload_file_rounded,
                      title: l10n.exportBackup,
                      subtitle: l10n.exportBackupSubtitle,
                      onTap: () => _exportBackup(context, l10n),
                    ),
                    const Gap(10),
                    _buildSettingsTile(
                      context,
                      icon: Icons.download_rounded,
                      title: l10n.importBackup,
                      subtitle: l10n.importBackupSubtitle,
                      onTap: () => _importBackup(context, l10n),
                    ),
                    const Gap(24),

                    // Section 5: DANGER ZONE
                    ShortSectionHeader(title: l10n.dangerZone),
                    const Gap(12),
                    _buildSettingsTile(
                      context,
                      icon: Icons.delete_forever_rounded,
                      title: l10n.clearAllTournaments,
                      subtitle: l10n.clearAllSubtitle,
                      iconColor: const Color(0xFFD71212),
                      textColor: const Color(0xFFD71212),
                      onTap: () => _confirmResetData(context, l10n),
                    ),
                    const Gap(30),

                    // App Footer Brand Info
                    Text(
                      'FIXTURA $_appVersion',
                      style: const TextStyle(
                        fontFamily: 'BebasNeue',
                        fontSize: 16,
                        color: Colors.black54,
                        letterSpacing: 1,
                      ),
                    ),
                    const Gap(4),
                    const Text(
                      'Crafted with ❤️ by Louay Barraq',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                    const Gap(20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, LocaleProvider localeProvider, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
            color: Colors.black.withValues(alpha: 0.18),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.language_rounded,
              size: 20,
              color: Color(0xFFD71212),
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.language,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  l10n.selectLanguage,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: localeProvider.currentLanguageName,
              dropdownColor: Colors.black,
              borderRadius: BorderRadius.circular(6),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              // Closed/picked item styling: Black text on white tile
              selectedItemBuilder: (BuildContext context) {
                return _languages.map<Widget>((String lang) {
                  return Center(
                    child: Text(
                      lang,
                      style: const TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList();
              },
              // Open menu items: White text on black dropdown background
              items: _languages.map((String lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(
                    lang,
                    style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  localeProvider.setLanguageByName(newValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
            color: Colors.black.withValues(alpha: 0.18),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F1F1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: iconColor,
                  ),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.flip(
                  flipX: Directionality.of(context) == TextDirection.rtl,
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

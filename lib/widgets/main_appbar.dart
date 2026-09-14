import 'package:flutter/material.dart';
import 'package:fixtura/l10n/app_localizations.dart';
import '../screens/settings_screen.dart';

class MainAppbar extends StatelessWidget implements PreferredSizeWidget {
  final bool showSettingsButton;

  const MainAppbar({super.key, this.showSettingsButton = true});

  @override
  Size get preferredSize => const Size.fromHeight(80.0);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final l10n = AppLocalizations.of(context);

    return ClipRect(
      clipper: _BottomOnlyClipper(12), // >= blurRadius + spreadRadius
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: statusBarHeight),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCFC),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 1),
              blurRadius: 4,
              spreadRadius: 4,
              color: Colors.black.withValues(alpha: 0.25),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "FIXTURA",
                  style: TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 32,
                    color: Colors.black,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n?.appSubtitle ?? "Host & Manage\nLocal Leagues & Brackets",
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 11,
                    color: Colors.black,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
              ],
            ),
            if (showSettingsButton)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          spreadRadius: 0,
                          color: Colors.black.withValues(alpha: 0.25),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.settings,
                        size: 28,
                        color: Color(0xFFD71212),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomOnlyClipper extends CustomClipper<Rect> {
  final double extra;
  _BottomOnlyClipper(this.extra);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width, size.height + extra);

  @override
  bool shouldReclip(covariant _BottomOnlyClipper oldClipper) => false;
}

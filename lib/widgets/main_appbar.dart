import 'package:flutter/material.dart';

class MainAppbar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80.0);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return ClipRect(
      clipper: _BottomOnlyClipper(12), // >= blurRadius + spreadRadius
      child: Container(
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
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "FIXTURA",
              style: TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: 32,
                color: Colors.black,
                height: 1.0,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Host & Manage\nLocal Leagues & Brackets",
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 11,
                color: Colors.black,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
          ],
        ),
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
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

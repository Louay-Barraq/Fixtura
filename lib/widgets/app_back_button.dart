import 'package:flutter/material.dart';
import 'package:fixtura/widgets/circle_icon_button.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const AppBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned.directional(
      textDirection: Directionality.of(context),
      start: 10,
      top: 10,
      child: CircleIconButton(
        icon: Icons.arrow_back,
        flipInRtl: true,
        onTap: onTap ?? () => Navigator.pop(context),
      ),
    );
  }
}

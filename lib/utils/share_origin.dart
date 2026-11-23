import 'package:flutter/widgets.dart';

/// Where the share sheet is anchored: the widget that [context] belongs to.
/// iOS rejects a share without a non-empty origin inside the screen, on
/// iPhone as well as iPad.
Rect shareOrigin(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  if (box == null || !box.hasSize) return const Rect.fromLTWH(0, 0, 1, 1);
  return box.localToGlobal(Offset.zero) & box.size;
}

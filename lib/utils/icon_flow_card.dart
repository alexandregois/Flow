import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../go_installation_icons_icons.dart';

Widget getIconFlowCard(String icon, Color colorIcon) {
  return SizedBox(
    width: double.infinity,
    child: Padding(
      padding: const EdgeInsets.all(0),
      child: Icon(
        GoInstallationIcons.getIcon(icon),
        color: colorIcon,
      ),
    ),
  );
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

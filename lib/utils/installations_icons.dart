import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flutter/material.dart';
import '../go_installation_icons_icons.dart';

Widget getInstallationIcon(
    InstallationTypes installationTypes, bool isMainList) {
  return SizedBox(
    width: isMainList ? double.infinity : null,
    child: Padding(
      padding: const EdgeInsets.all(0),
      child: Icon(
        GoInstallationIcons.getIcon(installationTypes.config.icon),
        color: isMainList
            ? Colors.white
            : (installationTypes?.config?.color != null)
                ? getColor(installationTypes?.config?.color)
                : Colors.grey,
      ),
    ),
  );
}

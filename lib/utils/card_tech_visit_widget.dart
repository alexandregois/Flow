import 'package:auto_size_text/auto_size_text.dart';
import 'package:flow_flutter/controller/installation_send_controller.dart'
    as send;
import 'package:flow_flutter/go_installation_icons_icons.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/models/technical_visit_list.dart';
import 'package:flow_flutter/models/technical_visit_state_enum.dart';
import 'package:flow_flutter/utils/technichal_visit_stage.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/pair_widget.dart';
import 'package:flutter/material.dart';

class CardTechVisitTile extends StatelessWidget {
  final Installation installation;
  final send.SendingInstallation sendingInstallationState;
  const CardTechVisitTile(
      {Key key,
      @required this.installation,
      @required this.sendingInstallationState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 42, 0),
          child: PairWidget.horizontal(
            child1: Expanded(
              child: ListTile(
                leading: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Icon(
                      GoInstallationIcons.getIcon(installation
                          .installationType.installationTypes.config.icon),
                      color: getColor(installation
                          .installationType.installationTypes.config.color),
                      size: 30,
                    )),

                title: Text(
                    installation?.installationType?.installationTypes?.config
                            ?.features
                            ?.firstWhere(
                                (element) => element?.registerConfig != null,
                                orElse: () {
                              return null;
                            })
                            ?.registerConfig
                            ?.currentInfo
                            ?.plate ??
                        'Visita Técnica',
                    style: TextStyle(
                      fontSize: 15,
                    )),
                subtitle: _getAgreementSubTitle(installation, null),
                // trailing: IconButton(
                //   icon: Icon(Icons.delete),
                //   onPressed: sendingInstallationState == null ||
                //           installation.installationType.installationTypes
                //                   .pictureUploadCompleted ==
                //               null
                //       ? () {
                //           showDialog(
                //               context: context,
                //               barrierColor:
                //                   Theme.of(context).colorScheme.error.withOpacity(0.8),
                //               builder: (_) {
                //                 return MyDialog(installation: installation);
                //               });
                //         }
                //       : null,
                // ),
              ),
            ),
            child2: Column(
              children: [

                installation?.visitType == "M"
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                        child: AutoSizeText(
                          " Manutenção ",
                          style: TextStyle(
                              fontSize: 16,
                              color: _getInstallationTypeColor(installation
                                  .installationType.installationTypes)),
                        ),
                      )
                    : (installation?.visitType == "U")
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                          child: AutoSizeText(
                            "Desinstalação",
                            style: TextStyle(
                                fontSize: 16,
                                color: _getInstallationTypeColor(installation
                                    .installationType.installationTypes)),
                          ),
                        )
                    : (installation?.visitType == "A") 
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                          child: AutoSizeText(
                            "   Atualização   ",
                            style: TextStyle(
                                fontSize: 16,
                                color: _getInstallationTypeColor(installation
                                    .installationType.installationTypes)),
                          ),
                        )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                        child: AutoSizeText(
                          "   Instalação   ",
                          style: TextStyle(
                              fontSize: 16,
                              color: _getInstallationTypeColor(installation
                                  .installationType.installationTypes)),
                        ),
                      ),
                Container(
                  decoration: BoxDecoration(
                      color: _getStatusColor(installation.technicalVisit),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: _getCurrentStatus(null, installation?.stage?.stage)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

_getCurrentStatus(TechnicalVisit technicalVisit, TechnicalVisitStage technicalVisitStage) {

  if (technicalVisit != null) {
    return Text(
      technicalVisit.visitState.name,
      style: TextStyle(color: Colors.white, fontSize: 13),
    );
  } else if (technicalVisitStage != null) {
    //Olhando estado do banco local
    switch (technicalVisitStage.id) {
      case 0:
        return Text(
          "Com Erro",
          style: TextStyle(color: Colors.white, fontSize: 13),
        );
        break;
      case 1:
        return Text(
          "Em Andamento",
          style: TextStyle(color: Colors.white, fontSize: 13),
        );
        break;
      case 2:
        return Text(
          "Enviando",
          style: TextStyle(color: Colors.white, fontSize: 13),
        );
        break;
      case 4:
        return Text(
          "Cancelada",
          style: TextStyle(color: Colors.white, fontSize: 13),
        );
        break;
      default:
    }
  }
}

_getStatusColor(TechnicalVisit technicalVisit) {
  if (technicalVisit != null) {
    if (technicalVisit.visitState == TechnicalVisitStateEnum.WAITING)
      return Colors.deepPurple;
    if (technicalVisit.visitState == TechnicalVisitStateEnum.SCHEDULED)
      return Color(0xFFf27800);
    if (technicalVisit.visitState == TechnicalVisitStateEnum.IN_PROGRESS)
      return Colors.blue;
    if (technicalVisit.visitState == TechnicalVisitStateEnum.COMPLETED)
      return Colors.green;
    if (technicalVisit.visitState == TechnicalVisitStateEnum.CANCELED)
      return Colors.grey;
    if (technicalVisit.visitState == TechnicalVisitStateEnum.CLOSE_AUTOMATIC)
      return Colors.red;
  } else {
    return Colors.blue;
  }
}

_getInstallationTypeColor(InstallationTypes installationType) {
  return HexColor.fromHex(installationType.config.color);
}

Widget _getAgreementSubTitle(
    Installation installation, TechnicalVisit technicalVisit) {
  if (installation != null) {
    return Text(installation?.agreementId?.toString() ?? "",
        style: TextStyle(
          fontSize: 14,
        ));
  } else {
    return Text(technicalVisit?.agreementId.toString() ?? "",
        style: TextStyle(
          fontSize: 14,
        ));
  }
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

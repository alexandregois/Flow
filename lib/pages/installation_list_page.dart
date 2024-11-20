import 'package:auto_size_text/auto_size_text.dart';
import 'package:dartx/dartx.dart';
import 'package:flow_flutter/controller/V2Controllers/tech_visit_list_controller.dart';
import 'package:flow_flutter/controller/installation_send_controller.dart'
    as send;
import 'package:flow_flutter/controller/installation_send_controller.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/models/reason_finish_technical_visit.dart';
import 'package:flow_flutter/repository/impl/equipment_test_bloc.dart';
import 'package:flow_flutter/repository/impl/http_requests.dart';
import 'package:flow_flutter/repository/impl/picture_plate_bloc.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/better_classes.dart';
import 'package:flow_flutter/utils/card_tech_visit_widget.dart';
import 'package:flow_flutter/utils/technichal_visit_stage.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/pair_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'installation/installation_requirements_page.dart';

class InstallationListPage extends StatefulWidget {
  final Function baseTechRefresh;
  final CompanyConfig companyConfig;
  final bool companyFilter;
  final TechVisitListController controller;

  InstallationListPage(
      {Key key,
      this.companyConfig,
      this.baseTechRefresh,
      this.companyFilter,
      @required this.controller})
      : super(key: key);

  @override
  InstallationListPageState createState() => InstallationListPageState();
}

class InstallationListPageState extends State<InstallationListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();

    widget.controller.syncInstallations();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: RefreshIndicator(
        onRefresh: () {
          context.provide<send.InstallationSendController>().start();
          return Future.value();
        },
        displacement: 20,
        child: StreamBuilder<List<Installation>>(
          stream: context.provide<InstallationRepository>().listen().map(
              (list) => list.sortedByDescending(
                  (installation) => installation.startDate ?? 0)),
          builder: (context, snapshot) {
            if (snapshot.data == null || snapshot.data.isEmpty) {
              return Container();
            }
            return Column(
              children: [
                _InstallationList(
                  companyFilter: widget.companyFilter,
                  companyConfig: widget.companyConfig,
                  installations: snapshot.data,
                ),
                // Divider(),
              ],
            );
          },
        ),
      ),
    );
  }

  bool get wantKeepAlive => true;
}

class _InstallationList extends StatefulWidget {
  final List<Installation> installations;
  final CompanyConfig companyConfig;
  final bool companyFilter;

  const _InstallationList({
    Key key,
    @required this.installations,
    @required this.companyConfig,
    @required this.companyFilter,
  }) : super(key: key);

  @override
  _InstallationListState createState() => _InstallationListState();
}

class _InstallationListState extends State<_InstallationList>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    widget.installations.forEach((installation) {
      if (installation.stage.stage == TechnicalVisitStage.FINISHED)
        context.provide<InstallationSendController>().start(installation.appId);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<send.InstallationSendState>(
        stream: context.provide<send.InstallationSendController>(),
        builder: (context, snapshot) {
          final installationSendState = snapshot.data;

          // return ListView.builder(
          //     itemCount: widget.installations.length,
          //     padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          //     itemBuilder: (BuildContext context, int index) {
          // return _InstallationCard(
          //   companyConfig: widget.companyConfig,
          //   sendingInstallationState: installationSendState
          //       ?.sendingInstallations
          //       ?.firstOrNullWhere((element) =>
          //           element.installationId ==
          //           widget.installations[index].appId),
          //   installation: widget.installations[index],
          // );
          //     });
          var list = _getInstallationCardList(installationSendState);
          // print(list.toString())
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            child: Column(
              children: [
                ...list,
                list.isNotEmpty ? Divider() : Container(),
              ],
            ),
          );
        });
  }

  @override
  bool get wantKeepAlive => true;

  List<Widget> _getInstallationCardList(installationSendState) {
    List<_InstallationCard> list = [];
    list = widget.installations
        .map(
          (installation) => (installation.company != null)
              ? (DenoxRequests.selectedCompany == null ||
                      installation.company.id ==
                          DenoxRequests.selectedCompany.id)
                  ? _InstallationCard(
                      companyFilter: widget.companyFilter,
                      companyConfig: widget.companyConfig,
                      sendingInstallationState: installationSendState
                          ?.sendingInstallations
                          ?.firstWhere(
                        (element) =>
                            element.installationId == installation.appId,
                        orElse: () => null,
                      ),
                      installation: installation,
                    )
                  : null
              : _InstallationCard(
                  companyFilter: widget.companyFilter,
                  companyConfig: widget.companyConfig,
                  sendingInstallationState:
                      installationSendState?.sendingInstallations?.firstWhere(
                    (element) => element.installationId == installation.appId,
                    orElse: () => null,
                  ),
                  installation: installation,
                ),
        )
        .toList();

    list.removeWhere((element) => element == null);
    return list;
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

class _InstallationCard extends StatelessWidget {
  final Installation installation;
  final CompanyConfig companyConfig;
  final bool companyFilter;
  final send.SendingInstallation sendingInstallationState;
  static final _format = DateFormat('E dd/MM, HH:mm', 'pt_BR');

  const _InstallationCard({
    Key key,
    @required this.companyConfig,
    @required this.installation,
    this.sendingInstallationState,
    @required this.companyFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PicturePlateBloc picturePlateBloc = Provider.of<PicturePlateBloc>(context);
    EquipmentTestBloc equipmentTestBloc =
        Provider.of<EquipmentTestBloc>(context);
    var theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
        onLongPress: () {
          context
              .provide<send.InstallationSendController>()
              .start(installation.appId);
        },
        onTap: () {
          picturePlateBloc.remove();
          equipmentTestBloc.remove();

          print(
              'Clicked on installation ${installation.appId}//${installation.cloudId}//${installation.installationType.installationTypes}\n//${installation.company.name}');

          if (sendingInstallationState == null) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => InstallationRequirementsPage(
                      isContinuation: true,
                      installation: installation,
                      installationTypes:
                          installation.installationType.installationTypes,
                      // companyConfig.installationTypes
                      //     .firstOrNullWhere((element) =>
                      //         element.config.vehicleType.name ==
                      //         installation.installationType.name),
                    )));
            //     .then((value) {
            //   if (value is Installation) {
            //     context
            //         .provide<InstallationSendController>()
            //         .start(value.appId);
            //   }
            // });
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CardTechVisitTile(
              installation: installation,
              sendingInstallationState: sendingInstallationState,
            ),
            //  ListTile(
            //     leading: Container(
            //                       decoration: BoxDecoration(
            //                         color: Colors.white,
            //                         shape: BoxShape.circle,
            //                         boxShadow: [
            //                           BoxShadow(
            //                               blurRadius: 10,
            //                               color: _getInstallationTypeColor(
            //                                   installation
            //             ?.installationType?.installationTypes),
            //                               spreadRadius: 2)
            //                         ],
            //                       ),
            //                       child: CircleAvatar(
            //                         backgroundColor: _getInstallationTypeColor(
            //                             installation
            //             ?.installationType?.installationTypes),
            //                         foregroundColor: Colors.white,
            //                         child: _getInstallationIcon(
            //                             installation
            //             ?.installationType?.installationTypes),
            //                       ),
            //                     ),
            //     title: Text(installation
            //             ?.installationType?.installationTypes?.config?.features
            //             ?.firstOrNullWhere(
            //                 (element) => element?.registerConfig != null)
            //             ?.registerConfig
            //             ?.currentInfo
            //             ?.plate ??
            //         'Visita Técnica'),
            //     subtitle: _getSubtitle(),
            //     trailing: IconButton(
            //       icon: Icon(Icons.delete),
            //       onPressed: sendingInstallationState == null || installation.installationType.installationTypes.pictureUploadCompleted == null
            //           ? () {
            //               // _deleteInstallation(context);
            //               showDialog(
            //                   context: context,
            //                   barrierColor: Theme.of(context)
            //                       .colorScheme
            //                       .error
            //                       .withOpacity(0.8),
            //                   builder: (_) {
            //                     return MyDialog(installation: installation);
            //                   });
            //             }
            //           : null,
            //     ),
            //   ),
            if (installation.stage.message != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Material(
                  color: theme.colorScheme.error,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: ListTile(
                    title: AutoSizeText(
                      "Ocorreu um erro no envio, por favor clique e segure neste card para tentar enviar novamente sua instalação\n" +
                          installation.stage.message,
                      maxLines: 5,
                      minFontSize: 12,
                      style: theme.primaryTextTheme.bodySmall,
                    ),
                    // trailing: IconButton(
                    //   onPressed: () {
                    //     widget.tracker.qrCodeError = null;
                    //   },
                    //   icon: Icon(
                    //     Icons.close,
                    //     color: theme.colorScheme.onError,
                    //   ),
                    // ),
                  ),
                ),
              ),
            SizedBox(
              height: 4,
            ),
            if (sendingInstallationState?.step == send.Step.uploadingPictures)
              LinearProgressIndicator(
                value: sendingInstallationState.currentProgress /
                    sendingInstallationState.maxProgress,
                valueColor: AlwaysStoppedAnimation(
                    (installation.stage.message != null)
                        ? theme.colorScheme.error
                        : _getBackgroundColor()),
              )
            else
              LinearProgressIndicator(
                value: installation.progress,
                valueColor: AlwaysStoppedAnimation(
                    (installation.stage.message != null)
                        ? theme.colorScheme.error
                        : Colors.green),
              ),
            // if (installation.stage.message == null &&
            //     sendingInstallationState?.step != send.Step.uploadingPictures)
            // Container(
            //   color: _getBackgroundColor(),
            //   height: 2,
            // ),

            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: PairWidget.horizontal(
                    child1: Expanded(
                      child: ListTile(
                        dense: true,
                        title: Text("Data de início"),
                        subtitle: installation.startDate == null
                            ? '-'
                            : Text(
                                _format.format(installation.startDate),
                              ),
                      ),
                    ),
                    child2: installation.finishDate != null
                        ? Expanded(
                            child: ListTile(
                              dense: true,
                              title: Text("Data de fim:"),
                              subtitle: Text(
                                _format.format(installation.finishDate),
                              ),
                            ),
                          )
                        : (installation.company != null && !companyFilter)
                            ? Padding(
                                padding: EdgeInsets.only(right: 42),
                                child: Container(
                                  height: 50,
                                  width: 100,
                                  child: Image.network(
                                    installation.company.logoURL
                                            .contains("http://")
                                        ? installation.company.logoURL
                                            .replaceFirst("http://", "https://")
                                        : installation.company.logoURL,
                                  ),
                                ),
                              )
                            : null,
                  ),
                ),
                Visibility(
                  visible: true,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4, right: 4),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.grey[600],
                        ),
                        onPressed: sendingInstallationState == null ||
                                installation.installationType.installationTypes
                                        .pictureUploadCompleted ==
                                    null
                            ? () {
                                showDialog(
                                    context: context,
                                    barrierColor: Theme.of(context)
                                        .colorScheme
                                        .error
                                        .withOpacity(0.8),
                                    builder: (_) {
                                      return MyDialog(
                                          installation: installation);
                                    });
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // if (installation.finishDate != null)
            //   ListTile(
            //     dense: true,
            //     title: Text("Data de fim:"),
            //     subtitle: Text(
            //       _format.format(installation.finishDate),
            //     ),
            //   )
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (installation.stage.stage) {
      case TechnicalVisitStage.CLOSED:
      // case TechnicalVisitStage.DATA_UPLOADED:
      case TechnicalVisitStage.FINISHED:
        return Colors.green;

      case TechnicalVisitStage.HAS_ERRORS:
        return Colors.red;

      default:
        return Colors.blueGrey;
    }
  }
}

class MyDialog extends StatefulWidget {
  final Installation installation;
  MyDialog({Key key, this.installation}) : super(key: key);

  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  TextEditingController controller = TextEditingController();
  int selectReasonId;

  bool dataLoaded = false;

  ReasonFinishTechnicalVisitListing reasonResult;
  LatLong currentLatLong;

  Future<void> getData() async {
    var reasonResult = await context
        .provide<RequestsRepository>()
        .getReasonFinishTechnicalVisit();

    var currentLatLong =
        await context.provide<LocationRepository>().getCurrentLatLong();

    setState(() {
      this.reasonResult = reasonResult;
      this.currentLatLong = currentLatLong;
      this.dataLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return ShowUp.tenth(
      duration: 200,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        title: Text('CUIDADO'),
        content: dataLoaded
            ? SingleChildScrollView(
                child: Column(children: [
                  Text(
                    ('Você está prestes a cancelar e apagar essa Visita Técnica do seu aplicativo.\n\n' +
                        "Ao apagar esta instalação, todos os dados e fotos referentes a ela serão apagados.\n\nEstá ação não pode ser desfeita." +
                        " \n\nDeseja cancelar a visita técnica?\n"),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  DropdownSearch<String>(
                    // selectedItem: reasonResult.reasons[0].name,
                    popupProps: PopupProps.menu(
                      // showSearchBox: true,
                      showSelectedItems: true,
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: "Motivo",
                        hintStyle: theme.textTheme.titleLarge.copyWith(color: theme.colorScheme.primary),
                      ),
                    ),
                    clearButtonProps: ClearButtonProps(isVisible: false),
                    items: [
                      ...reasonResult.reasons.map((reason) {
                        return reason.name;
                      })
                    ],
                    onChanged: (value) {
                      selectReasonId = reasonResult.reasons
                          .firstWhere((element) => element.name == value)
                          .id;
                      print(selectReasonId);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor selecione um motivo';
                      } else {
                        return null;
                      }
                    },
                  ),
                  // SearchableDropdown.single(
                  //   searchHint: Text(
                  //     "Motivo",
                  //     style: theme.textTheme.headline6
                  //         .copyWith(color: theme.colorScheme.primary),
                  //   ),
                  //   closeButton: "Fechar",
                  //   label: Text(
                  //     "Motivo",
                  //     style: theme.textTheme.subtitle1
                  //         .copyWith(color: theme.colorScheme.primary),
                  //   ),
                  //   isExpanded: true,
                  //   // value: _state.text,
                  //   displayClearIcon: false,
                  //   onChanged: (value) async {
                  //     setState(() {
                  //       selectReasonId = value;
                  //     });
                  //   },
                  //   items: [
                  //     ...reasonResult.reasons.map((reason) {
                  //       return DropdownMenuItem(
                  //         child: Text(reason.name),
                  //         value: reason.id,
                  //       );
                  //     })
                  //   ],
                  //   validator: (value) {
                  //     if (value == null) {
                  //       return 'Por favor selecione um motivo';
                  //     } else {
                  //       return null;
                  //     }
                  //   },
                  // ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    // style: TextStyle(color: Colors.white),
                    controller: controller,
                    onChanged: (value) {
                      setState(() {});
                    },
                    minLines: 3,
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        gapPadding: 2,
                      ),
                      labelText: 'Observação',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                    ),
                  )
                ]),
              )
            : Center(
                child: SpinKitWave(
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
              ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text("Não"),
          ),
          TextButton(
            child: Text(
              "Sim",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: (selectReasonId != null)
                    ? Theme.of(context).colorScheme.error
                    : Colors.grey,
              ),
            ),
            onPressed: (selectReasonId != null)
                ? () async {
                    BetterInt valueReturned = await context
                        .provide<RequestsRepository>()
                        .cancelInstallation(
                            widget.installation.cloudId,
                            selectReasonId,
                            controller.text != null ? controller.text : "",
                            currentLatLong.latitude,
                            currentLatLong.longitude);
                    if (valueReturned.intValue != 1 &&
                        valueReturned.intValue != 237) {
                      Navigator.of(context).pop();
                      errorDialog(context, valueReturned.errorMessage);
                    } else {
                      context
                          .provide<InstallationRepository>()
                          .deleteInstallations([widget.installation]);

                      Navigator.of(context).pop();
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }

  void errorDialog(BuildContext context, String texto) {
    showDialog(
      context: context,
      barrierColor: Colors.red.withOpacity(0.8),
      builder: (context) => ShowUp.tenth(
        duration: 200,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          title: Text("Erro"),
          content: Text(texto),
        ),
      ),
    );
  }
}

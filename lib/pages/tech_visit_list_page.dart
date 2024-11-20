import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dartx/dartx.dart';
import 'package:flow_flutter/go_installation_icons_icons.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/models/technical_visit_list.dart';
import 'package:flow_flutter/models/technical_visit_state_enum.dart';
import 'package:flow_flutter/pages/installation/tech_visit_requirements_page.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/no_glow_behavior.dart';
import 'package:flow_flutter/utils/util_extensions.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/advanced_state.dart';
import 'package:flow_flutter/widget/pair_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class TechnicalVisitListPage extends StatefulWidget {
  final bool isHistory;
  final bool companyFilter;
  final String filter;

  const TechnicalVisitListPage(
      {Key key,
      @required this.isHistory,
      @required this.companyFilter,
      this.filter})
      : super(key: key);
  @override
  _TechnicalVisitListPageState createState() => _TechnicalVisitListPageState();
}

class GlobalData {
  static String visitType;
}

class _TechnicalVisitListPageState extends AdvancedState<TechnicalVisitListPage>
    with AutomaticKeepAliveClientMixin {
  ScrollController controller;
  Future<TechnicalVisitList> _request;
  InstallationRepository installationRepository;
  List<TechnicalVisit> technicalVisits;
  int nextPage;
  bool scrollRefresh;
  bool isLoading;
  List<Installation> installationsList;

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    technicalVisits = [];
    nextPage = 2;
    scrollRefresh = false;
    isLoading = false;
    installationRepository = context.provide<InstallationRepository>();
    // _refresh();
    installationRepository.getInstallations().then((installations) async {
      installationsList = installations;
    });

    _request = context.provide<RequestsRepository>().getTechnicalVisit(
        widget.isHistory,
        filter: widget.filter,
        companyFilter: widget.companyFilter,
        page: 1);
    controller = new ScrollController()..addListener(_scrollListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  _refresh() {
    setState(() {
      scrollRefresh = false;
      technicalVisits = [];
      nextPage = 2;
      installationRepository.getInstallations().then((installations) async {
        installationsList = installations;
      });
      _request = context.provide<RequestsRepository>().getTechnicalVisit(
          widget.isHistory,
          filter: widget.filter,
          companyFilter: widget.companyFilter,
          page: 1);
    });
  }

  Future<void> loadTechVisitList(
      AsyncSnapshot<TechnicalVisitList> snapshot) async {
    // if (installationRepository != null)
    // await installationRepository.getInstallations().then((installations) async {
    //   installationsList = installations;
    // });
    snapshot.data.technicalVisits.forEach((technicalVisit) {

      GlobalData.visitType = technicalVisit?.visitType;

      if (widget.isHistory) {
        if (!technicalVisits.contains(technicalVisit))
          technicalVisits.add(technicalVisit);
      } else {
        int result = this.installationsList.indexWhere(
            (installation) => installation.cloudId == technicalVisit.id);
      
        if (!technicalVisits.contains(technicalVisit) && result == -1) {

          // if (technicalVisit.visitState == TechnicalVisitStateEnum.COMPLETED &&
          //     technicalVisit.installationTypes.pictureUploadCompleted ==
          //         false) {

          if (technicalVisit.installationTypes.pictureUploadCompleted ==
                  false) {
            printDebug("Finalizado com foto pendente, deveria estar no APP = " +
                technicalVisit.id.toString());
          } else {
            technicalVisits.add(technicalVisit);
          }
        } else {
          printDebug("Nao add visita na lista pois ja esta no app com id = " +
              technicalVisit.id.toString());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!scrollRefresh) _refresh();

    return Scaffold(
      body: RefreshIndicator(
        displacement: 20,
        onRefresh: () async {
          _refresh();
          return true;
        },
        child: FutureBuilder<TechnicalVisitList>(
            future: _request,
            builder: (BuildContext context,
                AsyncSnapshot<TechnicalVisitList> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SpinKitWave(
                    color: theme.colorScheme.secondary,
                    size: 30,
                  ),
                );
              }
              if (snapshot.hasData) {
                if (!scrollRefresh) loadTechVisitList(snapshot);

                scrollRefresh = false;
                return _buildTechnicalVisitList(
                    context, technicalVisits, widget.isHistory);
              } else {

                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ShowUp.fifth(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Ops, saiu algo errado.\nVerifique sua conexão com a internet e tente novamente!",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      ShowUp.fifth(
                        delay: 200,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(),
                              backgroundColor: theme.colorScheme.secondary),
                          child: Text(
                            "Tentar novamente",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: _refresh,
                        ),
                        // child: RaisedButton(
                        //   shape: StadiumBorder(),
                        //   color: theme.accentColor,
                        //   child: Text(
                        //     "Tentar novamente",
                        //     style: TextStyle(color: Colors.white),
                        //   ),
                        //   onPressed: _refresh,
                        // ),
                      ),
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }

  Widget _buildTechnicalVisitList(BuildContext context, List<TechnicalVisit> techVisits, bool isHistory) {
    if (isHistory)
      techVisits.sort((a, b) {
        if (b.visitState == TechnicalVisitStateEnum.IN_PROGRESS) return 1;
        if (b.visitFinishDate == null || a.visitFinishDate == null) {
          return b.forecastStartDate.compareTo(a.forecastStartDate);
        }
        return b.visitFinishDate.compareTo(a.visitFinishDate);
      });
    else
      techVisits.sort((a, b) {
        if (b.visitFinishDate != null) return 1;
        if (b.visitState == TechnicalVisitStateEnum.SCHEDULED) return -1;
        if (b.visitState == TechnicalVisitStateEnum.IN_PROGRESS) return -1;

        return a.forecastStartDate.compareTo(b.forecastStartDate);
      });
    if (techVisits.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.6),
            child: ShowUp.half(
              child: Center(
                child: Text(
                  isHistory
                      ? "Nenhuma visita encontrada no histórico"
                      : installationsList != null
                          ? installationsList.length == 0
                              ? "Você não possui nenhuma visita pendente."
                              : ""
                          : "Você não possui nenhuma visita pendente.",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        )
      );
    }
    return ScrollConfiguration(
      behavior: NoGlowBehavior(),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ShowUp(
              offset: 0.1,
              key: ValueKey("list"),
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                itemCount: techVisits.length,
                itemBuilder: (context, index) {
                  var technicalVisit = techVisits[index];
                  if (index == techVisits.length - 1)
                    return Column(
                      children: [
                        _MaintenanceCard(
                          companyFilter: widget.companyFilter,
                          technicalVisit: technicalVisit,
                          refresh: _refresh,
                          isHistory: isHistory,
                        ),
                        isLoading
                            ? SpinKitWave(
                                color: Theme.of(context).colorScheme.secondary,
                                size: 30,
                              )
                            : SizedBox(height: 200),
                      ],
                    );
                  return _MaintenanceCard(
                    companyFilter: widget.companyFilter,
                    technicalVisit: technicalVisit,
                    refresh: _refresh,
                    isHistory: isHistory,
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  bool get wantKeepAlive => true;

  _scrollListener() async {
    if (controller.position.extentAfter < 300 && !isLoading) {
      isLoading = true;

      var result = await context
          .provide<RequestsRepository>()
          .getTechnicalVisit(widget.isHistory,
              filter: widget.filter,
              companyFilter: widget.companyFilter,
              page: nextPage);

      setState(() {
        scrollRefresh = true;
        result.technicalVisits.forEach((e) {
          print(nextPage);
          if (!technicalVisits.contains(e)) technicalVisits.add(e);
        });
        nextPage += 1;
        isLoading = false;
      });
    }
  }
}

class _MaintenanceCard extends StatelessWidget {
  final TechnicalVisit technicalVisit;
  final RefreshCallBack refresh;
  final bool companyFilter;
  final bool isHistory;
  static final _format = DateFormat('E dd/MM, HH:mm', 'pt_BR');

  const _MaintenanceCard({
    Key key,
    @required this.isHistory,
    @required this.technicalVisit,
    this.refresh,
    @required this.companyFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Installation installation;
    final theme = Theme.of(context).copyWith(
      dividerColor: Colors.transparent,
      accentColor: Colors.black,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        child: InkWell(
            borderRadius: const BorderRadius.all(
              Radius.circular(12),
            ),
            //onLongPress: () {enviar},
            onTap: () {},
            child: Theme(
              data: theme,
              child: ListTileTheme(
                dense: true,
                child: ExpansionTile(
                  tilePadding: EdgeInsets.only(right: 8),
                  title: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: PairWidget.horizontal(
                          child1: Expanded(
                            child: ListTile(
                              leading: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 8, 0, 0),
                                  child: Icon(
                                    GoInstallationIcons.getIcon(technicalVisit
                                        .installationTypes.config.icon),
                                    color: getColor(technicalVisit
                                        .installationTypes.config.color),
                                    size: 30,
                                  )),
                              title: _getTitle(technicalVisit),
                              subtitle: _getSubTitle(technicalVisit),
                              /* Deletar Manutenção, se precisar descomentar e implementar
                                    trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: sendingInstallationState == null
                                        ? () {
                                            _deleteInstallation(context);
                                          }
                                        : null,
                                  ), */
                            ),
                          ),
                          child2: Column(
                            children: [
                              _getInstallationType(technicalVisit),
                              Container(
                                decoration: BoxDecoration(
                                    color: _getStatusColor(technicalVisit),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    child: _getCurrentStatus(technicalVisit)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      /* Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: */
                      technicalVisit.customer.name != null
                          ? Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Row(
                                children: [Text(technicalVisit.customer.name)],
                              ),
                            )
                          : SizedBox(),

                      Stack(children: [
                        PairWidget.horizontal(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          child1: Expanded(
                            child: ListTile(
                              dense: true,
                              title: technicalVisit.visitFinishDate == null
                                  ? Text("Data de início")
                                  : Text("Data da finalização"),
                              subtitle: technicalVisit.visitFinishDate != null
                                  ?
                                  //Se possui data de finalizacao
                                  Text(
                                      _format.format(
                                          technicalVisit.visitFinishDate),
                                    )
                                  :
                                  //Senao verifica se possui data de start
                                  technicalVisit.forecastStartDate == null
                                      ? '-'
                                      : Text(
                                          _format.format(
                                              technicalVisit.forecastStartDate),
                                        ),
                            ),
                          ),
                          child2: companyFilter
                              ? null
                              : technicalVisit.company != null
                                  ? Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 0, 40),
                                      child: Container(
                                        width: 100,
                                        height: 30,
                                        child: Image.network(
                                          _getCompanyLogo(
                                              technicalVisit.company.logoURL,
                                              false),
                                        ),
                                      ),
                                    )
                                  : null,
                        ),
                        if (isHistory == false)
                          Visibility(
                            visible: true,
                            child: Positioned(
                              bottom: 0,
                              right: technicalVisit.visitState ==
                                      TechnicalVisitStateEnum.SCHEDULED
                                  ? 15
                                  : 8,
                              // alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: TextButton(
                                  child: Text(
                                    _getStartButtonText(technicalVisit),
                                    style: TextStyle(
                                        color: context.theme.primaryColor),
                                  ),
                                  onPressed: () async => _confirmationPage(
                                      context, technicalVisit),
                                ),
                              ),
                            ),
                          ),
                      ]),
                      //),
                      /*LinearProgressIndicator(
                                value: 0 / 100,
                                valueColor:
                                    AlwaysStoppedAnimation(_getBackgroundColor(technicalVisit)),
                              ),*/
                    ],
                  ),
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          color: _getInstallationTypeColor(
                              technicalVisit.installationTypes),
                          height: 2,
                        ),
                        if (technicalVisit.mainDevice != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                            child: PairWidget.horizontal(
                              child1: Expanded(
                                child: ListTile(
                                  title: Text("Equi. Principal"),
                                  subtitle:
                                      Text(_getSubDescription(technicalVisit)),
                                ),
                              ),
                              child2: Expanded(
                                child: ListTile(
                                  title: _getLocal(technicalVisit),
                                  //Text(technicalVisit.installationType.name),
                                  // subtitle:
                                ),
                              ),
                            ),
                          ),
                        if (technicalVisit.visitReason != null)
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: ListTile(
                              //isThreeLine: true,
                              title: Text("Motivo"),
                              subtitle: AutoSizeText(
                                technicalVisit.visitReason,
                                maxLines: 10,
                                minFontSize: 12,
                              ),
                            ),
                          ),
                        // isHistory
                        //     ? Container()
                        //     : Align(
                        //         alignment: Alignment.bottomRight,
                        //         child: Padding(
                        //           padding:
                        //               const EdgeInsets.fromLTRB(8, 0, 4, 4),
                        //           child: technicalVisit.visitState == 3
                        //               ? null
                        //               : FlatButton(
                        //                   onPressed: () async =>
                        //                       _confirmationPage(
                        //                           context, technicalVisit),
                        //                   child: _getStartButtonText(
                        //                       technicalVisit),
                        //                 ),
                        //         ),
                        //       ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  Widget _getInstallationType(TechnicalVisit technicalVisit) {
    if (technicalVisit?.visitType == "M") {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
        child: AutoSizeText(
          " Manutenção ",
          style: TextStyle(
              fontSize: 16,
              color:
                  _getInstallationTypeColor(technicalVisit.installationTypes)),
        ),
      );
    } else if (technicalVisit?.visitType == "U") {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
        child: AutoSizeText(
          "Desinstalação",
          style: TextStyle(
              fontSize: 16,
              color:
                  _getInstallationTypeColor(technicalVisit.installationTypes)),
        ),
      );
    } else if(technicalVisit?.visitType == "A") {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
        child: AutoSizeText(
          "Atualização",
          style: TextStyle(
              fontSize: 16,
              color:
                  _getInstallationTypeColor(technicalVisit.installationTypes)),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
        child: AutoSizeText("   Instalação   ",
            style: TextStyle(
                fontSize: 16,
                color: _getInstallationTypeColor(
                    technicalVisit.installationTypes))),
      );
    }
  }

  void callback(BuildContext context) {
    Navigator.of(context).pop();
  }

  _getInstallationTypeColor(InstallationTypes installationType) {
    return HexColor.fromHex(installationType.config.color);
  }

  _getBackgroundColor(TechnicalVisit technicalVisit) {
    return Colors.blue;
  }

  _getStatusColor(TechnicalVisit technicalVisit) {
    if (technicalVisit?.visitType == "M") {
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
    } else if (technicalVisit?.visitType == "U") {
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
    } else if (technicalVisit?.visitType == "I") {
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
    }
  }

  _getTitle(TechnicalVisit technicalVisit) {
    if (technicalVisit.visitType == "M")
      return Text(technicalVisit?.localInfo?.identifier ?? "-------",
          style: TextStyle(
            fontSize: 15,
          ));
    else if (technicalVisit.visitType == "U")
      return Text(technicalVisit?.localInfo?.identifier ?? "-------",
          style: TextStyle(
            fontSize: 15,
          ));
    else if (technicalVisit.visitType == "I")
      return Text(technicalVisit?.localInfo?.identifier ?? "-------",
          style: TextStyle(
            fontSize: 15,
          ));
  }

  _getSubTitle(TechnicalVisit technicalVisit) {
    return Text(technicalVisit?.agreementId.toString() ?? "",
        style: TextStyle(
          fontSize: 14,
        ));
  }

  _getCurrentStatus(TechnicalVisit technicalVisit) {
    return Text(
      technicalVisit.visitState.name,
      style: TextStyle(color: Colors.white, fontSize: 13),
    );
  }

  _getLocal(TechnicalVisit technicalVisit) {
    String marca = technicalVisit.localInfo?.brandName ?? "";
    String modelo = technicalVisit.localInfo?.modelName ?? "";
    String ano = "";
    if (technicalVisit.localInfo?.year != null)
      ano += technicalVisit.localInfo?.year.toString() + "/";
    if (technicalVisit.localInfo?.modelYear != null)
      ano += technicalVisit.localInfo?.modelYear.toString();
    /* String ano = technicalVisit.localInfo?.year.toString() ??
                                                                                      "" + technicalVisit.localInfo?.modelYear.toString() ??
                                                                                      ""; */
    return AutoSizeText(
      technicalVisit.installationTypes.name +
          "\n" +
          technicalVisit.installationTypes.config.features.count().toString() +
          " passos\n" +
          marca +
          " " +
          modelo +
          "\n" +
          ano +
          "\n",
      minFontSize: 12,
      maxLines: 4,
    );
  }

// OUTDATED METHOD
  // _getInstallationDesc(InstallationType e) {
  //   //futuramente adicionar mais funcionalidades (mais ids) e trocar icones para os presentes na cloud
  //   if (e == null)
  //     return Row(children: [
  //       Icon(
  //         Icons.help,
  //         color: Colors.grey,
  //       ),
  //       SizedBox(width: 12),
  //       Text("---------")
  //     ]);
  //   switch (e.id) {
  //     case 1:
  //       return Row(children: [
  //         Icon(
  //           FlowIcons.car_side,
  //           color: Colors.grey,
  //         ),
  //         SizedBox(width: 12),
  //         Text(e.name)
  //       ]);
  //       break;
  //     case 2:
  //       return Row(children: [
  //         Icon(
  //           FlowIcons.motorcycle,
  //           color: Colors.grey,
  //         ),
  //         SizedBox(width: 12),
  //         Text(e.name)
  //       ]);
  //       break;
  //     case 3:
  //       return Row(children: [
  //         Icon(
  //           FlowIcons.truck,
  //           color: Colors.grey,
  //         ),
  //         SizedBox(width: 12),
  //         Text(e.name)
  //       ]);
  //       break;
  //     case 7:
  //       return Row(children: [
  //         Icon(
  //           FlowIcons.network,
  //           color: Colors.grey,
  //         ),
  //         SizedBox(width: 12),
  //         Text(e.name)
  //       ]);
  //       break;
  //     case 8:
  //       return Row(children: [
  //         Icon(
  //           FlowIcons.network,
  //           color: Colors.grey,
  //         ),
  //         SizedBox(width: 12),
  //         Text(e.name)
  //       ]);
  //       break;
  //     default:
  //       return Row(children: [
  //         Icon(
  //           Icons.help,
  //           color: Colors.grey,
  //         ),
  //         SizedBox(width: 12),
  //         Text("-----")
  //       ]);
  //   }
  // }

  void myCallback(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  void _confirmationPage(context, TechnicalVisit technicalVisit) async {
    String tipo = (technicalVisit.visitType == 'U'
        ? "Desinstalação"
        : (technicalVisit.visitType == 'M')
            ? "Manutenção"
        : (technicalVisit.visitType == 'A')
            ? "Atualização"
            : "Instalação");

    // if (technicalVisit.visitState != 2) {
    //   Navigator.of(context)
    //       .push(MaterialPageRoute(builder: (ctx) => _loading(ctx)))
    //       .then((value) => refresh());
    // } else {
    showDialog(
      context: context,
      barrierColor: _getBackgroundColor(technicalVisit).withOpacity(0.8),
      builder: (context) => ShowUp.tenth(
        duration: 200,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(
              color: _getBackgroundColor(technicalVisit),
              width: 2,
            ),
          ),
          title: Text("Iniciar " + tipo),
          content: Text("Ao iniciar uma " +
              tipo +
              " ela será marcada como em andamento e a ação não poderá ser desfeita.\nDeseja continuar?"),
          actions: [
            TextButton(
              child: Text("Não"),
              onPressed: Navigator.of(context).pop,
            ),
            TextButton(
              child: Text(
                "Sim",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getBackgroundColor(technicalVisit),
                ),
              ),
              onPressed: () async {
                //checar na api se pode ou nao começar a instalação
                // if(erroNaAPI){ dialogo de erro }

                // TechnicalVisitEdit request = await getEditInfo(context);

                Navigator.of(context).pop();
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => TechVisitRequirementsPage(
                              companyId: technicalVisit.company.id,
                              techVisit: technicalVisit,
                              color: _getBackgroundColor(technicalVisit),
                            )))
                    .then((value) => refresh());
              },
            ),
            // FlatButton(
            //   onPressed: Navigator.of(context).pop,
            //   child: Text("Não"),
            // ),
            // FlatButton(
            //   child: Text(
            //     "Sim",
            //     style: TextStyle(
            //       fontWeight: FontWeight.bold,
            //       color: _getBackgroundColor(technicalVisit),
            //     ),
            //   ),
            //   onPressed: () async {
            //     //checar na api se pode ou nao começar a instalação
            //     // if(erroNaAPI){ dialogo de erro }

            //     // TechnicalVisitEdit request = await getEditInfo(context);

            //     Navigator.of(context).pop();
            //     Navigator.of(context)
            //         .push(MaterialPageRoute(
            //             builder: (context) => TechVisitRequirementsPage(
            //                   companyId: technicalVisit.company.id,
            //                   techVisit: technicalVisit,
            //                   color: _getBackgroundColor(technicalVisit),
            //                 )))
            //         .then((value) => refresh());
            //   },
            // ),
          ],
        ),
      ),
    );
    // }
  }

  _getStartButtonText(TechnicalVisit technicalVisit) {
    if (technicalVisit.visitState == TechnicalVisitStateEnum.SCHEDULED)
      return "Iniciar";
    else if (technicalVisit.visitState == TechnicalVisitStateEnum.IN_PROGRESS) {
      return "Recomeçar";
    } else if (technicalVisit.visitState == TechnicalVisitStateEnum.COMPLETED) {
      return "Recomeçar"; //direcionar para a aba de fotos direto
    }
    return "Iniciar";
  }

  String _getSubDescription(TechnicalVisit technicalVisit) {
    String brandname = (technicalVisit.mainDevice.brandName ?? "");
    String model = (technicalVisit.mainDevice.model ?? "");
    String serial = (technicalVisit.mainDevice.serial ?? "---");
    String protocolo = (technicalVisit.mainDevice.modelTechName ?? "---");

    return brandname +
        " " +
        model +
        "\nSerial: " +
        serial +
        "\nProtocolo: " +
        protocolo;

    /* "\n" +
                                                      technicalVisit.mainDevice.modelName + */
  }

  String _getCompanyLogo(String logoURL, bool isSmallLogo) {
    String logo = logoURL.contains("http://")
        ? technicalVisit.company.logoURL.replaceFirst("http://", "https://")
        : technicalVisit.company.logoURL;
    if (isSmallLogo) {
      var index = logo.lastIndexOf('.');
      logo = logo.substring(0, index).trim() +
          "-small" +
          logo.substring(index).trim();
    }
    return logo;
  }
}

typedef RefreshCallBack = void Function();

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

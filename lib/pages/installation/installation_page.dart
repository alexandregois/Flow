import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dartx/dartx.dart';
import 'package:flow_flutter/controller/V2Controllers/checklist_controller_V2.dart';
import 'package:flow_flutter/controller/V2Controllers/custom_page_controller.dart';
import 'package:flow_flutter/controller/V2Controllers/devices_controller.dart';
import 'package:flow_flutter/controller/V2Controllers/devices_controller_V3.dart';
import 'package:flow_flutter/controller/V2Controllers/devices_new_controller.dart';
import 'package:flow_flutter/controller/V2Controllers/finish_controller.dart';
import 'package:flow_flutter/controller/V2Controllers/pictures_controller.dart';
import 'package:flow_flutter/controller/V2Controllers/register_controller.dart';
import 'package:flow_flutter/controller/V2Controllers/test_controller.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/pages/installation/checklist_page.dart';
import 'package:flow_flutter/pages/installation/equipments_page.dart';
import 'package:flow_flutter/pages/installation/equipments_pageV3.dart';
import 'package:flow_flutter/pages/installation/equipments_pagev2.dart';
import 'package:flow_flutter/pages/installation/installation_finish_page.dart';
import 'package:flow_flutter/pages/installation/pictures_to_take_page.dart';
import 'package:flow_flutter/pages/installation/register_info_page.dart';
import 'package:flow_flutter/pages/installation/test_page.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/animation/growup.dart';
import 'package:flow_flutter/utils/installation_step.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/lazy_stream_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final globalScaffoldKey = GlobalKey<ScaffoldState>();
String globalVisitType;

class InstallationPage extends StatefulWidget {
  final Installation installation;
  final InstallationTypes installationTypes;

  InstallationPage({
    Key key,
    this.installation,
    this.installationTypes,
  }) : super(key: key);

  @override
  _InstallationPageState createState() => _InstallationPageState();
}

class _InstallationPageState extends State<InstallationPage>
    with TickerProviderStateMixin {
  CustomPageController controller;
  Future _controllerInitialization;
  TabController tabController;
  List<String> titleList;
  String currentTitle;
  bool init = true;

  @override
  void initState() {
    super.initState();
    titleList = [];
    controller ??= CustomPageController(
      changeTabs,
      widget.installation,
      widget.installationTypes,
      context.provide<AppDataRepository>(),
      installationRepository: context.provide<InstallationRepository>(),
    );
    _controllerInitialization = controller.init(
        pictureRepository: context.provide<PictureToTakeRepository>(),
        checklistRepository: context.provide<ChecklistRepository>(),
        deviceRepository: context.provide<DevicesRepository>(),
        vehiclesRepository: context.provide<VehiclesRepository>(),
        requestsRepository: context.provide<RequestsRepository>(),
        testRepository: context.provide<TestRepository>());
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void changeTabs(int index) {
    tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return InheritedProvider.value(
      value: controller,
      child: FutureBuilder(
          future: _controllerInitialization,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return LazyStreamBuilder<List<InstallationPart>>(
                  stream: controller,
                  builder: (context, snapshot) {
                    if (init) {
                      tabController = TabController(
                          length: snapshot.data.length, vsync: this);
                      for (var installationPart in snapshot.data) {
                        titleList.add(installationPart.name);
                        print('Added ${installationPart.name}');
                      }
                      currentTitle = _getInstallationTitle();
                      // tabController.addListener(changeTitle);
                      init = false;
                    }
                    return
                      // DefaultTabController(
                      //   length: snapshot.data.length,
                      //   child:
                      Scaffold(
                        key: globalScaffoldKey,
                        appBar: AppBar(
                          // backgroundColor: Theme.of(context).colorScheme.primary,
                          centerTitle: true,
                          shape: appBarBottomShape,
                          flexibleSpace: gradientAppBar(),
                          title: AutoSizeText(
                            controller.isEditable
                                ? currentTitle
                                : 'Apenas leitura',
                            minFontSize: 8,
                          ),
                          bottom: _Tabs(
                            tabController: tabController,
                            controllers: snapshot.data,
                          ),
                        ),
                        body: _buildBody(snapshot),
                      );
                    // );
                  });
            }
            if (snapshot.hasError)
              return Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                ),
                body: Center(
                  child: Text(
                    "Erro ao carregar Instalação",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            else
              return Container();
          }),
    );
  }

  String _getPlate() {
    String plate = "";
    if (widget.installation.installationType.installationTypes.config != null) {
      var feature = widget
          .installation.installationType.installationTypes.config.features
          .firstOrNullWhere((element) => element.registerConfig != null);

      if (feature != null) {
        plate = feature?.registerConfig?.currentInfo?.plate ?? "";
      } else {
        plate = "Não identificado";
      }
    }
    if (plate == null || plate.isEmpty) {
      plate = "Não identificado";
    }
    return plate;
  }

  Widget _buildBody(AsyncSnapshot<List<InstallationPart>> snapshot) {
    return TabBarView(
      controller: tabController,
      children: [
        ...snapshot.data.map(
              (e) => _getPageForStep(e),
        ),
        // InstallationFinishPage(),
      ],
    );
  }

  // String _getTabName

  Widget _getPageForStep(InstallationPart step) {
    if (step is RegisterController) return RegisterInfoPage(controller: step);

    if (step is PicturesController) return PicturesToTakePage(controller: step);

    if (step is ChecklistControllerV2) return ChecklistPage(controller: step);

    if (step is DevicesController) return EquipmentsPage(controller: step);

    if (step is DevicesNewController) return EquipmentsPageV2(controller: step);

    if (step is DevicesControllerV3) return EquipmentsPageV3(controller: step);

    if (step is TestController) return TestPage(controller: step);

    if (step is FinishController) {
      globalVisitType = widget.installation.visitType;
      return InstallationFinishPage(controller: step);
    }

    return Container(
      child: Center(child: Text("NOT IMPLEMENTED YET")),
    );

    // throw Exception('Installation step not found for ${step.runtimeType}');
  }

  void changeTitle() {
    setState(() {
      currentTitle = titleList[tabController.index] + " - " + _getPlate();
    });
  }

  String _getInstallationTitle() {
    if (widget.installation.visitType != null) {
      if (widget.installation.visitType == 'I') {
        return "Instalação";
      } else if (widget.installation.visitType == 'U') {
        return "Desinstalação";
      } else if (widget.installation.visitType == 'M') {
        return "Manutenção";
      } else if (widget.installation.visitType == 'A') {
        return "Atualização";
      }
    }
    return "Instalação";
  }
}

class _Tabs extends StatefulWidget with PreferredSizeWidget {
  final List<InstallationPart> controllers;
  final TabController tabController;

  _Tabs({
    this.controllers,
    @required this.tabController,
  });

  @override
  Size get preferredSize => Size.fromHeight(50);

  @override
  __TabsState createState() => __TabsState();
}

class __TabsState extends State<_Tabs> {
  int centerPage = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: widget.tabController,
      indicatorSize: TabBarIndicatorSize.label,
      isScrollable: true,
      onTap: (index) {
        var installationController = widget.controllers.elementAt(0);

        if (installationController is RegisterController) {
          installationController.updateLocalInfoPlate();
        }
      },
      labelStyle: Theme.of(context)
          .primaryTextTheme
          .bodyLarge
          .copyWith(fontWeight: FontWeight.bold),
      unselectedLabelStyle: Theme.of(context)
          .primaryTextTheme
          .bodyLarge
          .copyWith(fontWeight: FontWeight.normal),
      unselectedLabelColor: Colors.white.withOpacity(0.6),

      tabs: [
        ...widget.controllers
            .mapIndexed((index, controller) => _buildTab(controller)),
      ],
    );
  }

  StreamBuilder<ReadyState> _buildTab(InstallationPart controller) {
    return LazyStreamBuilder<ReadyState>(
        stream: controller.readyStream,
        builder: (context, snapshot) {
          return Tab(
            icon: snapshot.data.status == ReadyStatus.ready
                ? GrowUp(
              duration: 500,
              curve: Curves.bounceOut,
              child: Icon(
                Icons.check,
                size: 14,
                color: Colors.green,
              ),
            )
                : snapshot.data.status == ReadyStatus.warning
                ? GrowUp(
              duration: 500,
              curve: Curves.bounceOut,
              child: Icon(
                Icons.warning_rounded,
                size: 14,
                color: Colors.yellow,
              ),
            )
                : Container(
              height: 14,
              width: 14,
            ),
            iconMargin: const EdgeInsets.all(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),

              child: Text("${controller.name}"),
            ),
          );
        });
  }
}

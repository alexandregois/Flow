import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dartx/dartx.dart';
import 'package:flow_flutter/models/company.dart';
import 'package:flow_flutter/models/exceptions.dart';
import 'package:flow_flutter/models/get_all_info.dart';
import 'package:flow_flutter/repository/impl/http_requests.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/services/get_all_info_service.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/no_glow_behavior.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/flow_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
//import 'package:package_info/package_info.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class FunctionalityPage extends StatefulWidget {
  @override
  FunctionalityPageState createState() => new FunctionalityPageState();
}

class FunctionalityPageState extends State<FunctionalityPage> {
  Future<GetAllInfo> _getAllInfo;
  Future<PackageInfo> _packageInfo;
  RequestsRepository requestsRepository;
  bool callback;
  var _packageInfoFuture = PackageInfo.fromPlatform();
  Companies _selectedCompany;

  @override
  void initState() {
    Timer.run(() {
      _refresh();
    });
    callback = false;
    requestsRepository = context.provide<RequestsRepository>();
    _selectedCompany = DenoxRequests.selectedCompany;

    super.initState();
  }

  Future<GetAllInfo> _refresh() async {
    _packageInfo ??= PackageInfo.fromPlatform();
    var appVersion = (await _packageInfo).buildNumber;

    setState(() {
      _getAllInfo = GetAllInfoService(
              appVersion, context.provide<RequestsRepository>(),
              appData: context.provide<AppDataRepository>(),
              devicesRepo: context.provide<DevicesRepository>(),
              vehiclesRepo: context.provide<VehiclesRepository>(),
              checklistRepo: context.provide<ChecklistRepository>(),
              picturesToTakeRepo: context.provide<PictureToTakeRepository>(),
              companyConfigRepo: context.provide<CompanyConfigRepository>())
          .performGetAllInfo(true);
    });
    return _getAllInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _getAppBar(context),
          SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              displacement: 10,
              child: Builder(builder: (context) => _buildBody(context)),
            ),
          ),
          // Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 5, 5, 5),
            child: FutureBuilder<PackageInfo>(
                future: _packageInfoFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData)
                    return Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "v${snapshot.data.version}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  else {
                    return Container();
                  }
                }),
          ),
        ],
      ),
    );
  }

  Widget _getAppBar(BuildContext context) {
    // var appBarTheme = Theme.of(context).appBarTheme;

    return Container(
      height: 170 + MediaQuery.of(context).viewInsets.top,
      decoration: BoxDecoration(
        // color: appBarTheme.color,
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Colors.blue[600],
              Colors.blue[900],
            ]),
        borderRadius: BorderRadius.only(
          bottomLeft: const Radius.circular(16),
          bottomRight: const Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Spacer(),
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.centerRight,
                  child: Image.network(
                    _selectedCompany.logoURL.contains("http://")
                        ? _selectedCompany.logoURL
                            .replaceFirst("http://", "https://")
                        : _selectedCompany.logoURL,
                  ),
                )
              ],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _getTitle(),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  PopupMenuButton<int> _buildPopupMenuButton(BuildContext context) {
    return PopupMenuButton<int>(
      icon: Icon(Icons.more_horiz),
      onSelected: (i) {
        switch (i) {
          case 0:
            _performLogout(context);
            break;
          case 1:
            _forceLogoutAllPlataforms(context);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          // PopupMenuItem<int>(
          //   value: 0,
          //   child: Text("Atualizar informações"),
          // ),
          PopupMenuItem<int>(
            value: 1,
            child: Text("Sair"),
          )
        ];
      },
    );
  }

  void _performLogout(BuildContext context) {
    Timer(300.milliseconds, () {
      performLogout(
          appData: Provider.of<AppDataRepository>(context, listen: false),
          devicesRepo: Provider.of<DevicesRepository>(context, listen: false),
          checklistRepo:
              Provider.of<ChecklistRepository>(context, listen: false),
          picturesRepo:
              Provider.of<PictureToTakeRepository>(context, listen: false),
          vehiclesRepo:
              Provider.of<VehiclesRepository>(context, listen: false));
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => LoginPage()),
      // );

      // MyAppState.of(context).reload();
    });
  }

  FutureBuilder<GetAllInfo> _getTitle() {
    return FutureBuilder<GetAllInfo>(
      future: _getAllInfo,
      builder: (BuildContext context, AsyncSnapshot<GetAllInfo> snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting &&
            (snapshot.hasData || snapshot.hasError)) {
          var subtitleText = snapshot.hasData
              ? "Olá, ${snapshot.data.name}"
              : "Erro ao carregar";

          if (snapshot.error is RefreshTokenException) {
            _performLogout(context);
          }

          var appBarTheme = Theme.of(context).appBarTheme;

          return Column(
            crossAxisAlignment:
                currentPlatform(context) == TargetPlatform.android
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ShowUp(
                offset: 0.05,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Image.asset('assets/image/Logo_Flow-03.png',
                        width: 70, height: 70),
                  ),
                  title: AutoSizeText(
                    subtitleText,
                    style: appBarTheme.textTheme.bodyText1,
                    maxLines: 1,
                    // textAlign: TextAlign.center,
                  ),
                  subtitle: AutoSizeText(
                    "${snapshot.data?.email ?? 'Por favor, tente novamente'}",
                    style: appBarTheme.textTheme.caption,
                    maxLines: 1,
                  ),
                  trailing: Theme(
                    data: ThemeData(
                      iconTheme: appBarTheme.iconTheme,
                    ),
                    child: _buildPopupMenuButton(context),
                  ),
                ),
              )
            ],
          );
        } else {
          return ShowUp.fifth(
            child: ListTile(
              title: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Atualizando",
                      style: Theme.of(context).primaryTextTheme.bodySmall,
                    ),
                    SizedBox(width: 8.0),
                    SpinKitWave(
                      color: Colors.white,
                      size: 10.0,
                    )
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    var showUpDelay = 200;

    return FutureBuilder(
        future: _getAllInfo,
        builder: (BuildContext context, AsyncSnapshot<GetAllInfo> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: SpinKitWave(
                color: Theme.of(context).colorScheme.secondary,
                size: 30,
              ),
            );
          if (snapshot.connectionState == ConnectionState.done) {
            List<Funcionality> _functionalities = [];

            if (snapshot.data.configuration.isTechnical) {
              _functionalities.add(new Funcionality(
                  "technicalVisit", "Visita Técnica", Icons.settings));
            }

            if (snapshot.data.configuration.isReadyAnswer) {
              _functionalities.add(new Funcionality(
                  "readyAnswer", "Pronta Resposta", Icons.settings_remote));
            }

            if (snapshot.data.configuration.isAsset) {
              _functionalities.add(new Funcionality(
                  "asset", "Gestão de Ativos", Icons.directions_bus));
            }

            var _funcionalitiesItemCard = _functionalities.asMap();

            try {
              if (_functionalities.length == 1 && !callback) {
                printDebug("onFuncionalityTap");
                _addCallback(_functionalities);
              }

              //   CompanyList aux = snapshot.data.configuration;
              //   var listCompanies = aux.companies.asMap();
              //   if (listCompanies.length == 1 && !callback) {
              //     printDebug("onCompanyTap");
              //     _addCallback(listCompanies);
              //   }

              //   // print(listCompanies.companies.asMap()[0].technicalname);
              return ScrollConfiguration(
                behavior: NoGlowBehavior(),
                child: ListView.builder(
                  // shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  // physics: ClampingScrollPhysics(),
                  itemCount: (_funcionalitiesItemCard.length / 2).round(),
                  // itemCount: (companyList.length / 2).round(),
                  itemBuilder: (context, index) {
                    return Column(children: [
                      Row(
                        children: [
                          Expanded(
                            child: ShowUp(
                              delay: showUpDelay += 100,
                              child: MenuCard(
                                _funcionalitiesItemCard[2 * index].name,
                                _funcionalitiesItemCard[2 * index].icon,
                                onTap: () {
                                  _onFuncionalityTap(context,
                                      _funcionalitiesItemCard[2 * index]);
                                },
                              ),
                            ),
                          ),
                          _funcionalitiesItemCard.containsKey(2 * index + 1)
                              ? Expanded(
                                  child: ShowUp(
                                    delay: showUpDelay += 100,
                                    child: MenuCard(
                                      _functionalities[2 * index + 1].name,
                                      _functionalities[2 * index + 1].icon,
                                      onTap: () {
                                        _onFuncionalityTap(
                                            context,
                                            _funcionalitiesItemCard[
                                                2 * index + 1]);
                                      },
                                    ),
                                  ),
                                )
                              : Expanded(child: Container()),
                        ],
                      ),
                    ]);
                  },
                ),
              );
            } catch (e) {
              print(e.toString());
              return LayoutBuilder(
                builder: (context, constraints) => ScrollConfiguration(
                  behavior: NoGlowBehavior(),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    // mainAxisAlignment: MainAxisAlignment.center,
                    // shrinkWrap: true,
                    child: Column(children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.wifi_off,
                          color: Colors.grey,
                          size: 100,
                        ),
                      ),
                    ]),
                  ),
                ),
              );
            }
          }
          return Center(
            child: SpinKitWave(
              color: Theme.of(context).colorScheme.secondary,
              size: 30,
            ),
          );
        });
  }

  Future<void> _onFuncionalityTap(
      BuildContext context, Funcionality funcionality) async {
    // DenoxRequests.setCompany(company);

    // await performCompanyConfig(context);

    if (funcionality.key == "technicalVisit") {
      context.flowNavigator.selectPage(FlowPage.techVisit);
      return;
    }

    if (funcionality.key == "asset") {
      context.flowNavigator.selectPage(FlowPage.asset);
      return;
    }
  }

  void _forceLogoutAllPlataforms(BuildContext context) {
    _performLogout(context);
  }

  void _addCallback(listfuncionalities) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _onFuncionalityTap(context, listfuncionalities[0]);
      setState(() {
        callback = true;
      });
    });
  }
}

class Funcionality {
  String key;
  String name;
  IconData icon;

  Funcionality(this.key, this.name, this.icon);
}

class MenuCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  MenuCard(this.name, this.icon, {this.onTap});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Opacity(
      // opacity: enabled ? 1.0 : 0.3,
      opacity: 1.0,
      child: Container(
        height: 150,
        child: Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Center(
                            child: Container(
                              height: 50,
                              width: 130,
                              child: Icon(icon),
                            ),
                          )),
                      // Container(
                      //   color: color,
                      //   height: 1.5,
                      // ),
                      Text(
                        name,
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

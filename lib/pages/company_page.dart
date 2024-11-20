import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dartx/dartx.dart';
import 'package:flow_flutter/models/company.dart';
import 'package:flow_flutter/models/exceptions.dart';
import 'package:flow_flutter/models/get_all_info.dart';
import 'package:flow_flutter/pages/base_pages/base_tech_visit.dart';
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

class CompanyPage extends StatefulWidget {
  @override
  CompanyPageState createState() => new CompanyPageState();
}

class CompanyPageState extends State<CompanyPage> {
  // static const _methodChannel = MethodChannel("company_page");

  Future<GetAllInfo> _getAllInfo;
  Future<PackageInfo> _packageInfo;
  Future<CompanyList> _companiesRequest;
  RequestsRepository requestsRepository;
  bool callback;
  var _packageInfoFuture = PackageInfo.fromPlatform();

  @override
  void initState() {
    Timer.run(() {
      _refresh();
    });
    callback = false;
    requestsRepository = context.provide<RequestsRepository>();
    _companiesRequest = requestsRepository.getCompanyList();

    super.initState();
  }

  Future<GetAllInfo> _refresh() async {
    _packageInfo ??= PackageInfo.fromPlatform();
    var appVersion = (await _packageInfo).buildNumber;

    setState(() {
      _companiesRequest = requestsRepository.getCompanyList();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          DenoxRequests.selectedCompany = null;
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => BaseTechVisit(
                    companyFilter: false,
                    isHistory: false,
                  )));
        },
        tooltip: 'Visitas agendadas',
        child: Icon(Icons.search),
      ),
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
    return Container(
      height: 150 + MediaQuery.of(context).viewInsets.top,
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: _getTitle()
            ),
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

          case 2:
            _showDialog("Conta excluída com sucesso");
            _performLogout(context);
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
          ),
          Platform.isIOS
              ? PopupMenuItem<int>(
                  value: 2,
                  child: Text("Excluir conta"),
                )
              : null,
        ];
      },
    );
  }

  void _showDialog(String text) {
    showDialog(
      context: context,
      barrierColor: Colors.blue.withOpacity(0.8),
      builder: (context) => ShowUp.tenth(
        duration: 200,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
          title: Text("Sucesso"),
          content: Text(text),
        ),
      ),
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
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.transparent,
                    child: Center(
                      child: Image.asset(
                        'assets/image/Logo_Flow-03.png',
                      ),
                    ),
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
                    maxLines: 2,
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
                      style: Theme.of(context).primaryTextTheme.caption,
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
    var isAndroid = Theme.of(context).platform == TargetPlatform.android;

    var showUpDelay = 200;

    return FutureBuilder(
        future: _companiesRequest,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: SpinKitWave(
                color: Theme.of(context).colorScheme.secondary,
                size: 30,
              ),
            );
          if (snapshot.connectionState == ConnectionState.done) {
            try {
              CompanyList aux = snapshot.data;
              var listCompanies = aux.companies.asMap();
              if (listCompanies.length == 1 && !callback) {
                printDebug("onCompanyTap");
                _addCallback(listCompanies);
              }

              // print(listCompanies.companies.asMap()[0].technicalname);
              return ScrollConfiguration(
                behavior: NoGlowBehavior(),
                child: ListView.builder(
                  // shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  // physics: ClampingScrollPhysics(),
                  itemCount: (listCompanies.length / 2).round(),
                  // itemCount: (companyList.length / 2).round(),
                  itemBuilder: (context, index) {
                    return Column(children: [
                      Row(
                        children: [
                          Expanded(
                            child: ShowUp(
                              delay: showUpDelay += 100,
                              child: MenuCard(
                                listCompanies[2 * index].name,
                                "",
                                // companyList[2 * index],
                                // description[2 * index],
                                listCompanies[2 * index].logoURL,
                                HexColor.fromHex(
                                    listCompanies[2 * index].color),
                                //enabled: isAndroid,
                                onTap: () {
                                  _onCompanyTap(
                                      context, listCompanies[2 * index]);
                                },
                              ),
                            ),
                          ),
                          listCompanies.containsKey(2 * index + 1)
                              // companyList.asMap().containsKey(2 * index + 1)
                              ? Expanded(
                                  child: ShowUp(
                                    delay: showUpDelay += 100,
                                    child: MenuCard(
                                      listCompanies[2 * index + 1].name,
                                      "",
                                      // companyList[2 * index],
                                      // description[2 * index],
                                      listCompanies[2 * index + 1].logoURL,
                                      HexColor.fromHex(
                                          listCompanies[2 * index + 1].color),
                                      //enabled: isAndroid,
                                      onTap: () {
                                        _onCompanyTap(context,
                                            listCompanies[2 * index + 1]);
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

//passar company correspondente
  Future<void> _onCompanyTap(BuildContext context, Companies company) async {
    DenoxRequests.setCompany(company);

    await performCompanyConfig(context);

    context.flowNavigator.selectPage(FlowPage.funcionality);
  }

  // Future<CompanyConfig> performCompanyConfig(BuildContext context) async {
  //   return context
  //       .provide<RequestsRepository>()
  //       .getCompanyConfig()
  //       .then((listing) async {
  //     if (listing != null) {
  //       await context
  //           .provide<CompanyConfigRepository>()
  //           .putCompanyConfig(listing);
  //       return listing;
  //     } else {
  //       return null;
  //     }
  //   });
  // }

  void _forceLogoutAllPlataforms(BuildContext context) {
    //Other platforms

    //Locally
    _performLogout(context);
  }

  void _addCallback(listCompanies) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _onCompanyTap(context, listCompanies[0]);
      setState(() {
        callback = true;
      });
    });
  }
}

class MenuCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;
  final Color color;

  MenuCard(
    this.title,
    this.subtitle,
    this.image,
    this.color, {
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Opacity(
      opacity: enabled ? 1.0 : 0.3,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: ClipPath(
          clipper: ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            height: 120,
            decoration: BoxDecoration(
                border: Border(
              left: BorderSide(color: color, width: 10),
            )),
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius:
                  BorderRadius.horizontal(right: Radius.circular(12.0)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 4.0, bottom: 4),
                            child: Center(
                              child: Container(
                                height: 50,
                                width: 130,
                                child: Image.network(
                                  image.contains("http://")
                                      ? image.replaceFirst(
                                          "http://", "https://")
                                      : image,
                                ),
                              ),
                            )),
                        // Container(
                        //   color: color,
                        //   height: 1.5,
                        // ),
                        Text(
                          title,
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    if (hexString == null) return Colors.grey;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

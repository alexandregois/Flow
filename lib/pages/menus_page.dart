// import 'dart:async';

// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:dartx/dartx.dart';
// import 'package:flow_flutter/flow_icons_icons.dart';
// import 'package:flow_flutter/models/conpany_config.dart';

// import 'package:flow_flutter/models/exceptions.dart';
// import 'package:flow_flutter/models/get_all_info.dart';
// import 'package:flow_flutter/pages/selling_page.dart';
// import 'package:flow_flutter/repository/repositories.dart';
// import 'package:flow_flutter/services/get_all_info_service.dart';
// import 'package:flow_flutter/utils/no_glow_behavior.dart';
// import 'package:flow_flutter/utils/utils.dart';
// import 'package:flow_flutter/widget/flow_navigator.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:package_info/package_info.dart';
import 'package:package_info_plus/package_info_plus.dart';
// import 'package:provider/provider.dart';
// import 'package:shinayser_essentials_flutter/shinayser_essentials_flutter.dart';

// class MenusPage extends StatefulWidget {
//   @override
//   MenusPageState createState() => new MenusPageState();
// }

// class MenusPageState extends State<MenusPage> {
//   static const _methodChannel = MethodChannel("menus_page");

//   Future<GetAllInfo> _getAllInfo;
//   // Future<CompanyConfig> _getCompanyConfig;
//   Future<PackageInfo> _packageInfo;
//   RequestsRepository requestsRepo;
//   var _packageInfoFuture = PackageInfo.fromPlatform();

//   @override
//   void initState() {
//     Timer.run(() {
//       _refresh();
//     });
//     requestsRepo = context.provide<RequestsRepository>();
//     // _getCompanyConfig = requestsRepo.getCompanyConfig();
//     super.initState();
//   }

//   Future<GetAllInfo> _refresh() async {
//     _packageInfo ??= PackageInfo.fromPlatform();
//     var appVersion = (await _packageInfo).buildNumber;

//     setState(() {
//       _getAllInfo = GetAllInfoService(
//               appVersion, context.provide<RequestsRepository>(),
//               appData: context.provide<AppDataRepository>(),
//               devicesRepo: context.provide<DevicesRepository>(),
//               vehiclesRepo: context.provide<VehiclesRepository>(),
//               checklistRepo: context.provide<ChecklistRepository>(),
//               picturesToTakeRepo: context.provide<PictureToTakeRepository>(),
//               companyConfigRepo: context.provide<CompanyConfigRepository>())
//           .performGetAllInfo(true);
//     });
//     return _getAllInfo;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           _getAppBar(context),
//           SizedBox(height: 8),
//           Expanded(
//             child: RefreshIndicator(
//               onRefresh: _refresh,
//               displacement: 10,
//               child: Builder(builder: (context) => _buildBody(context)),
//             ),
//           ),
//           // Spacer(),
//           Padding(
//             padding: const EdgeInsets.all(4),
//             child: FutureBuilder<PackageInfo>(
//                 future: _packageInfoFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData)
//                     return Text(
//                       "v${snapshot.data.version}",
//                       style: Theme.of(context).textTheme.caption,
//                     );
//                   else {
//                     return Container();
//                   }
//                 }),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _getAppBar(BuildContext context) {
//     var appBarTheme = Theme.of(context).appBarTheme;

//     return Container(
//       height: 170 + MediaQuery.of(context).viewInsets.top,
//       decoration: BoxDecoration(
//         // color: appBarTheme.color,
//         gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: <Color>[
//               Colors.blue[600],
//               Colors.blue[900],
//             ]),
//         borderRadius: BorderRadius.only(
//           bottomLeft: const Radius.circular(32),
//           bottomRight: const Radius.circular(32),
//         ),
//       ),
//       child: SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             Spacer(),
//             // SizedBox(height: 8),
//             Row(children: [
//               Expanded(
//                 child: InkWell(
//                   borderRadius: const BorderRadius.all(
//                     Radius.circular(12),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 16.0),
//                     child: Align(
//                       alignment: Alignment.bottomLeft,
//                       child: Icon(
//                         Icons.arrow_back,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   onTap: () => Navigator.of(context).pop(),
//                 ),
//               ),
//               Text(
//                 "Flow",
//                 style: appBarTheme.textTheme.headline4
//                     .copyWith(fontWeight: FontWeight.bold),
//               ),
//               Expanded(child: Container())
//             ]),
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: _getTitle(),
//               ),
//             ),
//             // Spacer(),
//             // SizedBox(height: 4),
//             Spacer(),
//             // Center(
//             //   child: FutureBuilder<PackageInfo>(
//             //       future: _packageInfoFuture,
//             //       builder: (context, snapshot) {
//             //         if (snapshot.hasData)
//             //           return Text(
//             //             "v${snapshot.data.version}",
//             //             style: appBarTheme.textTheme.overline,
//             //           );
//             //         else {
//             //           return Container();
//             //         }
//             //       }),
//             // ),
//             // SizedBox(height: 8),
//           ],
//         ),
//       ),
//     );
//   }

//   PopupMenuButton<int> _buildPopupMenuButton(BuildContext context) {
//     return PopupMenuButton<int>(
//       icon: Icon(Icons.more_horiz),
//       onSelected: (i) {
//         // if (i == 0) {
//         //   _refresh();
//         // } else {
//         _performLogout(context);
//         // }
//       },
//       itemBuilder: (BuildContext context) {
//         return [
//           // PopupMenuItem<int>(
//           //   value: 0,
//           //   child: Text("Atualizar informações"),
//           // ),
//           PopupMenuItem<int>(
//             value: 1,
//             child: Text("Logout"),
//           )
//         ];
//       },
//     );
//   }

//   void _performLogout(BuildContext context) {
//     Timer(300.milliseconds, () {
//       performLogout(
//           appData: Provider.of<AppDataRepository>(context, listen: false),
//           devicesRepo: Provider.of<DevicesRepository>(context, listen: false),
//           checklistRepo:
//               Provider.of<ChecklistRepository>(context, listen: false),
//           picturesRepo:
//               Provider.of<PictureToTakeRepository>(context, listen: false),
//           vehiclesRepo:
//               Provider.of<VehiclesRepository>(context, listen: false));
//       // Navigator.of(context).pushReplacement(
//       //   MaterialPageRoute(builder: (context) => LoginPage()),
//       // );

//       // MyAppState.of(context).reload();
//     });
//   }

//   FutureBuilder<GetAllInfo> _getTitle() {
//     return FutureBuilder<GetAllInfo>(
//       future: _getAllInfo,
//       builder: (BuildContext context, AsyncSnapshot<GetAllInfo> snapshot) {
//         if (snapshot.connectionState != ConnectionState.waiting &&
//             (snapshot.hasData || snapshot.hasError)) {
//           var subtitleText = snapshot.hasData
//               ? "Olá ${snapshot.data.name}"
//               : "Erro ao carregar";

//           if (snapshot.error is RefreshTokenException) {
//             _performLogout(context);
//           }

//           var appBarTheme = Theme.of(context).appBarTheme;

//           return Column(
//             crossAxisAlignment:
//                 currentPlatform(context) == TargetPlatform.android
//                     ? CrossAxisAlignment.start
//                     : CrossAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               ShowUp(
//                 offset: 0.05,
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: snapshot.hasData
//                         ? null
//                         : Theme.of(context).colorScheme.error,
//                     child: Icon(
//                       snapshot.hasData ? Icons.person_outline : Icons.warning,
//                       color: appBarTheme.iconTheme.color,
//                     ),
//                   ),
//                   title: AutoSizeText(
//                     subtitleText,
//                     style: appBarTheme.textTheme.bodyText1,
//                     maxLines: 1,
//                     // textAlign: TextAlign.center,
//                   ),
//                   subtitle: AutoSizeText(
//                     "${snapshot.data?.email ?? 'Por favor, tente novamente'}",
//                     style: appBarTheme.textTheme.caption,
//                     maxLines: 1,
//                   ),
//                   trailing: Theme(
//                     data: ThemeData(
//                       iconTheme: appBarTheme.iconTheme,
//                     ),
//                     child: _buildPopupMenuButton(context),
//                   ),
//                 ),
//               )
//             ],
//           );
//         } else {
//           return ShowUp.fifth(
//             child: ListTile(
//               title: Center(
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     Text(
//                       "Atualizando",
//                       style: Theme.of(context).primaryTextTheme.caption,
//                     ),
//                     SizedBox(width: 8.0),
//                     SpinKitWave(
//                       color: Colors.white,
//                       size: 10.0,
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }
//       },
//     );
//   }

//   Widget _buildBody(BuildContext context) {
//     var isAndroid = Theme.of(context).platform == TargetPlatform.android;

//     var showUpDelay = 200;

//     return ScrollConfiguration(
//       behavior: NoGlowBehavior(),
//       child: ListView(
//         // shrinkWrap: true,
//         // crossAxisCount: 1,
//         // childAspectRatio: 1.1,
//         padding: const EdgeInsets.symmetric(horizontal: 8),
//         // physics: ClampingScrollPhysics(),
//         children: <Widget>[
//           // ShowUp(
//           //   delay: showUpDelay += 100,
//           //   child: MenuCard(
//           //     "Vendas",
//           //     "Inicie novas vendas e gerencie vendas já realizadas",
//           //     FlowIcons.cart_plus,
//           //     onTap: _onSellingTap,
//           //     enabled: false,
//           //   ),
//           // ),
//           // ShowUp(
//           //   delay: showUpDelay += 100,
//           //   child: MenuCard(
//           //     "Vistoria",
//           //     "Iniciar e organizar inspeções",
//           //     Icons.camera_alt,
//           //     enabled: false,
//           //   ),
//           // ),
//           // ShowUp(
//           //   delay: showUpDelay += 100,
//           //   child: MenuCard(
//           //     "Instalação",
//           //     "Inicie e gerencie instalações",
//           //     FlowIcons.cog_alt,
//           //     enabled: isAndroid,
//           //     onTap: () {
//           //       _onInstallationTap(context);
//           //     },
//           //   ),
//           // ),
//           ShowUp(
//             delay: showUpDelay += 100,
//             child: MenuCard(
//               "Visitas Técnicas",
//               "Inicie e gerencie Visitas Técnicas",
//               Icons.handyman,
//               enabled: isAndroid,
//               onTap: () {
//                 _onTechVisitTap(context);
//               },
//             ),
//           ),
//           ShowUp(
//             delay: showUpDelay += 100,
//             child: MenuCard(
//               "Histórico de Instalações",
//               "Verifique seu Histórico de Instalações",
//               Icons.settings_backup_restore,
//               enabled: isAndroid,
//               onTap: () {
//                 _onInstalationHistoryTap(context);
//               },
//             ),
//           ),
//           // ShowUp(
//           //   delay: showUpDelay += 100,
//           //   child: MenuCard("Manutenção", "Gerencie manutenções", Icons.build,
//           //       enabled: false),
//           // ),
//           // ShowUp(
//           //   delay: showUpDelay += 100,
//           //   child: MenuCard(
//           //     "Pronta-resposta",
//           //     "Acesso à área de pronta-resposta",
//           //     FlowIcons.siren,
//           //     enabled: isAndroid,
//           //     onTap: () {
//           //       _onRecoverTap(context);
//           //     },
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }

//   void _onInstalationHistoryTap(BuildContext context) async {
//     context.flowNavigator.selectPage(FlowPage.installationHistory);
//   }

//   void _onTechVisitTap(BuildContext context) async {
//     context.flowNavigator.selectPage(FlowPage.techVisit);
//   }

//   void _onInstallationTap(BuildContext context) async {
//     context.flowNavigator.selectPage(FlowPage.installationList);
//     // try {
//     //   await _methodChannel.invokeMethod("openInstallations");
//     // } catch (e) {
//     //   Scaffold.of(context)
//     //       .showSnackBar(SnackBar(content: Text("Não implementado")));
//     // }
//   }

//   void _onRecoverTap(BuildContext context) async {
//     try {
//       await _methodChannel.invokeMethod("openRecover");
//     } catch (e) {
//       Scaffold.of(context)
//           .showSnackBar(SnackBar(content: Text("Não implementado")));
//     }
//   }

//   // ignore: unused_element
//   void _onSellingTap() {
//     Navigator.of(context)
//         .push(MaterialPageRoute(builder: (context) => SellingPage()));

// //  showDialog(context: context, builder: (context) => SellingPage());
//   }
// }

// class MenuCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final bool enabled;
//   final VoidCallback onTap;

//   MenuCard(
//     this.title,
//     this.subtitle,
//     this.icon, {
//     this.enabled = true,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     var theme = Theme.of(context);

//     return Opacity(
//       opacity: enabled ? 1.0 : 0.3,
//       child: Card(
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(10.0))),
//         child: ListTile(
//           onTap: enabled ? onTap : null,
//           leading: Container(
//             width: 36,
//             height: 36,
//             child: Center(
//               child: Icon(
//                 icon,
//                 color: theme.accentColor,
//                 size: 28,
//               ),
//             ),
//           ),
//           title: Text(
//             title,
//             style: theme.textTheme.bodyText1,
//           ),
//           subtitle: Text(
//             subtitle ?? "Subtítulo",
//             style: theme.textTheme.caption,
//           ),
//         ),
//       ),
//     );
//   }
// }

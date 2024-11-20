import 'package:flow_flutter/controller/tech_visit_requirements_controller.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/models/technical_visit_list.dart';
import 'package:flow_flutter/pages/installation/installation_page.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/animation/growup.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/lazy_stream_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TechVisitRequirementsPage extends StatefulWidget {
  final TechnicalVisit techVisit;
  final Color color;
  final int companyId;
  TechVisitRequirementsPage({
    Key key,
    @required this.techVisit,
    this.color,
    @required this.companyId,
  }) : super(key: key);

  @override
  _TechVisitRequirementsPageState createState() =>
      _TechVisitRequirementsPageState();
}

class _TechVisitRequirementsPageState extends State<TechVisitRequirementsPage> {
  TechVisitRequirementsController controller;
  LatLong startLocation;
  Future<InstallationStart> _request;

  @override
  void didChangeDependencies() {
    controller ??= TechVisitRequirementsController(
      null,
      context.provide<LocationRepository>(),
    );
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void myCallback(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: <Color>[widget.color, widget.color.withAlpha(190)]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, //widget.color,
        body: LazyStreamBuilder<TechVisitRequirement>(
            stream: controller,
            builder: (context, snapshot) {
              switch (snapshot.data.step) {
                case RequirementStep.geolocation:
                  return _FetchingLatLong(widget.color);
                  break;

                case RequirementStep.done:
                  try {
                    startLocation = snapshot.data.data;
                    _request = context
                        .provide<RequestsRepository>()
                        .startInstallation(startLocation, widget.techVisit.id,
                            widget.companyId);
                  } catch (e) {
                    print(e);
                    return _NoConnection(widget.color);
                  }
                  try {
                    return FutureBuilder<InstallationStart>(
                      future: _request,
                      builder: (BuildContext context,
                          AsyncSnapshot<InstallationStart> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _FetchingTechVisit(widget.color);
                        }
                        // if (snapshot.hasError != null)
                        //   myCallback(() {
                        //     Navigator.pop(context, true);
                        //     _errorDialog(snapshot.error.toString());
                        //   });

                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData == true) {
                          if (snapshot.data.error == null)
                            return ShowUp.fifth(
                              child: InstallationPage(
                                installation: Installation.startFromCloud(
                                    snapshot.data,
                                    widget.techVisit,
                                    startLocation),
                                installationTypes:
                                    snapshot.data.installationTypes,
                              ),
                            );
                          else {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.of(context).pop();
                              errorDialog(context, snapshot.data.error);
                            });
                          }
                        }
                        if (snapshot.data == null) {
                          myCallback(() {
                            Navigator.pop(context, true);
                          });
                        }
                        return Container();
                      },
                    );
                  } catch (e) {
                    print(e);
                  }
                  break;
              }

              return Container();
            }),
      ),
    );
  }

  void errorDialog(BuildContext context, String errorMessage) {
    String texto = errorMessage;
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

class _FetchingLatLong extends StatelessWidget {
  final Color color;
  _FetchingLatLong(this.color);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Positioned(
                top: MediaQuery.of(context).viewPadding.top,
                child: GrowUp(
                  delay: 150,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: theme.colorScheme.onPrimary,
                    child: Icon(
                      Icons.arrow_back,
                      color: theme.textTheme.bodyLarge.color,
                    ),
                    onPressed: Navigator.of(context).pop,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShowUp.half(
                      child: SpinKitPulse(
                        size: 100,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Aguardando posição GPS",
                      style: theme.textTheme.titleLarge
                          .copyWith(color: theme.colorScheme.onPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Vá para uma área aberta para que o GPS funcione com um sinal melhor",
                      style: theme.textTheme.bodyLarge
                          .copyWith(color: theme.colorScheme.onPrimary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FetchingTechVisit extends StatelessWidget {
  final Color color;
  _FetchingTechVisit(this.color);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Positioned(
                top: MediaQuery.of(context).viewPadding.top,
                child: GrowUp(
                  delay: 150,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: theme.colorScheme.onPrimary,
                    child: Icon(
                      Icons.arrow_back,
                      color: theme.textTheme.bodyLarge.color,
                    ),
                    onPressed: Navigator.of(context).pop,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShowUp.fifth(
                      child: SpinKitCubeGrid(
                        size: 80,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Iniciando Visita Técnica.",
                      style: theme.textTheme.titleLarge
                          .copyWith(color: theme.colorScheme.onPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Por favor aguarde alguns momentos\nCertifique-se que está conectado na internet",
                      style: theme.textTheme.bodyLarge
                          .copyWith(color: theme.colorScheme.onPrimary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoConnection extends StatelessWidget {
  final Color color;
  _NoConnection(this.color);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: color,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Positioned(
                top: MediaQuery.of(context).viewPadding.top,
                child: GrowUp(
                  delay: 150,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: theme.colorScheme.onPrimary,
                    child: Icon(
                      Icons.arrow_back,
                      color: theme.textTheme.bodyLarge.color,
                    ),
                    onPressed: Navigator.of(context).pop,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShowUp.fifth(
                        child: Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 48,
                    )),
                    SizedBox(height: 8),
                    Text(
                      "Sem conexão com a Internet",
                      style: theme.textTheme.titleLarge
                          .copyWith(color: theme.colorScheme.onPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Certifique-se que está conectado na internet e tente novamente",
                      style: theme.textTheme.bodyLarge
                          .copyWith(color: theme.colorScheme.onPrimary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

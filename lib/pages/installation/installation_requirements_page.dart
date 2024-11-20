import 'package:flow_flutter/controller/installation_requirements_controller.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/customer.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/pages/installation/installation_page.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/animation/growup.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/lazy_stream_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class InstallationRequirementsPage extends StatefulWidget {
  final Installation installation;
  final InstallationTypes installationTypes;
  final bool isContinuation;
  final Customer customer;

  InstallationRequirementsPage(
      {Key key,
      @required this.installation,
      @required this.installationTypes,
      @required this.isContinuation,
      this.customer})
      : super(key: key);

  @override
  _InstallationRequirementsPageState createState() =>
      _InstallationRequirementsPageState();
}

class _InstallationRequirementsPageState
    extends State<InstallationRequirementsPage> {
  InstallationRequirementsController controller;
  var _startRequest;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    controller ??= InstallationRequirementsController(
      widget.installation,
      context.provide<LocationRepository>(),
    );
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Colors.blue, Colors.blue.withAlpha(190)]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, //Theme.of(context).primaryColor,

        body: LazyStreamBuilder<InstallationRequirement>(
            stream: controller,
            builder: (context, snapshot) {
              switch (snapshot.data.step) {
                case RequirementStep.geolocation:
                  return _FetchingLatLong();
                  break;

                case RequirementStep.done:
                  Installation _installation = snapshot.data.data;
                  _installation.customerEmail =
                      widget?.customer?.customerEmail ?? "";
                  _installation.customerId = widget?.customer?.id ?? null;
                  if (widget.isContinuation)
                    return InstallationPage(
                      installation: _installation,
                      installationTypes: widget.installationTypes,
                    );
                  try {
                    _startRequest = context
                        .provide<RequestsRepository>()
                        .startNewInstallation(_installation.startLocation,
                            widget.installationTypes.id, widget?.customer?.id);

                    return ShowUp.fifth(
                      child: FutureBuilder(
                          future: _startRequest,
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.connectionState ==
                                    ConnectionState.done) {
                              if (snapshot.data.errorMessage == null) {
                                _installation.cloudId = snapshot.data.intValue;
                                return InstallationPage(
                                  installation: _installation,
                                  installationTypes: widget.installationTypes,
                                );
                              } else {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  Navigator.of(context).pop();
                                  errorDialog(
                                      context, snapshot.data.errorMessage);
                                });
                              }
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _FetchingTechVisit(Colors.blue);
                            }
                            return Container();
                          }),
                    );
                  } catch (e) {
                    Navigator.of(context).pop();
                    errorDialog(context, e.toString());
                    print(e.toString());
                  }
              }

              return Container(
                  child: Center(
                child: Text(
                  "Erro ao carregar instalação",
                  style: TextStyle(color: Colors.white),
                ),
              ));
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
                    SpinKitPulse(
                      size: 60,
                      color: theme.colorScheme.onPrimary,
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

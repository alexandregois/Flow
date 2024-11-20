import 'package:flow_flutter/controller/V2Controllers/custom_page_controller.dart';
import 'package:flow_flutter/controller/installation_send_controller.dart';
import 'package:flow_flutter/controller/tech_visit_requirements_controller.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/animation/growup.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/lazy_stream_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class InstallationGetFinishLocationPage extends StatefulWidget {
  // final TechnicalVisit Installation;
  final Installation installation;
  final CustomPageController customPageController;
  final Color color;
  InstallationGetFinishLocationPage({
    Key key,
    this.color,
    @required this.installation,
    this.customPageController,
  }) : super(key: key);

  @override
  _InstallationGetFinishLocationPageState createState() =>
      _InstallationGetFinishLocationPageState();
}

class _InstallationGetFinishLocationPageState
    extends State<InstallationGetFinishLocationPage> {
  TechVisitRequirementsController controller;

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
                    myCallback(() {
                      Navigator.of(context).pop();
                      widget.customPageController
                          .finish(snapshot.data.data)
                          .then((value) => context
                              .provide<InstallationSendController>()
                              .start(widget.installation.appId));
                    });
                  } catch (e) {
                    print(e);
                    return _NoConnection(widget.color);
                  }
                  break;
              }
              // if (snapshot.data != null) {
              //   myCallback(() {
              //     Navigator.of(context).pop();
              //     widget.customPageController.finish(snapshot.data.data).then(
              //         (value) => context
              //             .provide<InstallationSendController>()
              //             .start(widget.installation.appId));
              //   });
              // }
              return Container();
            }),
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

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/request_status.dart';
import 'package:flow_flutter/utils/util_extensions.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rxdart/rxdart.dart';

class DevicePage extends StatefulWidget {
  final String serial;

  DevicePage({this.serial});

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  var _textController = TextEditingController();

  var _requestStatus = BehaviorSubject.seeded(RequestStatus.IDLE);

  @override
  void initState() {
    _textController.text = widget.serial;
    super.initState();
  }

  @override
  void dispose() {
    _requestStatus.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: AutoSizeText(
                "Identificação equipamento",
                minFontSize: 10,
                maxLines: 1,
                style: theme.textTheme.titleLarge,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        StreamBuilder<RequestStatus>(
            stream: _requestStatus,
            builder: (context, snapshot) {
              final requestStatus = snapshot.data;

              if (requestStatus == RequestStatus.WAITING) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ShowUp.fifth(
                      child: SpinKitRipple(
                          size: 20,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    SizedBox(height: 8),
                    ShowUp.fifth(
                      delay: 100,
                      child: Text("Processando..."),
                    )
                  ],
                );
              }

              if (requestStatus == RequestStatus.DONE) {
                // Navigator.pop(context, ser)

                // return SuccessWidget(
                //   fullSize: false,
                //   size: 80,
                //   message:
                //       "Se este e-mail estiver cadastrado em nossa base, você receberá as instruções para a troca de senha.\nLembre-se de olhar também na sua caixa de spam.",
                //   onFinishClicked: Navigator.of(context).pop,
                // );
              }

              if (requestStatus == RequestStatus.ERROR) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ShowUp.fifth(
                      child: Icon(
                        Icons.error_outline,
                        size: 36,
                        color: context.theme.colorScheme.error,
                      ),
                    ),
                    SizedBox(height: 8),
                    ShowUp.fifth(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "Não conseguimos resetar sua senha.\nPode ser que este e-mail não esteja cadastrado no sistema.\nPor favor, tente novamente.",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    ShowUp.fifth(
                      delay: 100,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Tentar novamente'),
                        onPressed: () {
                          _requestStatus.add(RequestStatus.IDLE);
                        },
                      ),
                    )
                  ],
                );
              }

              return _mainBody(requestStatus, theme);
            }),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _mainBody(RequestStatus requestStatus, ThemeData theme) => Column(
        mainAxisSize: MainAxisSize.min,
        key: ValueKey("mainBody"),
        children: <Widget>[
          SizedBox(height: 16),
          ShowUp.half(
            delay: 50,
            child: Text(
              "Insira a identificação do equipamento",
              textAlign: TextAlign.center,
            ),
          ),
          ShowUp.fifth(
            delay: 50,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextField(
                controller: _textController,
                enabled: requestStatus == RequestStatus.IDLE ||
                    requestStatus == RequestStatus.ERROR,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(),
                  labelText: "Identificação",
                ),
              ),
            ),
          ),
          FloatingActionButton(
              heroTag: 'qrcode',
              mini: true,
              backgroundColor: context.theme.colorScheme.secondary,
              child: Icon(
                Icons.qr_code,
                color: Colors.white,
              ),
              onPressed: () async {
                printDebug('Scanning QR code');
                final scanned = await FlutterBarcodeScanner.scanBarcode(
                  "#ff6666",
                  "Cancelar",
                  true,
                  ScanMode.QR,
                );

                printDebug('Código scaneado $scanned');
              }),
          ShowUp.fifth(
            delay: 50,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _textController,
              builder: (context, value, child) {
                return MaterialButton(
                  child: Text("Buscar dados"),
                  textColor: theme.colorScheme.secondary,
                  onPressed: () async {
                    _requestStatus.add(RequestStatus.WAITING);

                    var requestsRepo = context.provide<RequestsRepository>();

                    var serial =
                        _textController.text.trim().replaceAll(" ", "");

                    var visitType =
                        await requestsRepo.getVisityTypeByDevice(serial, null);

                    printDebug('Tipo de visita $visitType');

                    _requestStatus.add(RequestStatus.DONE);

                    _selectVisitType(context, serial, visitType);

                    // Navigator.pop(context, {serial, visitType});
                  },
                );
              },
            ),
          ),
        ],
      );

  void _selectVisitType(BuildContext context, String serial, String visitType) {
    Navigator.pop(context, {serial, visitType});
  }
}

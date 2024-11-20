import 'dart:async';
import 'package:circular_menu/circular_menu.dart';
import 'package:dartx/dartx.dart';
import 'package:flow_flutter/controller/V2Controllers/custom_page_controller.dart';
import 'package:flow_flutter/controller/V2Controllers/devices_controller.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/models/installation_type.dart';
import 'package:flow_flutter/pages/installation/installation_page.dart';
import 'package:flow_flutter/pages/installation/new_tracker_form_page.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/animation/growup.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/installation_step.dart';
import 'package:flow_flutter/utils/util_extensions.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/lazy_stream_builder.dart';
import 'package:flow_flutter/widget/pair_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EquipmentsPage extends StatefulWidget {
  final DevicesController controller;

  EquipmentsPage({
    Key key,
    @required this.controller,
    // @required this.installationType,
    // @required this.backgroundColor,
    // @required this.installation,
  }) : super(key: key);

  @override
  _EquipmentsPageState createState() => _EquipmentsPageState();
}

class _EquipmentsPageState extends State<EquipmentsPage>
    with AutomaticKeepAliveClientMixin {
  var _circularMenuKey = GlobalKey<CircularMenuState>();
  var _bodyKey = GlobalKey();
  InstallationType installationType;
  Installation installation;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final customPageController = context.provide<CustomPageController>();
    // var theme = Theme.of(context);
    // widget.controller.isEditable = false;
    this.installation = customPageController.installation;
    this.installationType = customPageController.installation.installationType;
    return LayoutBuilder(
      builder: (context, constraints) =>
          LazyStreamBuilder<List<DeviceController>>(
        stream: widget.controller,
        builder: (context, snapshot) => Scaffold(
          body: (constraints.maxHeight > 300)
              ? CircularMenu(
                  // toggleButtonIconColor: theme.colorScheme.secondary,
                  startingAngleInRadian: 3.2,
                  endingAngleInRadian: 4.7,
                  key: _circularMenuKey,
                  alignment: Alignment.bottomRight,
                  toggleButtonPadding: 10,
                  toggleButtonMargin: 16,
                  toggleButtonColor: context.theme.colorScheme.secondary,
                  toggleButtonSize: 32,
                  animationDuration: 200.milliseconds,
                  reverseCurve: Curves.easeIn,
                  curve: Curves.easeInOut,
                  radius: 64,
                  items: [
                    CircularMenuItem(
                      icon: Icons.add,
                      color: context.theme.colorScheme.secondary,
                      onTap: () {
                        _circularMenuKey.currentState.reverseAnimation();
                        trackerForm();
                        // widget.controller.addTracker(Tracker());
                      },
                    ),
                    CircularMenuItem(
                      icon: Icons.qr_code,
                      color: context.theme.colorScheme.secondary,
                      onTap: () {
                        // _circularMenuKey.currentState.reverseAnimation();
                        _startCodeReading(context, true);
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(builder: (context) => CodeReadPage()),
                        // );
                      },
                    ),
                  ],
                  backgroundWidget: _body(snapshot),
                )
              : _body(snapshot),
        ),
      ),
    );
  }

  Widget _body(AsyncSnapshot<List<DeviceController>> snapshot) {
    return Column(
      key: _bodyKey,
      children: [
        Expanded(
          child: snapshot.data?.firstOrNull != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 8,
                    bottom: 90,
                  ),
                  child: Column(
                    children: snapshot.data
                        .map((item) => _getTrackerCard(item))
                        .toList(),
                  ),
                )
              : Center(
                  child: ShowUp.fifth(
                    child: Text("Nenhum equipamento adicionado"),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _getTrackerCard(DeviceController item) {
    return LazyStreamBuilder<ReadyState>(
      key: ValueKey(item),
      stream: item.readyStream,
      builder: (context, snapshot) => _TrackerCard(
        installation: this.installation,
        color: Colors.blue,
        tracker: item,
        controller: widget.controller,
        isReady: snapshot.data.status,
        installationType: this.installationType,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

  void _startCodeReading(BuildContext context, bool isAdd) async {
    try {
      final scanned = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancelar",
        true,
        ScanMode.QR,
      );

      if (scanned != '-1') {
        //widget.controller.addCodeRead(scanned);
        DeviceController newTracker =
            await widget.controller.addCodeReadTechVisit(scanned);
        if (newTracker.qrCodeError == null)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NewTrackerFormPage(
                color: Colors.blue,
                installationType: this.installationType,
                controller: widget.controller,
                installation: this.installation,
                tracker: newTracker,
                isAdd: true,
                animationController: null,
              ),
            ),
          );
        else
          errorDialog(context);
      }
    } on PlatformException {
      print('Platform exception');
    }
  }

  void trackerForm() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => NewTrackerFormPage(
              controller: widget.controller,
              color: Colors.blue,
              installationType: this.installation.installationType,
              installation: this.installation,
              tracker: null,
              isAdd: true,
              animationController: null,
            )));
  }

  void errorDialog(BuildContext context) {
    String texto =
        "O equipamento não existe ou não está 'Ativo' e 'Disponível' no sistema.";
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

class _TrackerCard extends StatefulWidget {
  final DeviceController tracker;
  final DevicesController controller;
  final ReadyStatus isReady;
  final InstallationType installationType;
  final Color color;
  final Installation installation;
  const _TrackerCard({
    Key key,
    this.tracker,
    this.controller,
    this.isReady,
    this.installationType,
    this.color,
    this.installation,
  }) : super(key: key);

  @override
  __TrackerCardState createState() => __TrackerCardState();
}

class __TrackerCardState extends State<_TrackerCard>
    with SingleTickerProviderStateMixin {
  TextEditingController _serialController;
  TextEditingController _brandController;
  TextEditingController _modelController;
  TextEditingController _localController;
  bool _needUpdateIdentifier = false;
  bool enabled;

  Timer _updateIdentifierTimer;

  AnimationController _animationController;
  CurvedAnimation _addRemoveAnimation;

  @override
  void initState() {
    enabled = widget.tracker.isEditable;
    _animationController = AnimationController(
      vsync: this,
      duration: 300.milliseconds,
    );

    _addRemoveAnimation = CurvedAnimation(
      curve: Curves.easeIn,
      parent: _animationController,
    );

    _animationController.forward();

    _animationController.addListener(() {
      if (_animationController.status == AnimationStatus.dismissed) {
        _removeTracker();
      }
    });

    _serialController = TextEditingController(
      text: widget.tracker.serial,
    );

    _localController = TextEditingController();
    if (widget.tracker.installationLocal != null) {
      _localController.text = widget?.installationType?.installationLocals
          ?.firstOrNullWhere(
              (local) => local.id == widget.tracker.installationLocal)
          ?.name;

      if (_localController.text == 'UNKNOWN') _localController.text = "";
    } else {
      _localController.text = "";
    }
    _modelController = TextEditingController();
    if ((widget.tracker.modelName == null ||
            widget.tracker.modelName == "null") &&
        widget.tracker.modelId != null) {
      widget.controller.models.any((model) {
        if (model.id == widget.tracker.modelId) {
          _modelController.text = model.name;
          return true;
        } else
          return false;
      });
      if (_modelController.text == 'UNKNOWN') _modelController.text = "";
    } else
      _modelController.text = widget.tracker.modelName;

    _brandController = TextEditingController();
    if ((widget.tracker.brandName == null ||
            widget.tracker.brandName == "null") &&
        widget.tracker.brandId != null) {
      widget.controller.brands.any((brand) {
        if (brand.id == widget.tracker.brandId) {
          _brandController.text = brand.name;
          return true;
        } else
          return false;
      });
      if (_brandController.text == 'UNKNOWN') _brandController.text = "";
    } else
      _brandController.text = widget.tracker.brandName;

    _needUpdateIdentifier = widget.tracker.isProcessingQrCode;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant _TrackerCard oldWidget) {
    if (_needUpdateIdentifier) {
      _serialController.text = widget.tracker.serial ?? '';
    }

    if (!widget.tracker.isProcessingQrCode) {
      _needUpdateIdentifier = false;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return SizeTransition(
      sizeFactor: _addRemoveAnimation,
      axis: Axis.vertical,
      axisAlignment: -1,
      child: widget.tracker.isProcessingQrCode
          ? _cardForProcessing(theme)
          : _cardNonProcessing(
              theme,
              widget.installationType,
              (widget.isReady == ReadyStatus.ready),
            ),
    );

    // return widget.tracker.isProcessingQrCode
    //     ? _cardForProcessing(theme)
    //     : _cardNonProcessing(
    //         theme,
    //         installationController,
    //         widget.isReady == ReadyStatus.ready,
    //       );
  }

  Widget _cardNonProcessing(
    ThemeData theme,
    InstallationType installationType,
    bool isReady,
  ) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: PairWidget.horizontal(
                      child1: isReady
                          ? GrowUp(
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 22,
                              ),
                            )
                          : Icon(
                              Icons.app_registration,
                              size: 22,
                            ),
                      spacing: 8,
                      child2: Text(
                        "Equipamento",
                        style: theme.textTheme.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                if (widget.tracker.qrCodeError != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      bottom: 12,
                    ),
                    child: Material(
                      color: theme.colorScheme.error,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: ListTile(
                        title: Text(
                          widget.tracker.qrCodeError,
                          style: theme.primaryTextTheme.bodySmall,
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            widget.tracker.qrCodeError = null;
                          },
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.onError,
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else
                  const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: _getGroupName(),
                ),
                // if (widget.controller.hasInstallationLocals)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: _installationLocalButton(installationType),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: _brandsButton()),
                      SizedBox(width: 8),
                      Expanded(child: _modelsButton()),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    controller: _serialController,
                    enabled: false,
                    onChanged: _updateIdentifier,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        gapPadding: 2,
                      ),
                      labelText: 'Identificação',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                // const SizedBox(height: 12),
                _automatedTestWidget(context),
              ],
            ),
          ),
        ),
        // if (widget.controller.isEditable)
        Positioned(
          right: 12,
          top: 0,
          child: FloatingActionButton(
            heroTag: 'close',
            mini: true,
            backgroundColor: theme.colorScheme.surface,
            child: Icon(
              Icons.close,
              color: Colors.red,
            ),
            onPressed: () async {
              // if (widget.tracker.groupId == null)
              //   _animationController.reverse(from: 1);
              // else
              if (widget.tracker.serial == null ||
                  widget.tracker.serial == "null") {
                _removeSlotDialog(widget.color);
              } else
                _removeDialog(widget.color);
            },
          ),
        ),
        Positioned(
          right: 60,
          top: 0,
          child: FloatingActionButton(
            heroTag: 'edit',
            mini: true,
            backgroundColor: theme.colorScheme.surface,
            child: Icon(
              Icons.edit,
              color: Color(0xFFf27800),
            ),
            onPressed: () {
              _editPage(
                context,
                widget.color,
                widget.tracker,
              );
            },
          ),
        ),
      ],
    );
  }

  void _removeTracker() {
    widget.controller.removeTracker(widget.tracker);
  }

  Widget _automatedTestWidget(BuildContext context) {
    var isProcessing = widget.tracker.isProcessingAutomatedTest;
    var hasIdentifier = widget.tracker.serial?.isNotBlank == true;
    var hasAutomatedTest = widget.tracker.automatedTest != null;

    return Opacity(
      opacity: hasIdentifier ? 1.0 : 0.5,
      child: ListTile(
        trailing: isProcessing
            ? Container(
                width: 40,
                child: SpinKitHourGlass(
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              )
            : Icon(
                hasAutomatedTest
                    ? Icons.check_circle
                    : Icons.not_started_outlined,
                key: ValueKey(hasAutomatedTest),
                color: hasAutomatedTest ? Colors.green : null,
              ),
        title: hasAutomatedTest
            ? Text(
                "Teste realizado",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: hasAutomatedTest ? Colors.green : null,
                ),
              )
            : ShowUp.tenth(
                key: ValueKey(isProcessing),
                child: Text(
                  isProcessing
                      ? 'Processando teste...'
                      : "Iniciar teste automatizado",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
        subtitle: widget.tracker.automatedTestError != null
            ? Text(
                widget.tracker.automatedTestError,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            : null,
        onTap: (isProcessing || !hasIdentifier || hasAutomatedTest)
            ? null
            : widget.tracker.startAutomatedTest,
      ),
    );
  }

  Widget _cardForProcessing(ThemeData theme) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              child: PairWidget.horizontal(
                child1: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SpinKitHourGlass(
                    color: theme.colorScheme.secondary,
                    size: 20,
                  ),
                ),
                spacing: 8,
                child2: Expanded(
                  child: Text(
                    "Processando...",
                    style: theme.textTheme.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // if (widget.controller.isEditable)
        Positioned(
          right: 12,
          top: 0,
          child: FloatingActionButton(
            mini: true,
            heroTag: 'close2',
            backgroundColor: Colors.deepPurple,
            child: Icon(
              Icons.close,
              color: Colors.red,
            ),
            onPressed: () {
              _animationController.reverse(from: 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _brandsButton() {
    var outlineInputBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      gapPadding: 2,
    );
    return TextField(
      controller: _brandController,
      enabled: false,
      decoration: InputDecoration(
        border: outlineInputBorder,
        labelText: 'Marca',
      ),
      textCapitalization: TextCapitalization.characters,
    );
    // var currentBrandId = widget.controller.brands
    //         .any((brand) => brand.id == widget.tracker.brandId)
    //     ? widget.tracker.brandId
    //     : null;

    // return IgnorePointer(
    //   ignoring: !enabled,
    //   child: OutlineDropdownButton(
    //     hint: Text("Marca"),
    //     inputDecoration: InputDecoration(
    //       border: OutlineInputBorder(),
    //       contentPadding: const EdgeInsets.symmetric(
    //         horizontal: 12,
    //       ),
    //       labelText: (currentBrandId == null) ? null : 'Marca',
    //     ),
    //     onChanged: (value) {
    //       if (enabled) {
    //         widget.tracker.brandId = value;
    //       }
    //     },
    //     value: currentBrandId,
    //     items: widget.controller.brands
    //         .map(
    //           (e) => DropdownMenuItem(
    //             child: AutoSizeText(
    //               e.name,
    //               minFontSize: 8,
    //             ),
    //             value: e.id,
    //           ),
    //         )
    //         .toList(),
    //   ),
    // );
  }

  Widget _modelsButton() {
    var outlineInputBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      gapPadding: 2,
    );
    return TextField(
      controller: _modelController,
      enabled: false,
      decoration: InputDecoration(
        border: outlineInputBorder,
        labelText: 'Modelo',
      ),
      textCapitalization: TextCapitalization.characters,
    );
//     var currentBrandId = widget.controller.brands
//             .any((brand) => brand.id == widget.tracker.brandId)
//         ? widget.tracker.brandId
//         : null;
// //
//     var currentModelId = widget.controller.models
//             .any((brand) => brand.id == widget.tracker.modelId)
//         ? widget.tracker.modelId
//         : null;

//     return IgnorePointer(
//       ignoring: !enabled,
//       child: OutlineDropdownButton(
//         hint: Text("Modelo"),
//         inputDecoration: InputDecoration(
//           border: OutlineInputBorder(),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 12,
//           ),
//           labelText: (currentModelId == null) ? null : 'Modelo',
//         ),
//         onChanged: (value) {
//           if (enabled) {
//             widget.tracker.modelId = value;
//           }
//         },
//         value: currentModelId,
//         items: widget.controller.models
//             .where((model) => model.brandId == currentBrandId)
//             .map(
//               (e) => DropdownMenuItem(
//                 child: AutoSizeText(
//                   e.name,
//                   minFontSize: 7,
//                   maxLines: 1,
//                 ),
//                 value: e.id,
//               ),
//             )
//             .toList(),
//       ),
//     );
  }

  Widget _installationLocalButton(
    InstallationType installationType,
  ) {
    var outlineInputBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      gapPadding: 2,
    );
    return TextField(
      controller: _localController,
      enabled: false,
      decoration: InputDecoration(
        border: outlineInputBorder,
        labelText: 'Local da instalação',
      ),
      textCapitalization: TextCapitalization.characters,
    );
    // return IgnorePointer(
    //   ignoring: !enabled,
    //   child: OutlineDropdownButton(
    //       hint: Text("Local da instalação"),
    //       inputDecoration: InputDecoration(
    //         border: OutlineInputBorder(),
    //         contentPadding: const EdgeInsets.symmetric(
    //           horizontal: 12,
    //         ),
    //         labelText: (widget.tracker.installationLocal == null)
    //             ? null
    //             : 'Local da instalação',
    //       ),
    //       value: widget.tracker.installationLocal,
    //       onChanged: (value) {
    //         if (enabled) {
    //           widget.tracker.installationLocal = value;
    //         }
    //       },
    //       items: installationType.installationLocals
    //           .map(
    //             (e) => DropdownMenuItem(
    //               child: Text(e.name),
    //               value: e.id,
    //             ),
    //           )
    //           .toList()
    //           .sortedByDescending((element) => element.value)),
    // );
  }

  void _updateIdentifier(String text) {
    _updateIdentifierTimer?.cancel();
    _updateIdentifierTimer = Timer(0.5.seconds, () {
      widget.tracker.serial = text;
    });
  }

  void _editPage(BuildContext context, Color color, DeviceController tracker) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: color.withOpacity(0.8),
      builder: (context) => ShowUp.tenth(
        duration: 200,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(
              color: color,
              width: 2,
            ),
          ),
          title: Text("Alterar Equipamento"),
          content: SingleChildScrollView(
            child: Text(
                "De que forma deseja inserir os dados para alterar este equipamento?"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                bool isAdd = false;
                if (widget.tracker.serial == null ||
                    widget.tracker.serial == "null") isAdd = true;
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NewTrackerFormPage(
                          color: color,
                          controller: widget.controller,
                          installationType: widget.installationType,
                          installation: widget.installation,
                          isAdd: isAdd,
                          tracker: tracker,
                          animationController: _animationController,
                          trackerOld: null,
                        )));
              },
              child: Text("Manualmente"),
            ),
            TextButton(
              child: Text(
                "Qr Code",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                bool isAdd = false;
                if (widget.tracker.serial == null ||
                    widget.tracker.serial == "null") isAdd = true;
                _startCodeReading(globalScaffoldKey.currentContext, isAdd);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeDialog(Color color) {
    showDialog(
      context: context,
      barrierColor: color.withOpacity(0.8),
      builder: (context) => ShowUp.tenth(
        duration: 200,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(
              color: color,
              width: 2,
            ),
          ),
          title: Text("Desinstalando"),
          content: Text("Este equipamento foi devidamente desinstalado?"),
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
                  color: color,
                ),
              ),
              onPressed: () async {
                bool requestFuture = await context
                    .provide<RequestsRepository>()
                    .deleteTrackerTechnicalVisit(widget.installation.cloudId,
                        widget.tracker.serial, widget.tracker.deviceId);
                if (requestFuture) {
                  Navigator.of(context).pop();

                  //apagando dados para virar um slot vazio
                  widget.tracker.brandName = null;
                  widget.tracker.modelName = null;
                  widget.tracker.serial = null;
                  widget.controller.addTracker(
                      Tracker(
                        serial: widget.tracker.serial,
                        modelName: widget.tracker.modelName,
                        modelTechName: widget.tracker.modelTechName,
                        modelId: widget.tracker.modelId,
                        modelType: widget.tracker.modelType,
                        groupId: widget.tracker.groupId,
                        brandName: widget.tracker.brandName,
                        brandId: widget.tracker.brandId,
                        main: widget.tracker.main,
                        equipmentItemId: widget.tracker.equipmentItemId,
                        groupName: widget.tracker.groupName,
                        installationLocal: widget.tracker.installationLocal,
                        deviceId: widget.tracker.deviceId,
                      ),
                      true,
                      Operation.REMOVED,
                      widget.tracker.serial);

                  _animationController.reverse(
                      from: 1); //remover o slot inteiro
                  _successOnDeleteTracker();
                } else {
                  _deleteErrorDialogInternet(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeSlotDialog(Color color) {
    showDialog(
      context: context,
      barrierColor: color.withOpacity(0.8),
      builder: (context) => ShowUp.tenth(
        duration: 200,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(
              color: color,
              width: 2,
            ),
          ),
          title: Text("Removendo slot"),
          content: Text("Este slot de equipamento foi devidamente removido?"),
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
                  color: color,
                ),
              ),
              onPressed: () async {
                bool deletedOnCloud = await context
                    .provide<RequestsRepository>()
                    .deleteTrackerSlot(widget.tracker.deviceId);
                if (deletedOnCloud) {
                  Navigator.of(context).pop();

                  widget.tracker.brandName = null;
                  widget.tracker.modelName = null;
                  widget.tracker.serial = null;
                  widget.tracker.deviceId = null;
                  widget.tracker.groupName = null;

                  _animationController.reverse(
                      from: 1); //este serve para remover o slot inteiro
                  _successOnDeleteSlot();
                } else {
                  _deleteErrorDialog(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  _getGroupName() {
    if (widget.tracker.groupName != null)
      return Text("Grupo: " + widget.tracker.groupName);
    else {
      return Text("");
    }
  }

  void _deleteErrorDialogInternet(BuildContext context) {
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
          content:
              Text("Verifique sua conexão com a internet e tente novamente"),
        ),
      ),
    );
  }

  void _successOnDeleteTracker() {
    showDialog(
      context: context,
      barrierColor: Colors.green.withOpacity(0.8),
      builder: (context) => ShowUp.tenth(
        duration: 200,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(
              color: Colors.green,
              width: 2,
            ),
          ),
          title: Text("Sucesso"),
          content: Text(
              "Equipamento foi removido com sucesso, se quiser remover o slot também toque no \"X\" do slot."),
        ),
      ),
    );
  }

  void _successOnDeleteSlot() {
    showDialog(
      context: context,
      barrierColor: Colors.green.withOpacity(0.8),
      builder: (context) => ShowUp.tenth(
        duration: 200,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(
              color: Colors.green,
              width: 2,
            ),
          ),
          title: Text("Sucesso"),
          content: Text("Slot foi removido."),
        ),
      ),
    );
  }

  void _deleteErrorDialog(BuildContext context) {
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
          content: Text("Não foi possível remover o slot do equipamento."),
        ),
      ),
    );
  }

  void _startCodeReading(BuildContext context, bool isAdd) async {
    try {
      final scanned = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancelar",
        true,
        ScanMode.QR,
      );

      if (scanned != '-1') {
        //widget.controller.addCodeRead(scanned);
        DeviceController newTracker =
            await widget.controller.addCodeReadTechVisit(scanned);
        if (newTracker.qrCodeError == null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NewTrackerFormPage(
                color: widget.color,
                installationType: widget.installationType,
                controller: widget.controller,
                installation: widget.installation,
                tracker: newTracker,
                isAdd: isAdd,
                animationController: _animationController,
                trackerOld: widget.tracker,
              ),
            ),
          );
        } else
          errorDialog(context);
      }
    } on PlatformException {
      print('Platform exception');
    }
  }

  void errorDialog(BuildContext context) {
    String texto =
        "O equipamento não existe ou não está 'Ativo' e 'Disponível' no sistema.";
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

import 'package:flow_flutter/controller/V2Controllers/custom_page_controller.dart';
import 'package:flow_flutter/controller/V2Controllers/devices_controller.dart';
import 'package:flow_flutter/controller/V2Controllers/devices_new_controller.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/pages/installation/tracker_form_page.dart';
import 'package:flow_flutter/repository/impl/equipment_test_bloc.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/animation/growup.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/pair_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class EquipmentsPageV2 extends StatefulWidget {
  final DevicesNewController controller;

  const EquipmentsPageV2({Key key, @required this.controller})
      : super(key: key);

  @override
  _EquipmentsPageV2State createState() => _EquipmentsPageV2State();
}

class _EquipmentsPageV2State extends State<EquipmentsPageV2> {
  Installation installation;
  Future<List<Tracker>> _trackers;
  EquipmentTestBloc equipmentTestBloc;

  Future<void> _updateTrackers() async {
    setState(() {
      _trackers = context
          .provide<RequestsRepository>()
          .getGroupsByTechnicalVisit(
              technicalVisitId: widget.controller.technicalVisitId,
              groups: widget.controller.groups);
    });
  }

  @override
  void initState() {
    super.initState();

    final customPageController = context.provide<CustomPageController>();
    this.installation = customPageController.installation;

    _updateTrackers();
  }

  @override
  void didChangeDependencies() {
    equipmentTestBloc = context.watch<EquipmentTestBloc>();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Tracker>>(
        future: _trackers,
        builder: (BuildContext context, AsyncSnapshot<List<Tracker>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitWave(
                color: Theme.of(context).colorScheme.secondary,
                size: 30,
              ),
            );
          }
          if (snapshot.hasData) {
            snapshot.data.forEach((tracker) {
              if (tracker.main != null && tracker.main) {
                equipmentTestBloc.add(tracker.serial);
              }
            });

            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  widget.controller.validTrackers(snapshot.data);

                  final tracker = snapshot.data[index];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CardDevice(
                      tracker: tracker,
                      installation: installation,
                      controller: widget.controller,
                      updateTrackers: _updateTrackers
                    )
                  );
                });
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }
}

class CardDevice extends StatefulWidget {
  final Tracker tracker;
  final Installation installation;
  final DevicesNewController controller;
  final Function updateTrackers;

  const CardDevice(
      {Key key,
      @required this.tracker,
      @required this.installation,
      @required this.controller,
      @required this.updateTrackers})
      : super(key: key);

  @override
  _CardDeviceState createState() => _CardDeviceState();
}

class _CardDeviceState extends State<CardDevice> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Card(
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PairWidget.vertical(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    child1: PairWidget.horizontal(
                      child1: Icon(
                        Icons.app_registration,
                        size: 22,
                      ),
                      child2: Text(
                        widget.tracker.groupName,
                        style: theme.textTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    child2: PairWidget.horizontal(
                      child1: widget.tracker.forRemoval
                          ? GrowUp(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 22,
                              ),
                            )
                          : widget.tracker.associate
                              ? GrowUp(
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 22,
                                  ),
                                )
                              : GrowUp(
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 22,
                                  ),
                                ),
                      child2: widget.tracker.forRemoval
                          ? Text('Para remoção')
                          : widget.tracker.associate
                              ? Text('Associado')
                              : Text('Requerido'),
                    ),
                  ),
                  widget.tracker.forRemoval
                      ? FloatingActionButton(
                          heroTag: 'close',
                          mini: true,
                          backgroundColor: theme.colorScheme.surface,
                          child: Icon(
                            Icons.close,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _removeDialog(widget.tracker);
                            // _removeSlotDialog(
                            //     widget.tracker,
                            //     widget.controller.technicalVisitId,
                            //     widget.updateTrackers);
                          })
                      : FloatingActionButton(
                          heroTag: 'edit',
                          mini: true,
                          backgroundColor: theme.colorScheme.surface,
                          child: Icon(
                            Icons.edit,
                            color: Color(0xFFf27800),
                          ),
                          onPressed: () {
                            if (widget.tracker.hardwareFeature != null &&
                                widget.tracker.parent != null &&
                                !widget.tracker.parent.associate) {
                              _errorDialog(
                                  "Por favor associe o equipamento ${widget.tracker.parent.groupName} antes de associar o periférico.");
                              return;
                            }

                            _editDialogOptions(
                                context,
                                widget.tracker,
                                widget.tracker.peripheral != null
                                    ? true
                                    : false,
                                widget.controller);
                          },
                        )
                ],
              ),
            ),
            widget.tracker.peripheral != null &&
                    widget.tracker.peripheral.id != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Row(
                      children: [
                        Text(
                          widget.tracker.peripheral.name,
                          style: theme.textTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
            widget.tracker.installationLocal != null
                ? _localTextField(widget.tracker, widget.installation)
                : SizedBox(),
            widget.tracker.serial != null
                ? _serialTextField(widget.tracker.serial)
                : SizedBox(),
            widget.tracker.virtual
                ? Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Row(
                      children: [Text('Equipamento existente')],
                      //children: [Text('Associação virtual')],
                    ),
                  )
                : SizedBox(),
            SizedBox(height: 10.0)
            // Column(
            //   children: widget.tracker.items
            //       .map((item) => Padding(
            //             padding: const EdgeInsets.all(8.0),
            //             child: Column(
            //               children: [
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                   children: [
            //                     PairWidget.vertical(
            //                       child1: PairWidget.horizontal(
            //                         child1: Icon(
            //                           Icons.account_tree_outlined,
            //                           size: 22,
            //                         ),
            //                         child2: Text(
            //                           item.hardwareFeature.description,
            //                           style: theme.textTheme.bodyText1.copyWith(
            //                             fontWeight: FontWeight.bold,
            //                           ),
            //                         ),
            //                       ),
            //                       child2: PairWidget.horizontal(
            //                         child1:
            //                             (item.serial != null || item.associate)
            //                                 ? GrowUp(
            //                                     child: Icon(
            //                                       Icons.check_circle,
            //                                       color: Colors.green,
            //                                       size: 22,
            //                                     ),
            //                                   )
            //                                 : GrowUp(
            //                                     child: Icon(
            //                                       Icons.error_outline,
            //                                       color: Colors.red,
            //                                       size: 22,
            //                                     ),
            //                                   ),
            //                         child2: item.required
            //                             ? Text('Requerido')
            //                             : SizedBox(),
            //                       ),
            //                     ),
            //                     // item.groupId != null ?
            //                     FloatingActionButton(
            //                       heroTag: 'edit',
            //                       mini: true,
            //                       backgroundColor: theme.colorScheme.surface,
            //                       child: Icon(
            //                         Icons.edit,
            //                         color: Color(0xFFf27800),
            //                       ),
            //                       onPressed: () {
            //                         if (widget.tracker.serial == null ||
            //                             widget.tracker.serial.isEmpty) {
            //                           _errorDialog(
            //                               "Por favor associe o equipamento ${widget.tracker.groupName} antes de associar o periférico.");
            //                         } else {
            //                           if (item.groupId != null) {
            //                             _editDialogOptions(context, item, true,
            //                                 widget.controller);
            //                           } else {
            //                             _associatePeripheralDialog(
            //                                 context, item);
            //                           }
            //                         }
            //                       },
            //                     ),
            //                   ],
            //                 ),
            //                 Row(
            //                   children: [
            //                     Text(
            //                       item.peripheral.name,
            //                       style: theme.textTheme.bodyText1.copyWith(
            //                         fontWeight: FontWeight.bold,
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //                 item.serial != null
            //                     ? _serialTextField(item.serial)
            //                     : SizedBox(),
            //               ],
            //             ),
            //           ))
            //       .toList(),
            // )
          ],
        ),
      ),
    );
  }

  Padding _localTextField(Tracker tracker, Installation installation) {
    InstallationLocal local = installation.installationType.installationLocals
        .firstWhere((local) => local.id == tracker.installationLocal);

    var textLocal = local.name;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: TextEditingController(text: textLocal),
        enabled: false,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            gapPadding: 2,
          ),
          labelText: 'Local da instalação',
        ),
        textCapitalization: TextCapitalization.characters,
      ),
    );
  }

  Padding _serialTextField(String serial) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: TextEditingController(text: serial),
        enabled: false,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            gapPadding: 2,
          ),
          labelText: 'Identificação',
        ),
        textCapitalization: TextCapitalization.characters,
      ),
    );
  }

  void _errorDialog(String text) {
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
          content: Text(text),
        ),
      ),
    );
  }

  // void _associatePeripheralDialog(BuildContext context, Tracker tracker) {
  //   showDialog(
  //       context: context,
  //       barrierColor: Colors.blue.withOpacity(0.8),
  //       builder: (context) => ShowUp.tenth(
  //           duration: 200,
  //           child: AlertDialog(
  //             title: Text('Associar equipamento'),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.all(Radius.circular(16)),
  //               side: BorderSide(
  //                 color: Colors.blue,
  //                 width: 2,
  //               ),
  //             ),
  //             content: Text('Confirma a associação do periférico ?'),
  //             actions: [
  //               TextButton(
  //                 child: Text('Sim'),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                   setState(() {
  //                     tracker.associate = true;
  //                   });
  //                 },
  //               ),
  //               TextButton(
  //                 child: Text('Não'),
  //                 onPressed: () async {
  //                   Navigator.of(context).pop();
  //                 },
  //               )
  //             ],
  //           )));
  // }

  void _successDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.green.withOpacity(0.9),
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
          title: ShowUp.fifth(
            key: ValueKey("success"),
            child: Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 40,
            ),
          ),
          content: ShowUp.fifth(
            key: ValueKey("successText"),
            delay: 200,
            child: Text("Equipamento adicionado com sucesso"),
          ),
        ),
      ),
    );
  }

  void _removeDialog(Tracker tracker) {
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
          title: Text("Desinstalando"),
          content: Text("Este equipamento foi devidamente desinstalado?"),
          actions: [
            TextButton(
              child: Text("Informar permanência equipamento"),
              onPressed: () {
                widget.controller
                    .updateDeviceList(tracker, Operation.NOT_CHANGED, null);
                widget.updateTrackers();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text("Não"),
            ),
            TextButton(
              child: Text(
                "Sim",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
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

                  _successOnDeleteTracker();

                  widget.updateTrackers();

// setState(() {
//       _trackers = context
//           .provide<RequestsRepository>()
//           .getGroupsByTechnicalVisit(
//               technicalVisitId: widget.controller.technicalVisitId,
//               groups: widget.controller.groups);
//     });

                  //   widget.controller.addTracker(
                  //       Tracker(
                  //         serial: widget.tracker.serial,
                  //         modelName: widget.tracker.modelName,
                  //         modelTechName: widget.tracker.modelTechName,
                  //         modelId: widget.tracker.modelId,
                  //         modelType: widget.tracker.modelType,
                  //         groupId: widget.tracker.groupId,
                  //         brandName: widget.tracker.brandName,
                  //         brandId: widget.tracker.brandId,
                  //         main: widget.tracker.main,
                  //         equipmentItemId: widget.tracker.equipmentItemId,
                  //         groupName: widget.tracker.groupName,
                  //         installationLocal: widget.tracker.installationLocal,
                  //         deviceId: widget.tracker.deviceId,
                  //       ),
                  //       true,
                  //       Operation.REMOVED,
                  //       widget.tracker.serial);

                  //   _animationController.reverse(
                  //       from: 1); //remover o slot inteiro
                  //   _successOnDeleteTracker();
                  // } else {
                  //   _deleteErrorDialogInternet(context);
                } else {
                  _errorDialog('Falha ao remover equipamento.');
                }
              },
            ),
          ],
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

  // void _removeSlotDialog(
  //     Tracker tracker, int technicalVisitId, Function updateTrackers) {
  //   showDialog(
  //     context: context,
  //     barrierColor: Colors.blue.withOpacity(0.8),
  //     builder: (context) => ShowUp.tenth(
  //       duration: 200,
  //       child: AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(16)),
  //           side: BorderSide(
  //             color: Colors.blue,
  //             width: 2,
  //           ),
  //         ),
  //         title: Text("Removendo slot"),
  //         content: Text("Este slot de equipamento foi devidamente removido?"),
  //         actions: [
  //           TextButton(
  //               child: Text("Não"),
  //               onPressed: () async {
  //                 // await updateTrackers();
  //                 Navigator.pop(context);
  //               }),
  //           TextButton(
  //             child: Text(
  //               "Sim",
  //               style: TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.blue,
  //               ),
  //             ),
  //             onPressed: () async {
  //               bool successDeleteTracker = await context
  //                   .provide<RequestsRepository>()
  //                   .deleteTrackerTechnicalVisit(
  //                       technicalVisitId, tracker.serial, tracker.deviceId);

  //               if (!successDeleteTracker) {
  //                 _errorDialog('Não foi possível remover o equipamento.');
  //                 Navigator.pop(context);
  //                 return;
  //               }

  //               bool successDeleteSlot = await context
  //                   .provide<RequestsRepository>()
  //                   .deleteTrackerSlot(tracker.deviceId);

  //               if (!successDeleteSlot) {
  //                 _errorDialog('Não foi possível remover o slot.');
  //                 return;
  //               } else {
  //                 Navigator.pop(context);
  //                 _successOnDeleteSlot();
  //                 widget.controller
  //                     .updateDeviceList(tracker, Operation.REMOVED, null);
  //                 widget.updateTrackers();
  //               }
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // void _successOnDeleteSlot() {
  //   showDialog(
  //     context: context,
  //     barrierColor: Colors.green.withOpacity(0.8),
  //     builder: (context) => ShowUp.tenth(
  //       duration: 200,
  //       child: AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(16)),
  //           side: BorderSide(
  //             color: Colors.green,
  //             width: 2,
  //           ),
  //         ),
  //         title: Text("Sucesso"),
  //         content: Text("Slot removido com sucesso."),
  //       ),
  //     ),
  //   );
  // }

  void _editDialogOptions(BuildContext context, Tracker tracker,
      bool isPeripheral, DevicesNewController controller) {
    showDialog(
        context: context,
        barrierColor: Colors.blue.withOpacity(0.8),
        builder: (context) => ShowUp.tenth(
            duration: 200,
            child: AlertDialog(
              title: Text('Associar equipamento'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                side: BorderSide(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
              content: Text('Como deseja associar o equipamento ?'),
              actions: [
                TextButton(
                  child: Text('Manualmente'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return TrackerFormPage(
                        groupName: tracker.groupName,
                        installation: widget.installation,
                        trackerParam: tracker,
                        operation: tracker.serial == null
                            ? Operation.ADDED
                            : Operation.CHANGED,
                        controller: controller,
                        serialNew: null,
                      );
                    })).then((value) async {
                      await widget.updateTrackers();
                    });
                  },
                ),
                TextButton(
                  child: Text('Qr Code'),
                  onPressed: () async {
                    printDebug('Qr Code');

                    final scanned = await FlutterBarcodeScanner.scanBarcode(
                      "#ff6666",
                      "Cancelar",
                      true,
                      ScanMode.QR,
                    );

                    printDebug('QR Code return $scanned');

                    if (scanned != '-1') {
                      var result = await context
                          .provide<RequestsRepository>()
                          .getTrackerForCode(scanned);

                      if (result.error != null) {
                        Navigator.of(context).pop();
                        _errorDialog("O equipamento não existe ou não está 'Ativo' e 'Disponível' no sistema.");
                      } else {
                        printDebug('Serial qrcode escaneado ${result.tracker.serial}');

                        var operation = tracker.serial == null
                            ? Operation.ADDED
                            : Operation.CHANGED;

                        Navigator.of(context).pop();
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return TrackerFormPage(
                            groupName: tracker.groupName,
                            installation: widget.installation,
                            trackerParam: tracker,
                            operation: operation,
                            controller: controller,
                            serialNew: result.tracker.serial
                          );
                        })).then((value) async {
                          await widget.updateTrackers();
                        });
                      }
                    }
                  },
                ),
                tracker.allowVirtual
                    ? TextButton(
                        child: Text('Associar equipamento existente'),
                        onPressed: () async {
                          if (tracker.associate && tracker.virtual) {
                            Navigator.of(context).pop();
                            _errorDialog("O equipamento já está associado.");
                            return;
                          }

                          tracker.virtual = true;

                          try {
                            Tracker trackerResponse = await context
                              .provide<RequestsRepository>()
                              .addTrackerTechnicalVisitV2(widget.installation.cloudId, tracker);

                            Navigator.of(context).pop();
                            
                            if (trackerResponse.serial != "Error") {
                              await widget.updateTrackers();
                              _successDialog();
                            }
                            else {
                              _errorDialog("Erro ao associar equipamento.");
                            }

                          } catch (e) {
                            Navigator.of(context).pop();
                            _errorDialog("Erro ao associar equipamento.");
                          }

                        },
                      )
                    : SizedBox()
              ],
            )));
  }
}

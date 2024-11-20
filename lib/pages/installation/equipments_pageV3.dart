import 'package:dartx/dartx.dart';
import 'package:flow_flutter/controller/V2Controllers/custom_page_controller.dart';
import 'package:flow_flutter/controller/V2Controllers/devices_controller_V3.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/pages/installation/edit_equipment_page.dart';
import 'package:flow_flutter/repository/impl/equipment_test_bloc.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class EquipmentsPageV3 extends StatefulWidget {
  final DevicesControllerV3 controller;

  const EquipmentsPageV3({Key key, @required this.controller})
      : super(key: key);

  @override
  State<EquipmentsPageV3> createState() => _EquipmentsPageV3State();
}

class _EquipmentsPageV3State extends State<EquipmentsPageV3> {
  Installation installation;
  Future<List<Slot>> _slots;
  EquipmentTestBloc equipmentTestBloc;

  Future<void> _updateSlots() async {
    setState(() {
      _slots = context.provide<RequestsRepository>()
        .getSlotsByTechnicalVisit(
          technicalVisitId: widget.controller.technicalVisitId
        );
    });

  }

  @override
  void initState() {
    super.initState();

    final customPageController = context.provide<CustomPageController>();
    this.installation = customPageController.installation;

    _updateSlots();
  }

  @override
  void didChangeDependencies() {
    equipmentTestBloc = context.watch<EquipmentTestBloc>();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Slot>>(
      future: _slots,
      builder: (BuildContext context, AsyncSnapshot<List<Slot>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SpinKitWave(
              color: Theme.of(context).colorScheme.secondary,
              size: 30,
            ),
          );
        } else if (snapshot.hasError) {
          // Caso ocorra um erro durante a execução do Future
          return Center(child: Text('Erro: ${snapshot.error}'));
        } else {
          
          // Caso o Future tenha sido concluído com sucesso
          snapshot.data.forEach((slot) {
            if (slot.main != null && slot.main && slot.serial != null) {
              equipmentTestBloc.add(slot.serial);
            }
          });

          widget.controller.updateReady(snapshot.data);

          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              final slot = snapshot.data[index];
              return new SlotCard(
                slots: snapshot.data,
                slot: slot,
                installation: this.installation,
                updateSlots: this._updateSlots,
                controller: widget.controller
              );
          });
        }
      },
    );
  }
}

class SlotCard extends StatefulWidget {
  final Slot slot;
  final Installation installation;
  final Function updateSlots;
  final List<Slot> slots;
  final DevicesControllerV3 controller;

  const SlotCard({
    Key key, 
    @required this.slot, 
    @required this.installation,
    @required this.updateSlots,
    @required this.slots,
    @required this.controller})
      : super(key: key);

  @override
  State<SlotCard> createState() => _SlotCardState();
}

class _SlotCardState extends State<SlotCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: SlotDescription(slot: widget.slot),
              ),
              Expanded(
                  flex: 1,
                  child: !widget.slot.operationCompleted ? Column(
                    children: [
                      widget.slot.operation != "D" ? // E = Edit
                      IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            printDebug("Edit taped");
                            
                            if(widget.slot.parentId != null) {
                              Slot slotParent = _getParentNoAssociate(widget.slot);
                              if(slotParent != null) {
                                _warningDialog("Por favor, antes de associar o equipamento, por favor associe o equipamento ${slotParent.equipment.name}.");
                              }
                              else {
                                _editDialogOptions(context, widget.slot);
                              }
                            }
                            else {
                              _editDialogOptions(context, widget.slot);
                            }

                            widget.controller.updateReady(widget.slots);
                            
                          }
                      ) : SizedBox(),
                      widget.slot.operation == "D" ? // D = Delete
                        IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {

                              if(widget.slot.parentId != null) {
                                Slot slotParent = _getParent(widget.slot);
                                _warningDialog("Por favor remova o equipamento ${slotParent.equipment.name} ${slotParent.serial}.");
                              }
                              else {
                                await _removeDialog(widget.slot, context);
                              }

                              // if(_verifyChild(widget.slot)) {
                              //   _warningDialog("Por favor remova as câmeras antes de remover este equipamento.");
                              // }
                              // else {
                              // }
                            }
                        ) : SizedBox(),
                    ],
                  ) : SizedBox())
            ],
          ),
        ),
      ),
    );
  }

  Slot _getParent(Slot slot) {
    return widget.slots.firstOrNullWhere((element) => element.deviceId == slot.parentId);
  }

  Slot _getParentNoAssociate(Slot slot) {
    return widget.slots.firstOrNullWhere((element) => element.deviceId == slot.parentId && element.serial == null);
  }

  Future<void> _removeDialog(Slot slot, BuildContext context) async {
    printDebug("Remove dialog");

    bool loading = false;

    showDialog(
        context: context,
        builder: (context) => ShowUp.tenth(
              duration: 200,
              child: AlertDialog(
                title: Text("Remover Equipamento",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                content: loading ?
                  Center(child: CircularProgressIndicator()) :
                  Text("Deseja remover o equipamento ${slot.equipment != null ? slot.equipment.name : slot.group.name}?"),
                actions: [
                  TextButton(
                    child: Text("Cancelar"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    onPressed: () async {

                      if(widget.slot.serial != null) {

                        setState(() {
                          loading = true;
                        });

                        bool success = await context
                          .provide<RequestsRepository>()
                          .deleteTrackerTechnicalVisit(
                              widget.installation.cloudId,
                              widget.slot.serial,
                              widget.slot.deviceId);

                        setState(() {
                          loading = false;
                        });
                            
                        if(!success) {  
                          _errorDialog('Falha ao remover equipamento.');
                          return;
                        }
                      }

                      setState(() {
                        loading = true;
                      });

                      bool success = await context
                          .provide<RequestsRepository>()
                          .deleteTrackerSlot(widget.slot.deviceId);

                      setState(() {
                        loading = false;
                      });

                      if(success) {
                        Navigator.of(context).pop();
                        await _successOnDeleteTracker();
                        widget.updateSlots();
                      }
                      else {
                        _errorDialog('Falha ao remover slot do contrato.');
                      }

                      Navigator.of(context).pop();
                    },
                    child: Text("Remover"),
                  ),
                ],
              ),
            ));
  }

  Future<void> _successOnDeleteTracker() async {
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
          content: Text("Equipamento foi removido com sucesso."),
        ),
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

  void _warningDialog(String text) {
    showDialog(
      context: context,
      barrierColor: Colors.yellow.withOpacity(0.8),
      builder: (context) => ShowUp.tenth(
        duration: 200,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(
              color: Colors.yellow,
              width: 2,
            ),
          ),
          title: Text("Alerta"),
          content: Text(text),
        ),
      ),
    );
  }
  
  void _editDialogOptions(BuildContext context, Slot slot) {

    showDialog(
      context: context, 
      barrierColor: Colors.blue.withOpacity(0.8),
      builder: (context) => ShowUp.tenth(
        duration: 200,
        child: AlertDialog(
          title: Text("Associar Equipamento"),
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
              child: Text("Manualmente"),
              onPressed: () {
                //Fecha o dialog
                Navigator.of(context).pop();

                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) {
                    return EditEquipmentPage(
                      slot: slot,
                      installation: widget.installation
                    );
                    // return TrackerFormPage(
                    //   groupName: tracker.groupName,
                    //   installation: widget.installation,
                    //   trackerParam: tracker,
                    //   operation: tracker.serial == null
                    //       ? Operation.ADDED
                    //       : Operation.CHANGED,
                    //   controller: controller,
                    //   serialNew: null,
                    // );
                  })
                ).then((value) async {
                  await widget.updateSlots();
                });

              }
            ),
            TextButton(
              child: Text("QR Code"),
              onPressed: () async {
                final scanned = await FlutterBarcodeScanner.scanBarcode(
                  "#ff6666",
                  "Cancelar",
                  true,
                  ScanMode.QR,
                );

                if (scanned != '-1') {
                  var result = await context.provide<RequestsRepository>().getTrackerForCode(scanned);
                  if (result.error != null) {
                    Navigator.of(context).pop();
                    _errorDialog("O equipamento não existe ou não está 'Ativo' e 'Disponível' no sistema.");
                  } else {

                    //Fecha o dialog
                    Navigator.of(context).pop();

                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) {
                        return EditEquipmentPage(
                          slot: slot,
                          installation: widget.installation,
                          serialNew: result.tracker.serial
                        );
                        // return TrackerFormPage(
                        //   groupName: tracker.groupName,
                        //   installation: widget.installation,
                        //   trackerParam: tracker,
                        //   operation: tracker.serial == null
                        //       ? Operation.ADDED
                        //       : Operation.CHANGED,
                        //   controller: controller,
                        //   serialNew: null,
                        // );
                      })
                    ).then((value) async {
                      await widget.updateSlots();
                    });

                  }

                }
              }
            )
          ],
          // Column(
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     TextButton(
          //       onPressed: () {
          //         Navigator.of(context).pop();
          //         // _editDialog(context, slot);
          //       },
          //       child: Text("Editar"),
          //     ),
          //     TextButton(
          //       onPressed: () {
          //         Navigator.of(context).pop();
          //         // _changeDialog(context, slot);
          //       },
          //       child: Text("Alterar"),
          //     ),
          //   ],
          // ),
        ),
      )
    );

  }
}

class SlotDescription extends StatelessWidget {
  const SlotDescription({Key key, this.slot}) : super(key: key);

  final Slot slot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            this.slot.equipment != null
                ? this.slot.equipment.name
                : this.slot.group.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        this.slot.hardwareFeature != null ?
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 8.0),
          child: Text(
            this.slot.hardwareFeature.description
          ),
        ) 
        : SizedBox(),
        this.slot.peripheral != null ?
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 8.0),
          child: Text(
            this.slot.peripheral.name
          ),
        ) 
        : SizedBox(),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 8.0),
          child: slot.serial != null
              ? Text(
                  this.slot.serial,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                )
              : slot.virtual
                  ? Text(
                      "Equipamento Virtual",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  : SizedBox(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Badge(
            operationLabel: this.slot.operationName,
            color: this.slot.operationColor,
          ),
        ),
        !slot.operationCompleted ? slot.groupAlter != null || slot.equipmetAlter != null
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Alterar para:",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    this.slot.equipmetAlter != null ?
                    this.slot.equipmetAlter.name :
                    this.slot.groupAlter.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            )
          : SizedBox()
        : SizedBox()
      ],
    );
  }
}

class Badge extends StatelessWidget {
  const Badge({Key key, @required this.operationLabel, @required this.color})
      : super(key: key);

  final String operationLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: this.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            this.operationLabel,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class ExpandableCard extends StatefulWidget {
  const ExpandableCard({Key key}) : super(key: key);

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _isExpanded = !isExpanded;
          });
        },
        children: [
          ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text('Clique para Expandir'),
              );
            },
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Texto que será exibido ao expandir o card.',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            isExpanded: _isExpanded,
          ),
        ],
      ),
    );
  }
}

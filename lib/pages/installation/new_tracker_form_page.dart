import 'package:auto_size_text/auto_size_text.dart';
import 'package:flow_flutter/controller/V2Controllers/devices_controller.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/models/installation_type.dart';
import 'package:flow_flutter/repository/impl/equipment_test_bloc.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/util_extensions.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/pair_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:provider/provider.dart';

class NewTrackerFormPage extends StatefulWidget {
  final Color color;
  final DevicesController controller;
  final InstallationType installationType;
  final Installation installation;
  final DeviceController trackerOld;
  final DeviceController tracker;
  final AnimationController animationController;
  final bool isAdd;

  NewTrackerFormPage({
    Key key,
    @required this.color,
    @required this.controller,
    @required this.installationType,
    @required this.installation,
    this.tracker,
    @required this.isAdd,
    @required this.animationController,
    this.trackerOld,
  }) : super(key: key);

  @override
  _NewTrackerFormPageState createState() => _NewTrackerFormPageState();
}

class _NewTrackerFormPageState extends State<NewTrackerFormPage> {
  EquipmentTestBloc equipmentTestBloc;
  DeviceController tracker;
  bool enabled = true;
  int installationId;
  RequestsRepository requestsRepository;

  TextEditingController _serialController;

  @override
  void initState() {
    super.initState();
    installationId = widget.installation.cloudId;
    if (widget.tracker == null) {
      tracker = DeviceController(Tracker());
    } else
      tracker = widget.tracker;

    _serialController = TextEditingController(text: tracker.serial);
    if (!widget.isAdd && widget.trackerOld != null) {
      tracker.serial = widget.trackerOld.serial;
      tracker.deviceId = widget.trackerOld.deviceId;
      tracker.groupName = widget.trackerOld.groupName;
      tracker.installationLocal = widget.trackerOld.installationLocal;
      tracker.modelId = widget.trackerOld.modelId;
      tracker.brandId = widget.trackerOld.brandId;
    }
  }

  @override
  Widget build(BuildContext context) {
    equipmentTestBloc = Provider.of<EquipmentTestBloc>(context);
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: widget.color,
        flexibleSpace: gradientAppBar(
            color1: widget.color, color2: widget.color.withAlpha(190)),
        shape: appBarBottomShape,
        centerTitle: true,
        title: AutoSizeText(
          'Novo Equipamento',
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(15),
          child: SizedBox(
            height: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
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
                      child1: Icon(
                        Icons.app_registration,
                        size: 22,
                      ),
                      spacing: 8,
                      child2: Text(
                        "Equipamento",
                        style: context.theme.textTheme.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 0),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: _getGroupName(),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: _installationLocalButton(widget.installationType),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    controller: _serialController,
                    enabled: true,
                    onChanged: (text) {
                      if (widget.isAdd) tracker.serial = text;
                    },
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
                const SizedBox(height: 16),
                // const SizedBox(height: 12),
                // _automatedTestWidget(context),
                _saveButton(context),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      // if (widget.controller.isEditable)
    );
  }

  _getGroupName() {
    if (tracker.groupName != null)
      return Text("Grupo: " + tracker.groupName);
    else {
      return Text("");
    }
  }

  Widget _installationLocalButton(
    InstallationType installationType,
  ) {
    return OutlineDropdownButton(
        hint: Text("Local da instalação"),
        inputDecoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          labelText: (tracker.installationLocal == null)
              ? null
              : 'Local da instalação',
        ),
        value: tracker.installationLocal,
        onChanged: (value) {
          if (enabled) {
            setState(() {
              print("value: $value");
              tracker.installationLocal = value;
            });
          }
        },
        items: installationType.installationLocals
            .map(
              (local) => DropdownMenuItem(
                child: Text(local.name),
                value: local.id,
              ),
            )
            .toList());
  }

  Widget _saveButton(BuildContext context) {
    return Visibility(
      visible: true,
      child: widget.controller.waiting
          ? SizedBox(
              width: 100.0,
              height: 60.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SpinKitWave(
                    color: Theme.of(context).colorScheme.secondary,
                    size: 20.0,
                  ),
                  Text("Atualizando")
                ],
              ),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: const StadiumBorder(),
              ),
              child: widget.isAdd
                  ? Text("Adicionar Equipamento")
                  : Text("Salvar Alteração"),
              onPressed: () async {
                
                if (widget.isAdd) {
                  super.setState(() {
                    widget.controller.updateWaiting(true);
                  });
                  //enviando na forma adicionar
                  Tracker requestFuture = await context
                      .provide<RequestsRepository>()
                      .addTrackerTechnicalVisit(
                          installationId, tracker, tracker.installationLocal);
                  if (requestFuture.serial != "Error") {
                    widget.controller
                        .addTracker(requestFuture, true, Operation.ADDED);
                    equipmentTestBloc.add(requestFuture.serial);
                    Navigator.of(context).pop();
                    _successDialog();
                  } else {
                    _noSuchDevice(_serialController.text, context);
                  }
                  super.setState(() {
                    widget.controller.updateWaiting(false);
                  });
                } else {
                 
                  //enviando na forma trocar
                  super.setState(() {
                    widget.controller.updateWaiting(true);
                  });
                  Tracker requestFuture = await context
                      .provide<RequestsRepository>()
                      .changeTrackerTechnicalVisit(
                          widget.installation.cloudId,
                          tracker,
                          _serialController.text,
                          tracker.installationLocal);
                  if (requestFuture.serial != "Error") {
                    widget.controller.addTracker(
                        requestFuture, true, Operation.CHANGED, tracker.serial);
                    equipmentTestBloc.add(requestFuture.serial);
                    Navigator.of(context).pop();
                    widget.animationController.reverse(from: 1);
                    _successDialog();
                  } else {
                    _noSuchDevice(_serialController.text, context);
                  }
                  super.setState(() {
                    widget.controller.updateWaiting(false);
                  });
                }
              }),
    );
  }

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

  void _noSuchDevice(String serial, BuildContext context) {
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
          content: Text("O equipamento com serial " +
              serial +
              " não existe ou não está 'Ativo' e 'Disponível' no sistema."),
        ),
      ),
    );
  }
}

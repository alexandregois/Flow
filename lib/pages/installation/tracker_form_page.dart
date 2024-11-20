import 'package:auto_size_text/auto_size_text.dart';
import 'package:flow_flutter/controller/V2Controllers/devices_controller.dart';
import 'package:flow_flutter/controller/V2Controllers/devices_new_controller.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/repository/impl/equipment_test_bloc.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/util_extensions.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/pair_widget.dart';
import 'package:flutter/material.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:provider/provider.dart';

class TrackerFormPage extends StatefulWidget {
  final String groupName;
  final Installation installation;
  final Tracker trackerParam;
  final Operation operation;
  final DevicesNewController controller;
  final String serialNew;

  const TrackerFormPage(
      {Key key,
      @required this.groupName,
      @required this.installation,
      @required this.trackerParam,
      @required this.operation,
      @required this.controller,
      @required this.serialNew})
      : super(key: key);

  @override
  _TrackerFormPageState createState() => _TrackerFormPageState();
}

class _TrackerFormPageState extends State<TrackerFormPage> {
  EquipmentTestBloc equipmentTestBloc;
  Tracker tracker;
  TextEditingController _serialController;

  @override
  void initState() {
    super.initState();

    this.tracker = widget.trackerParam;

    if(widget.operation == Operation.ADDED) {
      this.tracker.serial = widget.serialNew;
    }

    _serialController = TextEditingController(
      text: widget.serialNew != null ? widget.serialNew : tracker.serial,
    );
  }

  @override
  Widget build(BuildContext context) {
    equipmentTestBloc = Provider.of<EquipmentTestBloc>(context);

    return Scaffold(
      appBar: _appBar(),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        height: 300,
        child: Card(
          margin: EdgeInsets.all(10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(context),
              _groupNameWidget(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlineDropdownButton(
                    hint: Text("Local da instalação"),
                    value: tracker.installationLocal,
                    inputDecoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      labelText: 'Local da instalação',
                    ),
                    onChanged: (installationLocalId) {
                      setState(() {
                        this.tracker.installationLocal = installationLocalId;
                      });
                    },
                    items:
                        widget.installation.installationType.installationLocals
                            .map(
                              (e) => DropdownMenuItem(
                                child: Text(e.name),
                                value: e.id,
                              ),
                            )
                            .toList()),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _serialController,
                  enabled: true,
                  onChanged: (serial) {
                    if (widget.operation == Operation.ADDED) {
                      this.tracker.serial = serial;
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
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
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(widget.operation == Operation.ADDED
                      ? 'Adicionar Equipamento'
                      : 'Editar Equipamento'),
                  onPressed: () async {
                    if (widget.operation == Operation.ADDED) {
                      try {
                        Tracker trackerResponse = await context
                            .provide<RequestsRepository>()
                            .addTrackerTechnicalVisitV2(
                                widget.installation.cloudId, this.tracker);

                        if (trackerResponse.serial != "Error") {
                          if (this.tracker.main) {
                            equipmentTestBloc.add(this.tracker.serial);
                          }

                          widget.controller.updateDeviceList(
                              trackerResponse, Operation.ADDED, tracker.serial);

                          Navigator.pop(context);
                          _successDialog(widget.operation);
                        } else {
                          _noSuchDevice(_serialController.text, context);
                        }
                      } catch (e) {
                        _errorDialog(e.toString());
                      }
                    } else {
                      // Edition mode
                      try {
                        Tracker trackerResponse = await context
                            .provide<RequestsRepository>()
                            .changeTrackerTechnicalVisitV2(
                                widget.installation.cloudId,
                                tracker,
                                _serialController.text);
                        if (trackerResponse.serial != "Error") {
                          if (tracker.main) {
                            equipmentTestBloc.add(tracker.serial);
                          }

                          widget.controller.updateDeviceList(trackerResponse,
                              Operation.CHANGED, tracker.serial);
                          Navigator.pop(context);
                          _successDialog(widget.operation);
                        } else {
                          _noSuchDevice(_serialController.text, context);
                        }
                      } catch (e) {
                        _errorDialog(e.message);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
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

  void _successDialog(Operation operation) {
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
            child: Text(operation == Operation.ADDED
                ? "Equipamento adicionado com sucesso"
                : "Equipamento editado com sucesso"),
          ),
        ),
      ),
    );
  }

  Center _groupNameWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Text("Grupo: ${widget.groupName}"),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: PairWidget.horizontal(
        child1: Icon(
          Icons.app_registration,
          size: 22,
        ),
        child2: Text(
          "Equipamento",
          style: context.theme.textTheme.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      // backgroundColor: widget.color,
      flexibleSpace: gradientAppBar(
          color1: Colors.blue, color2: Colors.blue.withAlpha(190)),
      shape: appBarBottomShape,
      centerTitle: true,
      title: AutoSizeText(
        widget.operation == Operation.ADDED
            ? 'Novo Equipamento'
            : 'Editar Equipamento',
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(15),
        child: SizedBox(
          height: 15,
        ),
      ),
    );
  }
}

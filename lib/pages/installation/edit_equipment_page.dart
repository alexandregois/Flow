import 'package:auto_size_text/auto_size_text.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/util_extensions.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/pair_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:groovin_widgets/groovin_widgets.dart';

class EditEquipmentPage extends StatefulWidget {
  final Slot slot;
  final Installation installation;
  final String serialNew;

  const EditEquipmentPage({
    Key key, 
    @required this.slot,
    @required this.installation,
    this.serialNew
  }) : super(key: key);

  @override
  State<EditEquipmentPage> createState() => _EditEquipmentPageState();
}

class _EditEquipmentPageState extends State<EditEquipmentPage> {

  TextEditingController _serialController;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    _serialController = TextEditingController(
      text: widget.serialNew != null ? widget.serialNew : widget.slot.serial
    );

    widget.slot.serial = widget.serialNew != null ? widget.serialNew : widget.slot.serial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: loading ?
        Center(
            child: SpinKitWave(
              color: Theme.of(context).colorScheme.secondary,
              size: 30,
            ),
          ) : _body(context),
    );
  }

  AppBar _appBar() {
    return AppBar(
      // backgroundColor: widget.color,
      flexibleSpace: gradientAppBar(
          color1: Colors.blue,
          color2: Colors.blue.withAlpha(190)
      ),
      shape: appBarBottomShape,
      centerTitle: true,
      title: AutoSizeText(
        widget.slot.operation == 'A'
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
              // _groupNameWidget(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlineDropdownButton(
                    hint: Text("Local da instalação"),
                    value: widget.slot.installationLocalId,
                    inputDecoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      labelText: 'Local da instalação',
                    ),
                    onChanged: (installationLocalId) {
                      setState(() {
                        widget.slot.installationLocalId = installationLocalId;
                      });
                    },
                    items:
                        widget.installation.installationType.installationLocals
                            .map(
                              (installationLocal) => DropdownMenuItem(
                                child: Text(installationLocal.name),
                                value: installationLocal.id,
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
                    if (widget.slot.operation == "A") {
                      widget.slot.serial = serial;
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
                  child: Text(widget.slot.operation == 'A'
                      ? 'Adicionar Equipamento'
                      : 'Editar Equipamento'),
                  onPressed: () async {

                    printDebug("Editar equipamento tape");

                    setState(() {
                      loading = true;
                    });

                    if (widget.slot.operation == 'A') {
                      printDebug("Adicionar");
                      try {
                        Tracker trackerResponse = await context
                            .provide<RequestsRepository>()
                            .addTrackerTechnicalVisitV3(widget.installation.cloudId, widget.slot);

                        if (trackerResponse.serial != "Error") {
                          // if (this.tracker.main) {
                          //   equipmentTestBloc.add(this.tracker.serial);
                          // }

                          // widget.controller.updateDeviceList(trackerResponse, Operation.ADDED, tracker.serial);

                          Navigator.pop(context);
                          _successDialog(widget.slot);
                        } else {
                          _noSuchDevice(_serialController.text, context);
                        }
                      } catch (e) {
                        _errorDialog(e.toString());
                      }
                      setState(() {
                        loading = false;
                      });

                    } 
                    else {
                      // Edition mode
                      try {
                        Tracker trackerResponse = await context
                            .provide<RequestsRepository>()
                            .changeTrackerTechnicalVisitV3(
                              widget.installation.cloudId,
                              widget.slot,
                              _serialController.text
                            );

                        setState(() {
                          loading = false;
                        });
                        
                        if (trackerResponse.serial != "Error") {
                          printDebug("Sucesso ao alterar equipamento");
                          // if (tracker.main) {
                          //   equipmentTestBloc.add(tracker.serial);
                          // }

                          // widget.controller.updateDeviceList(trackerResponse,
                          //     Operation.CHANGED, tracker.serial);
                          Navigator.pop(context);
                          _successDialog(widget.slot);
                        } else {
                          printDebug("Erro ao alterar equipamento");
                          _noSuchDevice(_serialController.text, context);
                        }
                      } catch (e) {
                        setState(() {
                          loading = false;
                        });
                        printDebug("EXCEÇÃO: " + e.toString());
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

  void _successDialog(Slot slot) {
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
            child: Text(slot.operation == 'A'
                ? "Equipamento adicionado com sucesso"
                : "Equipamento editado com sucesso"),
          ),
        ),
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

}




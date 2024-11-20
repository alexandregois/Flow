import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dartx/dartx.dart';
import 'package:flow_flutter/controller/V2Controllers/checklist_controller_V2.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/pages/installation/show_signature_page.dart';
import 'package:flow_flutter/pages/signature_page.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/no_glow_behavior.dart';
import 'package:flow_flutter/widget/lazy_stream_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ChecklistPage extends StatefulWidget {
  final ChecklistControllerV2 controller;
  // final Color backgroundColor;

  ChecklistPage({Key key, @required this.controller}) : super(key: key);

  @override
  _ChecklistPageState createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage>
    with AutomaticKeepAliveClientMixin {
  TextEditingController _commentary;

  @override
  void initState() {
    _commentary = TextEditingController(text: widget.controller.commentary);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // final installationController = context.provide<InstallationController>();

    // var outlineInputBorder = OutlineInputBorder(
    //   borderRadius: const BorderRadius.all(Radius.circular(10)),
    //   gapPadding: 2,
    // );
    var theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: (widget.controller.checklistConfig.requireSign)
          ? (widget.controller.signatureUri == null)
              ? FloatingActionButton.extended(
                  icon: Icon(Icons.touch_app),
                  label: Text("Assinatura"),
                  backgroundColor: theme.colorScheme.secondary,
                  onPressed: () => _onSignatureClick(),
                )
              : FloatingActionButton.extended(
                  icon: Icon(Icons.check),
                  label: Text("Assinatura"),
                  backgroundColor: Colors.green,
                  onPressed: () => _onSignatureClick(),
                )
          : null,
      body: LazyStreamBuilder<List<CheckListItems>>(
          stream: widget.controller,
          builder: (context, snapshot) => Column(
                children: [
                  Expanded(
                    child: snapshot.data?.firstOrNull != null
                        ? ScrollConfiguration(
                            behavior: NoGlowBehavior(),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 60),
                              child: ListView(
                                  padding: const EdgeInsets.all(8),
                                  children: [
                                    ...snapshot.data
                                        .map((item) => _ChecklistItemRow(
                                              // item: item,
                                              key: ValueKey(item.key),
                                              listingItem: item,
                                              controller: widget.controller,
                                            ))
                                        .toList()
                                          ..sort((a, b) => a.listingItem.order
                                              .compareTo(b.listingItem.order)),
                                    // PhotoLoaderCard(),
                                  ]),
                            ),
                          )
                        : Center(
                            child: Text("Nenhuma checagem a fazer"),
                          ),
                  ),
                ],
              )),
    );
  }

  void _onSignatureClick() {
    if (widget.controller.signatureUri == null) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => SignaturePage()))
          .then((it) => _saveSignaturePicture(it));
    } else {
      // Navigator.of(context).push(MaterialPageRoute(
      //   builder: (context) => ShowSignaturePage(
      //     signatureUri: widget.controller.signatureUri,
      //   ),
      // ));

      showDialog(
        context: context,
        builder: (context) => ShowUp.tenth(
          child: Dialog(
            clipBehavior: Clip.antiAlias,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: ShowSignaturePage(
              signatureUri: widget.controller.signatureUri,
            ),
          ),
        ),
      ).then((value) {
        if (value == true) {
          setState(() {
            widget.controller.updateSignatureUri(null);
          });
        }
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _commentary.dispose();
    super.dispose();
  }

  void _saveSignaturePicture([ByteData byteDate]) async {
    if (byteDate != null) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      var now = DateTime.now().millisecondsSinceEpoch;

      final signaturePath = '${appDocDir.path}/Signatures/$now.jpeg';

      _deleteOldSignaturePhoto();

      final newSignature = File(signaturePath)..createSync(recursive: true);

      newSignature
          .writeAsBytes(byteDate.buffer.asUint8List(
            byteDate.offsetInBytes,
            byteDate.lengthInBytes,
          ))
          .then((value) => setState(() {
                widget.controller.updateSignatureUri(Uri.parse(signaturePath));
              }));
    }
  }

  void _deleteOldSignaturePhoto() {
    if (widget.controller.signatureUri != null) {
      setState(() {
        File(widget.controller.signatureUri.toString()).delete();
        widget.controller.updateSignatureUri(null);
      });
    }
  }
}

class _ChecklistItemRow extends StatelessWidget {
  // final ChecklistInstallationItem item;
  final CheckListItems listingItem;
  final ChecklistControllerV2 controller;

  const _ChecklistItemRow({
    Key key,
    // this.item,
    this.controller,
    this.listingItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final required = (listingItem.required && listingItem.checked == null);
    int initialIndex = listingItem.checked == null
        ? -1
        : listingItem.checked
            ? 1
            : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        elevation: 2.5,
        shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        child: Container(
          decoration: required
              ? BoxDecoration(
                  color: Colors.white,
                  // shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 2, color: Colors.red, spreadRadius: 0.5)
                  ],
                )
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 3, 0, 3),
                  child: AutoSizeText(
                    listingItem.name,
                    minFontSize: 12,
                    // style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              ToggleSwitch(
                  minHeight: 45,
                  minWidth: 70.0,
                  initialLabelIndex: initialIndex,
                  cornerRadius: 12,
                  activeBgColor: Colors.green,
                  inactiveBgColor: Colors.white54,
                  labels: ['Não', 'Sim'],
                  activeBgColors: [Colors.red, Colors.green],
                  onToggle: (index) {
                    controller.updateItem(listingItem.key, index);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

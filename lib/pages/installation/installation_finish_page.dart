// import 'dart:async';
// import 'dart:io';
//
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:dartx/dartx.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flow_flutter/controller/V2Controllers/custom_page_controller.dart';
// import 'package:flow_flutter/controller/V2Controllers/finish_controller.dart';
// import 'package:flow_flutter/pages/installation/show_signature_page.dart';
// import 'package:flow_flutter/utils/animation/showup.dart';
// import 'package:flow_flutter/utils/installation_step.dart';
// import 'package:flow_flutter/utils/no_glow_behavior.dart';
// import 'package:flow_flutter/utils/utils.dart';
// import 'package:flow_flutter/widget/lazy_stream_builder.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:toggle_switch/toggle_switch.dart';
//
// import '../signature_page.dart';
// import '../tech_visit_list_page.dart';
// import 'installation_get_finish_location_page.dart';
// import 'installation_page.dart';
//
// class InstallationFinishPage extends StatefulWidget {
//   final FinishController controller;
//
//   InstallationFinishPage({Key key, this.controller}) : super(key: key);
//
//   @override
//   _InstallationFinishPageState createState() => _InstallationFinishPageState();
// }
//
// class _InstallationFinishPageState extends State<InstallationFinishPage>
//     with AutomaticKeepAliveClientMixin {
//   TextEditingController _comments;
//   TextEditingController _commentsViolation;
//   TextEditingController _commentsPendencyItem;
//   CustomPageController customPageController;
//   Timer _updateObservationTimer;
//   int _initialIndex = 0;
//   int _indexPendencyItem = 0;
//   bool _isItemSelected = false;
//   Key _dropdownKey = UniqueKey();
//
//   @override
//   void initState() {
//     super.initState();
//
//     ///GlobalData.visitType = "M";
//
//     if (globalVisitType == "M" ||
//         globalVisitType == "U" ||
//         globalVisitType == "A")
//     simulateToggleSwitchClick();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       onToggleSwitch(1);
//     });
//
//     _comments = TextEditingController(text: widget.controller.observation);
//     _commentsViolation = TextEditingController();
//     _commentsPendencyItem = TextEditingController();
//     customPageController = context.provide<CustomPageController>();
//   }
//
//   void onToggleSwitch(int index) {
//     setState(() {
//       _initialIndex = index;
//     });
//   }
//
//   @override
//   void didChangeDependencies() {
//     print(widget.controller.observation);
//     _comments ??= TextEditingController(
//       text: widget.controller.observation,
//     );
//     customPageController ??= context.provide<CustomPageController>();
//     super.didChangeDependencies();
//   }
//
//   void simulateToggleSwitchClick() {
//     setState(() {
//       _initialIndex = 1;
//       _isItemSelected = false;
//     });
//
//     _updateContainsViolation(true);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     var backgroundColor = Theme.of(context).colorScheme.primary;
//
//     var outlineInputBorder = OutlineInputBorder(
//       borderRadius: const BorderRadius.all(Radius.circular(10)),
//       gapPadding: 2,
//     );
//
//     const cardShape = const RoundedRectangleBorder(
//       borderRadius: const BorderRadius.all(Radius.circular(10)),
//     );
//     var theme = Theme.of(context);
//     print("Fim assinatura " + widget.controller.signatureUri.toString());
//     return Scaffold(
//       body: LazyStreamBuilder<List<InstallationPart>>(
//         stream: customPageController,
//         builder: (context, snapshot) {
//           return Stack(
//             children: [
//               ScrollConfiguration(
//                 behavior: NoGlowBehavior(),
//                 child: ListView(
//                   children: [
//                     if (customPageController.isEditable)
//                       Card(
//                         margin: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         shape: cardShape,
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             ...snapshot.data.map((e) {
//                               var index = snapshot.data.indexOf(e);
//                               if (index != snapshot.data.lastIndex)
//                                 return _InstallationReadyCard(
//                                     e, index, widget.controller, false);
//                               else
//                                 return _InstallationReadyCard(
//                                     e, index, widget.controller, true);
//                             })
//                           ],
//                         ),
//                       ),
//                     Card(
//                       margin: const EdgeInsets.symmetric(horizontal: 16),
//                       shape: cardShape,
//                       child: Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             TextField(
//                               controller: _comments,
//                               inputFormatters: [
//                                 TextInputFormatter.withFunction(
//                                         (oldValue, newValue) {
//                                       if (oldValue.text.contains("RST01 - ") ||
//                                           oldValue.text.contains("RST02 - ") ||
//                                           oldValue.text.contains("RST03 - ") ||
//                                           oldValue.text.contains("RCT01 - ") ||
//                                           oldValue.text.contains("RCT02 - ") ||
//                                           oldValue.text.contains("SA001 - ")) {
//                                         if (oldValue.text.startsWith(newValue.text) &&
//                                             newValue.selection.start <= 8) {
//                                           return oldValue;
//                                         }
//                                       }
//                                       return newValue;
//                                     }),
//                               ],
//                               enabled: customPageController.isEditable,
//                               keyboardType: TextInputType.multiline,
//                               maxLines: 6,
//                               minLines: 3,
//                               decoration: InputDecoration(
//                                 focusColor: backgroundColor,
//                                 hoverColor: backgroundColor,
//                                 fillColor: backgroundColor,
//                                 border: outlineInputBorder,
//                                 labelText: 'Comentários em Geral',
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 12,
//                                   vertical: 8,
//                                 ),
//                               ),
//                               textCapitalization: TextCapitalization.none,
//                               onChanged: _updateComments,
//                             ),
//                             (globalVisitType == "M" ||
//                                 globalVisitType == "U" ||
//                                 globalVisitType == "A")
//                                 ? Column(
//                               children: [
//                                 const SizedBox(height: 10),
//                                 if (_initialIndex == 1) ...[
//                                   const SizedBox(height: 25),
//                                   Align(
//                                     alignment: Alignment.centerLeft,
//                                     child: Text(
//                                         "Selecione o motivo de mau uso ou violação"),
//                                   ),
//                                   const SizedBox(height: 10),
//                                   DropdownSearch<String>(
//                                     key: _dropdownKey,
//                                     items: [
//                                       "RST01 - Reposicionamento/Recolocação – (Cliente)",
//                                       "RST02 - Falha na instalação anterior (Técnico)",
//                                       "RST03 - Desvio no componente, sem troca (Maxtrack)",
//                                       "RCT01 - Dano físico (Cliente)",
//                                       "RCT02 - Desvio no componente, com troca (Maxtrack)",
//                                       "SA001 - Sem Alteração",
//                                     ],
//                                     onChanged: (value) {
//                                       if (value != null) {
//                                         setState(() {
//                                           _comments.text = _comments.text
//                                               .replaceAll("RST01 - ", "")
//                                               .replaceAll("RST02 - ", "")
//                                               .replaceAll("RST03 - ", "")
//                                               .replaceAll("RCT01 - ", "")
//                                               .replaceAll("RCT02 - ", "")
//                                               .replaceAll("SA001 - ", "");
//
//                                           if (_comments.text.length > 1) {
//                                             if (_comments.text.indexOf(value
//                                                 .substring(0, 5)) ==
//                                                 -1)
//                                               _comments.text =
//                                                   value.substring(0, 5) +
//                                                       " - " +
//                                                       _comments.text;
//                                           } else {
//                                             _comments.text =
//                                                 value.substring(0, 5) +
//                                                     " - ";
//                                           }
//
//                                           _isItemSelected = true;
//                                           _dropdownKey = UniqueKey();
//                                         });
//                                       }
//                                     },
//                                     dropdownDecoratorProps:
//                                     DropDownDecoratorProps(
//                                       dropdownSearchDecoration:
//                                       InputDecoration(
//                                         //labelText: "Selecione um motivo",
//                                         contentPadding:
//                                         EdgeInsets.symmetric(
//                                             horizontal: 12,
//                                             vertical: 4),
//                                         border: OutlineInputBorder(
//                                             borderRadius:
//                                             BorderRadius.circular(10)),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ],
//                             )
//                                 : Container(),
//                             const SizedBox(height: 35),
//                             _isItemSelected == true
//                                 ? Text(
//                                 "Quais equipamentos e quais foram os motivos de mau uso ou violação ?")
//                                 : Container(),
//                             _isItemSelected == true
//                                 ? TextField(
//                               controller: _commentsViolation,
//                               enabled: customPageController.isEditable,
//                               // && _isItemSelected,
//                               keyboardType: TextInputType.multiline,
//                               maxLines: 7,
//                               minLines: 3,
//                               decoration: InputDecoration(
//                                 focusColor: backgroundColor,
//                                 hoverColor: backgroundColor,
//                                 fillColor: backgroundColor,
//                                 border: outlineInputBorder,
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 12,
//                                   vertical: 8,
//                                 ),
//                               ),
//                               textCapitalization: TextCapitalization.none,
//                               onChanged: _updateCommentsViolation,
//                             )
//                                 : Container(),
//                             const SizedBox(height: 25),
//                             Text("Algum item não pode ser instalado?"),
//                             const SizedBox(height: 25),
//                             ToggleSwitch(
//                                 minHeight: 45,
//                                 minWidth: 70.0,
//                                 initialLabelIndex: _indexPendencyItem,
//                                 cornerRadius: 12,
//                                 activeBgColor: Colors.green,
//                                 inactiveBgColor: Colors.white54,
//                                 labels: ['Não', 'Sim'],
//                                 activeBgColors: [Colors.green, Colors.red],
//                                 onToggle: (index) {
//                                   setState(() {
//                                     _indexPendencyItem = index;
//                                   });
//                                   _updateContainsPendencyItem(
//                                       index == 0 ? false : true);
//                                 }),
//                             _indexPendencyItem == 1
//                                 ? Padding(
//                               padding: EdgeInsets.only(top: 15),
//                               child: Text(
//                                   "Quais items ficaram pendentes para instalação ?"),
//                             )
//                                 : Container(),
//                             _indexPendencyItem == 1
//                                 ? TextField(
//                               controller: _commentsPendencyItem,
//                               enabled: customPageController.isEditable,
//                               keyboardType: TextInputType.multiline,
//                               maxLines: 6,
//                               minLines: 3,
//                               decoration: InputDecoration(
//                                 focusColor: backgroundColor,
//                                 hoverColor: backgroundColor,
//                                 fillColor: backgroundColor,
//                                 border: outlineInputBorder,
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 12,
//                                   vertical: 8,
//                                 ),
//                               ),
//                               textCapitalization: TextCapitalization.none,
//                               onChanged: _updateCommentsPendencyItem,
//                             )
//                                 : Container(),
//                             const SizedBox(height: 25),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                   ],
//                 ),
//               ),
//               if (widget.controller.finishConfig.requireSign)
//                 Positioned(
//                   right: 16,
//                   bottom: 80, // Ajuste a posição conforme necessário
//                   child: FloatingActionButton.extended(
//                     icon: widget.controller.signatureUri == null
//                         ? Icon(Icons.touch_app)
//                         : Icon(Icons.check),
//                     label: Text("Assinatura"),
//                     backgroundColor: widget.controller.signatureUri == null
//                         ? theme.colorScheme.secondary
//                         : Colors.green,
//                     onPressed: () => _onSignatureClick(),
//                   ),
//                 ),
//               Positioned(
//                 bottom: 11,
//                 left: 0,
//                 right: 0,
//                 child: Center(
//                   child: LazyStreamBuilder<bool>(
//                     stream: customPageController.readyStream,
//                     builder: (context, snapshot) => ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         shape: const StadiumBorder(),
//                       ),
//                       child: Text("Finalizar instalação"),
//                       onPressed: snapshot.data
//                           ? () {
//                         if (_comments.text.isEmpty || _comments.text.length < 3) {
//                           showDialog(
//                             context: context,
//                             builder: (context) => AlertDialog(
//                               title: Text("Erro"),
//                               content: Text("Por favor, preencha o campo de comentários."),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.of(context).pop(),
//                                   child: Text("OK"),
//                                 ),
//                               ],
//                             ),
//                           );
//                         } else if (!_isItemSelected && (globalVisitType == "M" ||
//                             globalVisitType == "U" ||
//                             globalVisitType == "A")) {
//                           showDialog(
//                             context: context,
//                             builder: (context) => AlertDialog(
//                               title: Text("Erro"),
//                               content: Text("Por favor, selecione um item."),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.of(context).pop(),
//                                   child: Text("OK"),
//                                 ),
//                               ],
//                             ),
//                           );
//                         } else {
//                           _onFinished(customPageController, context);
//                         }
//                       }
//                           : null,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//
//
//   void _validateAndProceed() {
//     if (_comments.text.isEmpty || _comments.text.length < 5) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text("Erro"),
//           content: Text(
//               "Você deve selecionar um motivo e o campo de comentários deve ter no mínimo 100 caracteres."),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text("OK"),
//             ),
//           ],
//         ),
//       );
//       return;
//     }
//
//     if (_comments.text.length < 100) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text("Erro"),
//           content:
//               Text("O campo de comentários deve ter no mínimo 100 caracteres."),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text("OK"),
//             ),
//           ],
//         ),
//       );
//       return;
//     }
//
//     _onFinished(customPageController, context);
//   }
//
//   void _onFinished(
//       CustomPageController customPageController,
//       BuildContext context,
//       ) {
//
//     List<String> codes = [
//       "RST01",
//       "RST02",
//       "RST03",
//       "RCT01",
//       "RCT02",
//       "SA001",
//     ];
//
//     // Verifica se _comments.text contém pelo menos um dos códigos
//     bool containsCode = codes.any((code) => _comments.text.contains(code));
//
//     if (!containsCode && (globalVisitType == "M" ||
//         globalVisitType == "U" ||
//         globalVisitType == "A")) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text("Erro"),
//           content: Text("Por favor, inclua pelo menos um dos códigos necessários em Comentários."),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text("OK"),
//             ),
//           ],
//         ),
//       );
//     } else {
//       Navigator.of(context).push(MaterialPageRoute(builder: (context) {
//           return InstallationGetFinishLocationPage(
//           color: Colors.blue,
//           installation: customPageController.installation,
//           customPageController: customPageController,
//         );
//       })).then(Navigator.of(context).pop);
//     }
//   }
//
//   @override
//   bool get wantKeepAlive => true;
//
//   void _updateComments(String text) {
//     _updateObservationTimer?.cancel();
//     _updateObservationTimer = Timer(250.milliseconds, () {
//       widget.controller.observation = text;
//     });
//     widget.controller.updateComments(text);
//   }
//
//   void _updateCommentsViolation(String text) {
//     _updateObservationTimer?.cancel();
//     _updateObservationTimer = Timer(250.milliseconds, () {
//       widget.controller.observationViolation = text;
//     });
//     widget.controller.updateCommentsViolation(text);
//   }
//
//   void _updateCommentsPendencyItem(String text) {
//     _updateObservationTimer?.cancel();
//     _updateObservationTimer = Timer(250.milliseconds, () {
//       widget.controller.observationPendencyItem = text;
//     });
//     widget.controller.updateCommentsPendencyItem(text);
//   }
//
//   void _updateContainsViolation(bool containsViolation) {
//     widget.controller.updateContainsViolation(containsViolation);
//   }
//
//   void _updateContainsPendencyItem(bool containsPendencyItems) {
//     widget.controller.updatePendencyItem(containsPendencyItems);
//   }
//
//   @override
//   void dispose() {
//     // _customerEmail.dispose();
//     _comments.dispose();
//     super.dispose();
//   }
//
//   void _saveSignaturePicture([ByteData byteDate]) async {
//     if (byteDate != null) {
//       Directory appDocDir = await getApplicationDocumentsDirectory();
//       var now = DateTime.now().millisecondsSinceEpoch;
//
//       final signaturePath = '${appDocDir.path}/Signatures/$now.jpeg';
//
//       _deleteOldSignaturePhoto();
//
//       final newSignature = File(signaturePath)..createSync(recursive: true);
//       newSignature
//           .writeAsBytes(byteDate.buffer.asUint8List(
//             byteDate.offsetInBytes,
//             byteDate.lengthInBytes,
//           ))
//           .then((value) => setState(() {
//                 widget.controller.updateSignatureUri(Uri.parse(signaturePath));
//               }));
//     }
//   }
//
//   void _deleteOldSignaturePhoto() {
//     widget.controller.updateSignatureUri(null);
//     if (widget.controller.signatureUri != null) {
//       try {
//         File(widget.controller.signatureUri.toString()).delete();
//       } catch (e) {
//         print(e);
//       }
//     }
//   }
//
//   void _onSignatureClick() {
//     if (widget.controller.signatureUri == null) {
//       Navigator.of(context)
//           .push(MaterialPageRoute(builder: (context) => SignaturePage()))
//           .then((it) => _saveSignaturePicture(it));
//     } else {
//
//       showDialog(
//         context: context,
//         builder: (context) => ShowUp.tenth(
//           child: Dialog(
//             clipBehavior: Clip.antiAlias,
//             shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(Radius.circular(16)),
//             ),
//             child: ShowSignaturePage(
//               signatureUri: widget.controller.signatureUri,
//             ),
//           ),
//         ),
//       ).then((value) {
//         if (value == true) {
//           setState(() {
//             widget.controller.updateSignatureUri(null);
//           });
//         }
//       });
//     }
//   }
// }
//
// class _InstallationReadyCard extends StatelessWidget {
//   final InstallationPart controller;
//   final int index;
//   final FinishController finishController;
//   final bool isFinish;
//
//   _InstallationReadyCard(
//       this.controller, this.index, this.finishController, this.isFinish);
//
//   @override
//   Widget build(BuildContext context) {
//     var theme = Theme.of(context);
//
//     return LazyStreamBuilder<ReadyState>(
//         stream: controller.readyStream,
//         builder: (context, snapshot) {
//           final state = snapshot.data;
//           Color readyColor;
//           IconData readyIcon;
//           String subtitle;
//           bool ready;
//
//           switch (snapshot.data.status) {
//             case ReadyStatus.notReady:
//               readyColor = theme.colorScheme.error;
//               readyIcon = Icons.error_outline_outlined;
//               subtitle = state.message;
//               ready = false;
//               break;
//
//             case ReadyStatus.ready:
//               readyColor = Colors.green;
//               readyIcon = Icons.check_circle;
//               subtitle = 'Concluído';
//               ready = true;
//               break;
//
//             case ReadyStatus.warning:
//               readyColor = Colors.yellow[600];
//               readyIcon = Icons.warning_rounded;
//               subtitle = state.message;
//               ready = false;
//               break;
//           }
//
//           return ready
//               ? Container()
//               : InkWell(
//                   onTap: () => finishController.changeTabs(index),
//                   child: ListTile(
//                     trailing: Icon(
//                       readyIcon,
//                       color: readyColor,
//                     ),
//                     title: isFinish ? Text(subtitle) : Text(controller.name),
//                     subtitle: isFinish
//                         ? null
//                         : subtitle != null
//                             ? AutoSizeText(
//                                 subtitle,
//                                 style: theme.textTheme.bodySmall,
//                                 minFontSize: 8,
//                               )
//                             : null,
//                   ),
//                 );
//         });
//   }
// }

import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dartx/dartx.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flow_flutter/controller/V2Controllers/custom_page_controller.dart';
import 'package:flow_flutter/controller/V2Controllers/finish_controller.dart';
import 'package:flow_flutter/pages/installation/show_signature_page.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/installation_step.dart';
import 'package:flow_flutter/utils/no_glow_behavior.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/lazy_stream_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../controller/V2Controllers/tech_visit_list_controller.dart';
import '../../models/reasonFinish.dart';
import '../../widget/reasonDropdownSearch.dart';
import '../../widget/reasonFinishListWidget.dart';
import '../signature_page.dart';
import '../tech_visit_list_page.dart';
import 'installation_get_finish_location_page.dart';
import 'installation_page.dart';

class InstallationFinishPage extends StatefulWidget {
  final FinishController controller;

  InstallationFinishPage({Key key, this.controller}) : super(key: key);

  @override
  _InstallationFinishPageState createState() => _InstallationFinishPageState();
}

class _InstallationFinishPageState extends State<InstallationFinishPage>
    with AutomaticKeepAliveClientMixin {
  TextEditingController _comments;
  TextEditingController _commentsViolation;
  TextEditingController _commentsPendencyItem;
  TextEditingController _generalCommentsController;
  CustomPageController customPageController;
  Timer _updateObservationTimer;
  int _initialIndex = 0;
  int _initialMotivoIndex = 1;
  int _indexPendencyItem = 0;
  bool _isItemSelected = false;
  Key _dropdownKey = UniqueKey();

  List<ReasonFinish> selectedReasons = [];
  bool _showReasonFinishListWidget = false;
  int _indiceInicialMauUso = 0;

  // Variável que armazena o motivo selecionado
  ReasonFinish selectedReason;

  String strMotivoMauUso = '';

  List<String> _dropdownItems = [
    "RST02 - Falha na instalação anterior (Técnico)",
    "RST03 - Desvio no componente, sem troca (Maxtrack)",
    "RCT02 - Desvio no componente, com troca (Maxtrack)",
    "SA001 - Sem Alteração"
  ];

  @override
  void initState() {
    super.initState();

    // Carregar os comentários salvos ao inicializar a página
    _getSelectedVisitId().then((visitId) {
      if (visitId != null) {
        _loadGeneralComments(visitId).then((value) {
          setState(() {
            _generalCommentsController.text = value;
          });
        });


        _loadSelectedReasons(visitId).then((_) {
          setState(() {
            // Se houver um motivo salvo, ele será atribuído ao selectedReason
            if (selectedReason != null) {
              // Aqui você pode atualizar a UI com o motivo salvo
              selectedReasons = [selectedReason]; // Cria uma lista com o único motivo
            }
          });
        });

        _loadSelectedDropdownValue(visitId).then((selectedValue) {
          setState(() {
            if (selectedValue.isNotEmpty) {
              // _generalCommentsController.text =
              //     selectedValue + "\n" + _generalCommentsController.text;
            }
          });
        });

        _loadSelectedToggleSwitch(visitId).then((savedIndex) {
          setState(() {
            _initialMotivoIndex = savedIndex;
            _showReasonFinishListWidget = savedIndex == 0;
            widget.controller.finishConfig.visitCompletelyFinished =
            (savedIndex == 1);
          });
        });

        _loadSelectedMauUsoToggle(visitId).then((savedIndex) {
          setState(() {
            _indiceInicialMauUso = savedIndex;
            _isItemSelected = savedIndex == 1;
          });
        });

        _loadSelectedPendencyInstallToggle(visitId).then((savedIndex) {
          setState(() {
            _indexPendencyItem = savedIndex;
          });
        });
      }
    });

    _showReasonFinishListWidget = true;

    _indexPendencyItem = 0;
    _initialIndex = 0;
    _indiceInicialMauUso = 0;

    if (globalVisitType == "M" ||
        globalVisitType == "U" ||
        globalVisitType == "A")
      simulateToggleSwitchClick();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onToggleSwitch(1);
    });

    _comments = TextEditingController(text: widget.controller.observation);
    _commentsViolation = TextEditingController();
    _commentsPendencyItem = TextEditingController();
    _generalCommentsController = TextEditingController();
    customPageController = context.provide<CustomPageController>();

    print("requireSign: ${widget.controller.finishConfig.requireSign}");
  }

  void simulateToggleSwitchClick() {
    setState(() {
      _initialIndex = 0;
      _isItemSelected = false;
    });

    _updateContainsViolation(true);
  }

  void onToggleSwitch(int index) {
    setState(() {
      _initialIndex = index;
    });
  }

  Future<void> _saveSelectedPendencyInstallToggle(
      String visitId, int selectedIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'selected_pendency_install_toggle_$visitId', selectedIndex);
  }

  Future<int> _loadSelectedPendencyInstallToggle(String visitId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selected_pendency_install_toggle_$visitId') ??
        0; // Default é "Não"
  }

  Future<void> _saveSelectedMauUsoToggle(
      String visitId, int selectedIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_mau_uso_toggle_$visitId', selectedIndex);
  }

  Future<int> _loadSelectedMauUsoToggle(String visitId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selected_mau_uso_toggle_$visitId') ??
        0; // Default é "Não"
  }

  Future<int> _loadSelectedToggleSwitch(String visitId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selected_toggle_value_$visitId') ??
        1; // Default é "Total"
  }

  Future<void> _saveSelectedToggleSwitch(
      String visitId, int selectedIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_toggle_value_$visitId', selectedIndex);
  }

  Future<void> _saveSelectedDropdownValue(
      String visitId, String selectedValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_dropdown_value_$visitId', selectedValue);
  }

  Future<String> _loadSelectedDropdownValue(String visitId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_dropdown_value_$visitId') ?? '';
  }

  Future<String> _loadGeneralComments(String visitId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('general_comments_$visitId') ?? '';
  }

  Future<String> _getSelectedVisitId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_technical_visit_id');
  }

  Future<void> _saveGeneralComments(String visitId, String comments) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('general_comments_$visitId', comments);
  }

  Future<void> _saveSelectedReasons(String visitId, ReasonFinish selectedReason) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_reason_$visitId', selectedReason.name);
    await prefs.setString('selected_reason_$visitId', selectedReason.key);
    await prefs.setString('selected_reason_$visitId', selectedReason.id as String);
  }

  Future<void> _loadSelectedReasons(String visitId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedReason = prefs.getString('selected_reason_$visitId') ?? '';
    if (savedReason.isNotEmpty) {
      setState(() {
        selectedReason = ReasonFinish(name: savedReason);  // Carrega e define o motivo selecionado
      });
    }
  }

  @override
  void didChangeDependencies() {
    _comments ??= TextEditingController(text: widget.controller.observation);
    _generalCommentsController ??= TextEditingController();
    customPageController ??= context.provide<CustomPageController>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _comments.dispose();
    _commentsViolation.dispose();
    _commentsPendencyItem.dispose();
    _generalCommentsController.dispose();
    super.dispose();
  }

  void _updateGeneralComments(String text) {
    _updateObservationTimer?.cancel();
    _updateObservationTimer = Timer(250.milliseconds, () {
      widget.controller.generalComments = text;
    });
    widget.controller.updateGeneralComments(text);
  }

  void _onFinished(
      CustomPageController customPageController, BuildContext context) {


    // if (_isItemSelected == false || _generalCommentsController.text.isEmpty) {
    //   showDialog(
    //     context: context,
    //     builder: (context) => AlertDialog(
    //       title: Text("Erro"),
    //       content: Text(
    //           "Por favor, selecione um motivo e preencha o campo de comentários."),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.of(context).pop(),
    //           child: Text("OK"),
    //         ),
    //       ],
    //     ),
    //   );
    //   return;
    // }


    // // Perform validation on comments and reasons if needed
    // if (_comments.text.isEmpty || _comments.text.length < 3) {
    //   showDialog(
    //     context: context,
    //     builder: (context) => AlertDialog(
    //       title: Text("Erro"),
    //       content: Text("Por favor, preencha o campo de comentários."),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.of(context).pop(),
    //           child: Text("OK"),
    //         ),
    //       ],
    //     ),
    //   );
    //   return;
    // }


    // if (_initialMotivoIndex == 0 && selectedReasons.isEmpty) {
    //   showDialog(
    //     context: context,
    //     builder: (context) => AlertDialog(
    //       title: Text("Erro"),
    //       content: Text(
    //           "Você deve selecionar ao menos um motivo de finalização para visitas parciais."),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.of(context).pop(),
    //           child: Text("OK"),
    //         ),
    //       ],
    //     ),
    //   );
    //   return;
    // }

    // Proceed to the next page or process the completion
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return InstallationGetFinishLocationPage(
        color: Colors.blue,
        installation: customPageController.installation,
        customPageController: customPageController,
      );
    })).then((_) => Navigator.of(context).pop());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var backgroundColor = Theme.of(context).colorScheme.primary;

    var outlineInputBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      gapPadding: 2,
    );

    const cardShape = const RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
    );
    var theme = Theme.of(context);

    return Scaffold(
      body: LazyStreamBuilder<List<InstallationPart>>(
        stream: customPageController,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados'));
          }

          if (!snapshot.hasData || snapshot.data.isEmpty) {
            return Center(child: Text('Nenhum dado disponível'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (customPageController.isEditable)
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: cardShape,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            if (snapshot.data[index] == null) {
                              return SizedBox.shrink();
                            }
                            return _InstallationReadyCard(
                              snapshot.data[index],
                              index,
                              widget.controller,
                              index == snapshot.data.length - 1,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 25),
                Center(
                  child: Text("Algum item não pode ser instalado?"),
                ),
                const SizedBox(height: 25),
                Center(
                  child: ToggleSwitch(
                    minHeight: 45,
                    minWidth: 90.0,
                    cornerRadius: 12,
                    initialLabelIndex: _indexPendencyItem,
                    labels: ['Não', 'Sim'],
                    activeBgColor: _indexPendencyItem == 0 ? Colors.red : Colors.green,
                    inactiveBgColor: Colors.grey.shade200,
                    onToggle: (index) {
                      setState(() {
                        _indexPendencyItem = index;
                      });

                      // Salvar o valor do ToggleSwitch no SharedPreferences
                      _getSelectedVisitId().then((visitId) {
                        if (visitId != null) {
                          _saveSelectedPendencyInstallToggle(visitId, index);
                        }
                      });

                      _updateContainsPendencyItem(index == 1);
                    },
                  ),
                ),
                if (_indexPendencyItem == 1)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Text("Quais itens ficaram pendentes para instalação?"),
                      ),
                      TextField(
                        controller: _commentsPendencyItem,
                        enabled: customPageController.isEditable,
                        keyboardType: TextInputType.multiline,
                        maxLines: 6,
                        minLines: 3,
                        decoration: InputDecoration(
                          focusColor: backgroundColor,
                          hoverColor: backgroundColor,
                          fillColor: backgroundColor,
                          border: outlineInputBorder,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        textCapitalization: TextCapitalization.none,
                        onChanged: _updateCommentsPendencyItem,
                      ),
                    ],
                  ),

                const SizedBox(height: 25),
                if (globalVisitType == "M" || globalVisitType == "U" || globalVisitType == "A")
                  Center(
                    child: Column(
                      children: [
                        Text("Houve mau uso ou violação?"),
                        const SizedBox(height: 25),
                        ToggleSwitch(
                          minHeight: 45,
                          minWidth: 90.0,
                          cornerRadius: 12,
                          initialLabelIndex: _indiceInicialMauUso,
                          labels: ['Não', 'Sim'],
                          activeBgColor: _indiceInicialMauUso == 0 ? Colors.red : Colors.green,
                          activeFgColor: Colors.white,
                          inactiveBgColor: Colors.grey.shade200,
                          inactiveFgColor: Colors.black,
                          onToggle: (index) {
                            setState(() {
                              _indiceInicialMauUso = index;
                              _isItemSelected = index == 1;

                              // Limpar itens selecionados ao alternar entre "Sim" e "Não"
                              _generalCommentsController.clear();
                              selectedReasons.clear(); // Limpar as seleções anteriores
                            });

                            // Salvar a seleção do ToggleSwitch no SharedPreferences
                            _getSelectedVisitId().then((visitId) {
                              if (visitId != null) {
                                _saveSelectedMauUsoToggle(visitId, index);
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 25),

                        // Exibir ReasonDropdownSearch baseado na escolha "Sim" ou "Não"
                        if (_indiceInicialMauUso == 1) // Exibe o ReasonDropdownSearch apenas quando "Sim" for selecionado
                          ReasonDropdownSearch(
                            showClientOptions: _indiceInicialMauUso == 1,
                            // Se for "Sim", mostrar as opções do cliente
                            onSelectionConfirmed: (selectedItems) {
                              setState(() {
                                strMotivoMauUso = selectedItems.name; // Atualiza o motivo de mau uso selecionado
                              });

                              // Salvar no SharedPreferences
                              _getSelectedVisitId().then((visitId) {
                                if (visitId != null) {
                                  _saveSelectedDropdownValue(visitId, strMotivoMauUso);
                                  _saveGeneralComments(visitId, strMotivoMauUso);
                                }
                              });

                              // Atualiza os comentários de violação com o motivo selecionado
                              _updateCommentsViolation(strMotivoMauUso);
                            },
                          ),
                      ],
                    ),
                  ),


                const SizedBox(height: 35),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "A Visita foi total ou parcialmente concluída?",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),
                      ToggleSwitch(
                        minHeight: 45,
                        minWidth: 90.0,
                        cornerRadius: 12,
                        initialLabelIndex: _initialMotivoIndex,
                        activeBgColor: _initialMotivoIndex == 1 ? Colors.green : Colors.red,
                        inactiveBgColor: Colors.grey.shade200,
                        labels: ['Parcial', 'Total'],
                        onToggle: (index) {
                          setState(() {
                            _initialMotivoIndex = index;
                            _showReasonFinishListWidget = index == 1;
                            widget.controller.finishConfig.visitCompletelyFinished = (index == 1);
                            widget.controller.updatevisitCompletelyFinished(index == 1);

                            // Salvar o valor do ToggleSwitch no SharedPreferences
                            _getSelectedVisitId().then((visitId) {
                              if (visitId != null) {
                                _saveSelectedToggleSwitch(visitId, index);
                              }
                            });
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                if (_showReasonFinishListWidget)
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Linha contendo o asterisco e o controle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Asterisco vermelho
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                "*",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Exibição do ReasonFinishListWidget
                            Flexible(
                              child: ReasonFinishListWidget(
                                onSelectionConfirmed: (selectedReason) async {
                                  String visitId = await _getSelectedVisitId();

                                  if (visitId != null) {
                                    await _saveSelectedReasons(visitId, selectedReason);  // Salva o motivo selecionado
                                  }

                                  setState(() {
                                    this.selectedReason = selectedReason;  // Atualiza o motivo selecionado
                                    widget.controller.updateReasonsFinish(selectedReason);
                                    widget.controller.updatevisitCompletelyFinished(true);// Atualiza o controlador
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Mover o bloco de "Comentários em Geral" aqui
                Padding(
                  padding: EdgeInsets.only(top: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text("Comentários em Geral"),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _generalCommentsController,
                        enabled: customPageController.isEditable,
                        keyboardType: TextInputType.multiline,
                        maxLines: 6,
                        minLines: 3,
                        decoration: InputDecoration(
                          focusColor: backgroundColor,
                          hoverColor: backgroundColor,
                          fillColor: backgroundColor,
                          border: outlineInputBorder,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: _updateGeneralComments, // Atualizando os comentários gerais
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (widget.controller.finishConfig.requireSign)
                  FloatingActionButton.extended(
                    icon: widget.controller.signatureUri == null ? Icon(Icons.touch_app) : Icon(Icons.check),
                    label: Text("Assinatura"),
                    backgroundColor: widget.controller.signatureUri == null ? theme.colorScheme.secondary : Colors.green,
                    onPressed: () => _onSignatureClick(),
                  ),
                Center(
                  child: LazyStreamBuilder<bool>(
                    stream: customPageController.readyStream,
                    builder: (context, snapshot) => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: const StadiumBorder(),
                      ),
                      child: Text("Finalizar instalação"),
                      onPressed: snapshot.data ? () => _onFinished(customPageController, context) : null,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  void _updateCommentsViolation(String text) {
    _updateObservationTimer?.cancel();
    _updateObservationTimer = Timer(250.milliseconds, () {
      widget.controller.observationViolation = text;
    });
    widget.controller.updateCommentsViolation(text);
  }

  void _updateCommentsPendencyItem(String text) {
    _updateObservationTimer?.cancel();
    _updateObservationTimer = Timer(250.milliseconds, () {
      widget.controller.observationPendencyItem = text;
    });
    widget.controller.updateCommentsPendencyItem(text);
  }

  void _updateContainsViolation(bool containsViolation) {
    widget.controller.updateContainsViolation(containsViolation);
  }

  void _updateContainsPendencyItem(bool containsPendencyItems) {
    widget.controller.updatePendencyItem(containsPendencyItems);
  }

  void _onSignatureClick() {
    if (widget.controller.signatureUri == null) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => SignaturePage()))
          .then((it) => _saveSignaturePicture(it));
    } else {
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

        if (widget.controller.signatureUri != null) {
          setState(() {
            widget.controller.requireSign = false;
          });
        }

        if (value == true) {
          setState(() {
            widget.controller.updateSignatureUri(null);
          });
        }
      });
    }
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
    widget.controller.updateSignatureUri(null);
    if (widget.controller.signatureUri != null) {
      try {
        File(widget.controller.signatureUri.toString()).delete();
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class _InstallationReadyCard extends StatelessWidget {
  final InstallationPart controller;
  final int index;
  final FinishController finishController;
  final bool isFinish;

  _InstallationReadyCard(
      this.controller, this.index, this.finishController, this.isFinish);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return LazyStreamBuilder<ReadyState>(
        stream: controller.readyStream,
        builder: (context, snapshot) {
          final state = snapshot.data;
          Color readyColor;
          IconData readyIcon;
          String subtitle;
          bool ready;

          switch (snapshot.data.status) {
            case ReadyStatus.notReady:
              readyColor = theme.colorScheme.error;
              readyIcon = Icons.error_outline_outlined;
              subtitle = state.message;
              ready = false;
              break;

            case ReadyStatus.ready:
              readyColor = Colors.green;
              readyIcon = Icons.check_circle;
              subtitle = 'Concluído';
              ready = true;
              break;

            case ReadyStatus.warning:
              readyColor = Colors.yellow[600];
              readyIcon = Icons.warning_rounded;
              subtitle = state.message;
              ready = false;
              break;
          }

          return ready
              ? Container()
              : InkWell(
            onTap: () => finishController.changeTabs(index),
            child: ListTile(
              trailing: Icon(
                readyIcon,
                color: readyColor,
              ),
              title: isFinish ? Text(subtitle) : Text(controller.name),
              subtitle: isFinish
                  ? null
                  : subtitle != null
                  ? AutoSizeText(
                subtitle,
                style: theme.textTheme.bodySmall,
                minFontSize: 8,
              )
                  : null,
            ),
          );
        });
  }
}

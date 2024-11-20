// import 'package:flutter/material.dart';
// import '../../models/reasonFinish.dart';
// import '../controller/V2Controllers/tech_visit_list_controller.dart';
//
// class ReasonFinishListWidget extends StatefulWidget {
//   final Function(List<ReasonFinish>) onSelectionConfirmed;
//
//   ReasonFinishListWidget({@required this.onSelectionConfirmed});
//
//   @override
//   _ReasonFinishListWidgetState createState() => _ReasonFinishListWidgetState();
// }
//
// class _ReasonFinishListWidgetState extends State<ReasonFinishListWidget> {
//   List<ReasonFinish> selectedReasons = [];
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         GestureDetector(
//           onTap: () => _showMultiSelectDialog(context),
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             // Adicionamos margens para evitar overflow
//             margin: EdgeInsets.symmetric(horizontal: 16), // Margem extra nas laterais
//             child: selectedReasons.isEmpty
//                 ? Text(
//               'Motivos da Finalização',
//               style: TextStyle(
//                 color: Colors.grey,
//               ),
//             )
//                 : Center(
//               child: Container(
//                 // Limita a largura para evitar overflow horizontal
//                 width: MediaQuery.of(context).size.width * 0.85, // Largura limitada
//                 child: Wrap(
//                   alignment: WrapAlignment.start,
//                   spacing: 8.0, // Espaçamento horizontal entre os chips
//                   runSpacing: 4.0, // Espaçamento vertical entre as linhas
//                   children: selectedReasons.map((reason) {
//                     return Chip(
//                       label: Text(
//                         reason.name,
//                         style: TextStyle(
//                           color: Colors.black,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       backgroundColor: Colors.blue.shade100, // Cor opcional
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 15),
//       ],
//     );
//   }
//
//   void _showMultiSelectDialog(BuildContext context) async {
//     final List<ReasonFinish> selected = await showDialog(
//       context: context,
//       builder: (context) {
//         return MultiSelectDialog(
//           reasons: globalReasonFinishList.reasons,
//           initiallySelectedReasons: selectedReasons,
//         );
//       },
//     );
//
//     if (selected != null && selected.isNotEmpty) {
//       setState(() {
//         selectedReasons = selected;
//       });
//       widget.onSelectionConfirmed(selectedReasons);
//     }
//   }
// }
//
// class MultiSelectDialog extends StatefulWidget {
//   final List<ReasonFinish> reasons;
//   final List<ReasonFinish> initiallySelectedReasons;
//
//   MultiSelectDialog({@required this.reasons, @required this.initiallySelectedReasons});
//
//   @override
//   _MultiSelectDialogState createState() => _MultiSelectDialogState();
// }
//
// class _MultiSelectDialogState extends State<MultiSelectDialog> {
//   List<ReasonFinish> _tempSelectedReasons = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _tempSelectedReasons = List.from(widget.initiallySelectedReasons);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Selecione os motivos'),
//       content: Container(
//         width: double.maxFinite,
//         child: ListView.builder(
//           shrinkWrap: true,
//           itemCount: widget.reasons.length,
//           itemBuilder: (context, index) {
//             final reason = widget.reasons[index];
//             final isSelected = _tempSelectedReasons.contains(reason);
//             return ListTile(
//               title: Text(
//                 reason.name,
//                 style: TextStyle(
//                   color: isSelected ? Colors.red : Colors.black,
//                 ),
//               ),
//               onTap: () {
//                 setState(() {
//                   if (isSelected) {
//                     _tempSelectedReasons.remove(reason);
//                   } else {
//                     _tempSelectedReasons.add(reason);
//                   }
//                 });
//               },
//               selected: isSelected,
//             );
//           },
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             if (_tempSelectedReasons.isEmpty) {
//               //_showValidationError(context);
//             } else {
//               Navigator.of(context).pop(_tempSelectedReasons);
//             }
//           },
//           child: Text('Confirmar'),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../models/reasonFinish.dart';
import '../controller/V2Controllers/tech_visit_list_controller.dart';


class ReasonFinishListWidget extends StatefulWidget {
  final Function(ReasonFinish) onSelectionConfirmed;  // Passa apenas um ReasonFinish

  ReasonFinishListWidget({@required this.onSelectionConfirmed});

  @override
  _ReasonFinishListWidgetState createState() => _ReasonFinishListWidgetState();
}

class _ReasonFinishListWidgetState extends State<ReasonFinishListWidget> {
  ReasonFinish selectedReason;  // Armazena o motivo selecionado

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showSingleSelectDialog(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: selectedReason == null
                ? Text(
              'Motivo da Finalização',
              style: TextStyle(color: Colors.grey),
            )
                : Center(
              child: Text(
                selectedReason.name,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }

  void _showSingleSelectDialog(BuildContext context) async {
    final ReasonFinish selected = await showDialog(
      context: context,
      builder: (context) {
        return SingleSelectDialog(
          reasons: globalReasonFinishList.reasons,
          initiallySelectedReason: selectedReason,
        );
      },
    );

    if (selected != null) {
      setState(() {
        selectedReason = selected;
      });
      widget.onSelectionConfirmed(selectedReason);  // Notifica a seleção única
    }
  }
}

class SingleSelectDialog extends StatefulWidget {
  final List<ReasonFinish> reasons;
  final ReasonFinish initiallySelectedReason;

  SingleSelectDialog({@required this.reasons, @required this.initiallySelectedReason});

  @override
  _SingleSelectDialogState createState() => _SingleSelectDialogState();
}

class _SingleSelectDialogState extends State<SingleSelectDialog> {
  ReasonFinish _tempSelectedReason;

  @override
  void initState() {
    super.initState();
    _tempSelectedReason = widget.initiallySelectedReason;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Selecione o motivo'),
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.reasons.length,
          itemBuilder: (context, index) {
            final reason = widget.reasons[index];
            final isSelected = _tempSelectedReason == reason;
            return ListTile(
              title: Text(
                reason.name,
                style: TextStyle(color: isSelected ? Colors.red : Colors.black),
              ),
              onTap: () {
                setState(() {
                  _tempSelectedReason = reason;  // Permite apenas um motivo
                });
              },
              selected: isSelected,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_tempSelectedReason != null) {
              Navigator.of(context).pop(_tempSelectedReason);  // Retorna o motivo selecionado
            }
          },
          child: Text('Confirmar'),
        ),
      ],
    );
  }
}

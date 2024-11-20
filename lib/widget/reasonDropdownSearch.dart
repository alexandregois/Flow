// import 'package:flutter/material.dart';
// import '../../models/reasonFinish.dart';
//
// class ReasonDropdownSearch extends StatefulWidget {
//   final Function(ReasonFinish) onSelectionConfirmed;
//   final bool showClientOptions;
//
//   ReasonDropdownSearch({@required this.onSelectionConfirmed, @required this.showClientOptions});
//
//   @override
//   _ReasonDropdownSearchState createState() => _ReasonDropdownSearchState();
// }
//
// class _ReasonDropdownSearchState extends State<ReasonDropdownSearch> {
//   ReasonFinish selectedReason;
//
//   // Define os motivos dependendo se é "Sim" ou "Não"
//   List<String> get _reasons {
//     return widget.showClientOptions
//         ? [
//       "RST01 - Reposicionamento/Recolocação – (Cliente)",
//       "RCT01 - Dano físico (Cliente)"
//     ]
//         : [
//       "RST02 - Falha na instalação anterior (Técnico)",
//       "RST03 - Desvio no componente, sem troca (Maxtrack)",
//       "RCT02 - Desvio no componente, com troca (Maxtrack)",
//       "SA001 - Sem Alteração"
//     ];
//   }
//
//   @override
//   void didUpdateWidget(covariant ReasonDropdownSearch oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // Limpar os itens selecionados se houver mudança nas opções (de "Sim" para "Não" e vice-versa)
//     if (oldWidget.showClientOptions != widget.showClientOptions) {
//       setState(() {
//         selectedReason = null; // Limpa a seleção ao alternar entre "Sim" e "Não"
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         GestureDetector(
//           onTap: () => _showSingleSelectDialog(context),
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             margin: EdgeInsets.symmetric(horizontal: 16),
//             child: selectedReason == null
//                 ? Text(
//               'Motivos de Mau Uso',
//               style: TextStyle(
//                 color: Colors.grey,
//               ),
//             )
//                 : Center(
//               child: Text(
//                 selectedReason.name,
//                 style: TextStyle(
//                   color: Colors.black,
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
//   void _showSingleSelectDialog(BuildContext context) async {
//     final ReasonFinish selected = await showDialog(
//       context: context,
//       builder: (context) {
//         return SingleSelectDialog(
//           reasons: _reasons.map((name) => ReasonFinish(name: name)).toList(),
//           initiallySelectedReason: selectedReason,
//         );
//       },
//     );
//
//     if (selected != null) {
//       setState(() {
//         selectedReason = selected;
//       });
//       widget.onSelectionConfirmed(selectedReason);
//     }
//   }
// }
//
// class SingleSelectDialog extends StatefulWidget {
//   final List<ReasonFinish> reasons;
//   final ReasonFinish initiallySelectedReason;
//
//   SingleSelectDialog({@required this.reasons, @required this.initiallySelectedReason});
//
//   @override
//   _SingleSelectDialogState createState() => _SingleSelectDialogState();
// }
//
// class _SingleSelectDialogState extends State<SingleSelectDialog> {
//   ReasonFinish _tempSelectedReason;
//
//   @override
//   void initState() {
//     super.initState();
//     _tempSelectedReason = widget.initiallySelectedReason;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Motivos de Mau Uso'),
//       content: Container(
//         width: double.maxFinite,
//         child: ListView.builder(
//           shrinkWrap: true,
//           itemCount: widget.reasons.length,
//           itemBuilder: (context, index) {
//             final reason = widget.reasons[index];
//             final isSelected = _tempSelectedReason == reason;
//             return ListTile(
//               title: Text(
//                 reason.name,
//                 style: TextStyle(
//                   color: isSelected ? Colors.red : Colors.black,
//                 ),
//               ),
//               onTap: () {
//                 setState(() {
//                   _tempSelectedReason = reason;
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
//             if (_tempSelectedReason != null) {
//               Navigator.of(context).pop(_tempSelectedReason);
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

class ReasonDropdownSearch extends StatefulWidget {
  final Function(ReasonFinish) onSelectionConfirmed;
  final bool showClientOptions;

  ReasonDropdownSearch({@required this.onSelectionConfirmed, @required this.showClientOptions});

  @override
  _ReasonDropdownSearchState createState() => _ReasonDropdownSearchState();
}

class _ReasonDropdownSearchState extends State<ReasonDropdownSearch> {
  ReasonFinish selectedReason;

  // Define os motivos listando todos os itens juntos
  List<String> get _reasons {
    return [
      "RST01 - Reposicionamento/Recolocação – (Cliente)",
      "RCT01 - Dano físico (Cliente)"
    ];
  }

  @override
  void didUpdateWidget(covariant ReasonDropdownSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Limpar os itens selecionados se houver mudança nas opções (de "Sim" para "Não" e vice-versa)
    if (oldWidget.showClientOptions != widget.showClientOptions) {
      setState(() {
        selectedReason = null; // Limpa a seleção ao alternar entre "Sim" e "Não"
      });
    }
  }

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
              'Motivos de Mau Uso',
              style: TextStyle(
                color: Colors.grey,
              ),
            )
                : Center(
              child: Text(
                selectedReason.name,
                style: TextStyle(
                  color: Colors.black,
                ),
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
          reasons: _reasons.map((name) => ReasonFinish(name: name)).toList(),
          initiallySelectedReason: selectedReason,
        );
      },
    );

    if (selected != null) {
      setState(() {
        selectedReason = selected;
      });
      widget.onSelectionConfirmed(selectedReason);
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
      title: Text('Motivos de Mau Uso'),
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
                style: TextStyle(
                  color: isSelected ? Colors.red : Colors.black,
                ),
              ),
              onTap: () {
                setState(() {
                  _tempSelectedReason = reason;
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
              Navigator.of(context).pop(_tempSelectedReason);
            }
          },
          child: Text('Confirmar'),
        ),
      ],
    );
  }
}

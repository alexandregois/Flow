import 'dart:io';
import 'package:flow_flutter/widget/pair_widget.dart';
import 'package:flutter/material.dart';

class ShowSignaturePage extends StatefulWidget {
  final Uri signatureUri;

  // final ChecklistController controller;

  const ShowSignaturePage({
    Key key,
    @required this.signatureUri,
    // @required this.controller,
  }) : super(key: key);

  @override
  _ShowSignaturePageState createState() => _ShowSignaturePageState();
}

class _ShowSignaturePageState extends State<ShowSignaturePage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PairWidget.vertical(
          child1: Image.file(
            File(widget.signatureUri.toString()),
          ),
          spacing: 16,
          child2: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(shape: StadiumBorder(), backgroundColor: Colors.red),
            icon: Icon(Icons.delete_outline),
            label: Text("Apagar"),
            onPressed: deleteSignature,
          ),
          // child2: RaisedButton.icon(
          //   shape: StadiumBorder(),
          //   icon: Icon(Icons.delete_outline),
          //   color: Colors.red,
          //   label: Text("Apagar"),
          //   onPressed: deleteSignature,
          // ),
        ),
      ),
    );
  }

  void deleteSignature() {
    // if (widget.controller.signatureUri != null) {
    Navigator.of(context).pop(true);
    File(widget.signatureUri.toString()).delete();
    // }
  }
}

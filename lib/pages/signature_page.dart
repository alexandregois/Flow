import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hand_signature/signature.dart';


class SignaturePage extends StatefulWidget {
  SignaturePage({Key key}) : super(key: key);

  @override
  _SignaturePageState createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  final control = HandSignatureControl(
    threshold: 3.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );

  Timer _updateStateTimer;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    // SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    control.addListener(() {
      _updateStateTimer?.cancel();
      _updateStateTimer = Timer(200.milliseconds, () {
        setState(() {});
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIOverlays([
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Assinatura"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: control.isFilled
            ? IconButton(
                onPressed: () {},
                icon: IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () {
                    control.toImage().then(Navigator.of(context).pop);
                  },
                ),
              )
            : BackButton(),
        // leading: BackButton(
        //   onPressed: () {
        //     if (control.isFilled) {
        //       control.toImage().then(Navigator.of(context).pop);
        //     } else {
        //       Navigator.of(context).pop();
        //     }
        //   },
        // ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () {
              control.clear();
            },
          ),
          // FlatButton(
          //   child: Text("Limpar"),
          //   onPressed: () {
          //     control.clear();
          //   },
          // )
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: HandSignaturePainterView(
              control: control,
              color: Colors.black,
              width: 2,
              maxWidth: 10.0,
              type: SignatureDrawType.line,
            ),
          ),
        ],
      ),
    );

    // return Scaffold(
    //   body: Stack(
    //     children: [
    //       Positioned.fill(
    //         child: HandSignaturePainterView(
    //           control: control,
    //           color: Colors.black,
    //           width: 1.0,
    //           maxWidth: 10.0,
    //           type: SignatureDrawType.shape,
    //         ),
    //       ),
    //       Padding(
    //         padding: EdgeInsets.only(
    //           left: 8,
    //           top: MediaQuery.of(context).viewPadding.top,
    //         ),
    //         child: FloatingActionButton(
    //           elevation: 2,
    //           child: Icon(
    //             Icons.arrow_back,
    //             color: theme.colorScheme.onSurface,
    //           ),
    //           backgroundColor: theme.colorScheme.surface,
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}

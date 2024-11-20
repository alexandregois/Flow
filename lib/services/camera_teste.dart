//import 'package:camera/camera.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//
//class CameraApp extends StatefulWidget {
//  @override
//  _CameraAppState createState() => new _CameraAppState();
//}
//
//class _CameraAppState extends State<CameraApp> {
//  CameraController controller;
//
//  @override
//  void initState() {
//    super.initState();
//
//    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
//
//    availableCameras().then((List<CameraDescription> cameras) {
//      setState(() {
//        controller = new CameraController(cameras[0], ResolutionPreset.medium);
//        controller.initialize().then((_) {
//          if (!mounted) {
//            return;
//          } else {
//            setState(() {});
//          }
//        });
//      });
//    });
//  }
//
//  @override
//  void dispose() {
//    SystemChrome.setPreferredOrientations([]);
//    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
//
//    controller?.dispose();
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return _getBody();
//  }
//
//  Widget _getBody() {
//    if (controller == null || !controller.value.isInitialized) {
//      return Container();
//    }
//    return Container(
//      child: Center(
//        child: AspectRatio(
//            aspectRatio: controller.value.aspectRatio,
//            child: CameraPreview(controller)),
//      ),
//    );
//  }
//}

//
// // lib/background_service.dart
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
//
// void onStart(ServiceInstance service) async {
//   // TODO: Configure o que o serviço deve fazer aqui
//   if (service is AndroidServiceInstance) {
//     service.on('setAsForeground').listen((event) {
//       service.setAsForegroundService();
//     });
//
//     service.on('setAsBackground').listen((event) {
//       service.setAsBackgroundService();
//     });
//   }
//
//   service.on('stopService').listen((event) {
//     service.stopSelf();
//   });
//
//   // Exemplo de execução em loop para manter o serviço ativo
//   while (true) {
//     await Future.delayed(Duration(seconds: 1));
//     print('Serviço em execução');
//   }
// }
//
// void initializeService() async {
//   final service = FlutterBackgroundService();
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       autoStart: true,
//       isForegroundMode: true,
//     ),
//     iosConfiguration: IosConfiguration(
//       onForeground: onStart,
//       onBackground: onIosBackground,
//     ),
//   );
//   service.startService();
// }
//
// bool onIosBackground(ServiceInstance service) {
//   WidgetsFlutterBinding.ensureInitialized();
//   return true;
// }

// import 'package:flow_flutter/controller/vehicle_info_controller.dart';
// import 'package:flow_flutter/models/installation.dart';
// import 'package:flow_flutter/utils/installation_step.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   test('Check is not ready', () async {
//     var vehicleInfoController = VehicleInfoController();

//     expect(
//         vehicleInfoController.readyStream.map((e) => e.status),
//         emits(
//           equals(ReadyStatus.notReady),
//         ));
//   });

//   test('Check is not ready with initial values', () async {
//     var vehicleInfoController = VehicleInfoController(
//       currentInfo: VehicleInfo(
//         model: 'Model',
//         chassis: 'Chassis',
//       ),
//     );

//     expect(
//         vehicleInfoController.readyStream.map((e) => e.status),
//         emits(
//           equals(ReadyStatus.notReady),
//         ));
//   });

//   test('Check is ready with initial values', () async {
//     var vehicleInfoController = VehicleInfoController(
//       currentInfo: VehicleInfo(
//         model: 'Model',
//         chassis: 'Chassis',
//         brand: 'Brand',
//         city: 'City',
//         color: 'Color',
//         modelYear: 'ModelYear',
//         odometer: 'Odometer',
//         plate: 'Plate',
//         state: 'State',
//         year: 'Year',
//       ),
//     );

//     expect(
//         vehicleInfoController.readyStream.map((e) => e.status),
//         emits(
//           equals(ReadyStatus.ready),
//         ));
//   });

//   test('Check is ready', () async {
//     var vehicleInfoController = VehicleInfoController();
//     vehicleInfoController.plate = 'OWU8850';

//     expect(
//         vehicleInfoController.readyStream.map((e) => e.status),
//         emits(
//           equals(ReadyStatus.ready),
//         ));
//   });
// }

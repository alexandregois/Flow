// import 'package:dartx/dartx.dart';
// import 'package:flow_flutter/controller/pictures_to_take_controller.dart';
// import 'package:flow_flutter/models/pictures_to_take_listing.dart';
// import 'package:flow_flutter/utils/installation_step.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   final picturesToTake = [
//     Picture()
//       ..id = 1
//       ..required = true
//       ..observationRequired = false,
//     Picture()
//       ..id = 2
//       ..required = true
//       ..observationRequired = true,
//     Picture()
//       ..id = 3
//       ..observationRequired = true,
//   ];

//   // group('Picture processing', () {
//   //   test('Without processing', () async {
//   //     var controller = PicturesToTakeController(picturesToTake);
//   //     controller.addPicture(PictureTaken()..id = 1);
//   //
//   //     var picturesTaken = await controller.stream.first;
//   //
//   //     expect(picturesTaken, hasLength(1));
//   //     expect(picturesTaken.first.id, 1);
//   //   });
//   //
//   //   test('With processing', () async {
//   //     var controller = PicturesToTakeController(
//   //       picturesToTake,
//   //       // pictureProcessor: (it) async =>
//   //       //     Future.delayed(1.milliseconds, () => it),
//   //     );
//   //
//   //     controller.addPicture(PictureTaken()..id = 1);
//   //
//   //     var picturesTaken = await controller.stream.first;
//   //     expect(picturesTaken.first.isProcessing, true);
//   //     await Future.delayed(1.milliseconds);
//   //     picturesTaken = await controller.stream.first;
//   //     expect(picturesTaken.first.isProcessing, false);
//   //   });
//   // });

//   group('Ready state', () {
//     test('Is not ready with missing required pictures', () async {
//       var controller = PicturesToTakeController(picturesToTake);

//       controller.addPicture(PictureTaken()..id = 1);
//       // controller.addPicture(PictureTaken()..id = 3);

//       expect(controller.readyStream.map((e) => e.status),
//           emits(ReadyStatus.notReady));
//     });

//     test('Is not ready with missing comments', () async {
//       var controller = PicturesToTakeController(picturesToTake);

//       controller.addPicture(PictureTaken()..id = 1);
//       controller.addPicture(PictureTaken()
//         ..id = 2
//         ..observation = 'comment');
//       controller.addPicture(PictureTaken()..id = 3);

//       expect(controller.readyStream.map((e) => e.status),
//           emits(ReadyStatus.notReady));
//     });

//     test('Is ready', () async {
//       var controller = PicturesToTakeController(picturesToTake);

//       controller.addPicture(
//         PictureTaken()..id = 1,
//       );

//       controller.addPicture(
//         PictureTaken()
//           ..id = 2
//           ..observation = 'comment',
//       );

//       controller.addPicture(
//         PictureTaken()
//           ..id = 3
//           ..observation = 'comment',
//       );

//       expect(controller.readyStream.map((e) => e.status),
//           emits(ReadyStatus.ready));
//     });
//   });
// }

// import 'package:flow_flutter/controller/installation_send_controller.dart';
// import 'package:flow_flutter/models/installation.dart';
// import 'package:flow_flutter/models/photos_by_installation.dart';
// import 'package:flow_flutter/repository/repositories.dart';
// import 'package:flow_flutter/utils/technichal_visit_stage.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:dartx/dartx.dart';

// // class MockChecklistRepository extends Mock implements ChecklistRepository {}
// //
// // class MockPicturesToTakeRepository extends Mock
// //     implements PictureToTakeRepository {}

// class MockInstallationRepository extends Mock
//     implements InstallationRepository {}

// class MockAppDataRepository extends Mock implements AppDataRepository {}

// class MockRequestsRepository extends Mock implements RequestsRepository {}

// void main() {
//   // final picturesToTakeRepo = MockPicturesToTakeRepository();
//   // final checklistRepo = MockChecklistRepository();
//   // final appDataRepo = MockAppDataRepository();
//   final mockRequestsRepo = MockRequestsRepository();
//   final mockInstallationRepo = MockInstallationRepository();

//   setUp(() {
//     reset(mockInstallationRepo);
//     reset(mockRequestsRepo);

//     final installation = Installation.forValues(
//       appId: 1,
//       stage: InstallationStage(
//         stage: TechnicalVisitStage.FINISHED,
//       ),
//       picturesInfo: [
//         PictureInfo(
//           imageId: 1,
//           observation: 'Test',
//           // fileLocation: Uri.parse(''),
//         ),
//       ],
//     );

//     when(mockInstallationRepo.getInstallations())
//         .thenAnswer((realInvocation) async => [installation]);

//     when(mockInstallationRepo.getInstallation(1)).thenAnswer(
//       (realInvocation) async => installation,
//     );

//     when(mockRequestsRepo.sendInstallation(any)).thenAnswer(
//       (realInvocation) async => 666,
//     );

//     when(mockRequestsRepo.getPhotosForInstallation(any)).thenAnswer(
//       (realInvocation) async => PhotosForInstallation(),
//     );

//     when(mockRequestsRepo.sendInstallationPicture(any, any, any)).thenAnswer(
//       (realInvocation) async => false,
//     );
//   });

//   test('Sequence of calls', () async {
//     var controller = InstallationSendController(
//       mockRequestsRepo,
//       mockInstallationRepo,
//     );

//     controller.start();

//     untilCalled(mockInstallationRepo.getInstallations()).timeout(1.seconds);
//     untilCalled(mockRequestsRepo.sendInstallation(any)).timeout(1.seconds);
//     untilCalled(mockInstallationRepo.putInstallation(any)).timeout(1.seconds);
//     untilCalled(mockRequestsRepo.getPhotosForInstallation(any))
//         .timeout(1.seconds);
//     untilCalled(mockRequestsRepo.sendInstallationPicture(any, any, any))
//         .timeout(1.seconds);
//     untilCalled(mockInstallationRepo.deleteInstallations(any))
//         .timeout(1.seconds);
//   });

//   test('Pictures upload', () async {
//     var controller = InstallationSendController(
//       mockRequestsRepo,
//       mockInstallationRepo,
//     );

//     controller.start();

//     expect(
//         controller.stream.map((event) => event.sendingInstallations.first.step),
//         emitsInOrder(
//           [
//             Step.cloudId,
//             Step.cloudId,
//             Step.uploadingPictures,
//           ],
//         ));

//     expect(controller.stream.map((event) => event.sendingInstallations.length),
//         emits(1));

//     expect(
//         controller.stream
//             .skip(2)
//             .map((event) => event.sendingInstallations.first.maxProgress),
//         emits(1));

//     expect(
//         controller.stream
//             .skip(4)
//             .map((event) => event.sendingInstallations.length),
//         emits(0));
//   });
// }

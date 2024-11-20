// import 'package:dartx/dartx.dart';
// import 'package:flow_flutter/controller/checklist_controller.dart';
// import 'package:flow_flutter/controller/installation_controller.dart';
// import 'package:flow_flutter/controller/pictures_to_take_controller.dart';
// import 'package:flow_flutter/controller/V2Controllers/devices_controller.dart';
// import 'package:flow_flutter/controller/vehicle_info_controller.dart';
// import 'package:flow_flutter/models/checklist_listing.dart';
// import 'package:flow_flutter/models/installation.dart';
// import 'package:flow_flutter/models/installation_type.dart';
// import 'package:flow_flutter/models/pictures_to_take_listing.dart';
// import 'package:flow_flutter/repository/repositories.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';

// class MockChecklistRepository extends Mock implements ChecklistRepository {}

// class MockPicturesToTakeRepository extends Mock
//     implements PictureToTakeRepository {}

// class MockInstallationRepository extends Mock
//     implements InstallationRepository {}

// class MockAppDataRepository extends Mock implements AppDataRepository {}

// void main() {
//   final picturesToTakeRepo = MockPicturesToTakeRepository();
//   final checklistRepo = MockChecklistRepository();
//   final appDataRepo = MockAppDataRepository();

//   setUp(() {
//     List<Picture> fakePicturesDatabase = [
//       Picture()
//         ..id = 1
//         ..required = true
//     ];
//     List<ChecklistListingItem> fakeChecklistDatabase = [];

//     when(picturesToTakeRepo.getPictures(any))
//         .thenAnswer((invocation) async => fakePicturesDatabase);

//     when(checklistRepo.getChecklistItems(any))
//         .thenAnswer((invocation) async => fakeChecklistDatabase);
//   });

//   test('Installation not ready', () async {
//     var controller = InstallationController(
//       Installation.start(InstallationType.CAR),
//       appDataRepo,
//     );

//     await controller.init();

//     expect(controller.readyStream, emits(false));
//   });

//   test('Installation ready (without pictures and checklists)', () async {
//     var controller = InstallationController(
//       Installation.start(InstallationType.CAR),
//       appDataRepo,
//     );

//     await controller.init();

//     VehicleInfoController info = (await controller.first)
//         .firstWhere((element) => element is VehicleInfoController);

//     DevicesController trackers = (await controller.first)
//         .firstWhere((element) => element is DevicesController);

//     info.plate = 'Plate';

//     controller.customerEmail = 'test@gmail.com';

//     trackers.addTracker(Tracker(
//       serial: 'AAAA',
//       modelId: 1,
//       brandId: 1,
//       installationLocal: 1,
//     ));

//     await Future.delayed(10.milliseconds);

//     expect(controller.readyStream, emits(true));
//   });

//   test('Installation fully ready', () async {
//     var controller = InstallationController(
//       Installation.start(InstallationType.CAR),
//       appDataRepo,
//     );

//     await controller.init(
//       pictureRepository: picturesToTakeRepo,
//       checklistRepository: checklistRepo,
//     );

//     VehicleInfoController info = (await controller.first)
//         .firstWhere((element) => element is VehicleInfoController);

//     DevicesController trackers = (await controller.first)
//         .firstWhere((element) => element is DevicesController);

//     ChecklistController checklist = (await controller.first)
//         .firstWhere((element) => element is ChecklistController);

//     PicturesToTakeController picturesToTake = (await controller.first)
//         .firstWhere((element) => element is PicturesToTakeController);

//     info.plate = 'Plate';

//     trackers.addTracker(Tracker(
//       serial: 'AAAA',
//       modelId: 1,
//       brandId: 1,
//       installationLocal: 1,
//     ));

//     picturesToTake.addPicture(PictureTaken()..id = 1);

//     checklist.updateSignatureUri(Uri.parse('just a random uri'));

//     controller.customerEmail = 'test@gmail.com';

//     await Future.delayed(10.milliseconds);

//     expect(controller.readyStream, emits(true));
//   });

//   test('Installation auto save', () async {
//     final installationRepo = MockInstallationRepository();

//     var controller = InstallationController(
//       Installation.start(InstallationType.CAR),
//       appDataRepo,
//       installationRepository: installationRepo,
//     );

//     await controller.init(
//       pictureRepository: picturesToTakeRepo,
//       checklistRepository: checklistRepo,
//     );

//     VehicleInfoController info = (await controller.first)
//         .firstWhere((element) => element is VehicleInfoController);

//     DevicesController trackers = (await controller.first)
//         .firstWhere((element) => element is DevicesController);

//     ChecklistController checklist = (await controller.first)
//         .firstWhere((element) => element is ChecklistController);

//     PicturesToTakeController picturesToTake = (await controller.first)
//         .firstWhere((element) => element is PicturesToTakeController);

//     await 1.seconds.delay;

//     info.plate = 'Plate';

//     controller.customerEmail = 'test@gmail.com';

//     await untilCalled(installationRepo.putInstallation(any));
//     reset(installationRepo);

//     trackers.addTracker(Tracker(
//       serial: 'AAAA',
//       modelId: 1,
//       brandId: 1,
//       installationLocal: 1,
//     ));

//     await untilCalled(installationRepo.putInstallation(any));
//     reset(installationRepo);

//     picturesToTake.addPicture(PictureTaken()..id = 1);

//     await untilCalled(installationRepo.putInstallation(any));
//     reset(installationRepo);

//     checklist.updateSignatureUri(Uri.parse('just a random uri'));

//     await untilCalled(installationRepo.putInstallation(any));
//     reset(installationRepo);
//   });
// }

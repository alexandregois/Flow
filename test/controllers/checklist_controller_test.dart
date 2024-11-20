// import 'package:dartx/dartx.dart';
// import 'package:flow_flutter/controller/checklist_controller.dart';
// import 'package:flow_flutter/controller/pictures_to_take_controller.dart';
// import 'package:flow_flutter/models/checklist_listing.dart';
// import 'package:flow_flutter/models/installation.dart';
// import 'package:flow_flutter/models/pictures_to_take_listing.dart';
// import 'package:flow_flutter/utils/installation_step.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   final checklistItems = [
//     ChecklistListingItem()..id = 1,
//     ChecklistListingItem()..id = 2,
//     ChecklistListingItem()..id = 3,
//   ];

//   group('Items requirement', () {
//     test('Not required and no signature', () async {
//       var controller = ChecklistController(
//         checklistItems,
//         allItemsRequired: false,
//       );

//       expect(controller.readyStream.map((e) => e.status),
//           emits(ReadyStatus.notReady));
//     });

//     test('Not required with signature', () async {
//       var controller = ChecklistController(
//         checklistItems,
//         allItemsRequired: false,
//       );

//       controller.updateSignatureUri(Uri.tryParse(''));

//       expect(controller.readyStream.map((e) => e.status),
//           emits(ReadyStatus.ready));
//     });

//     test('Required with signature and no itens checked', () async {
//       var controller = ChecklistController(
//         checklistItems,
//         allItemsRequired: true,
//       );

//       controller.updateSignatureUri(Uri.tryParse(''));
//       controller.updateItem(1, true);

//       expect(controller.readyStream.map((e) => e.status),
//           emits(ReadyStatus.notReady));
//     });

//     test('Required with signature all itens checked', () async {
//       var controller = ChecklistController(
//         checklistItems,
//         allItemsRequired: true,
//       );

//       controller.updateSignatureUri(Uri.tryParse(''));
//       controller.updateItem(1, true);
//       controller.updateItem(2, true);
//       controller.updateItem(3, true);

//       expect(controller.readyStream.map((e) => e.status),
//           emits(ReadyStatus.ready));
//     });

//     // test('Starts not ready', () async {
//     //   var controller = ChecklistController(
//     //     checklistItems,
//     //     allItemsRequired: true,
//     //     currentChecklist: Checklist(
//     //       items: [
//     //         ChecklistInstallationItem(id: 1, checked: true),
//     //         ChecklistInstallationItem(id: 2, checked: true),
//     //         ChecklistInstallationItem(id: 3),
//     //       ],
//     //     ),
//     //   );

//     //   expect(controller.readyStream.map((e) => e.status),
//     //       emits(ReadyStatus.notReady));
//     // });

//     // test('Starts already ready', () async {
//     //   var controller = ChecklistController(
//     //     checklistItems,
//     //     allItemsRequired: true,
//     //     currentChecklist: Checklist(
//     //       items: [
//     //         ChecklistInstallationItem(id: 1, checked: true),
//     //         ChecklistInstallationItem(id: 2, checked: true),
//     //         ChecklistInstallationItem(id: 3, checked: true),
//     //       ],
//     //       signatureUri: Uri.tryParse(''),
//     //     ),
//     //   );

//     //   expect(controller.readyStream.map((e) => e.status),
//     //       emits(ReadyStatus.ready));
//     // });
//   });

//   group('Items emitting', () {
//     test('No itens checked', () async {
//       var controller = ChecklistController(checklistItems);

//       var emptyItems =
//           await controller.map((event) => event.map((e) => e.checked)).first;

//       expect(emptyItems, [null, null, null]);
//     });

//     test('One item checked', () async {
//       var controller = ChecklistController(checklistItems);

//       controller.updateItem(2, true);

//       var emptyItems =
//           await controller.map((event) => event.map((e) => e.checked)).first;

//       expect(emptyItems, [null, true, null]);
//     });
//   });
// }

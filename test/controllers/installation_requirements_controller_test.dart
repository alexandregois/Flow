
// import 'package:flow_flutter/controller/installation_requirements_controller.dart';
// import 'package:flow_flutter/models/installation.dart';
// import 'package:flow_flutter/models/installation_type.dart';
// import 'package:flow_flutter/repository/repositories.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';

// class MockLocationRepository extends Mock implements LocationRepository {}

// void main() {
//   final locationRepo = MockLocationRepository();

//   test('Need geolocation', () async {
//     var controller = InstallationRequirementsController(
//       Installation.start(InstallationType.CAR),
//       locationRepo,
//     );

//     expect(controller.map((event) => event.step),
//         emits(RequirementStep.geolocation));
//   });

//   test('Fetches geolocation', () async {
//     final fakeLatLong = LatLong(
//       latitude: 1,
//       longitude: 2,
//     );

//     when(locationRepo.getCurrentLatLong())
//         .thenAnswer((invocation) async => fakeLatLong);

//     var controller = InstallationRequirementsController(
//       Installation.start(InstallationType.CAR),
//       locationRepo,
//     );

//     verify(locationRepo.getCurrentLatLong());

//     expect(
//         controller.map((event) => event.data?.startLocation),
//         emitsInOrder([
//           null,
//           fakeLatLong,
//         ]));
//   });

//   test('Already done', () async {
//     var controller = InstallationRequirementsController(
//       Installation.start(InstallationType.CAR)..startLocation = LatLong(),
//       locationRepo,
//     );

//     expect(controller.map((event) => event.step), emits(RequirementStep.done));
//   });
// }

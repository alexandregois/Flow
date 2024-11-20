import 'package:flow_flutter/models/checklist_listing.dart';
import 'package:flow_flutter/models/device_listing.dart' as device;
import 'package:flow_flutter/models/get_all_info.dart';
import 'package:flow_flutter/models/pictures_to_take_listing.dart';
import 'package:flow_flutter/models/vehicle_listing.dart' as vehicle;
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/services/get_all_info_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockRequestsRepository extends Mock implements RequestsRepository {}

class MockDevicesRepository extends Mock implements DevicesRepository {}

class MockVehiclesRepository extends Mock implements VehiclesRepository {}

class MockChecklistRepository extends Mock implements ChecklistRepository {}

class MockPicturesToTakeRepository extends Mock
    implements PictureToTakeRepository {}

void main() {
  MockRequestsRepository requests;
  MockDevicesRepository devicesRepo;
  MockVehiclesRepository vehiclesRepo;
  MockChecklistRepository checklistRepo;
  MockPicturesToTakeRepository picturesToTakeRepo;
  GetAllInfoService service;

  setUp(() {
    requests = MockRequestsRepository();
    devicesRepo = MockDevicesRepository();
    vehiclesRepo = MockVehiclesRepository();
    checklistRepo = MockChecklistRepository();
    picturesToTakeRepo = MockPicturesToTakeRepository();

    when(requests.getAllInfo()).thenAnswer((_) async => GetAllInfo());
  });

  test('Fetch devices', () async {
    service = GetAllInfoService(
      '1',
      requests,
      devicesRepo: devicesRepo,
    );

    //Requests setup
    when(requests.getDeviceListing(any)).thenAnswer(
      (_) async => device.DeviceListing()
        ..requestDate = 666
        ..brands = [device.Brand()..id = 1]
        ..models = [device.Model()..id = 1],
    );

    List<device.Brand> fakeBrandsDatabase = [];
    List<device.Model> fakeModelsDatabase = [];

    //Repository setup
    when(devicesRepo.getLastDateRequest())
        .thenAnswer((_) async => DateTime.fromMillisecondsSinceEpoch(666));

    when(devicesRepo.setBrands(any)).thenAnswer((invocation) async {
      fakeBrandsDatabase = invocation.positionalArguments[0];
    });

    when(devicesRepo.getBrands())
        .thenAnswer((invocation) async => fakeBrandsDatabase);

    when(devicesRepo.setModels(any)).thenAnswer((invocation) async {
      fakeModelsDatabase = invocation.positionalArguments[0];
    });

    when(devicesRepo.getModels())
        .thenAnswer((invocation) async => fakeModelsDatabase);

    //Proper tests
    await service.performGetAllInfo(true, true);

    verify(requests.getDeviceListing(any));
    verify(devicesRepo.setBrands(any));
    verify(devicesRepo.setModels(any));
    verify(devicesRepo.setLastDateRequest(any));

    expect(devicesRepo.getBrands(), completion(fakeBrandsDatabase));
    expect(devicesRepo.getModels(), completion(fakeModelsDatabase));
  });

  test('Fetch Vehicles', () async {
    service = GetAllInfoService(
      '1',
      requests,
      vehiclesRepo: vehiclesRepo,
    );

    //Requests setup
    when(requests.getVehicleListing(any)).thenAnswer(
      (_) async => vehicle.VehicleListing()
        ..requestDate = 666
        ..brands = [vehicle.Brand()..id = 1]
        ..models = [vehicle.Model()..id = 1],
    );

    List<vehicle.Brand> fakeBrandsDatabase = [];
    List<vehicle.Model> fakeModelsDatabase = [];

    //Repository setup
    when(vehiclesRepo.getLastDateRequest())
        .thenAnswer((_) async => DateTime.fromMillisecondsSinceEpoch(666));

    when(vehiclesRepo.setBrands(any)).thenAnswer((invocation) async {
      fakeBrandsDatabase = invocation.positionalArguments[0];
    });

    when(vehiclesRepo.getBrands())
        .thenAnswer((invocation) async => fakeBrandsDatabase);

    when(vehiclesRepo.setModels(any)).thenAnswer((invocation) async {
      fakeModelsDatabase = invocation.positionalArguments[0];
    });

    when(vehiclesRepo.getModels())
        .thenAnswer((invocation) async => fakeModelsDatabase);

    await service.performGetAllInfo(true, true);

    verify(requests.getVehicleListing(any));
    verify(vehiclesRepo.setBrands(any));
    verify(vehiclesRepo.setModels(any));
    verify(vehiclesRepo.setLastDateRequest(any));

    expect(vehiclesRepo.getBrands(), completion(fakeBrandsDatabase));
    expect(vehiclesRepo.getModels(), completion(fakeModelsDatabase));
  });


  test('New app version', () async {
    service = GetAllInfoService(
      '2',
      requests,
      devicesRepo: devicesRepo,
      checklistRepo: checklistRepo,
      picturesToTakeRepo: picturesToTakeRepo,
      vehiclesRepo: vehiclesRepo,
    );

    when(requests.getDeviceListing(any)).thenAnswer(
      (_) async => device.DeviceListing()
        ..requestDate = 666
        ..brands = [device.Brand()..id = 1]
        ..models = [device.Model()..id = 1],
    );

    when(requests.getVehicleListing(any)).thenAnswer(
      (_) async => vehicle.VehicleListing()
        ..requestDate = 666
        ..brands = [vehicle.Brand()..id = 1]
        ..models = [vehicle.Model()..id = 1],
    );

    when(requests.getChecklistListing(any)).thenAnswer(
      (_) async => ChecklistListing()
        ..requestDate = 666
        ..items = [ChecklistListingItem(), ChecklistListingItem()],
    );

    //Requests setup
    when(requests.getPicturesListing(any)).thenAnswer(
      (_) async => PicturesListing()
        ..requestDate = 666
        ..pictures = [Picture(), Picture()],
    );

    var dateTime = DateTime.fromMillisecondsSinceEpoch(666);

    when(devicesRepo.getLastDateRequest()).thenAnswer((_) async => dateTime);

    when(checklistRepo.getLastDateRequest()).thenAnswer((_) async => dateTime);

    when(picturesToTakeRepo.getLastDateRequest())
        .thenAnswer((_) async => dateTime);

    when(vehiclesRepo.getLastDateRequest()).thenAnswer((_) async => dateTime);

    when(devicesRepo.getLastVersionRequest())
        .thenAnswer((realInvocation) async => '1');
    when(checklistRepo.getLastVersionRequest())
        .thenAnswer((realInvocation) async => '1');
    when(picturesToTakeRepo.getLastVersionRequest())
        .thenAnswer((realInvocation) async => '1');
    when(vehiclesRepo.getLastVersionRequest())
        .thenAnswer((realInvocation) async => '1');

    await service.performGetAllInfo(true, true);

    verifyNever(requests.getDeviceListing(dateTime));
    verifyNever(requests.getChecklistListing(dateTime));
    verifyNever(requests.getPicturesListing(dateTime));
    verifyNever(requests.getVehicleListing(dateTime));
  });

  // test('Delete pictures', () async {
  //   service = GetAllInfoService(
  //     '1',
  //     requests,
  //     picturesToTakeRepo: picturesToTakeRepo,
  //   );

  //   var one = Picture()
  //     ..id = 1
  //     ..deleted = true;
  //   var two = Picture()
  //     ..id = 2
  //     ..deleted = true;
  //   var three = Picture()..id = 3;
  //   var four = Picture()..id = 4;
  //   var five = Picture()..id = 5;

  //   //Requests setup
  //   when(requests.getPicturesListing(any)).thenAnswer(
  //     (_) async {
  //       return PicturesListing()
  //         ..requestDate = 666
  //         ..pictures = [
  //           one,
  //           two,
  //           three,
  //           four,
  //           five,
  //         ];
  //     },
  //   );

  //   List<Picture> fakeDatabase = [
  //     Picture()..id = 1,
  //     Picture()..id = 2,
  //   ];

  //   when(picturesToTakeRepo.deletePictures(any)).thenAnswer((invocation) async {
  //     List<Picture> toDelete = invocation.positionalArguments[0];
  //     toDelete.forEach(
  //         (element) => fakeDatabase.removeWhere((e) => e.id == element.id));
  //   });

  //   when(picturesToTakeRepo.addPictures(any)).thenAnswer((invocation) async {
  //     fakeDatabase = invocation.positionalArguments[0];
  //   });

  //   when(picturesToTakeRepo.getPictures())
  //       .thenAnswer((invocation) async => fakeDatabase);

  //   //Proper tests
  //   await service.performGetAllInfo(true, true);

  //   expect(
  //       picturesToTakeRepo.getPictures(),
  //       completion(allOf([
  //         hasLength(3),
  //         isNot(contains(one)),
  //         isNot(contains(two)),
  //         contains(three),
  //         contains(four),
  //         contains(five),
  //       ])));
  // });
}

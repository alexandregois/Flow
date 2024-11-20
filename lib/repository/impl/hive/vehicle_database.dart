import 'package:flow_flutter/models/hive/hive_models.dart';
import 'package:flow_flutter/models/vehicle_listing.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:hive/hive.dart';

class HiveVehicleDatabase extends VehiclesRepository {
  static const _boxBrandsName = 'vehicleBrands';
  static const _boxModelsName = 'vehicleModels';

  @override
  Future deleteBrands([List<Brand> brands]) =>
      Hive.openBox<HiveVehicleBrand>(_boxBrandsName).then((box) {
        if (brands == null) {
          box.clear();
        } else {
          brands.forEach((item) => box.delete(item.id));
        }
      });

  @override
  Future deleteModels([List<Model> models]) =>
      Hive.openBox<HiveVehicleModel>(_boxModelsName).then((box) {
        if (models == null) {
          box.clear();
        } else {
          models.forEach((item) => box.delete(item.id));
        }
      });

  @override
  Future<List<Brand>> getBrands() async =>
      Hive.openBox<HiveVehicleBrand>(_boxBrandsName)
          .then((box) => box.values.map((e) => e.fromHive).toList());

  @override
  Future<List<Model>> getModels() async =>
      Hive.openBox<HiveVehicleModel>(_boxModelsName)
          .then((box) => box.values.map((e) => e.fromHive).toList());

  @override
  Future setBrands(List<Brand> brands) async {
    var box = await Hive.openBox<HiveVehicleBrand>(_boxBrandsName);
    brands.forEach((it) => box.put(it.id, it.toHive));
    
  }

  @override
  Future setModels(List<Model> models) async {
    var box = await Hive.openBox<HiveVehicleModel>(_boxModelsName);
    models.forEach((it) => box.put(it.id, it.toHive));
  }

  @override
  Future<DateTime> getLastDateRequest() async {
    var box = await Hive.openBox<int>('requestDates');
    if (box.containsKey('vehicle')) {
      return DateTime.fromMillisecondsSinceEpoch(box.get('vehicle'));
    } else {
      return null;
    }
  }

  @override
  Future setLastDateRequest(DateTime dateRequest) async {
    Hive.openBox<int>('requestDates')
        .then((box) => box.put('vehicle', dateRequest?.millisecondsSinceEpoch));
  }

  @override
  Future<String> getLastVersionRequest() async =>
      (await Hive.openBox<String>('requestAppVersion')).get('vehicle');

  @override
  Future setLastVersionRequest(String appVersion) =>
      Hive.openBox<String>('requestAppVersion')
          .then((box) => box.put('vehicle', appVersion));
}

extension on Model {
  HiveVehicleModel get toHive => HiveVehicleModel()
    ..id = this.id
    ..name = this.name
    ..brandId = this.brandId
    ..fipeName = this.fipeName
    ..key = this.key;
}

extension on HiveVehicleModel {
  Model get fromHive => Model()
    ..id = this.id
    ..name = this.name
    ..brandId = this.brandId
    ..fipeName = this.fipeName
    ..key = this.key;
}

extension on Brand {
  HiveVehicleBrand get toHive => HiveVehicleBrand()
    ..id = this.id
    ..name = this.name
    ..vehicleType = this.vehicleType
    ..fipeName = this.fipeName
    ..key = this.key;
}

extension on HiveVehicleBrand {
  Brand get fromHive => Brand()
    ..id = this.id
    ..name = this.name
    ..vehicleType = this.vehicleType
    ..fipeName = this.fipeName
    ..key = this.key;
}

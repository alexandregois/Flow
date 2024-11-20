import 'package:flow_flutter/models/device_listing.dart';
import 'package:flow_flutter/models/hive/hive_models.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:hive/hive.dart';

class HiveDeviceDatabase extends DevicesRepository {
  static const _boxBrandsName = 'deviceBrands';
  static const _boxModelsName = 'deviceModels';
  static const _boxGroupsName = 'deviceGroups';

  @override
  Future deleteBrands([List<Brand> brands]) =>
      Hive.openBox<HiveDeviceBrand>(_boxBrandsName).then((box) {
        if (brands == null) {
          box.clear();
        } else {
          brands.forEach((item) => box.delete(item.id));
        }
      });

  @override
  Future deleteModels([List<Model> models]) =>
      Hive.openBox<HiveDeviceModel>(_boxModelsName).then((box) {
        if (models == null) {
          box.clear();
        } else {
          models.forEach((item) => box.delete(item.id));
        }
      });

  Future deleteGroups([List<Group> groups]) =>
      Hive.openBox<HiveDeviceGroup>(_boxGroupsName).then((box) {
        if (groups == null) {
          box.clear();
        } else {
          groups.forEach((item) => box.delete(item.id));
        }
      });

  @override
  Future<List<Brand>> getBrands() async =>
      Hive.openBox<HiveDeviceBrand>(_boxBrandsName)
          .then((box) => box.values.map((e) => e.fromHive).toList());

  @override
  Future<List<Model>> getModels() async =>
      Hive.openBox<HiveDeviceModel>(_boxModelsName)
          .then((box) => box.values.map((e) => e.fromHive).toList());

  @override
  Future<List<Group>> getGroups() async =>
      Hive.openBox<HiveDeviceGroup>(_boxGroupsName)
          .then((box) => box.values.map((e) => e.fromHive).toList());

  @override
  Future setBrands(List<Brand> brands) async {
    var box = await Hive.openBox<HiveDeviceBrand>(_boxBrandsName);
    brands.forEach((it) => box.put(it.id, it.toHive));
  }

  @override
  Future setModels(List<Model> models) async {
    var box = await Hive.openBox<HiveDeviceModel>(_boxModelsName);
    models.forEach((it) => box.put(it.id, it.toHive));
  }

  @override
  Future setGroups(List<Group> groups) async {
    var box = await Hive.openBox<HiveDeviceGroup>(_boxGroupsName);
    groups.forEach((it) => box.put(it.id, it.toHive));
  }

  @override
  Future<DateTime> getLastDateRequest() async {
    var box = await Hive.openBox<int>('requestDates');
    if (box.containsKey('device')) {
      return DateTime.fromMillisecondsSinceEpoch(box.get('device'));
    } else {
      return null;
    }
  }

  @override
  Future setLastDateRequest(DateTime dateRequest) async =>
      Hive.openBox<int>('requestDates').then(
          (box) => box.put('device', dateRequest?.millisecondsSinceEpoch));

  @override
  Future<String> getLastVersionRequest() async =>
      (await Hive.openBox<String>('requestAppVersion')).get('device');

  @override
  Future setLastVersionRequest(String appVersion) =>
      Hive.openBox<String>('requestAppVersion')
          .then((box) => box.put('device', appVersion));
}

extension on Model {
  HiveDeviceModel get toHive => HiveDeviceModel()
    ..id = this.id
    ..name = this.name
    ..model = this.model
    ..brandId = this.brandId;
}

extension on HiveDeviceModel {
  Model get fromHive => Model()
    ..id = this.id
    ..name = this.name
    ..model = this.model
    ..brandId = this.brandId;
}

extension on Brand {
  HiveDeviceBrand get toHive => HiveDeviceBrand()
    ..id = this.id
    ..name = this.name;
}

extension on HiveDeviceBrand {
  Brand get fromHive => Brand()
    ..id = this.id
    ..name = this.name;
}

extension on Group {
  HiveDeviceGroup get toHive => HiveDeviceGroup()
    ..id = this.id
    ..name = this.name;
}

extension on HiveDeviceGroup {
  Group get fromHive => Group()
    ..id = this.id
    ..name = this.name;
}

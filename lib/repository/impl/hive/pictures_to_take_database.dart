import 'package:flow_flutter/models/hive/hive_models.dart';
import 'package:flow_flutter/models/installation_type.dart';
import 'package:flow_flutter/models/pictures_to_take_listing.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:hive/hive.dart';

class HivePicturesToTakeDatabase extends PictureToTakeRepository {
  static const _boxName = 'picturesToTakeItems';

  @override
  Future deletePictures([List<Picture> pictures]) =>
      Hive.openBox<HivePictureToTake>(_boxName).then((box) {
        if (pictures == null) {
          box.clear();
        } else {
          pictures.forEach((item) => box.delete(item.id));
        }
      });

  @override
  Future<List<Picture>> getPictures([InstallationType installationType]) =>
      Hive.openBox<HivePictureToTake>(_boxName).then((box) => box.values
          .map((e) => e.fromHive)
          .where((element) =>
              installationType == null ||
              element.installationType == installationType.id)
          .toList());

  @override
  Future addPictures(List<Picture> pictures) async {
    var box = await Hive.openBox<HivePictureToTake>(_boxName);
    pictures.forEach((it) => box.put(it.id, it.toHive));
  }

  @override
  Future<DateTime> getLastDateRequest() async {
    var box = await Hive.openBox<int>('requestDates');
    if (box.containsKey('picturesToTake')) {
      return DateTime.fromMillisecondsSinceEpoch(box.get('picturesToTake'));
    } else {
      return null;
    }
  }

  @override
  Future setLastDateRequest(DateTime dateRequest) async {
    Hive.openBox<int>('requestDates').then((box) =>
        box.put('picturesToTake', dateRequest?.millisecondsSinceEpoch));
  }

  @override
  Future<String> getLastVersionRequest() async =>
      (await Hive.openBox<String>('requestAppVersion')).get('picturesToTake');

  @override
  Future setLastVersionRequest(String appVersion) =>
      Hive.openBox<String>('requestAppVersion')
          .then((box) => box.put('picturesToTake', appVersion));
}

extension on Picture {
  HivePictureToTake get toHive => HivePictureToTake()
    ..id = this.id
    ..name = this.name
    ..installationType = this.installationType
    ..order = this.order
    ..required = this.required
    ..sent = this.sent
    ..description = this.description
    ..observationDesc = this.observationDesc
    ..observationRequired = this.observationRequired
    ..orientation = this.orientation;
}

extension on HivePictureToTake {
  Picture get fromHive => Picture()
    ..id = this.id
    ..name = this.name
    ..installationType = this.installationType
    ..order = this.order
    ..required = this.required
    ..sent = this.sent
    ..description = this.description
    ..observationDesc = this.observationDesc
    ..observationRequired = this.observationRequired
    ..orientation = this.orientation;
}

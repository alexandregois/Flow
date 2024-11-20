import 'package:flow_flutter/models/checklist_listing.dart';
import 'package:flow_flutter/models/hive/hive_models.dart';
import 'package:flow_flutter/models/installation_type.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:hive/hive.dart';

class HiveChecklistDatabase extends ChecklistRepository {
  static const _boxName = 'checklistItems';

  @override
  Future deleteChecklistItems([List<ChecklistListingItem> items]) {
    return Hive.openBox<HiveChecklistItem>(_boxName).then((box) {
      if (items == null) {
        box.clear();
      } else {
        items.forEach((item) => box.delete(item.id));
      }
    });
  }

  @override
  Future<List<ChecklistListingItem>> getChecklistItems(
          [InstallationType installationType]) =>
      Hive.openBox<HiveChecklistItem>(_boxName).then((box) => box.values
          .map((e) => e.fromHive)
          .where((element) =>
              installationType == null ||
              element.installationType == installationType.id)
          .toList());

  @override
  Future addChecklistItems(List<ChecklistListingItem> items) async {
    var box = await Hive.openBox<HiveChecklistItem>(_boxName);
    items.forEach((it) => box.put(it.id, it.toHive));
  }

  @override
  Future<DateTime> getLastDateRequest() async {
    var box = await Hive.openBox<int>('requestDates');
    if (box.containsKey('checklist')) {
      return DateTime.fromMillisecondsSinceEpoch(box.get('checklist'));
    } else {
      return null;
    }
  }

  @override
  Future setLastDateRequest(DateTime dateRequest) async {
    Hive.openBox<int>('requestDates').then(
        (box) => box.put('checklist', dateRequest?.millisecondsSinceEpoch));
  }

  @override
  Future<String> getLastVersionRequest() async =>
      (await Hive.openBox<String>('requestAppVersion')).get('checklist');

  @override
  Future setLastVersionRequest(String appVersion) =>
      Hive.openBox<String>('requestAppVersion')
          .then((box) => box.put('checklist', appVersion));
}

extension on ChecklistListingItem {
  HiveChecklistItem get toHive => HiveChecklistItem()
    ..id = this.id
    ..name = this.name
    ..installationType = this.installationType
    ..order = this.order;
}

extension on HiveChecklistItem {
  ChecklistListingItem get fromHive => ChecklistListingItem()
    ..id = this.id
    ..name = this.name
    ..installationType = this.installationType
    ..order = this.order;
}

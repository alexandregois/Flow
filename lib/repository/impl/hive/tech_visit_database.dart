import 'package:flow_flutter/models/hive/hive_models.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/models/technical_visit_edit.dart';
import 'package:flow_flutter/models/technical_visit_list.dart';
import 'package:flow_flutter/models/technical_visit_state_enum.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:hive/hive.dart';

class HiveTechVisitDatabase extends TechVisitRepository {
  static const _boxTechVisit = 'techVisit';
  static const _boxTechVisitEdit = 'techVisitEdit';

  @override
  Future<List<TechnicalVisit>> getTechVisitList() async {
    List<TechnicalVisit> technicalVisit =
        await Hive.openBox<HiveTechnicalVisit>(_boxTechVisit).then((box) =>
            box.values?.map((e) => e.fromHive)?.toList() ?? <TechnicalVisit>[]);
    return technicalVisit;
  }

  @override
  Future<TechnicalVisitEdit> getTechVisitEdit(int techVisitId) async =>
      Hive.openBox<HiveTechnicalVisitEdit>(_boxTechVisitEdit)
          .then((box) => box.get(techVisitId.toString()).fromHive);

  @override
  Future putTechVisit(TechnicalVisit technicalVisit) =>
      Hive.openBox<HiveTechnicalVisit>(_boxTechVisit)
          .then((box) => box.put(technicalVisit.id, technicalVisit.toHive));

  @override
  Future putTechVisitEdit(TechnicalVisitEdit technicalVisitEdit) =>
      Hive.openBox<HiveTechnicalVisitEdit>(_boxTechVisitEdit).then(
          (box) => box.put(technicalVisitEdit.id, technicalVisitEdit.toHive));

  @override
  Future deleteTechnicalVisit([List<TechnicalVisit> models]) =>
      Hive.openBox<HiveTechnicalVisit>(_boxTechVisit).then((box) {
        if (models == null) {
          box.clear();
        } else {
          models.forEach((item) {
            box.delete(item.id);
          });
        }
      });

  @override
  Future deleteTechnicalVisitEdit([List<TechnicalVisitEdit> models]) =>
      Hive.openBox<HiveTechnicalVisitEdit>(_boxTechVisitEdit).then((box) {
        if (models == null) {
          box.clear();
        } else {
          models.forEach((item) {
            box.delete(item.id);
          });
        }
      });
}

extension on TechnicalVisit {
  HiveTechnicalVisit get toHive => HiveTechnicalVisit()
    ..id = this.id
    ..visitType = this.visitType
    ..visitState = this.visitState.id
    ..forecastStartDate = this.forecastStartDate
    ..forecastFinishDate = this.forecastFinishDate
    ..visitReason = this.visitReason
    ..techPersonId = this.techPersonId
    ..techPersonName = this.techPersonName
    ..agreementId = this.agreementId
    ..localInfo = this.localInfo?.toHive
    ..mainDevice = this.mainDevice?.toHive
    ..visitStartDate = this.visitStartDate
    ..visitFinishDate = this.visitFinishDate
    ..cancelDate = this.cancelDate;
}

extension on TechnicalVisitEdit {
  HiveTechnicalVisitEdit get toHive => HiveTechnicalVisitEdit()
    ..id = this.id
    ..agreementId = this.agreementId
    ..visitType = this.visitType
    ..visitState = this.visitState
    ..forecastStartDate = this.forecastStartDate
    ..forecastFinishDate = this.forecastFinishDate
    ..visitReason = this.visitReason
    ..agreementId = this.agreementId
    ..localInfo = this.localInfo?.toHive
    ..devices = this.devices?.toHive;
}

extension on HiveTechnicalVisitEdit {
  TechnicalVisitEdit get fromHive => TechnicalVisitEdit()
    ..id = this.id
    ..agreementId = this.agreementId
    ..visitType = this.visitType
    ..visitState = this.visitState
    ..forecastStartDate = this.forecastStartDate
    ..forecastFinishDate = this.forecastFinishDate
    ..visitReason = this.visitReason
    ..agreementId = this.agreementId
    ..localInfo = this.localInfo?.fromHive
    ..devices = this.devices?.fromHive;
}

extension on List<HiveTrackerTechVisit> {
  List<Tracker> get fromHive => this
      .map((e) => Tracker()
        ..brandId = e.brandId
        ..modelId = e.modelId
        ..serial = e.serial
        ..brandName = e.brandName
        ..deviceId = e.deviceId
        ..equipmentItemId = e.equipmentItemId
        ..configName = e.configName
        ..installationLocal = e.installationLocal
        ..main = e.main
        ..modelTechName = e.modelTechName
        ..modelName = e.modelName
        ..modelType = e.modelType
        ..groupId = e.groupId
        ..groupName = e.groupName)
      .toList();
}

extension on LocalInfo {
  HiveLocalInfo get toHive => HiveLocalInfo()
    ..color = this.color
    ..model = this.modelName
    ..identifier = this.identifier
    ..brand = this.brandName
    ..chassis = this.chassis
    ..odometer = this.odometer.toString()
    ..state = this.stateName
    ..cityName = this.cityName
    ..modelYear = this.modelYear
    ..year = this.year
    ..description = this.description
    ..brandId = this.brandId
    ..modelId = this.modelId
    ..ufId = this.ufId
    ..cityId = this.cityId
    ..modelId = this.modelId
    ..brandId = this.brandId;
}

extension on MainDevice {
  HiveMainDevice get toHive => HiveMainDevice()
    ..brandName = this.brandName
    ..model = this.model
    ..modelName = this.modelName
    ..modelTechName = this.modelTechName
    ..serial = this.serial;
}

extension on HiveMainDevice {
  MainDevice get fromHive => MainDevice()
    ..brandName = this.brandName
    ..model = this.model
    ..modelName = this.modelName
    ..modelTechName = this.modelTechName
    ..serial = this.serial;
}

extension on List<Tracker> {
  List<HiveTrackerTechVisit> get toHive => this
      .map((e) => HiveTrackerTechVisit()
        ..brandId = e.brandId
        ..modelId = e.modelId
        ..serial = e.serial
        ..brandName = e.brandName
        ..deviceId = e.deviceId
        ..equipmentItemId = e.equipmentItemId
        ..configName = e.configName
        ..installationLocal = e.installationLocal
        ..main = e.main
        ..modelTechName = e.modelTechName
        ..modelName = e.modelName
        ..modelType = e.modelType
        ..groupId = e.groupId
        ..groupName = e.groupName)
      .toList();
}

extension on HiveTechnicalVisit {
  TechnicalVisit get fromHive => TechnicalVisit()
    ..id = this.id
    ..visitType = this.visitType
    ..visitState = TechnicalVisitStateEnumHelper.getByValue(this.visitState)
    ..forecastStartDate = this.forecastStartDate
    ..forecastFinishDate = this.forecastFinishDate
    ..visitReason = this.visitReason
    ..techPersonId = this.techPersonId
    ..techPersonName = this.techPersonName
    ..agreementId = this.agreementId
    ..localInfo = this.localInfo?.fromHive
    ..mainDevice = this.mainDevice?.fromHive;
}

extension on HiveLocalInfo {
  LocalInfo get fromHive => LocalInfo()
    ..color = this.color
    ..modelName = this.model
    ..identifier = this.identifier
    ..brandName = this.brand
    ..chassis = this.chassis
    ..odometer = int.parse(this.odometer)
    ..stateName = this.state
    ..cityName = this.cityName
    ..modelYear = this.modelYear
    ..year = this.year
    ..description = this.description
    ..cityId = this.cityId
    ..brandId = this.brandId
    ..modelId = this.modelId;
}

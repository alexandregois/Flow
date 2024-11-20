import 'package:flow_flutter/models/company.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/hive/hive_models.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/models/installation_type.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/technichal_visit_stage.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:hive/hive.dart';

import 'company_config_database.dart';

class HiveInstallationDatabase extends InstallationRepository {
  static const _boxInstallationName = 'installationBox11';

  @override
  Future putInstallation(Installation installation) async {
    var installationFinded = await getInstallation(installation.appId);

    if (installationFinded == null) {
      print('Put installation: ${installation.hiveId}');

      return Hive.openBox<HiveInstallation>(_boxInstallationName)
          .then((box) => box.put(installation.hiveId, installation.toHive));
    } else {
      print('Put installation finded: ${installationFinded.hiveId}');

      return Hive.openBox<HiveInstallation>(_boxInstallationName).then(
          (box) => box.put(installationFinded.hiveId, installation.toHive));
    }
  }

  /// This will only delete the installation information, but not the pictures.
  /// To delete the pictures you must call [deleteAllPicturesFromInstallation]
  /// on the [utils.dart] file.

  @override
  Future deleteInstallations([List<Installation> models]) =>
      Hive.openBox<HiveInstallation>(_boxInstallationName).then((box) {
        if (models == null) {
          box.values.forEach((element) {
            deletePicturesFromInstallation(element.fromHive);
          });
          box.clear();
        } else {
          models.forEach((item) async {
            deletePicturesFromInstallation(item);
            print(item.hiveId);
            await box.delete(item.hiveId.toString());
            await box.delete(item.appId.toString());
          });
        }
      });

  @override
  Future<List<Installation>> getInstallations() async {
    List<Installation> installations =
        await Hive.openBox<HiveInstallation>(_boxInstallationName).then((box) =>
            box.values?.map((e) => e.fromHive)?.toList() ?? <Installation>[]);
    return installations;
  }

  @override
  Future<Installation> getInstallation(int installationId) async {
    Installation installation =
        await Hive.openBox<HiveInstallation>(_boxInstallationName).then(
            (box) => box.get(installationId.toString())?.fromHive ?? null);

    return installation;
  }

  Stream<List<Installation>> listen() async* {
    final box = await Hive.openBox<HiveInstallation>(_boxInstallationName);
    yield await getInstallations();
    yield* box.watch().asyncMap((event) => getInstallations());
  }

  @override
  Future deleteAllBoxInfo() async {
    await Hive.openBox<HiveInstallation>(_boxInstallationName)
        .then((box) => box.deleteAll(box.keys));
  }
}

////////////////////////////////////////////////////////////////////////////////
extension on RegisterConfig {
  // ignore: unused_element
  HiveRegisterConfig get toHive => HiveRegisterConfig()
    ..aditionalFields = this.aditionalFields?.toHive
    ..currentInfo = this.currentInfo.toHive
    ..recordType = this.recordType.toHive;
}

extension on VehicleInfo {
  HiveVehicleInfo get toHive => HiveVehicleInfo()
    ..color = this.color
    ..modelName = this.modelName
    ..plate = this.plate
    ..brand = this.brand
    ..chassis = this.chassis
    ..fleetId = this.fleetId
    ..odometer = this.odometer
    ..stateName = this.stateName
    ..cityName = this.cityName
    ..modelYear = this.modelYear
    ..year = this.year
    ..ufId = this.ufId
    ..cityId = this.cityId
    ..brandId = this.brandId
    ..modelId = this.modelId
    ..vehicleId = this.vehicleId;
}

extension on HiveRegisterConfig {
  // ignore: unused_element
  RegisterConfig get fromHive => RegisterConfig()
    ..aditionalFields =
        this.aditionalFields?.map((element) => element.fromHive)?.toList()
    ..currentInfo = this.currentInfo.fromHive
    ..recordType = this.recordType.fromHive;
}

extension on HiveVehicleInfo {
  VehicleInfo get fromHive => VehicleInfo()
    ..color = this.color
    ..modelName = this.modelName
    ..plate = this.plate
    ..brand = this.brand
    ..chassis = this.chassis
    ..fleetId = this.fleetId
    ..odometer = this.odometer
    ..stateName = this.stateName
    ..cityName = this.cityName
    ..modelYear = this.modelYear
    ..year = this.year
    ..ufId = this.ufId
    ..cityId = this.cityId
    ..brandId = this.brandId
    ..modelId = this.modelId
    ..vehicleId = this.vehicleId;
}
////////////////////////////////////////////////////////////////////////////////

extension on HiveAditionalFields {
  AditionalFields get fromHive => AditionalFields()
    ..name = this.name
    ..order = this.order
    ..required = this.required
    ..tag = this.tag;
}

extension on List<AditionalFields> {
  List<HiveAditionalFields> get toHive => this
      .map((e) => HiveAditionalFields()
        ..name = e.name
        ..order = e.order
        ..required = e.required
        ..tag = e.tag)
      .toList();
}

////////////////////////////////////////////////////////////////////////////////
extension on LatLong {
  HiveLatLong get toHive => HiveLatLong()
    ..latitude = this?.latitude
    ..longitude = this?.longitude;
}

extension on HiveLatLong {
  LatLong get fromHive => LatLong()
    ..latitude = this?.latitude
    ..longitude = this?.longitude;
}

////////////////////////////////////////////////////////////////////////////////

extension on List<HiveCheckListItems> {
  List<CheckListItems> get fromHive => this
      .map((e) => CheckListItems()
        ..key = e.key
        ..checked = e.checked
        ..name = e.name
        ..order = e.order
        ..required = e.required)
      .toList();
}

////////////////////////////////////////////////////////////////////////////////
extension on Checklist {
  // ignore: unused_element
  HiveChecklist get toHive => HiveChecklist()
    ..signatureUri = this.signatureUri?.toString()
    ..observation = this.observation
    ..items = this.items.toHive;
}

extension on HiveChecklist {
  // ignore: unused_element
  Checklist get fromHive => Checklist()
    ..signatureUri =
        this.signatureUri != null ? Uri.parse(this.signatureUri) : null
    ..observation = this.observation
    ..items = this.items.fromHive;
}

////////////////////////////////////////////////////////////////////////////////
extension on List<HiveTestInfo> {
  // ignore: unused_element
  List<TestInfo> get fromHive => this
      .map((e) => TestInfo()
        ..technicalVisitId = e.technicalVisitId
        ..key = e.key
        ..description = e.description
        ..icon = e.icon
        ..iconColor = e.iconColor
        ..name = e.name
        ..require = e.require
        ..status = e.status
        ..statusDate = e.statusDate
        ..statusResult = e.statusResult
        ..jsonResult = e.jsonResult
        ..serial = e.serial
        ..analyzeItens = e.analyzeItens.fromHive
        ..configItens = e.configItens.fromHive)
      .toList();
}

extension on List<HiveAnalyzeItems> {
  List<AnalyzeItems> get fromHive => this
      .map((e) => AnalyzeItems()
        ..name = e.name
        ..path = e.path
        ..value = e.value
        ..translate = e.translate
        ..icon = e.icon
        ..iconColor = e.iconColor)
      .toList();
}

extension on List<HiveTestItems> {
  List<TestItems> get fromHive => this
      .map((e) => TestItems()
        ..key = e.key
        ..name = e.name
        ..override = e.override
        ..value = e.value)
      .toList();
}

////TEST
////////////////////////////////////////////////////////////////////////////////
// extension on TestConfig {
//   HiveTestConfig get toHive => HiveTestConfig()
//     ..name = this.name?.toString()
//     ..items = this.items.toHive;
// }

// extension on HiveTestConfig {
//   TestConfig get fromHive => TestConfig()
//     ..name = this.name
//     ..items = this.items.fromHive;
// }

////////////////////////////////////////////////////////////////////////////////
extension on InstallationStage {
  HiveInstallationStage get toHive => HiveInstallationStage()
    ..stage = this.stage.id
    ..message = this.message;
}

extension on HiveInstallationStage {
  InstallationStage get fromHive => InstallationStage()
    ..stage = TechnicalVisitStage.stageFor(this.stage)
    ..message = this.message;
}

extension on Companies {
  HiveCompanies get toHive => HiveCompanies()
    ..id = this.id
    ..name = this.name
    ..logoURL = this.logoURL
    ..technicalname = this.technicalname
    ..color = this.color;
}

extension on HiveCompanies {
  Companies get fromHive => Companies()
    ..id = this.id
    ..name = this.name
    ..logoURL = this.logoURL
    ..technicalname = this.technicalname
    ..color = this.color;
}

////////////////////////////////////////////////////////////////////////////////
extension on List<Tracker> {
  List<HiveTrackerTechVisit> get toHive => this.map((e) {
        return HiveTrackerTechVisit()
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
          ..groupName = e.groupName;
      }).toList();
}

////////////////////////////////////////////////////////////////////////////////
extension on List<PictureInfo> {
  // ignore: unused_element
  List<HivePictureInfo> get toHive => this
      .map(
        (e) => HivePictureInfo()
          ..sent = e.sent
          ..observation = e.observation
          ..fileLocation = e.fileLocation.toString()
          ..imageId = e.imageId
          ..isCustom = e.isCustom,
      )
      .toList();
}

extension on List<HivePictureInfo> {
  // ignore: unused_element
  List<PictureInfo> get fromHive => this
      .map(
        (e) => PictureInfo()
          ..sent = e.sent
          ..observation = e.observation
          ..fileLocation = Uri.tryParse(e.fileLocation)
          ..imageId = e.imageId
          ..isCustom = e.isCustom,
      )
      .toList();
}
////////////////////////////////////////////////////////////////////////////////

extension on Installation {
  HiveInstallation get toHive => HiveInstallation()
    ..company = this?.company?.toHive
    ..progress = this.progress
    ..agreementId = this.agreementId
    ..stage = this.stage.toHive
    ..appId = this.appId
    ..cloudId = this.cloudId
    ..customerId = this.customerId
    ..customerEmail = this.customerEmail
    ..finishDate = this.finishDate
    ..finishLocation = this.finishLocation.toHive
    ..startDate = this.startDate
    ..installationTypes = this.installationType?.installationTypes?.toHive
    ..startLocation = this.startLocation?.toHive
    ..trackers = this.trackers?.toHive
    // ..techinicalVisit = this.technicalVisit.toHive
    ..visitType = this.visitType
    ..comments = this.comments;

  String get hiveId => appId.toString();
}

extension on HiveInstallation {
  Installation get fromHive {
    InstallationType aux = InstallationType();
    InstallationType installationType;
    installationType =
        aux.transform(installationTypes: this.installationTypes?.fromHive);

    return Installation.forValues()
      ..company = this?.company?.fromHive
      ..progress = this.progress
      ..agreementId = this.agreementId
      ..stage = this.stage?.fromHive
      ..appId = this.appId
      ..cloudId = this.cloudId
      ..customerId = this.customerId
      ..customerEmail = this.customerEmail
      ..finishDate = this.finishDate
      ..finishLocation = this.finishLocation.fromHive
      ..startDate = this.startDate
      ..installationType = installationType
      ..startLocation = this.startLocation?.fromHive

      // ..technicalVisit = this.techinicalVisit.fromHive
      ..trackers = this.trackers?.fromHive
      ..comments = this.comments
      ..visitType = this.visitType;
  }
}

// extension on HiveTechinicalVisit {
//   TechnicalVisit get fromHive => TechnicalVisit()
//   ..agreementId = this.agreementId
//   ..id = this.id
//   ..
//     ;
// }
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

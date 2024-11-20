import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/hive/hive_models.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:hive/hive.dart';

import '../../../models/reasonFinish.dart';

class HiveCompanyConfigDatabase extends CompanyConfigRepository {
  static const _boxCompanyConfig = 'companyConfig11';

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

  @override
  Future<CompanyConfig> getCompanyConfig() async {
    CompanyConfig companyConfig =
        await Hive.openBox<HiveCompanyConfig>(_boxCompanyConfig).then((box) =>
            box.values.isNotEmpty
                ? box?.values?.first?.fromHive
                : CompanyConfig(installationTypes: []));
    return companyConfig;
  }

  @override
  Future putCompanyConfig(CompanyConfig companyConfig) =>
      Hive.openBox<HiveCompanyConfig>(_boxCompanyConfig).then((box) async {
        await box.deleteAll(box.keys);
        box.add(companyConfig.toHive);
      });

  @override
  Future clearBox() =>
      Hive.openBox<HiveCompanyConfig>(_boxCompanyConfig).then((box) {
        box.clear();
      });
}

/////////////////////////////////////////////////////////////////////////////
/// FROM HIVE GETTERS

extension ext0 on HiveCompanyConfig {
  CompanyConfig get fromHive => CompanyConfig()
    ..installationTypes =
        this.installationTypes.map((element) => element.fromHive).toList();
}

extension ext1 on HiveInstallationTypes {
  InstallationTypes get fromHive => InstallationTypes()
    ..id = this.id
    ..config = this.config.fromHive
    ..name = this.name
    ..pictureUploadCompleted = this.pictureUploadCompleted;
}

extension ext2 on HiveVehicleType {
  VehicleType get fromHive => VehicleType()
    ..id = this?.id
    ..name = this?.name;
}

extension ext3 on HiveFeatureType {
  FeatureType get fromHive => FeatureType()
    ..id = this.id
    ..name = this.name;
}

extension ext4 on HiveFeatures {
  Features get fromHive => Features()
    ..checklistConfig = this?.checklistConfig?.fromHive
    ..id = this.id
    ..featureType = this.featureType.fromHive
    ..order = this.order
    ..deviceConfig = this?.deviceConfig?.fromHive
    ..deviceNewConfig = this?.deviceNewConfig?.fromHive
    ..deviceConfigV3 = this?.deviceConfigV3?.fromHive
    ..finishConfig = this?.finishConfig?.fromHive
    ..pictureConfig = this?.pictureConfig?.fromHive
    ..registerConfig = this?.registerConfig?.fromHive
    ..testConfig = this?.testConfig?.fromHive;
}

extension ext5 on HiveDeviceConfig {
  DeviceConfig get fromHive => DeviceConfig()
    ..brands = this.brands.map((element) => element.fromHive).toList()
    ..models = this.models.map((element) => element.fromHive).toList()
    ..devices = this?.devices?.fromHive
    ..locals = this?.locals?.fromHive;
}

extension on HiveDeviceLog {
  // ignore: unused_element
  DeviceLog get fromHive => DeviceLog()..devices = this?.devices?.fromHive;
}

extension ext6 on HiveFinishConfig {

  FinishConfig get fromHive => FinishConfig()
    ..observation = this.observation
    ..signatureUri =
        this.signatureUri != null ? Uri.parse(this.signatureUri) : null
    ..requireSign = this.requireSign
    ..showEmailField = this.showEmailField
    ..containsViolation = this.containsViolation
    ..observationViolation = this.observationViolation
    ..containsPendencyItem = this.containsPendencyItem
    ..observationPendencyItem = this.observationPendencyItem
    ..visitCompletelyFinished = this.visitCompletelyFinished
    ..reasonFinish = this?.reasonFinish?.fromHive;

}

extension ext7 on HivePictureConfig {
  PictureConfig get fromHive => PictureConfig()
    ..customPicturesCount = this.customPictureCount
    ..items = this.items.map((element) => element.fromHive).toList()
    ..name = this.name
    ..onlyCameraSource = this.onlyCameraSource
    ..currentPicturesInfo = this?.currentPicturesInfo?.fromHive;
}

extension ext8 on HivePictureItems {
  PictureItems get fromHive => PictureItems()
    ..description = this.description
    ..id = this.id
    ..cloudFileId = this.cloudFileId
    ..name = this.name
    ..isCoverPicture = this.isCoverPicture
    ..observationDesc = this.observationDesc
    ..observationRequired = this.observationRequired
    ..onlyCameraSource = this.onlyCameraSource
    ..order = this.order
    ..required = this.required
    ..orientation = this.orientation;
}

extension on HiveRegisterConfig {
  RegisterConfig get fromHive => RegisterConfig()
    ..aditionalFields = this.aditionalFields?.map((element) => element.fromHive)?.toList()
    ..currentInfo = this?.currentInfo?.fromHive
    ..recordType = this.recordType.fromHive;
}

extension on HiveTestConfig {
  TestConfig get fromHive => TestConfig()
    ..name = this.name
    ..tests = this.items?.map((element) => element.fromHive)?.toList();
}

extension on TestConfig {
  HiveTestConfig get toHive => HiveTestConfig()
    ..name = this.name
    ..items = this.tests.toHive;
}

extension on HiveVehicleInfo {
  VehicleInfo get fromHive => VehicleInfo()
    ..color = this.color
    ..modelName = this.modelName
    ..plate = this.plate
    ..brand = this.brand
    ..chassis = this.chassis
    ..odometer = this.odometer
    ..stateName = this.stateName
    ..cityName = this.cityName
    ..modelYear = this.modelYear
    ..fleetId = this.fleetId
    ..year = this.year
    ..ufId = this.ufId
    ..cityId = this.cityId
    ..brandId = this.brandId
    ..modelId = this.modelId
    ..vehicleId = this.vehicleId;
}

extension ext10 on HiveRecordType {
  RecordType get fromHive => RecordType()
    ..id = this.id
    ..name = this.name;
}

extension ext11 on HiveConfig {
  Config get fromHive => Config()
    ..features = this.features.map((feature) => feature.fromHive).toList()
    ..color = this.color
    ..icon = this.icon
    ..isIncludeCustomer = this.isIncludeCustomer
    ..canInstallMultipleMainEquipments = this.canInstallMultipleMainEquipments
    ..localType = this.localType.fromHive
    ..vehicleType = this.vehicleType.fromHive;
}

extension on HiveAditionalFields {
  AditionalFields get fromHive => AditionalFields()
    ..name = this.name
    ..order = this.order
    ..required = this.required
    ..value = this.value
    ..tag = this.tag;
}

extension on HiveTestInfo {
  TestInfo get fromHive => TestInfo()
    ..name = this.name
    ..description = this.description
    ..icon = this.icon
    ..iconColor = this.iconColor
    ..technicalVisitId = this.technicalVisitId
    ..key = this.key
    ..require = this.require
    ..status = this.status
    ..statusDate = this.statusDate
    ..statusResult = this.statusResult
    ..jsonResult = this.jsonResult
    ..serial = this.serial
    ..analyzeItens =
        this.analyzeItens?.map((element) => element.fromHive)?.toList()
    ..configItens =
        this.configItens?.map((element) => element.fromHive)?.toList();
}

extension on HiveAnalyzeItems {
  AnalyzeItems get fromHive => AnalyzeItems()
    ..name = this.name
    ..path = this.path
    ..value = this.value
    ..translate = this.translate
    ..icon = this.icon
    ..iconColor = this.iconColor;
}

extension on HiveTestItems {
  TestItems get fromHive => TestItems()
    ..name = this.name
    ..key = this.key
    ..override = this.override
    ..value = this.value;
}

extension ext13 on HiveBrands {
  Brands get fromHive => Brands()
    ..id = this.id
    ..name = this.name;
}

extension ext14 on HiveModels {
  Models get fromHive => Models()
    ..id = this.id
    ..name = this.name
    ..brandId = this.brandId
    ..groupId = this.groupId
    ..model = this.model;
}

extension ext15 on HiveCheckListItems {
  CheckListItems get fromHive => CheckListItems()
    ..key = this.key
    ..name = this.name
    ..checked = this.checked
    ..order = this.order
    ..required = this.required;
}

extension ext16 on HiveChecklistConfig {
  ChecklistConfig get fromHive => ChecklistConfig()
    ..items = this.items.map((element) => element.fromHive).toList()
    ..name = this.name
    ..requireSign = this.requireSign
    ..currentCheckList = this?.currentCheckList?.fromHive;
}

extension on HiveChecklist {
  Checklist get fromHive => Checklist()
    ..signatureUri =
        this.signatureUri != null ? Uri.parse(this.signatureUri) : null
    ..observation = this.observation
    ..items = this.items.fromHive;
}

//////////////////////////////////////////////////////////////////////////////////
/// FROM HIVE LIST GETTERS

extension on List<HiveDevices> {
  List<Devices> get fromHive => this
      .map((e) => Devices()
        ..deviceId = e.deviceId
        ..modelName = e.modelName
        ..oldSerial = e.oldSerial
        ..serial = e.serial
        ..state = e.state)
      .toList();
}

extension on List<HiveLocals> {
  List<InstallationLocal> get fromHive => this
      .map((e) => InstallationLocal()
        ..id = e.id
        ..name = e.name)
      .toList();
}

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

extension on List<HivePictureInfo> {
  List<PictureInfo> get fromHive => this
      .map(
        (e) => PictureInfo()
          ..observation = e.observation
          ..fileLocation = Uri.tryParse(e.fileLocation)
          ..imageId = e.imageId
          ..isCustom = e.isCustom
          ..sent = e.sent,
      )
      .toList();
}

//////////////////////////////////////////////////////////////////////////////////
/// TO HIVE GETTERS
extension on List<PictureInfo> {
  List<HivePictureInfo> get toHive => this
      .map(
        (e) => HivePictureInfo()
          ..observation = e.observation
          ..fileLocation = e.fileLocation.toString()
          ..imageId = e.imageId
          ..isCustom = e.isCustom
          ..sent = e.sent,
      )
      .toList();
}

extension on Checklist {
  HiveChecklist get toHive => HiveChecklist()
    ..signatureUri = this?.signatureUri?.toString()
    ..observation = this?.observation
    ..items = this.items.toHive;
}

extension ext17 on CompanyConfig {
  HiveCompanyConfig get toHive =>
      HiveCompanyConfig()..installationTypes = this.installationTypes.toHive;
}

extension ext18 on Config {
  HiveConfig get toHive => HiveConfig()
    ..color = this.color
    ..features = this.features.toHive
    ..icon = this.icon
    ..isIncludeCustomer = this.isIncludeCustomer
    ..canInstallMultipleMainEquipments = this.canInstallMultipleMainEquipments
    ..localType = this?.localType?.toHive
    ..vehicleType = this?.vehicleType?.toHive;
}

extension ext19 on FeatureType {
  HiveFeatureType get toHive => HiveFeatureType()
    ..id = this.id
    ..name = this.name;
}

extension ext20 on ChecklistConfig {
  HiveChecklistConfig get toHive => HiveChecklistConfig()
    ..items = this.items.toHive
    ..name = this.name
    ..requireSign = this.requireSign
    ..currentCheckList = this?.currentCheckList?.toHive;
}

extension ext21 on VehicleType {
  HiveVehicleType get toHive => HiveVehicleType()
    ..id = this?.id
    ..name = this?.name;
}

extension ext22 on DeviceConfig {
  HiveDeviceConfig get toHive => HiveDeviceConfig()
    ..brands = this.brands.toHive
    ..models = this.models.toHive
    ..devices = this?.devices?.toHive;
}

extension on DeviceLog {
  // ignore: unused_element
  HiveDeviceLog get toHive => HiveDeviceLog()..devices = this?.devices?.toHive;
}

extension ext23 on PictureConfig {
  HivePictureConfig get toHive => HivePictureConfig()
    ..customPictureCount = this.customPicturesCount
    ..items = this.items.toHive
    ..name = this.name
    ..onlyCameraSource = this.onlyCameraSource
    ..currentPicturesInfo = this?.currentPicturesInfo?.toHive;
}

extension on RegisterConfig {
  HiveRegisterConfig get toHive => HiveRegisterConfig()
    ..aditionalFields = this.aditionalFields?.toHive
    ..currentInfo = this?.currentInfo?.toHive
    ..recordType = this.recordType.toHive;
}

extension on FinishConfig {
  HiveFinishConfig get toHive => HiveFinishConfig()
    ..signatureUri = this?.signatureUri?.toString()
    ..observation = this.observation
    ..requireSign = this.requireSign
    ..showEmailField = this.showEmailField
    ..containsViolation = this.containsViolation
    ..observationViolation = this.observationViolation
    ..containsPendencyItem = this.containsPendencyItem
    ..observationPendencyItem = this.observationPendencyItem
    ..visitCompletelyFinished = this.visitCompletelyFinished
    ..reasonFinish = this?.reasonFinish?.toHive;
}

extension ext25 on RecordType {
  HiveRecordType get toHive => HiveRecordType()
    ..id = this.id
    ..name = this.name;
}

////////////////////////////////////////////////////////////////////////////////////
/// TO HIVE LIST GETTERS

extension ext26 on List<InstallationTypes> {
  List<HiveInstallationTypes> get toHive => this
      .map((e) => HiveInstallationTypes()
        ..id = e.id
        ..config = e.config.toHive
        ..name = e.name
        ..pictureUploadCompleted = e.pictureUploadCompleted)
      .toList();
}

extension on List<AditionalFields> {
  List<HiveAditionalFields> get toHive => this
      .map((e) => HiveAditionalFields()
        ..name = e.name
        ..order = e.order
        ..required = e.required
        ..tag = e.tag
        ..value = e.value)
      .toList();
}

extension ext28 on List<PictureItems> {
  List<HivePictureItems> get toHive => this
      .map((e) => HivePictureItems()
        ..isCoverPicture = e.isCoverPicture
        ..description = e.description
        ..id = e.id
        ..cloudFileId = e.cloudFileId
        // ..key = e.key
        ..name = e.name
        ..observationDesc = e.observationDesc
        ..observationRequired = e.observationRequired
        ..onlyCameraSource = e.onlyCameraSource
        ..order = e.order
        ..required = e.required
        ..orientation = e.orientation)
      .toList();
}

extension ext29 on List<Brands> {
  List<HiveBrands> get toHive => this
      .map((e) => HiveBrands()
        ..id = e.id
        ..name = e.name)
      .toList();
}

extension ext30 on List<Models> {
  List<HiveModels> get toHive => this
      .map((e) => HiveModels()
        ..id = e.id
        ..brandId = e.brandId
        ..groupId = e.groupId
        ..model = e.model
        ..name = e.name)
      .toList();
}

extension ext31 on List<Features> {
  List<HiveFeatures> get toHive => this
      .map((e) => HiveFeatures()
        ..featureType = e.featureType.toHive
        ..pictureConfig = e?.pictureConfig?.toHive
        ..registerConfig = e?.registerConfig?.toHive
        ..deviceConfig = e?.deviceConfig?.toHive
        ..deviceNewConfig = e?.deviceNewConfig?.toHive
        ..checklistConfig = e?.checklistConfig?.toHive
        ..finishConfig = e?.finishConfig?.toHive
        ..testConfig = e?.testConfig?.toHive
        ..id = e.id
        ..order = e.order)
      .toList();
}

extension on List<Devices> {
  List<HiveDevices> get toHive => this
      .map((e) => HiveDevices()
        ..deviceId = e.deviceId
        ..modelName = e.modelName
        ..oldSerial = e.oldSerial
        ..serial = e.serial
        ..state = e.state)
      .toList();
}

extension ext32 on List<CheckListItems> {
  List<HiveCheckListItems> get toHive => this
      .map((e) => HiveCheckListItems()
        ..name = e.name
        ..key = e.key
        ..order = e.order
        ..checked = e.checked
        ..required = e.required)
      .toList();
}

extension ext33 on InstallationTypes {
  HiveInstallationTypes get toHive => HiveInstallationTypes()
    ..id = this.id
    ..name = this.name
    ..config = this.config.toHive
    ..pictureUploadCompleted = this.pictureUploadCompleted;
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

extension ext34 on List<TestInfo> {
  List<HiveTestInfo> get toHive => this
      .map((e) => HiveTestInfo()
        ..name = e.name
        ..technicalVisitId = e.technicalVisitId
        ..key = e.key
        ..icon = e.icon
        ..iconColor = e.iconColor
        ..require = e.require
        ..description = e.description
        ..require = e.require
        ..status = e.status
        ..statusDate = e.statusDate
        ..statusResult = e.statusResult
        ..jsonResult = e.jsonResult
        ..serial = e.serial
        ..analyzeItens = e.analyzeItens.toHive
        ..configItens = e.configItens != null ? e.configItens.toHive : null)
      .toList();
}

extension ext35 on List<TestItems> {
  List<HiveTestItems> get toHive => this
      .map((e) => HiveTestItems()
        ..name = e.name
        ..key = e.key
        ..override = e.override
        ..value = e.value)
      .toList();
}

extension ext36 on List<AnalyzeItems> {
  List<HiveAnalyzeItems> get toHive => this != null
      ? this
          .map((e) => HiveAnalyzeItems()
            ..name = e.name
            ..path = e.path
            ..value = e.value
            ..translate = e.translate
            ..icon = e.icon
            ..iconColor = e.iconColor)
          .toList()
      : null;
}

extension ext37 on DeviceNewConfig {
  HiveDeviceNewConfig get toHive => HiveDeviceNewConfig()
    ..groups = this?.groups?.toHive
    ..devices = this?.devices?.toHive;
}

extension ext38 on List<Groups> {
  List<HiveGroups> get toHive => this
      .map((e) => HiveGroups()
        ..id = e.id
        ..name = e.name
        ..main = e.main
        ..required = e.required
        ..allowVirtual = e.allowVirtual
        ..items = e.items.toHive)
      .toList();
}

extension ext39 on List<GroupsItem> {
  List<HiveGroupItem> get toHive => this
      .map((e) => HiveGroupItem()
        ..required = e.required
        ..allowVirtual = e.allowVirtual
        ..peripheral = e.peripheral.toHive
        ..hardwareFeature = e.hardwareFeature.toHive
        ..group = e.group?.toHive)
      .toList();
}

extension ext40 on Peripheral {
  HivePeripheral get toHive => HivePeripheral()
    ..id = this.id
    ..name = this.name
    ..type = this.type;
}

extension ext41 on HardwareFeature {
  HiveHardwareFeature get toHive => HiveHardwareFeature()
    ..id = this.id
    ..description = this.description;
}

extension ext42 on HiveDeviceNewConfig {
  DeviceNewConfig get fromHive => DeviceNewConfig()
    ..groups = this.groups.map((element) => element.fromHive).toList()
    ..devices = this?.devices?.fromHive;
}

extension ext43 on HiveGroups {
  Groups get fromHive => Groups()
    ..id = this.id
    ..name = this.name
    ..main = this.main
    ..required = this.required
    ..allowVirtual = this.allowVirtual
    ..items = this.items != null
        ? this.items.map((element) => element.fromHive).toList()
        : null;
}

extension ext44 on HiveGroupItem {
  GroupsItem get fromHive => GroupsItem()
    ..required = this.required
    ..allowVirtual = this.allowVirtual
    ..peripheral = this.peripheral.fromHive
    ..hardwareFeature = this.hardwareFeature.fromHive
    ..group = this.group?.fromHive;
}

extension ext45 on HivePeripheral {
  Peripheral get fromHive => Peripheral()
    ..id = this.id
    ..name = this.name;
}

extension ext46 on HiveHardwareFeature {
  HardwareFeature get fromHive => HardwareFeature()
    ..id = this.id
    ..description = this.description;
}

extension ext47 on Groups {
  HiveGroups get toHive => HiveGroups()
    ..id = this.id
    ..name = this.name
    ..main = this.main
    ..required = this.required
    ..allowVirtual = this.allowVirtual;
}

extension ext48 on LocalType {
  HiveLocalType get toHive => HiveLocalType()
    ..id = this?.id
    ..name = this?.name;
}

extension ext49 on HiveLocalType {
  LocalType get fromHive => LocalType()
    ..id = this?.id
    ..name = this?.name;
}

extension ext50 on HiveDeviceConfigV3 {
  DeviceConfigV3 get fromHive => DeviceConfigV3()
    ..slots = this.slots.map((element) => element.fromHive).toList();
}

extension ext51 on HiveSlot {
  Slot get fromHive => Slot()
    ..deviceId = this.deviceId
    ..equipment = this.equipment.fromHive
    ..equipmetAlter = this.equipment.fromHive
    ..group = this.group.fromHive
    ..groupAlter = this.group.fromHive
    ..hardwareFeature = this.hardwareFeature.fromHive
    ..peripheral = this.peripheral.fromHive
    ..main = this.main
    ..operation = this.operation;
}

extension ext52 on HiveEquipment {
  Equipment get fromHive => Equipment()
    ..id = this?.id
    ..name = this?.name;
}

extension ext53 on HiveGroup {
  Group get fromHive => Group()
    ..id = this?.id
    ..name = this?.name;
}

extension ext54 on HiveReasonFinish {
  // Converte de HiveReasonFinish para ReasonFinish
  ReasonFinish get fromHive => ReasonFinish(
    id: this.id,
    name: this.name,
    key: this.key,
  );
}

extension ext55 on ReasonFinish {
  // Converte de ReasonFinish para HiveReasonFinish
  HiveReasonFinish get toHive => HiveReasonFinish()
    ..id = this.id
    ..name = this.name
    ..key = this.key;
}
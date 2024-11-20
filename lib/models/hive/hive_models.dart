import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../reasonFinish.dart';

part 'hive_models.g.dart';

@HiveType(typeId: 1)
class HiveDeviceBrand {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
}

@HiveType(typeId: 2)
class HiveDeviceModel {
  @HiveField(0)
  int id;
  @HiveField(1)
  String model;
  @HiveField(2)
  String name;
  @HiveField(3)
  int brandId;
}

@HiveType(typeId: 3)
class HiveChecklistItem {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  int order = 0;
  @HiveField(3)
  int installationType;
}

@HiveType(typeId: 4)
class HivePictureToTake {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String description;
  @HiveField(3)
  int order = 0;
  @HiveField(4)
  int installationType;
  @HiveField(5)
  bool required = false;
  @HiveField(6)
  bool observationRequired = false;
  @HiveField(7)
  String observationDesc;
  @HiveField(8)
  bool sent;
  @HiveField(9)
  String orientation;
}

@HiveType(typeId: 5)
class HiveVehicleBrand {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String fipeName;
  @HiveField(3)
  String key;
  @HiveField(4)
  String vehicleType;
}

@HiveType(typeId: 6)
class HiveVehicleModel {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String fipeName;
  @HiveField(3)
  int brandId;
  @HiveField(4)
  String key;
}

////////////////////////////////////////////////////////////////////////////////
@HiveType(typeId: 7)
class HiveInstallation extends HiveObject {
  @HiveField(0)
  HiveInstallationStage stage;
  @HiveField(1)
  int cloudId;
  @HiveField(2)
  int appId;
  @HiveField(3)
  HiveInstallationTypes installationTypes;
  @HiveField(4)
  String customerEmail;
  @HiveField(5)
  int customerId;
  @HiveField(6)
  List<HiveTrackerTechVisit> trackers;
  @HiveField(7)
  List<HivePictureInfo> picturesInfo;
  @HiveField(8)
  HiveLatLong startLocation;
  @HiveField(9)
  HiveRegisterConfig registerConfig;
  @HiveField(10)
  HiveChecklist checklist;
  @HiveField(11)
  DateTime startDate;
  @HiveField(12)
  DateTime finishDate;
  @HiveField(13)
  List<HivePictureInfo> customPicturesInfo;
  @HiveField(14)
  String comments;
  @HiveField(15)
  HiveDeviceLog deviceLog;
  @HiveField(16)
  int agreementId;
  @HiveField(17)
  double progress;
  @HiveField(18)
  HiveCompanies company;
  @HiveField(19)
  HiveLatLong finishLocation;
  @HiveField(20)
  String visitType;
}

@HiveType(typeId: 8)
class HiveTracker {
  @HiveField(0)
  String serial;
  @HiveField(1)
  int modelId;
  @HiveField(2)
  int brandId;
  @HiveField(3)
  int installationLocal;
}

@HiveType(typeId: 9)
class HivePictureInfo {
  @HiveField(0)
  String imageId;
  @HiveField(1)
  String fileLocation;
  @HiveField(2)
  String observation;
  @HiveField(3)
  bool isCustom;
  @HiveField(4)
  bool sent;
}

@HiveType(typeId: 10)
class HiveLatLong {
  @HiveField(0)
  double latitude;
  @HiveField(1)
  double longitude;
}

@HiveType(typeId: 11)
class HiveVehicleInfo {
  @HiveField(0)
  String modelName;
  @HiveField(1)
  String plate;
  @HiveField(2)
  String year;
  @HiveField(3)
  String stateName;
  @HiveField(4)
  String color;
  @HiveField(5)
  String chassis;
  @HiveField(6)
  String modelYear;
  @HiveField(7)
  String cityName;
  @HiveField(8)
  String brand;
  @HiveField(9)
  String odometer;
  @HiveField(10)
  String fleetId;
  @HiveField(11)
  int ufId;
  @HiveField(12)
  int cityId;
  @HiveField(13)
  int brandId;
  @HiveField(14)
  int modelId;
  @HiveField(15)
  int vehicleId;
}

@HiveType(typeId: 12)
class HiveChecklistInstallationItem {
  @HiveField(0)
  int id;
  @HiveField(1)
  bool checked;
}

@HiveType(typeId: 13)
class HiveChecklist {
  @HiveField(0)
  String observation;
  @HiveField(1)
  List<HiveCheckListItems> items;
  @HiveField(2)
  String signatureUri;
}

@HiveType(typeId: 14)
class HiveInstallationStage {
  @HiveField(0)
  int stage;
  @HiveField(1)
  String message;
}

@HiveType(typeId: 15)
class HiveCustomer {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
}

@HiveType(typeId: 16)
class HiveConfiguration {
  @HiveField(0)
  bool mandatoryPictures;
  @HiveField(1)
  bool checklistEasyCheck;
  @HiveField(2)
  bool createNewInstallation;
}

@HiveType(typeId: 17)
class HiveTechnicalVisitEdit {
  @HiveField(0)
  List<HiveTrackerTechVisit> devices;
  @HiveField(1)
  int visitState;
  @HiveField(2)
  int agreementId;
  @HiveField(3)
  DateTime forecastStartDate;
  @HiveField(4)
  DateTime forecastFinishDate;
  @HiveField(5)
  String visitType;
  @HiveField(6)
  String visitReason;
  @HiveField(7)
  HiveLocalInfo localInfo;
  @HiveField(8)
  int installationType;
  @HiveField(9)
  String modelTechName;
  @HiveField(10)
  int id;
}

@HiveType(typeId: 18)
class HiveTrackerTechVisit {
  @HiveField(0)
  String serial;
  @HiveField(1)
  int modelId;
  @HiveField(2)
  int brandId;
  @HiveField(3)
  int installationLocal;
  @HiveField(4)
  String configName;
  @HiveField(5)
  String groupName;
  @HiveField(6)
  String brandName;
  @HiveField(7)
  String modelName;
  @HiveField(8)
  String modelType;
  @HiveField(9)
  String modelTechName;
  @HiveField(10)
  bool main;
  @HiveField(11)
  int equipmentItemId;
  @HiveField(12)
  int groupId;
  @HiveField(13)
  int deviceId;
}

@HiveType(typeId: 19)
class HiveLocalInfo {
  @HiveField(0)
  String identifier;
  @HiveField(1)
  String brand;
  @HiveField(2)
  String model;
  @HiveField(3)
  int year;
  @HiveField(4)
  String state;
  @HiveField(5)
  String color;
  @HiveField(6)
  int modelYear;
  @HiveField(7)
  String cityName;
  @HiveField(8)
  String chassis;
  @HiveField(9)
  String odometer;
  @HiveField(10)
  String description;
  @HiveField(11)
  String fleetId;
  @HiveField(12)
  int ufId;
  @HiveField(13)
  int cityId;
  @HiveField(14)
  int brandId;
  @HiveField(15)
  int modelId;
}

@HiveType(typeId: 20)
class HiveTechnicalVisit {
  @HiveField(0)
  int id;
  @HiveField(1)
  String visitType;
  @HiveField(2)
  int visitState;
  @HiveField(3)
  int installationType;
  @HiveField(4)
  DateTime forecastStartDate;
  @HiveField(5)
  DateTime forecastFinishDate;
  @HiveField(6)
  String visitReason;
  @HiveField(7)
  HiveLocalInfo localInfo;
  @HiveField(8)
  int techPersonId;
  @HiveField(9)
  String techPersonName;
  @HiveField(10)
  HiveMainDevice mainDevice;
  @HiveField(11)
  int agreementId;
  @HiveField(12)
  int groupId;
  @HiveField(13)
  DateTime visitStartDate;
  @HiveField(14)
  DateTime visitFinishDate;
  @HiveField(15)
  DateTime cancelDate;
}

@HiveType(typeId: 21)
class HiveMainDevice {
  @HiveField(0)
  String serial;
  @HiveField(1)
  String model;
  @HiveField(2)
  String modelTechName;
  @HiveField(3)
  String brandName;
  @HiveField(4)
  String modelName;
}

@HiveType(typeId: 22)
class HiveDeviceGroup {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
}

@HiveType(typeId: 23)
class HiveCompanyConfig {
  @HiveField(0)
  List<HiveInstallationTypes> installationTypes;
}

@HiveType(typeId: 24)
class HiveInstallationTypes {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  HiveConfig config;
  @HiveField(3)
  bool pictureUploadCompleted;
}

@HiveType(typeId: 25)
class HiveVehicleType {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
}

@HiveType(typeId: 26)
class HiveFeatures {
  @HiveField(0)
  String id;
  @HiveField(1)
  int order;
  @HiveField(2)
  HiveFeatureType featureType;
  @HiveField(3)
  HiveRegisterConfig registerConfig;
  @HiveField(4)
  HiveChecklistConfig checklistConfig;
  @HiveField(5)
  HiveDeviceConfig deviceConfig;
  @HiveField(6)
  HivePictureConfig pictureConfig;
  @HiveField(7)
  HiveFinishConfig finishConfig;
  @HiveField(8)
  HiveTestConfig testConfig;
  @HiveField(9)
  HiveDeviceNewConfig deviceNewConfig;
  @HiveField(10)
  HiveDeviceConfigV3 deviceConfigV3;
}

@HiveType(typeId: 27)
class HiveConfig {
  @HiveField(0)
  HiveVehicleType vehicleType;
  @HiveField(1)
  String color;
  @HiveField(2)
  String icon;
  @HiveField(3)
  List<HiveFeatures> features;
  @HiveField(4)
  bool isIncludeCustomer;
  @HiveField(5)
  bool canInstallMultipleMainEquipments;
  @HiveField(6)
  HiveLocalType localType;
}

@HiveType(typeId: 28)
class HiveAditionalFields {
  @HiveField(0)
  String tag;
  @HiveField(1)
  String name;
  @HiveField(2)
  bool required;
  @HiveField(3)
  int order;
  @HiveField(4)
  String value;
}

@HiveType(typeId: 29)
class HiveBrands {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
}

@HiveType(typeId: 30)
class HiveModels {
  @HiveField(0)
  int id;
  @HiveField(1)
  String model;
  @HiveField(2)
  String name;
  @HiveField(3)
  int brandId;
  @HiveField(4)
  int groupId;
}

@HiveType(typeId: 31)
class HiveRegisterConfig {
  @HiveField(0)
  HiveRecordType recordType;
  @HiveField(1)
  List<HiveAditionalFields> aditionalFields;
  @HiveField(2)
  HiveVehicleInfo currentInfo;
}

@HiveType(typeId: 32)
class HiveChecklistConfig {
  @HiveField(0)
  String name;
  @HiveField(1)
  bool requireSign;
  @HiveField(2)
  List<HiveCheckListItems> items;
  @HiveField(3)
  HiveChecklist currentCheckList;
}

@HiveType(typeId: 33)
class HiveCheckListItems {
  @HiveField(0)
  String key;
  @HiveField(1)
  String name;
  @HiveField(2)
  int order;
  @HiveField(3)
  bool required;
  @HiveField(4)
  bool checked;
}

@HiveType(typeId: 34)
class HiveDeviceConfig {
  @HiveField(0)
  List<HiveBrands> brands;
  @HiveField(1)
  List<HiveModels> models;
  @HiveField(2)
  List<HiveDevices> devices;
  @HiveField(3)
  List<HiveLocals> locals;
}

@HiveType(typeId: 35)
class HivePictureConfig {
  @HiveField(0)
  String name;
  @HiveField(1)
  List<HivePictureItems> items;
  @HiveField(2)
  List<HivePictureInfo> currentPicturesInfo;
  @HiveField(3)
  bool onlyCameraSource;
  @HiveField(4)
  int customPictureCount;
}

@HiveType(typeId: 36)
class HivePictureItems {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String description;
  @HiveField(3)
  int order;
  @HiveField(4)
  bool required;
  @HiveField(5)
  bool onlyCameraSource;
  @HiveField(6)
  bool observationRequired;
  @HiveField(7)
  String observationDesc;
  @HiveField(8)
  int cloudFileId;
  @HiveField(9)
  bool isCoverPicture;
  @HiveField(10)
  String orientation;
}

@HiveType(typeId: 37)
class HiveFinishConfig {
  @HiveField(0)
  bool showEmailField;
  @HiveField(1)
  bool requireSign;
  @HiveField(2)
  String observation;
  @HiveField(3)
  String signatureUri;
  @HiveField(4)
  bool containsViolation;
  @HiveField(5)
  String observationViolation;
  @HiveField(6)
  bool containsPendencyItem;
  @HiveField(7)
  String observationPendencyItem;

  // Novo campo ReasonFinish
  @HiveField(8)
  //ReasonFinish reasonFinish;
  HiveReasonFinish reasonFinish;

  @HiveField(9)
  bool visitCompletelyFinished;

}


@HiveType(typeId: 38)
class HiveFeatureType {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
}

@HiveType(typeId: 39)
class HiveRecordType {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
}

@HiveType(typeId: 40)
class HiveDeviceLog {
  List<HiveDevices> devices;
}

@HiveType(typeId: 41)
class HiveDevices {
  @HiveField(0)
  int deviceId;
  @HiveField(1)
  String serial;
  @HiveField(2)
  String modelName;
  @HiveField(3)
  String state;
  @HiveField(4)
  String oldSerial;
}

@HiveType(typeId: 42)
class HiveCompanies {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String logoURL;
  @HiveField(3)
  String technicalname;
  @HiveField(4)
  String color;
}

@HiveType(typeId: 43)
class HiveTestConfig {
  @HiveField(0)
  String name;
  @HiveField(1)
  List<HiveTestInfo> items;
}

@HiveType(typeId: 44)
class HiveTestInfo {
  @HiveField(0)
  int technicalVisitId;
  @HiveField(1)
  String key;
  @HiveField(2)
  String name;
  @HiveField(3)
  String icon;
  @HiveField(4)
  String iconColor;
  @HiveField(5)
  String description;
  @HiveField(6)
  bool require;
  @HiveField(7)
  int status;
  @HiveField(8)
  DateTime statusDate;
  @HiveField(9)
  String statusResult;
  @HiveField(10)
  String jsonResult;
  @HiveField(11)
  String serial;
  @HiveField(12)
  List<HiveAnalyzeItems> analyzeItens;
  @HiveField(13)
  List<HiveTestItems> configItens;
}

@HiveType(typeId: 45)
class HiveTestItems {
  @HiveField(0)
  String key;
  @HiveField(1)
  String name;
  @HiveField(2)
  String value;
  @HiveField(3)
  bool override;
}

@HiveType(typeId: 46)
class HiveAnalyzeItems {
  @HiveField(0)
  String name;
  @HiveField(1)
  String path;
  @HiveField(2)
  String value;
  @HiveField(3)
  String translate;
  @HiveField(4)
  String icon;
  @HiveField(5)
  String iconColor;
}

@HiveType(typeId: 47)
class HiveDeviceNewConfig {
  @HiveField(0)
  List<HiveGroups> groups;
  @HiveField(1)
  List<HiveDevices> devices;
}

@HiveType(typeId: 48)
class HiveGroups {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(3)
  List<HiveGroupItem> items;
  @HiveField(4)
  bool main;
  @HiveField(5)
  bool allowVirtual;
  @HiveField(6)
  bool required;
}

@HiveType(typeId: 49)
class HiveGroupItem {
  @HiveField(0)
  bool required;
  @HiveField(1)
  HivePeripheral peripheral;
  @HiveField(3)
  HiveHardwareFeature hardwareFeature;
  @HiveField(4)
  HiveGroups group;
  @HiveField(5)
  bool allowVirtual;
}

@HiveType(typeId: 50)
class HivePeripheral {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String type;
}

@HiveType(typeId: 51)
class HiveHardwareFeature {
  @HiveField(0)
  String id;
  @HiveField(1)
  String description;
}

@HiveType(typeId: 52)
class HiveLocalType {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
}

@HiveType(typeId: 53)
class HiveLocals {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
}

@HiveType(typeId: 54)
class HiveDeviceConfigV3 {
  @HiveField(0)
  List<HiveSlot> slots;
}

@HiveType(typeId: 55)
class HiveSlot {
  @HiveField(0)
  int deviceId;
  @HiveField(1)
  bool main;
  @HiveField(2)
  String operation;
  @HiveField(3)
  HiveEquipment equipment;
  @HiveField(4)
  HiveEquipment equipmentAlter;
  @HiveField(5)
  HiveGroup group;
  @HiveField(6)
  HiveGroup groupAlter;
  @HiveField(7)
  HiveHardwareFeature hardwareFeature;
  @HiveField(8)
  HivePeripheral peripheral;
}

@HiveType(typeId: 56)
class HiveEquipment {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
}

@HiveType(typeId: 57)
class HiveGroup {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
}


@HiveType(typeId: 58)
class HiveReasonFinish {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String key;

  HiveReasonFinish({this.id, this.name, this.key});
}
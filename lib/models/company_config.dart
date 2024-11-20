import 'dart:convert';

import 'package:flow_flutter/models/reasonFinish.dart';
import 'package:flow_flutter/models/technical_visit_list.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'installation.dart';

class CompanyConfig {
  int requestDate;
  List<InstallationTypes> installationTypes;

  CompanyConfig({this.installationTypes});

  CompanyConfig.fromJson(Map<String, dynamic> json) {
    if (json['installationTypes'] != null) {
      installationTypes = <InstallationTypes>[];
      json['installationTypes'].forEach((v) {
        installationTypes.add(new InstallationTypes.fromJson(v));
      });
    }
    requestDate = json['requestDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.installationTypes != null) {
      data['installationTypes'] =
          this.installationTypes.map((v) => v.toJson()).toList();
    }
    data['requestDate'] = this.requestDate;
    return data;
  }
}

class InstallationStart {
  int id;
  String error;
  String visitType;
  int visitState;
  int forecastStartDate;
  int forecastFinishDate;
  String visitReason;
  int agreementId;
  int localId;
  LocalInfo localInfo;
  List<Tracker> devices;
  InstallationTypes installationTypes;

  InstallationStart(
      {this.id,
        this.error,
        this.visitType,
        this.visitState,
        this.forecastStartDate,
        this.forecastFinishDate,
        this.visitReason,
        this.agreementId,
        this.localId,
        this.devices,
        this.localInfo,
        this.installationTypes});

  InstallationStart.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    visitType = json['visitType'];
    visitState = json['visitState'];
    forecastStartDate = json['forecastStartDate'];
    forecastFinishDate = json['forecastFinishDate'];
    visitReason = json['visitReason'];
    agreementId = json['agreementId'];
    localId = json['localId'];
    if (json['devices'] != null) {
      devices = [];
      json['devices'].forEach((device) {
        devices.add(new Tracker.fromJson(device));
      });
    }
    localInfo = json["localInfo"] != null
        ? LocalInfo.fromJson(json["localInfo"])
        : null;
    installationTypes = json['installationType'] != null
        ? new InstallationTypes.fromJson(json['installationType'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['visitType'] = this.visitType;
    data['visitState'] = this.visitState;
    data['forecastStartDate'] = this.forecastStartDate;
    data['forecastFinishDate'] = this.forecastFinishDate;
    data['visitReason'] = this.visitReason;
    data['agreementId'] = this.agreementId;
    data['localId'] = this.localId;
    // if (this.localInfo != null) {
    //   data['localInfo'] = this.localInfo.toJson();
    // }
    if (this.devices != null) {
      data['devices'] = this.devices.map((v) => v.toJson()).toList();
    }
    if (this.installationTypes != null) {
      data['installationTypes'] = this.installationTypes.toJson();
    }
    return data;
  }
}

class InstallationTypes {
  int id;
  bool pictureUploadCompleted;
  String name;
  Config config;
  Config infoData;

  InstallationTypes({this.id, this.name, this.config});

  InstallationTypes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pictureUploadCompleted = json['pictureUploadCompleted'];
    name = json['name'];
    config = json['config'] != null ? new Config.fromJson(json['config']) : null;
    infoData = json['infoData'] != null ? new Config.fromJson(json['infoData']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['installationTypeId'] = this.id;
    data['name'] = name;
    data['pictureUploadCompleted'] = this.pictureUploadCompleted;
    if (this.config != null) {
      data['config'] = this.config.toJson();
    }
    return data;
  }
}

class Config {
  VehicleType vehicleType;
  String color;
  String icon;
  bool isIncludeCustomer;
  bool canInstallMultipleMainEquipments;
  List<Features> features;
  LocalType localType;

  Config({this.vehicleType, this.color, this.icon, this.features});

  Config.fromJson(Map<String, dynamic> json) {
    vehicleType = json['vehicleType'] != null
        ? new VehicleType.fromJson(json['vehicleType'])
        : null;
    localType = json['localType'] != null
        ? new LocalType.fromJson(json['localType'])
        : null;

    isIncludeCustomer = json['isIncludeCustomer'];
    // print("isIncludeCustomer: $isIncludeCustomer");
    canInstallMultipleMainEquipments = json['canInstallMultipleMainEquipments'];
    // print(
    //     "canInstallMultipleMainEquipments: $canInstallMultipleMainEquipments");
    color = json['color'];
    icon = json['icon'];
    if (json['features'] != null) {
      features = [];
      json['features'].forEach((v) {
        features.add(new Features.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.vehicleType != null && this.vehicleType.id != null) {
      data['vehicleType'] = this.vehicleType.toJson();
    }
    if (this.localType != null) {
      data['localType'] = this.localType.toJson();
    }
    data['isIncludeCustomer'] = this.isIncludeCustomer;
    data['canInstallMultipleMainEquipments'] = canInstallMultipleMainEquipments;
    data['color'] = this.color;
    data['icon'] = this.icon;
    if (this.features != null) {
      data['features'] = this.features.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VehicleType {
  String id;
  String name;

  VehicleType({this.id, this.name});

  VehicleType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class LocalType {
  String id;
  String name;

  LocalType({this.id, this.name});

  LocalType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['nome'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nome'] = this.name;
    return data;
  }
}

class Features {
  String id;
  int order;
  FeatureType featureType;
  RegisterConfig registerConfig;
  ChecklistConfig checklistConfig;
  DeviceConfig deviceConfig;
  DeviceNewConfig deviceNewConfig;
  DeviceConfigV3 deviceConfigV3;
  PictureConfig pictureConfig;
  TestConfig testConfig;
  FinishConfig finishConfig;

  Features(
      {this.id,
        this.order,
        this.featureType,
        this.registerConfig,
        this.checklistConfig,
        this.deviceConfig,
        this.pictureConfig,
        this.testConfig,
        this.finishConfig});

  Features.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    order = json['order'];
    featureType = json['featureType'] != null
        ? new FeatureType.fromJson(json['featureType'])
        : null;
    registerConfig = json['registerConfig'] != null
        ? new RegisterConfig.fromJson(json['registerConfig'])
        : null;
    checklistConfig = json['checklistConfig'] != null
        ? new ChecklistConfig.fromJson(json['checklistConfig'])
        : null;
    deviceConfig = json['deviceConfig'] != null
        ? new DeviceConfig.fromJson(json['deviceConfig'])
        : null;
    deviceNewConfig = json['deviceNewConfig'] != null
        ? new DeviceNewConfig.fromJson(json['deviceNewConfig'])
        : null;
    deviceConfigV3 = json['deviceConfigV3'] != null
        ? new DeviceConfigV3.fromJson(json['deviceConfigV3'])
        : null;
    pictureConfig = json['pictureConfig'] != null
        ? new PictureConfig.fromJson(json['pictureConfig'])
        : null;
    testConfig = json['testConfig'] != null
        ? new TestConfig.fromJson(json['testConfig'])
        : null;
    finishConfig = json['finishConfig'] != null
        ? new FinishConfig.fromJson(json['finishConfig'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order'] = this.order;
    if (this.featureType != null) {
      data['featureType'] = this.featureType.toJson();
    }
    if (this.registerConfig != null) {
      data['registerConfig'] = this.registerConfig.toJson();
    }
    if (this.checklistConfig != null) {
      data['checklistConfig'] = this.checklistConfig.toJson();
    }
    if (this.deviceConfig != null) {
      data['deviceConfig'] = this.deviceConfig.toJson();
    }
    if (this.deviceNewConfig != null) {
      data['deviceNewConfig'] = this.deviceNewConfig.toJson();
    }
    if (this.deviceConfigV3 != null) {
      data['deviceConfigV3'] = this.deviceConfigV3.toJson();
    }
    if (this.pictureConfig != null) {
      data['pictureConfig'] = this.pictureConfig.toJson();
    }
    if (this.testConfig != null) {
      data['testConfig'] = this.testConfig.toJson();
    }
    if (this.finishConfig != null) {
      data['finishConfig'] = this.finishConfig.toJson();
    }
    return data;
  }
}

class FeatureType {
  String id;
  String name;

  FeatureType({this.id, this.name});

  FeatureType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class RegisterConfig {
  int featureId;
  RecordType recordType;
  VehicleInfo currentInfo;
  // List<Fields> fields;
  List<AditionalFields> aditionalFields;

  RegisterConfig({
    this.recordType,
    this.aditionalFields,
    this.currentInfo,
  });

  RegisterConfig.fromJson(Map<String, dynamic> json) {
    recordType = json['recordType'] != null
        ? new RecordType.fromJson(json['recordType'])
        : null;
    if (json['additionalFields'] != null) {
      aditionalFields = [];
      json['additionalFields'].forEach((v) {
        aditionalFields.add(new AditionalFields.fromJson(v));
      });
    }
    // if (json['fields'] != null && json['fields'] != []) {
    //   currentInfo = VehicleInfo.fromJson(json['fields']);
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.recordType != null) {
      data['recordType'] = this.recordType.toJson();
    }
    if (this.aditionalFields != null) {
      data['additionalFields'] = this.aditionalFields.map((v) => v.toJson()).toList();
    }
    if (this.currentInfo != null) {
      data['fields'] = [
        fieldToJson("PLATE", "Placa", 1, this.currentInfo.plate),
        fieldToJson("BRAND", "Marca", 2, this.currentInfo.brand),
        fieldToJson("MODEL", "Modelo", 3, this.currentInfo.modelName),
        fieldToJson("YEAR", "Ano", 4, this.currentInfo.year),
        fieldToJson("MODELYEAR", "Ano Modelo", 5, this.currentInfo.modelYear),
        fieldToJson("CHASSIS", "Chassis", 6, this.currentInfo.chassis),
        fieldToJson("CITY", "Cidade", 7, this.currentInfo.cityName),
        fieldToJson("STATE", "Estado", 8, this.currentInfo.stateName),
        fieldToJson("COLOR", "Cor", 9, this.currentInfo.color),
        fieldToJson("ODOMETER", "Odometro", 10, this.currentInfo.odometer),
        fieldToJson("FLEET_ID", "ID da Frota", 11, this.currentInfo.fleetId),
        fieldToJson("CITY_ID", "ID da Cidade", 12, this.currentInfo?.cityId?.toString()),
        fieldToJson("MODEL_ID", "ID do Modelo", 13, this.currentInfo?.modelId?.toString()),
        fieldToJson("VEHICLE_ID", "ID do Veículo", 14, this.currentInfo?.vehicleId?.toString())
      ];
    }
    return data;
  }
}

class Fields {}

fieldToJson(String key, String name, int order, String field) {
  final Map<String, dynamic> data = new Map<String, dynamic>();

  data['key'] = key;
  data['name'] = name;
  data['order'] = order;
  data['value'] = field;

  return data;
}

class RecordType {
  String id;
  String name;

  RecordType({this.id, this.name});

  RecordType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class AditionalFields {
  String tag;
  String name;
  bool required;
  int order;
  String value;

  AditionalFields({this.tag, this.name, this.required, this.order});

  AditionalFields.fromJson(Map<String, dynamic> json) {
    tag = json['key'];
    name = json['name'];
    required = json['required'];
    order = json['order'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.tag;
    data['name'] = this.name;
    data['required'] = this.required;
    data['order'] = this.order;
    data['value'] = this.value;
    return data;
  }
}

class ChecklistConfig {
  String name;
  bool requireSign;
  bool pictureTaken;
  List<CheckListItems> items;
  Checklist currentCheckList;
  ChecklistConfig({this.name, this.requireSign, this.items});

  ChecklistConfig.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    requireSign = json['requireSign'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items.add(new CheckListItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['requireSign'] = this.requireSign;
    data['fileId'] = this.currentCheckList.cloudFileId;
    data['pictureTaken'] = this.pictureTaken;
    data["items"] = this.currentCheckList.items.map((v) => v.toJson()).toList();
    return data;
  }
}

class CheckListItems {
  String key;
  String name;
  int order;
  bool required;
  bool checked;

  CheckListItems(
      {this.key, this.name, this.order, this.required, this.checked});

  CheckListItems.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    name = json['name'];

    order = int.parse((json['order']).toString());
    required = json['required'];
    checked = json['checked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['name'] = this.name;
    data['order'] = this.order;
    data['required'] = this.required;
    data['checked'] = this.checked;

    return data;
  }
}

class TestConfig {
  String name;
  List<TestInfo> tests;

  TestConfig({this.name, this.tests});

  TestConfig.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['tests'] != null) {
      tests = [];
      json['tests'].forEach((v) {
        tests.add(new TestInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data["tests"] = this.tests.map((v) => v.toJson()).toList();
    return data;
  }
}

class TestStatus {
  TestStatus._();

  static const int ErrorSteps = -4;
  static const int ErrorMandatory = -3;
  static const int ErrorNonMandatory = -2;
  static const int Error = -1;
  static const int Pending = 0;
  static const int Success = 1;
  static const int IgnoredNonMandatory = 2;
  static const int IgnoredMandatory = 3;
  static const int Partial = 4;
  static const int Running = 5;
}

class ListCams {
  List<TechnicalVisitCam> listCams;

  ListCams({this.listCams});

  ListCams.fromJson(Map<String, dynamic> json) {
    if (json['listCams'] != null) {
      listCams = [];
      json['listCams'].forEach((v) {
        listCams.add(new TechnicalVisitCam.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["listCams"] = this.listCams.map((v) => v.toJson()).toList();
    return data;
  }
}

class TechnicalVisitCam {
  int id;
  int locId;
  String name;
  String model;
  String technicalName;
  String path;
  String hardwareFeatureId;
  String hardwareFeatureDescription;
  String peripheralName;

  TechnicalVisitCam(
      {this.id,
        this.name,
        this.model,
        this.technicalName,
        this.path,
        this.hardwareFeatureId,
        this.hardwareFeatureDescription,
        this.peripheralName});

  TechnicalVisitCam.fromJson(dynamic json) {
    id = json['id'];
    locId = json['locId'];
    name = json['name'];
    model = json["model"];
    technicalName = json['technicalName'];
    path = json['path'];
    hardwareFeatureId = json['hardwareFeatureId'];
    hardwareFeatureDescription = json['hardwareFeatureDescription'];
    peripheralName = json['peripheralName'];
  }

  Map<String, dynamic> toJson([bool forUpload = false]) {
    var map = <String, dynamic>{};
    map['id'] = this.id;
    map['locId'] = this.locId;
    map['name'] = this.name;
    map['model'] = this.model;
    map['technicalName'] = this.technicalName;
    map['path'] = this.path;
    map['hardwareFeatureId'] = this.hardwareFeatureId;
    map['hardwareFeatureDescription'] = this.hardwareFeatureDescription;
    map['peripheralName'] = this.peripheralName;

    return map;
  }
}

class CamList {
  List<CamInfo> cams;

  CamList.fromJson(dynamic json) {
    if (json["cams"] != null) {
      cams = [];
      json["cams"].forEach((v) {
        cams.add(CamInfo.fromJson(v));
      });
    }
  }
}

class CamInfo {
  String id;
  String localId;
  String name;
  String path;
  String pos;

  CamInfo.fromJson(dynamic json) {
    id = json['id'];
    localId = json['localId'];
    name = json['name'];
    path = json['path'];
    pos = json['pos'];
  }
}

class TestInfo {
  int technicalVisitId;
  String teste;
  String key;
  String name;
  String icon;
  String iconColor;
  String description;
  bool require;
  int status;
  // -4 = Erro em teste com vários passos
  // -3 = Erro em teste obrigatorio
  // -2 = Erro em teste nao obrigatorio
  // -1 = Erro
  // 0  = Pendente (nao iniciado)
  // 1  = Sucesso
  // 2  = Ignorado não obrigatório
  // 3  = Ignorado obrigatório
  // 4  = Parcial (em teste passo a passo nao finalizado)

  DateTime statusDate;
  String statusResult;
  String jsonResult;
  String serial;

  List<AnalyzeItems> analyzeItens;
  List<TestItems> configItens;
  int step = 0;
  String stepDescription = "";

  TestInfo(
      {this.key,
        this.name,
        this.icon,
        this.iconColor,
        this.description,
        this.require,
        this.status,
        this.statusDate,
        this.statusResult,
        this.jsonResult,
        this.serial,
        this.analyzeItens,
        this.configItens,
        this.step,
        this.stepDescription,
        this.technicalVisitId});

  TestInfo.fromJson(dynamic json) {
    technicalVisitId = json['technicalVisitId'];
    key = json['key'];
    name = json["name"];
    icon = json['icon'];
    iconColor = json['iconColor'];
    description = json['description'];
    require = json['require'] ?? false;
    status = json['status'];
    statusResult = json['statusResult'];

    statusDate = json['statusDate'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['statusDate'])
        : null;

    jsonResult = json['jsonResult'] != null ? json['jsonResult'] : "";

    serial = json['serial'];

    if (json["analyzeItens"] != null) {
      analyzeItens = [];
      json["analyzeItens"].forEach((v) {
        analyzeItens.add(AnalyzeItems.fromJson(v));
      });
    }

    if (json["configItens"] != null) {
      configItens = [];
      json["configItens"].forEach((v) {
        configItens.add(TestItems.fromJson(v));
      });
    }

    step = json['step'];

    stepDescription = json['stepDescription'];
  }

  Map<String, dynamic> toJson([bool forUpload = false]) {
    var map = <String, dynamic>{};
    map['technicalVisitId'] = this.technicalVisitId;
    map['key'] = this.key;
    map['name'] = this.name;
    map['icon'] = this.icon;
    map['iconColor'] = this.iconColor;
    map['description'] = this.description;
    map['require'] = this.require;
    map['status'] = this.status == null ? 0 : this.status;
    map['statusDate'] =
    this.statusDate != null ? this.statusDate.millisecondsSinceEpoch : null;
    map['statusResult'] = this.statusResult;

    map['jsonResult'] = this.jsonResult;

    map['serial'] = this.serial;

    map['analyzeItens'] = this.analyzeItens == null
        ? null
        : this.analyzeItens.map((v) => v.toJson()).toList();

    map['configItens'] = this.configItens == null
        ? null
        : this.configItens.map((v) => v.toJson()).toList();

    map['step'] = this.step == null ? 0 : this.step;

    map['stepDescription'] =
    this.stepDescription != null ? this.stepDescription : "";

    return map;
  }
}

class TestItems {
  String key;
  String name;
  String value;
  bool override;
  bool validatedJsonTest;

  TestItems({this.key, this.name, this.value, this.override});

  TestItems.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    name = json['name'];
    value = json['value'];
    override = json['override'];
    validatedJsonTest = json['validatedJsonTest'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['name'] = this.name;
    data['value'] = this.value;
    data['override'] = this.override;
    data['validatedJsonTest'] = this.validatedJsonTest;

    return data;
  }
}

class AnalyzeItems {
  String name;
  String path;
  String value;
  String translate;
  String icon;
  String iconColor;

  AnalyzeItems(
      {this.name,
        this.path,
        this.value,
        this.translate,
        this.icon,
        this.iconColor});

  AnalyzeItems.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    path = json['path'];
    value = json['value'];
    translate = json['translate'];
    icon = json['icon'];
    iconColor = json['iconColor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['path'] = this.path;
    data['value'] = this.value;
    data['translate'] = this.translate;
    data['icon'] = this.icon;
    data['iconColor'] = this.iconColor;

    return data;
  }
}

class DeviceConfigV3 {
  List<Slot> slots;

  DeviceConfigV3({this.slots});

  DeviceConfigV3.fromJson(Map<String, dynamic> json) {
    if (json['slots'] != null) {
      slots = [];
      json['slots'].forEach((v) {
        slots.add(new Slot.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    // if (this.devices != null) {
    //   data['devices'] = this.devices.map((v) => v.toJson()).toList();
    // }

    return data;
  }
}

class DeviceNewConfig {
  List<Groups> groups;
  List<Brands> brands;
  List<Models> models;
  List<Devices> devices;

  DeviceNewConfig({this.brands, this.models});

  DeviceNewConfig.fromJson(Map<String, dynamic> json) {
    brands = [];

    if (json['brands'] != null) {
      json['brands'].forEach((v) {
        brands.add(new Brands.fromJson(v));
      });
    }

    models = [];

    if (json['models'] != null) {
      json['models'].forEach((v) {
        models.add(new Models.fromJson(v));
      });
    }

    groups = [];

    if (json['groups'] != null) {
      json['groups'].forEach((v) {
        groups.add(new Groups.fromJson(v));
      });
    }

    devices = [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    if (this.devices != null) {
      data['devices'] = this.devices.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class DeviceConfig {
  List<Brands> brands;
  // List<Groups> groups;
  List<Models> models;
  List<Devices> devices;
  List<InstallationLocal> locals;
  // DeviceLog deviceLog;
  DeviceConfig({this.brands, this.models});

  DeviceConfig.fromJson(Map<String, dynamic> json) {
    if (json['brands'] != null) {
      brands = [];
      json['brands'].forEach((v) {
        brands.add(new Brands.fromJson(v));
      });
    }

    if (json['models'] != null) {
      models = [];
      json['models'].forEach((v) {
        models.add(new Models.fromJson(v));
      });
    }

    if (json['locals'] != null) {
      locals = [];
      json['locals'].forEach((v) {
        locals.add(new InstallationLocal.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    if (this.devices != null) {
      data['devices'] = this.devices.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class Groups {
  int id;
  String name;
  bool main;
  bool required;
  bool allowVirtual;
  List<GroupsItem> items;

  Groups({this.id, this.name});

  Groups.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'] != null ? json['name'] : json['nome'];
    required = json['required'];
    allowVirtual = json['allowVirtual'];
    main = json['main'];

    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items.add(new GroupsItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class Slot {
  int deviceId;
  bool main;
  String serial;
  bool virtual;
  String operation;
  String operationName;
  Color operationColor;
  Equipment equipment;
  Equipment equipmetAlter;
  Group group;
  Group groupAlter;
  HardwareFeature hardwareFeature;
  Peripheral peripheral;
  bool operationCompleted;
  int installationLocalId;
  int parentId;

  Slot({this.deviceId});

  Slot.fromJson(Map<String, dynamic> json) {
    deviceId = json['id'];
    operation = json['operation'];
    operationCompleted = json['operationCompleted'];
    installationLocalId = json['installationLocalId'];

    if(operationCompleted != null && operationCompleted) {
      this.operationName = "Concluído";
      this.operationColor = Colors.green;
    }
    else {
      switch (operation) {
        case "M":
          this.operationName = "Manter";
          this.operationColor = Colors.green;
          break;

        case "C":
          this.operationName = "Alterar";
          this.operationColor = Colors.blue;
          break;

        case "D":
          this.operationName = "Remover";
          this.operationColor = Colors.red;
          break;

        case "A":
          this.operationName = "Adicionar";
          this.operationColor = Colors.orange;
          break;

        default:
      }
    }

    main = json['main'];
    serial = json['serial'];
    virtual = json['virtual'];
    parentId = json['parentId'];

    equipment = json['equipment'] != null
        ? new Equipment.fromJson(json['equipment'])
        : null;
    equipmetAlter = json['equipmentAlter'] != null
        ? new Equipment.fromJson(json['equipmentAlter'])
        : null;
    group = json['groupEquipment'] != null
        ? new Group.fromJson(json['groupEquipment'])
        : null;
    groupAlter = json['groupEquipmentAlter'] != null
        ? new Group.fromJson(json['groupEquipmentAlter'])
        : null;
    hardwareFeature = json['hardwareFeature'] != null
        ? new HardwareFeature.fromJson(json['hardwareFeature'])
        : null;
    peripheral = json['peripheral'] != null
        ? new Peripheral.fromJson(json['peripheral'])
        : null;
  }
}

class Equipment {
  int id;
  String name;

  Equipment({this.id, this.name});

  Equipment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['nome'];
  }
}

class Group {
  int id;
  String name;

  Group({this.id, this.name});

  Group.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['nome'];
  }
}

class GroupsItem {
  bool allowVirtual;
  bool required;
  Peripheral peripheral;
  HardwareFeature hardwareFeature;
  Groups group;

  GroupsItem({this.required, this.peripheral, this.hardwareFeature});

  GroupsItem.fromJson(Map<String, dynamic> json) {
    allowVirtual = json['allowVirtual'];
    required = json['required'];

    if (json['peripheral'] != null) {
      peripheral = Peripheral.fromJson(json['peripheral']);
    }

    if (json['hardwareFeature'] != null) {
      hardwareFeature = HardwareFeature.fromJson(json['hardwareFeature']);
    }

    if (json['group'] != null) {
      group = Groups.fromJson(json['group']);
    }
  }
}

class Peripheral {
  int id;
  String name;
  String type;

  Peripheral({this.id, this.name, this.type});

  Peripheral.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
  }
}

class HardwareFeature {
  String id;
  String description;

  HardwareFeature({this.id, this.description});

  HardwareFeature.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['descricao'];
  }
}

class Brands {
  int id;
  String name;

  Brands({this.id, this.name});

  Brands.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class Models {
  int id;
  String model;
  String name;
  int brandId;
  int groupId;

  Models({this.id, this.model, this.name, this.brandId, this.groupId});

  Models.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    model = json['model'];
    name = json['name'];
    brandId = json['brandId'];
    groupId = json['groupId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['model'] = this.model;
    data['name'] = this.name;
    data['brandId'] = this.brandId;
    data['groupId'] = this.groupId;
    return data;
  }
}

class PictureConfig {
  bool onlyCameraSource;
  String name;
  int customPicturesCount;
  List<PictureItems> items;
  List<PictureInfo> currentPicturesInfo;

  PictureConfig({this.name, this.items});

  PictureConfig.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    onlyCameraSource = json['onlyCameraSource'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items.add(new PictureItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['onlyCameraSource'] = this.onlyCameraSource;
    if (this.items != null) {
      data['items'] =
          this.items.map((v) => v.toJson(this.currentPicturesInfo)).toList();
    }
    return data;
  }
}

class PictureItems {
  String id;
  // String key;
  bool isCoverPicture;
  String name;
  String description;
  int order;
  bool required;
  bool onlyCameraSource;
  bool observationRequired;
  String observationDesc;
  int cloudFileId;
  bool pictureTaken;
  String orientation;

  PictureItems(
      {this.id,
        // this.key,
        this.name,
        this.description,
        this.order,
        this.required,
        this.onlyCameraSource,
        this.observationRequired,
        this.observationDesc,
        this.isCoverPicture,
        this.orientation});

  PictureItems.fromJson(Map<String, dynamic> json) {
    id = json['key'];
    isCoverPicture = json['isCoverPicture'];
    // key = json['key'];
    name = json['name'];
    description = json['description'];
    order = json['order'];
    required = json['required'];
    orientation = json['orientation'];
    onlyCameraSource = json['onlyCameraSource'];
    observationRequired = json['observationRequired'];
    observationDesc = json['observationDesc'];
  }

  Map<String, dynamic> toJson(List<PictureInfo> currentPictures) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    PictureInfo thisPicture;
    if (currentPictures != null && currentPictures.isNotEmpty)
      // currentPictures?.fir
      thisPicture = currentPictures?.firstWhere(
              (picture) => picture.imageId == this.id,
          orElse: () => null);
    data['isCoverPicture'] = isCoverPicture;
    data['key'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['order'] = this.order;
    data['required'] = this.required;
    data['orientation'] = this.orientation;
    data['onlyCameraSource'] = this.onlyCameraSource;
    data['observationRequired'] = this.observationRequired;
    data['observationDesc'] = this.observationDesc;
    data['fileId'] = this.cloudFileId;
    data['pictureTaken'] = this.pictureTaken;
    data['observation'] = thisPicture?.observation ?? null;
    return data;
  }
}


class FinishConfig {
  bool showEmailField;
  bool requireSign;
  String email;
  int cloudFileId;
  bool pictureTaken;
  String observation;
  Uri signatureUri;
  bool containsViolation;
  String observationViolation;
  bool containsPendencyItem;
  String observationPendencyItem;
  bool visitCompletelyFinished;
  //List<ReasonFinish> reasonsFinish;
  ReasonFinish reasonFinish;
  int zendeskId;
  var prefs;

  FinishConfig({
    this.showEmailField,
    this.requireSign,
    this.cloudFileId,
    this.observation,
    this.signatureUri,
    this.containsViolation,
    this.observationViolation,
    this.containsPendencyItem,
    this.observationPendencyItem,
    this.visitCompletelyFinished,
    this.reasonFinish,
    this.zendeskId

  });

  FinishConfig.fromJson(Map<String, dynamic> json) {
    showEmailField = json['showEmailField'];
    requireSign = json['requireSign'];
  }


  Map<String, dynamic> toJson()  {

    final Map<String, dynamic> data = new Map<String, dynamic>();

    // ReasonFinish reasonFinish2 = ReasonFinish(
    //     id: 5,
    //     name: 'Manutenção Concluída :: Mudança no ponto de alimentação',
    //     key: 'manutencao_concluida_mudanca_no_ponto_de_alimentacao'
    // );

    // Preenche o mapa com os valores
    data['showEmailField'] = this.showEmailField;
    data['requireSign'] = this.requireSign;
    data['email'] = this.email;
    data['fileId'] = this.cloudFileId;
    data['pictureTaken'] = this.pictureTaken;
    data['observation'] = this.observation;
    data['signatureUri'] = this.signatureUri.toString();
    data['containsViolation'] = this.containsViolation;
    data['observationViolation'] = this.observationViolation;
    data['containsPendencyItem'] = this.containsPendencyItem;
    data['observationPendencyItem'] = this.observationPendencyItem;

    data['visitCompletelyFinished'] = this.visitCompletelyFinished;
    if (this.reasonFinish != null) {
      data['reasonFinish'] = this.reasonFinish.toJson();
    }

    // data['visitCompletelyFinished'] = true;
    // data['reasonFinish'] = reasonFinish2.toJson();

    return data;
  }


}

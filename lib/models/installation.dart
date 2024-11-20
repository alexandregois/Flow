import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/installation_type.dart';
import 'package:flow_flutter/models/technical_visit_list.dart';
import 'package:flow_flutter/repository/impl/http_requests.dart';
import 'package:flow_flutter/utils/technichal_visit_stage.dart';

import 'company.dart';

class Installation {
  InstallationStage stage;
  int cloudId;
  int appId;
  int agreementId;
  double progress;
  TechnicalVisit technicalVisit;
  InstallationType installationType;
  String comments;
  String customerEmail;
  int customerId;
  List<Tracker> trackers;
  LatLong startLocation;
  LatLong finishLocation;
  DateTime startDate;
  DateTime finishDate;
  String visitReason;
  String visitType;
  Companies company;

  Installation.start(InstallationType installationType) {
    this.company = DenoxRequests.selectedCompany;
    this.technicalVisit =
        TechnicalVisit(company: DenoxRequests.selectedCompany);
    this.appId = DateTime.now().millisecondsSinceEpoch;
    this.startDate = DateTime.now();
    this.installationType = installationType;
    this.progress = 0;
    installationType.installationTypes.config.features.forEach((feature) {
      if (feature.checklistConfig != null) {
        feature.checklistConfig.currentCheckList = Checklist(
          items: feature?.checklistConfig?.items,
          observation: null,
          signatureUri: null,
        );
      }
      if (feature.deviceConfig != null) feature.deviceConfig.devices = [];

      // if (feature.deviceNewConfig != null) {
      //   this.trackers = feature.deviceNewConfig.groups
      //       .map((group) => Tracker(deviceId: group.id, brandName: group.name))
      //       .toList();
      // }
    });

    this.stage = InstallationStage(
      stage: TechnicalVisitStage.IN_PROGRESS,
    );
  }

  Installation.startFromCloud(InstallationStart installationStart, TechnicalVisit technicalVisit, LatLong startLocation) {
    InstallationType aux = InstallationType();
    this.installationType = aux.transform(installationTypes: installationStart.installationTypes);
    // installationStart.installationTypes.config.features.forEach((element) {
    //   if (element.registerConfig != null) this.registerConfig = registerConfig;
    // });
    installationType.installationTypes.config.features.forEach((feature) {
      if (feature.checklistConfig != null) {
        feature.checklistConfig.currentCheckList = Checklist(
          items: feature?.checklistConfig?.items,
          observation: null,
          signatureUri: null,
        );
      }
      if (feature.testConfig != null) {
        if (feature.testConfig.name != null) {}
      }
      if (feature.registerConfig != null) {
        feature.registerConfig.currentInfo = VehicleInfo.fromLocalInfo(installationStart.localInfo);
      }
      if (feature.deviceConfig != null) {
        feature.deviceConfig.devices = [];
        installationStart?.devices?.forEach((device) {
          feature.deviceConfig.devices.add(Devices(
            deviceId: device.deviceId,
            serial: device.serial,
            modelName: device.modelName,
            state: "NOT_CHANGED",
          ));
        });
      }
      if (feature.deviceConfig != null)
        feature?.deviceConfig?.devices?.forEach((element) {
          print(element.toString());
        });

      if (feature.deviceNewConfig != null) {
        feature.deviceNewConfig.devices = [];
        installationStart?.devices?.forEach((device) {
          feature.deviceNewConfig.devices.add(Devices(
            deviceId: device.deviceId,
            serial: device.serial,
            modelName: device.modelName,
            state: "NOT_CHANGED",
          ));
        });
      }
    });
    this.technicalVisit = technicalVisit;
    this.progress = 0;
    this.agreementId = installationStart.agreementId;
    this.startLocation = startLocation;
    this.company = technicalVisit?.company;
    // this.picturesInfo = [];
    this.visitReason = installationStart?.visitReason;
    this.visitType = installationStart?.visitType;
    this.cloudId = installationStart.id;
    this.appId = DateTime.now().millisecondsSinceEpoch;
    this.startDate = DateTime.now();
    this.trackers = installationStart?.devices;
    // print(installationStart.devices.asMap()[0].serial);
    this.stage = InstallationStage(
      stage: TechnicalVisitStage.IN_PROGRESS,
    );
  }

  Installation.forValues(
      {this.company,
      this.progress,
      this.agreementId,
      this.appId,
      this.cloudId,
      this.stage,
      this.installationType,
      this.customerEmail,
      this.customerId,
      this.trackers,
      this.startLocation,
      this.finishDate,
      this.finishLocation,
      this.startDate,
      this.comments,
      this.visitType});

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};

    json["id"] = cloudId;
    json["latitude"] = finishLocation?.latitude;
    json["longitude"] = finishLocation?.longitude;
    json['finishDate'] = finishDate?.millisecondsSinceEpoch;
    json["infoData"] = installationType.installationTypes.toJson();

    return json;
  }
}

class Checklist {
  List<CheckListItems> items;
  Uri signatureUri;
  int cloudFileId;
  String observation;

  Checklist({
    this.observation,
    this.items,
    this.signatureUri,
  });

  Checklist.fromJson(dynamic json) {
    observation = json["observation"];

    if (json["items"] != null) {
      items = [];
      json["items"].forEach((v) {
        items.add(CheckListItems.fromJson(v));
      });
    }
    if (json["signatureUri"] != null) {
      signatureUri = Uri.parse(json["signatureUri"]);
    }
  }

  Map<String, dynamic> toJson([forUpload = false]) {
    var map = <String, dynamic>{};
    map["observation"] = observation;
    if (items != null) {
      map["items"] = items.map((v) => v.toJson()).toList();
    }
    if (!forUpload) {
      map['signatureUri'] = signatureUri;
    }
    map["fileId"] = cloudFileId;
    return map;
  }
}

class VehicleInfo {
  int vehicleId;
  String modelName;
  String plate;
  String year;
  String stateName;
  String color;
  String chassis;
  String modelYear;
  String cityName;
  String brand;
  String odometer;
  String fleetId;
  int cityId;
  int ufId;
  int brandId;
  int modelId;

  VehicleInfo({
    this.modelName,
    this.plate,
    this.year,
    this.stateName,
    this.color,
    this.chassis,
    this.modelYear,
    this.cityName,
    this.brand,
    this.odometer,
    this.fleetId,
    this.cityId,
    this.ufId,
    this.brandId,
    this.modelId,
    this.vehicleId
  });

  VehicleInfo.fromLocalInfo(LocalInfo localinfo) {
    modelName = localinfo.modelName;
    plate = localinfo.identifier;
    year = localinfo.year != null ? localinfo.year.toString() : null;
    stateName = localinfo.stateName;
    color = localinfo.color;
    chassis = localinfo.chassis;
    fleetId = localinfo.fleetId;
    modelYear = localinfo.modelYear != null ? localinfo.modelYear.toString() : null;
    cityName = localinfo.cityName;
    brand = localinfo.brandName;
    odometer = localinfo.odometer != null ? localinfo.odometer.toString() : null;
    ufId = localinfo.ufId;
    cityId = localinfo.cityId;
    brandId = localinfo.brandId;
    modelId = localinfo.modelId;
  }

  VehicleInfo.fromJson(dynamic json) {
    modelName = json["model"];
    plate = json["plate"];
    year = json["year"];
    stateName = json["state"];
    color = json["color"];
    chassis = json["chassis"];
    modelYear = json["modelYear"];
    fleetId = json["fleetId"];
    cityName = json["city"];
    brand = json["brand"];
    odometer = json["odometer"];
    ufId = json["ufId"];
    cityId = json["cityId"];
    brandId = json["brandId"];
    modelId = json["modelId"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["model"] = modelName;
    map["plate"] = plate;
    map["year"] = year;
    map["state"] = stateName;
    map["color"] = color;
    map["chassis"] = chassis;
    map["fleetId"] = fleetId;
    map["modelYear"] = modelYear;
    map["city"] = cityName;
    map["brand"] = brand;
    map["odometer"] = odometer;
    map["ufId"] = ufId;
    map["cityId"] = cityId;
    map["brandId"] = brandId;
    map["modelId"] = modelId;
    return map;
  }

  @override
  String toString() {
    return "Vehicle Info: brand: $brand, model: $modelName, plate: $plate, year: $year, state: $stateName, color: $color, chassis: $chassis, modelyear: $modelYear, city: $cityName, odometer: $odometer, fleetId: $fleetId, cityId: $cityId, modelId: $modelId";
  }
}

class LatLong {
  double latitude;
  double longitude;

  LatLong({
    this.latitude,
    this.longitude,
  });

  LatLong.fromJson(Map<String, dynamic> json) {
    latitude = json["latitude"];
    longitude = json["longitude"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["latitude"] = latitude;
    map["longitude"] = longitude;
    return map;
  }

  @override
  String toString() => 'LatLong(lat: $latitude, long: $longitude)';
}

class Tracker {
  String serial;
  int deviceId;
  int brandId;
  int modelId;
  int installationLocal;
  bool required;
  bool allowVirtual;
  Peripheral peripheral;
  HardwareFeature hardwareFeature;
  Tracker parent;
  int groupParentId;

  bool main = false;
  String configName;
  int groupId;
  String groupName;
  String brandName;
  String modelName;
  String modelType;
  String modelTechName;
  int equipmentItemId;
  bool virtual = false;
  bool associate = false;
  bool forRemoval = false;

  Tracker.criar(Groups group) {
    this.groupId = group.id;
    this.groupName = group.name;
    this.main = group.main;
    this.allowVirtual = group.allowVirtual;
    this.required = group.required;
    this.associate = false;

    // this.items = group?.items?.map((item) => Tracker.criarItem(item))?.toList();
  }

  static List<Tracker> getTrackerListByGroup(List<Groups> groups, List<Tracker> trackersInstalled) {
    List<Tracker> trackersFromInstalled = [];

    for (var group in groups) {
      trackersFromInstalled.add(Tracker.criar(group));
      for (var item in group.items) {
        trackersFromInstalled.add(Tracker.criarItem(group, item, trackersInstalled));
      }
    }

    for (var trackerInstalled in trackersInstalled) {
      for (var trackerFromInstalled in trackersFromInstalled) {
        if ((trackerFromInstalled.groupId == trackerInstalled.groupId &&
                trackerInstalled.hardwareFeature != null &&
                trackerFromInstalled.hardwareFeature != null &&
                trackerInstalled.hardwareFeature.id ==
                    trackerFromInstalled.hardwareFeature.id) ||
            (trackerFromInstalled.groupId == trackerInstalled.groupId &&
                trackerInstalled.hardwareFeature == null)) {
          trackerFromInstalled.deviceId = trackerInstalled.deviceId;
          trackerFromInstalled.main = trackerInstalled.main;
          // trackerFromInstalled.required = trackerInstalled.required;
          // trackerFromInstalled.allowVirtual = trackerInstalled.allowVirtual;
          trackerFromInstalled.configName = trackerInstalled.configName;
          trackerFromInstalled.installationLocal =
              trackerInstalled.installationLocal;
          trackerFromInstalled.brandId = trackerInstalled.brandId;
          trackerFromInstalled.brandName = trackerInstalled.brandName;
          trackerFromInstalled.modelId = trackerInstalled.modelId;
          trackerFromInstalled.modelName = trackerInstalled.modelName;
          trackerFromInstalled.modelType = trackerInstalled.modelType;
          trackerFromInstalled.equipmentItemId =
              trackerInstalled.equipmentItemId;
          trackerFromInstalled.serial = trackerInstalled.serial;
          trackerFromInstalled.hardwareFeature =
              trackerInstalled.hardwareFeature;
          trackerFromInstalled.peripheral = trackerInstalled.peripheral;
          trackerFromInstalled.associate = true;
          trackerFromInstalled.virtual = trackerInstalled.virtual;
        }
      }
    }

    return trackersFromInstalled;
  }

  Tracker.criarItem(
      Groups group, GroupsItem groupsItem, List<Tracker> trackersInstalled) {
    this.groupId = groupsItem?.group?.id;
    this.groupName = groupsItem?.group?.name;
    this.required = groupsItem.required;
    this.allowVirtual = groupsItem.allowVirtual;
    this.hardwareFeature = HardwareFeature(
        id: groupsItem.hardwareFeature.id,
        description: groupsItem.hardwareFeature.description);
    this.peripheral = Peripheral(
        id: groupsItem.peripheral.id,
        name: groupsItem.peripheral.name,
        type: groupsItem.peripheral.type);

    Tracker trackerParent;

    for (var trackerInstalled in trackersInstalled) {
      if (trackerInstalled.groupId == group.id) {
        trackerParent = trackerInstalled;
        trackerParent.associate = true;
        break;
      }
    }

    this.parent = trackerParent != null
        ? trackerParent
        : Tracker(groupId: group.id, groupName: group.name, main: group.main);
  }

  Tracker(
      {this.deviceId,
      this.main,
      this.configName,
      this.installationLocal,
      this.groupId,
      this.groupName,
      this.brandId,
      this.brandName,
      this.modelId,
      this.modelName,
      this.modelType,
      this.modelTechName,
      this.equipmentItemId,
      this.serial,
      this.required,
      this.peripheral,
      this.hardwareFeature,
      this.groupParentId});

  Tracker.fromJson(Map<String, dynamic> json) {
    main = json['main'];
    deviceId = json['deviceId'];

    parent = json['deviceParentId'] != null
        ? Tracker(deviceId: json['deviceParentId'])
        : null;

    configName = json['configName'];
    installationLocal = json['installationLocal'];
    groupId = json['groupId'];
    groupName = json['groupName'];
    brandId = json['brandId'];
    brandName = json['brandName'];
    modelId = json['modelId'];
    modelName = json['modelName'];
    modelType = json['modelType'];
    modelTechName = json['modelTechName'];
    equipmentItemId = json['equipmentItemId'];
    serial = json['serial'];
    required = json['required'];
    hardwareFeature = json['hardwareFeatureId'] != null
        ? HardwareFeature(
            id: json['hardwareFeatureId'],
            description: json['hardwareFeatureName'])
        : null;
    peripheral = json['peripheralId'] != null
        ? Peripheral(id: json['peripheralId'], name: json['peripheralName'])
        : null;
    virtual = json['virtual'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['deviceId'] = this.deviceId;
    data['deviceParentId'] = this.parent != null ? this.parent.deviceId : null;
    data['main'] = this.main;
    data['configName'] = this.configName;
    data['installationLocal'] = this.installationLocal;
    data['groupId'] = this.groupId;
    data['groupName'] = this.groupName;
    data['brandId'] = this.brandId;
    data['brandName'] = this.brandName;
    data['modelId'] = this.modelId;
    data['modelName'] = this.modelName;
    data['modelType'] = this.modelType;
    data['modelTechName'] = this.modelTechName;
    data['equipmentItemId'] = this.equipmentItemId;
    data['serial'] = this.serial;
    data['required'] = this.required;
    return data;
  }

  Map<String, dynamic> toJsonOld() {
    var map = <String, dynamic>{};
    map["identifier"] = serial;
    map["modelId"] = modelId;
    map["brandId"] = brandId;
    map["installationLocal"] = installationLocal;
    return map;
  }
}

class PictureInfo {
  String imageId;
  Uri fileLocation;
  String observation;
  bool isCustom;
  bool sent;
  bool onlyCameraSource;
  bool isCoverPicture;

  PictureInfo({
    this.isCoverPicture,
    this.imageId,
    this.fileLocation,
    this.observation = '',
    this.isCustom = false,
    this.sent,
    this.onlyCameraSource,
  });

  PictureInfo.fromJson(dynamic json) {
    isCoverPicture = json['isCoverPicture'];
    imageId = json["imageId"];
    isCustom = json["isCustom"] ?? false;
    observation = json["observation"];
    onlyCameraSource = json['onlyCameraSource'];
    fileLocation = Uri.tryParse(json["fileLocation"]);
  }

  Map<String, dynamic> toJson([bool forUpload = false]) {
    var map = <String, dynamic>{};
    map['isCoverPicture'] = isCoverPicture;
    map["imageId"] = imageId;
    map["observation"] = observation;
    map['onlyCameraSource'] = onlyCameraSource;
    if (!forUpload) {
      map["fileLocation"] = fileLocation.toString();
      map["isCustom"] = isCustom;
    }
    return map;
  }
}

class InstallationStage {
  TechnicalVisitStage stage;
  String message;

  InstallationStage({this.stage, this.message});

  InstallationStage.fromJson(dynamic json) {
    stage = TechnicalVisitStage.stageFor(json["stage"]);
    message = json['message'];
  }

  Map<String, dynamic> toJson() => {
        "stage": stage.id,
        'message': message,
      };
}

class DeviceLog {
  List<Devices> devices;

  DeviceLog({this.devices});

  DeviceLog.fromJson(Map<String, dynamic> json) {
    if (json['devices'] != null) {
      devices = [];
      json['devices'].forEach((v) {
        devices.add(new Devices.fromJson(v));
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

class Devices {
  int deviceId;
  String serial;
  String modelName;
  String state;
  String oldSerial;

  Devices(
      {this.deviceId, this.serial, this.modelName, this.state, this.oldSerial});

  Devices.fromJson(Map<String, dynamic> json) {
    deviceId = json['deviceId'];
    serial = json['serial'];
    modelName = json['modelName'];
    state = json['state'];
    oldSerial = json['oldSerial'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['deviceId'] = this.deviceId;
    data['serial'] = this.serial;
    data['modelName'] = this.modelName;
    data['state'] = this.state;
    data['oldSerial'] = this.oldSerial;
    return data;
  }

  @override
  String toString() {
    return "DeviceId: $deviceId\n {Serial: $serial, ModelName: $modelName, State: $state, oldSerial: $oldSerial}\n";
  }
}

class InstallationLocal {
  int id;
  String name;

  InstallationLocal({this.id, this.name});

  InstallationLocal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }

  @override
  String toString() {
    return "InstallationLocal: $id\n {Name: $name}\n";
  }
}

class DeviceChanges {
  List<Devices> deviceList;
  List<Tracker> devices;

  DeviceChanges({
    this.deviceList,
    this.devices,
  });
}

import 'package:flow_flutter/models/customer.dart';
import 'package:flow_flutter/models/technical_visit_state_enum.dart';

import 'company.dart';
import 'company_config.dart';

class TechnicalVisitList {
  int requestDate;
  int filterStartDate;
  int filterEndDate;
  List<TechnicalVisit> technicalVisits;

  TechnicalVisitList(
      {this.requestDate,
      this.filterStartDate,
      this.filterEndDate,
      this.technicalVisits});

  TechnicalVisitList.fromJson(Map<String, dynamic> json) {
    requestDate = json['requestDate'];
    filterStartDate = json['filterStartDate'];
    filterEndDate = json['filterEndDate'];
    if (json['technicalVisits'] != null) {
      technicalVisits = [];
      json['technicalVisits'].forEach((v) {
        technicalVisits.add(new TechnicalVisit.fromJson(v));
      });
    }
  }
}

class TechnicalVisit {
  int id;
  Companies company;
  String visitType;
  TechnicalVisitStateEnum visitState;
  DateTime forecastStartDate;
  DateTime forecastFinishDate;
  String visitReason;
  int agreementId;
  int techPersonId;
  String techPersonName;
  String finalChecklistPhotoURL;

  LocalInfo localInfo;
  MainDevice mainDevice;
  DateTime visitStartDate;
  DateTime visitFinishDate;
  DateTime cancelDate;
  InstallationTypes installationTypes;
  Customer customer;

  TechnicalVisit({
    this.id,
    this.visitType,
    this.company,
    this.visitState,
    this.installationTypes,
    this.forecastStartDate,
    this.forecastFinishDate,
    this.visitReason,
    this.techPersonId,
    this.techPersonName,
    this.agreementId,
    this.localInfo,
    this.mainDevice,
  });

  TechnicalVisit.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    visitType = json['visitType'];
    visitState = TechnicalVisitStateEnumHelper.getByValue(json['visitState']);
    company =
        json["company"] != null ? Companies.fromJson(json["company"]) : null;

    installationTypes = json["installationType"] != null
        ? InstallationTypes.fromJson(json["installationType"])
        : null;

    forecastStartDate = DateTime.fromMillisecondsSinceEpoch(json['forecastStartDate']);
    forecastFinishDate = DateTime.fromMillisecondsSinceEpoch(json['forecastFinishDate']);
    visitReason = json['visitReason'];
    techPersonId = json['techPersonId'];
    techPersonName = json['techPersonName'];
    agreementId = json['agreementId'];
    localInfo = json['localInfo'] != null
        ? new LocalInfo.fromJson(json['localInfo'])
        : null;
    mainDevice = json['mainDevice'] != null
        ? new MainDevice.fromJson(json['mainDevice'])
        : null;
    visitStartDate = json['visitStartDate'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['visitStartDate'])
        : null;
    visitFinishDate = json['visitFinishDate'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['visitFinishDate'])
        : null;
    cancelDate = json['cancelDate'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['cancelDate'])
        : null;
    customer = json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null;
  }
}

class LocalInfo {
  String identifier;
  String brandName;
  String modelName;
  int year;
  String stateName;
  String color;
  String chassis;
  int modelYear;
  String cityName;
  int odometer;
  String description;
  String fleetId;
  int cityId;
  int ufId;
  int modelId;
  int brandId;

  LocalInfo(
      {this.identifier,
      this.modelName,
      this.year,
      this.stateName,
      this.color,
      this.chassis,
      this.modelYear,
      this.cityName,
      this.brandName,
      this.odometer,
      this.description,
      this.fleetId,
      this.cityId,
      this.ufId,
      this.modelId,
      this.brandId});

  LocalInfo.fromJson(dynamic json) {
    identifier = json["identifier"];
    brandName = json["brand"];
    modelName = json["model"];
    year = json["year"];
    modelYear = json["modelYear"];
    color = json["color"];
    chassis = json["chassis"];
    odometer = json["odometer"];
    stateName = json["state"];
    cityName = json["city"];
    description = json["description"];
    fleetId = json["fleetId"];
    cityId = json["cityId"];
    ufId = json["ufId"];
    brandId = json["brandId"];
    modelId = json["modelId"];
  }
}

class MainDevice {
  String serial;
  String model;
  String modelTechName;
  String brandName;
  String modelName;

  MainDevice({
    this.serial,
    this.model,
    this.modelTechName,
    this.brandName,
    this.modelName,
  });

  MainDevice.fromJson(Map<String, dynamic> json) {
    serial = json['serial'];
    model = json['model'];
    modelTechName = json['modelTechName'];
    brandName = json['brandName'];
    modelName = json['modelName'];
  }
}

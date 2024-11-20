import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/models/technical_visit_list.dart';

class TechnicalVisitEdit {
  int id;
  String visitType;
  int visitState;
  // InstallationType installationType;
  DateTime forecastStartDate;
  DateTime forecastFinishDate;
  String visitReason;
  int agreementId;
  LocalInfo localInfo;
  List<Tracker> devices;
  String error;

  TechnicalVisitEdit(
      {this.id,
      this.visitType,
      this.visitState,
      // this.installationType,
      this.forecastStartDate,
      this.forecastFinishDate,
      this.visitReason,
      this.agreementId,
      this.localInfo,
      this.devices,
      this.error});

  TechnicalVisitEdit.fromJson(Map<String, dynamic> json) {
    error = null;
    id = json['id'];
    visitType = json['visitType'];
    visitState = json['visitState'];
    // installationType =
    //     InstallationType.installationFor(json["installationType"]);
    forecastStartDate =
        DateTime.fromMillisecondsSinceEpoch(json['forecastStartDate']);
    forecastFinishDate =
        DateTime.fromMillisecondsSinceEpoch(json['forecastFinishDate']);
    visitReason = json['visitReason'];
    agreementId = json['agreementId'];
    localInfo = json['localInfo'] != null
        ? new LocalInfo.fromJson(json['localInfo'])
        : null;
    if (json['devices'] != null) {
      devices = [];
      json['devices'].forEach((v) {
        devices.add(new Tracker.fromJson(v));
      });
    }
  }
}

import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/installation_step.dart';
import 'package:flutter/material.dart';

class DevicesControllerV3 with InstallationPart<DeviceConfigV3> {

  RequestsRepository requestsRepository;
  bool isEditable;
  String name;
  String visitType;
  int technicalVisitId;

  DevicesControllerV3({
    @required this.technicalVisitId,
    this.requestsRepository,
    this.isEditable,
    this.name,
    this.visitType
  });

  void dispose() {}
  
  @override
  DeviceConfigV3 build() {
    throw UnimplementedError();
  }

  void updateReady(List<Slot> slots) async {

    bool success = true;

    slots.forEach((slot) {
      if(!slot.operationCompleted) {
        readyStream.add(
          ReadyState.notReady('Por favor associe o equipamento ${slot.group.name}')
        );

        success = false;
      }
     });

    if(success) {
      readyStream.add(ReadyState.ready());
    }

  }

  // DeviceChanges build() {
  //   return DeviceChanges();
  // }

  // Stream<ReadyStatus> get readyStream => Stream.value(ReadyStatus.ready);

}
import 'package:flow_flutter/models/technical_visit_state_enum.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flutter/cupertino.dart';

import '../../models/reasonFinish.dart';

ReasonFinishList globalReasonFinishList;

class TechVisitListController {
  InstallationRepository installationRepository;
  RequestsRepository requestsRepository;

  TechVisitListController(
      {@required this.installationRepository,
        @required this.requestsRepository});

  Future<void> syncInstallations() async {
    var installations = await installationRepository.getInstallations();

    globalReasonFinishList = await requestsRepository.getReasonFinishList();

    for (var installation in installations) {
      var technicalVisit =
      await requestsRepository.getTechnicalVisitById(installation.cloudId);

      if (technicalVisit == null) {
        await installationRepository.deleteInstallations([installation]);
      }

      if (technicalVisit.visitState == TechnicalVisitStateEnum.CANCELED.id
          || technicalVisit.visitState == TechnicalVisitStateEnum.CLOSE_AUTOMATIC.id
          || technicalVisit.visitState == TechnicalVisitStateEnum.UNPRODUCTIVE.id
          || technicalVisit.visitState == TechnicalVisitStateEnum.CANCELED_DISPLACEMENT.id) {
        await installationRepository.deleteInstallations([installation]);
      }
    }
  }
}

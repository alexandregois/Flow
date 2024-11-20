import 'dart:convert';

import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/utils/installation_step.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/reasonFinish.dart';

class FinishController with InstallationPart<FinishConfig> {
  final FinishConfig finishConfig;
  String id;
  int cloudFileId;
  String observation;
  bool containsViolation = false;
  bool containsPendencyItem = false;
  String observationViolation;
  String observationPendencyItem;
  Uri _signatureUri;
  bool requireSign;
  ReasonFinish reasonFinish;
  String generalComments = '';
  Function(int) changeTabs;
  bool visitCompletelyFinished = false;

  FinishController({
    this.changeTabs,
    this.id,
    this.finishConfig,
    String name,
  }) {
    this.name = name;
    _signatureUri = finishConfig?.signatureUri;
    this.observation = finishConfig?.observation;
    updateReady();
  }

  String validateComments(String comments) {
    // if (comments == null || comments.isEmpty) {
    //   return 'Por favor insira um comentário';
    // }
    // return null;
  }

  String validateDropdownSelection(String value) {
    // if (value == null) {
    //   return 'Por favor selecione uma opção';
    // }
    // return null;
  }

  void updateSignatureUri(Uri signatureUri) {
    _signatureUri = signatureUri;
    finishConfig.signatureUri = signatureUri;
    // sendSignature();
    updateReady();
  }


  void updateComments(String observation) {
    this.observation = observation;
    updateReady();
  }

  void updateContainsViolation(bool containsViolation) {
    this.containsViolation = containsViolation;
    updateReady();
  }

  void updatePendencyItem(bool containsPendenceItem) {
    this.containsPendencyItem = containsPendenceItem;
    updateReady();
  }

  void updateCommentsViolation(String observationViolation) {
    this.observationViolation = observationViolation;
    updateReady();
  }

  void updateCommentsPendencyItem(String observationPendencyItem) {
    this.observationPendencyItem = observationPendencyItem;
    updateReady();
  }

  void updateReasonsFinish(ReasonFinish reasons) {
    this.reasonFinish = reasons;
    finishConfig.reasonFinish = reasons;
    this.visitCompletelyFinished = true;
    updateReady();
  }

  void updatevisitCompletelyFinished(bool visitaCompletamenteFinalizada) {
    this.visitCompletelyFinished = visitaCompletamenteFinalizada;
    finishConfig.visitCompletelyFinished = visitaCompletamenteFinalizada;
    updateReady();
  }

  void updateGeneralComments(String comments) {
    this.generalComments = comments;
    updateReady();
  }

  Uri get signatureUri => _signatureUri;

  @override
  FinishConfig build() {
    return FinishConfig(
        cloudFileId: this.finishConfig.cloudFileId,
        requireSign: this.finishConfig.requireSign,
        signatureUri: this._signatureUri,
        observation: this.observation,
        showEmailField: this.finishConfig.showEmailField,
        containsViolation: this.containsViolation,
        observationViolation: this.observationViolation,
        containsPendencyItem: this.containsPendencyItem,
        observationPendencyItem: this.observationPendencyItem,
        visitCompletelyFinished: this.visitCompletelyFinished,
        reasonFinish: this.reasonFinish);
  }

  void updateReady() {
    print("Update Ready Finish " +
        _signatureUri.toString() +
        " " +
        this.finishConfig.requireSign.toString());

    // if (_signatureUri == null && this.finishConfig.requireSign) {
    //   readyStream.add(ReadyState.notReady('Faltando a assinatura do cliente'));
    //   return;
    // }

    // if (containsViolation &&
    //     (observationViolation == null || observationViolation.isEmpty)) {
    //   readyStream.add(ReadyState.notReady(
    //       'Por favor preencha os detalhes de violação ou mau uso'));
    //   return;
    // }

    // if (containsPendencyItem && (observationPendencyItem == null || observationPendencyItem.isEmpty)) {
    //   readyStream.add(ReadyState.notReady(
    //       'Por favor preencha os detalhes dos itens que ficaram pendentes'));
    //   return;
    // }

    readyStream.add(ReadyState.ready());
  }
}

import 'package:dartx/dartx.dart';
import 'package:flow_flutter/controller/basic_controller.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/utils/installation_step.dart';

class ChecklistControllerV2 extends Stream<List<CheckListItems>>
    with InstallationPart<Checklist>, BasicController<List<CheckListItems>> {
  String id; // novo
  ChecklistConfig checklistConfig;
  String _observation;
  Uri _signatureUri;
  final List<CheckListItems> checkListItems;
  final bool isEditable;

  ChecklistControllerV2(this.checkListItems, this.isEditable,
      {this.checklistConfig,
      Checklist currentChecklist,
      this.id,
      String name}) {
    this.name = name;
    _signatureUri = currentChecklist?.signatureUri;
    _observation = currentChecklist?.observation;

    final controllerItems = checkListItems
        .map((e) => CheckListItems(
            key: e.key,
            name: e.name,
            required: e.required,
            order: e.order,
            checked: e.checked))
        .toList();

    currentChecklist?.items?.forEach((installationItem) {
      controllerItems
          .firstOrNullWhere((it) => it.key == installationItem.key)
          ?.checked = installationItem.checked;
    });

    add(controllerItems);
    updateReady();
  }

  void updateReady() {
    if (_signatureUri == null &&
        get().isNotEmpty &&
        this.checklistConfig.requireSign) {
      readyStream.add(ReadyState.notReady('Falta a assinatura do cliente'));
      return;
    } else if (get().any((item) => (item.required && item.checked == null))) {
      readyStream.add(
          ReadyState.notReady('Existem itens obrigatórios não informados'));
    } else
      readyStream.add(ReadyState.ready());
  }

  void updateItem(String key, int index) {
    if (isEditable) {
      // print("key: " + key.toString());
      //Se clicar 2x na mesma posicao volta pra null
      bool old = get()?.firstWhere((element) => element.key == key)?.checked;
      if ((old == false && index == 0) || (old == true && index == 1)) {
        get()?.firstWhere((element) => element.key == key)?.checked = null;
      } else {
        get()?.firstWhere((element) => element.key == key)?.checked =
            index == 1;
      }
    }
    add(get());
    updateReady();
  }

  void updateSignatureUri(Uri signatureUri) {
    _signatureUri = signatureUri;
    updateReady();
  }

  Uri get signatureUri => _signatureUri;

  void updateCommentary(String commentary) {
    if (isEditable) {
      _observation = commentary;
    }
    updateReady();
  }

  String get commentary => _observation;

  Checklist build() => Checklist(
        items: get()?.where((element) => element?.checked != null)?.toList(),
        observation: _observation,
        signatureUri: _signatureUri,
      );
}

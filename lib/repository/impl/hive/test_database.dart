import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/hive/hive_models.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:hive/hive.dart';

import '../../../utils/utils.dart';

class HiveTestDatabase extends TestRepository {
  static const _boxName = 'test';

  @override
  Future<DateTime> getLastDateRequest() async {
    var box = await Hive.openBox<int>('requestDates');
    if (box.containsKey('test')) {
      return DateTime.fromMillisecondsSinceEpoch(box.get(_boxName));
    } else {
      return null;
    }
  }

  @override
  Future setLastDateRequest(DateTime dateRequest) async {
    Hive.openBox<int>('requestDates')
        .then((box) => box.put('test', dateRequest?.millisecondsSinceEpoch));
  }

  @override
  Future<String> getLastVersionRequest() async =>
      (await Hive.openBox<String>('requestAppVersion')).get(_boxName);

  @override
  Future setLastVersionRequest(String appVersion) =>
      Hive.openBox<String>('requestAppVersion')
          .then((box) => box.put('test', appVersion));

  @override
  // Future<TestConfig> getTest() => Hive.openBox<HiveTestConfig>(_boxName)
  //     .then((box) => box.get('test').fromHive);
  Future<TestConfig> getTest() async {
    try {
      var box = await Hive.openBox<HiveTestConfig>(_boxName);
      var hiveTestConfig = box.get('test');

      if (hiveTestConfig == null) {
        throw Exception('Configuração do teste não encontrada.');
        sendErrorEmail('Configuração do teste não encontrada.');
      }

      return hiveTestConfig.fromHive;
    } catch (e) {
      // Tratar a exceção e retornar um valor padrão ou logar o erro
      print('Erro ao recuperar o teste: $e');
      sendErrorEmail('Erro ao recuperar o teste: $e');
      return TestConfig()..name = 'Configuração Padrão'..tests = [];
    }
  }

}

extension on HiveTestConfig {
  TestConfig get fromHive => TestConfig()
    ..name = this.name
    ..tests = this.items.fromHive;
}

extension on TestConfig {
  // ignore: unused_element
  HiveTestConfig get toHive => HiveTestConfig()
    ..name = this.name?.toString()
    ..items = this.tests.toHive;
}

extension on List<HiveTestInfo> {
  List<TestInfo> get fromHive => this
      .map((e) => TestInfo()
        ..technicalVisitId = e.technicalVisitId
        ..key = e.key
        ..description = e.description
        ..icon = e.icon
        ..iconColor = e.iconColor
        ..name = e.name
        ..require = e.require
        ..status = (e.status == null || e.status == TestStatus.Running)
            ? TestStatus.Pending
            : e.status
        ..statusDate = e.statusDate
        ..statusResult = e.statusResult
        ..jsonResult = e.jsonResult
        ..serial = e.serial
        ..analyzeItens = e.analyzeItens.fromHive
        ..configItens = e.configItens.fromHive)
      .toList();
}

extension on List<TestInfo> {
  List<HiveTestInfo> get toHive => this
      .map((e) => HiveTestInfo()
        ..name = e.name
        ..technicalVisitId = e.technicalVisitId
        ..key = e.key
        ..icon = e.icon
        ..iconColor = e.iconColor
        ..require = e.require
        ..description = e.description
        ..status = (e.status == null || e.status == TestStatus.Running)
            ? TestStatus.Pending
            : e.status
        ..statusDate = e.statusDate
        ..statusResult = e.statusResult
        ..jsonResult = e.jsonResult
        ..serial = e.serial
        ..analyzeItens = e.analyzeItens.toHive
        ..configItens = e.configItens.toHive)
      .toList();
}

extension on List<HiveTestItems> {
  List<TestItems> get fromHive => this
      .map((e) => TestItems()
        ..key = e.key
        ..name = e.name
        ..override = e.override
        ..value = e.value)
      .toList();
}

extension on List<TestItems> {
  List<HiveTestItems> get toHive => this
      .map((e) => HiveTestItems()
        ..name = e.name
        ..key = e.key
        ..override = e.override
        ..value = e.value)
      .toList();
}

extension on List<HiveAnalyzeItems> {
  List<AnalyzeItems> get fromHive => this
      .map((e) => AnalyzeItems()
        ..name = e.name
        ..path = e.path
        ..value = e.value
        ..translate = e.translate
        ..icon = e.icon
        ..iconColor = e.iconColor)
      .toList();
}

extension on List<AnalyzeItems> {
  List<HiveAnalyzeItems> get toHive => this
      .map((e) => HiveAnalyzeItems()
        ..name = e.name
        ..path = e.path
        ..value = e.value
        ..translate = e.translate
        ..icon = e.icon
        ..iconColor = e.iconColor)
      .toList();
}

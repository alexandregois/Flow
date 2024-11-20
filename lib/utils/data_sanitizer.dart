import '../models/company_config.dart';

import '../models/company_config.dart';

List<TestInfo> sanitizeTestInfo(List<TestInfo> testItems) {
  return testItems.map((item) {
    return TestInfo(
      technicalVisitId: item.technicalVisitId ?? 0,
      key: item.key ?? '',
      name: item.name ?? '',
      icon: item.icon ?? '',
      iconColor: item.iconColor ?? '',
      description: item.description ?? '',
      require: item.require ?? false,
      status: item.status ?? 0,
      statusDate: item.statusDate ?? DateTime.now(),
      statusResult: item.statusResult ?? '',
      jsonResult: item.jsonResult ?? '',
      serial: item.serial ?? '',
      analyzeItens: item.analyzeItens ?? [],
      configItens: item.configItens ?? [],
      step: item.step ?? 0,
      stepDescription: item.stepDescription ?? '',
    );
  }).toList();
}


List<Map<String, dynamic>> sanitizeData(List<Map<String, dynamic>> data) {
  return data.map((item) {
    return {
      'someKey': item['someKey'] ?? ' ',
      'anotherKey': item['anotherKey'] ?? 0,
      'listKey': item['listKey'] ?? [],
    };
  }).toList();
}

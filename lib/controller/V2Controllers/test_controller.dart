// import 'package:flow_flutter/models/company_config.dart';
// import 'package:flow_flutter/repository/repositories.dart';
// import 'package:flow_flutter/utils/installation_step.dart';
//
// class TestController with InstallationPart<TestConfig> {
//   int installationCloudId;
//   String id; // novo
//   String name;
//   List<TestInfo> testItems;
//   RequestsRepository requestsRepository;
//   bool waitingTest = false;
//   bool containsCamera = true;
//   String auxJustify = "";
//
//   TestController(
//       {int installationCloudId,
//       String name,
//       this.testItems,
//       this.requestsRepository}) {
//     this.installationCloudId = installationCloudId;
//     this.name = name;
//     this.testItems = testItems;
//     this.requestsRepository = requestsRepository;
//
//     updateReady();
//   }
//
//   void updateReady() {
//
//     bool ready = true;
//     String message = "";
//
//     for (var i = 0; i < this.testItems.length; i++) {
//       var test = this.testItems[i];
//
//       if(test.status == null || test.status <= TestStatus.Pending || test.status == TestStatus.Partial) {
//
//         if(!ready)
//           message += '\n';
//
//         message += '${test.description} não realizado ou ignorado';
//
//         ready = false;
//       }
//
//     }
//
//     //Sem Origatoriedade do Auto Teste
//     //readyStream.add(ReadyState.ready(message));
//
//     //Origatoriedade do Auto Teste
//     if(ready) {
//       readyStream.add(ReadyState.ready());
//     }
//     else {
//       readyStream.add(ReadyState.notReady(message));
//     }
//
//   }
//
//   void updateStartingTest(int index) {
//     this.testItems[index].status = TestStatus.Running;
//   }
//
//   Future<void> updateSucessTestAndEvidence(
//       int index, String newUrl, int technicalVisitId) async {
//     this.testItems[index].status = TestStatus.Success;
//     this.testItems[index].statusResult = newUrl;
//     this.testItems[index].technicalVisitId = technicalVisitId;
//
//     this.updateEquipmentTest(this.testItems[index]);
//   }
//
//   void updateJustification(String justification) {
//     //this.testItems[index].statusResult = "Ignorado: " + justification;
//     if (justification.isEmpty) {
//       this.auxJustify = "";
//     } else {
//       this.auxJustify = "Ignorado: " + justification;
//     }
//   }
//
//   void updateAcceptedJustification(index) {
//     this.testItems[index].statusResult = this.auxJustify;
//   }
//
//   bool enabledIgnoreButton(index) {
//     return testItems[index].require == false ||
//         (testItems[index].require && auxJustify.length > 20);
//   }
//
//   void clearDataTest(index) {
//     this.testItems[index].status = 0;
//     this.testItems[index].statusResult = null;
//     this.testItems[index].analyzeItens = null;
//     this.testItems[index].jsonResult = null;
//   }
//
//   void clearAllDataTests() {
//     this.testItems.map((e) => {
//           e.status = 0,
//           e.statusResult = null,
//           e.analyzeItens = null,
//           e.jsonResult = null
//         });
//   }
//
//   void updateItem(TestInfo testUpdated, index) {
//     this.testItems[index] = testUpdated;
//     updateReady();
//   }
//
//   void updateStatusCamTestItem(index, String url) {
//     this.testItems[index].status =
//         (url != null && url.isNotEmpty) ? TestStatus.Partial : TestStatus.Error;
//     this.testItems[index].statusResult = url;
//     this.testItems[index].statusDate = new DateTime.now();
//     this.testItems[index].technicalVisitId = installationCloudId;
//     //requestsRepository.updateEquipmentTest(this.testItems[index]);
//     updateReady();
//   }
//
//   TestConfig build() {
//     return TestConfig(
//       name: name,
//       tests: testItems,
//     );
//   }
//
//   Future<TestInfo> startEquipmentTest(TestInfo testInfo) async {
//     try {
//       testInfo.technicalVisitId = installationCloudId;
//       return await requestsRepository.startEquipmentTest(testInfo);
//     } catch (e) {
//       print('Start equipment test error: $e');
//       return null;
//     }
//   }
//
//   Future<String> getWowzaStreamUrl(int localId, int cameraId) async {
//     var wowzaStreamUrl = await requestsRepository.getWowzaStreamUrl(
//       localId,
//       cameraId,
//       false,
//     );
//
//     return wowzaStreamUrl;
//   }
//
//   Future<TestInfo> updateEquipmentTest(TestInfo testInfo) async {
//     try {
//       return await requestsRepository.updateEquipmentTest(testInfo);
//     } catch (e) {
//       print('Update equipment test error: $e');
//       return null;
//     }
//   }
//
//   Future<String> saveVCEvidenceImage(TestInfo testInfo) async {
//     try {
//       if (testInfo.statusResult != null && testInfo.statusResult.isNotEmpty) {
//         return await requestsRepository.saveEvidenceCamTest(
//             testInfo.statusResult, testInfo.technicalVisitId, testInfo.key);
//       } else {
//         return null;
//       }
//     } catch (e) {
//       print('Update equipment test error: $e');
//       return null;
//     }
//   }
//
//   Future<String> saveDVREvidenceImages(
//       int index, TechnicalVisitCam cam, String serial) async {
//     try {
//       return await requestsRepository.getEvidenceDVRCamTest(cam, index);
//     } catch (e) {
//       print('Update equipment test error: $e');
//       return null;
//     }
//   }
//
//   Future<TestInfo> ignoreTest(TestInfo testInfo) async {
//     try {
//       if (testInfo.require == false) {
//         testInfo.status = TestStatus.IgnoredNonMandatory;
//       } else {
//         testInfo.status = TestStatus.IgnoredMandatory;
//       }
//     } catch (e) {
//       print('Ignore test error: $e');
//     }
//     return testInfo;
//   }
//
//   void analizeResultJson() {}
// }




// //2o ajuste - TestController
//
// import 'package:flow_flutter/models/company_config.dart';
// import 'package:flow_flutter/repository/repositories.dart';
// import 'package:flow_flutter/utils/installation_step.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
//
// class TestController with InstallationPart<TestConfig> {
//   int installationCloudId;
//   String id; // novo
//   String name;
//   List<TestInfo> testItems;
//   RequestsRepository requestsRepository;
//   bool waitingTest = false;
//   bool containsCamera = true;
//   String auxJustify = "";
//   Box<TestInfo> testBox;
//
//   TestController(
//       {int installationCloudId,
//         String name,
//         this.testItems,
//         this.requestsRepository}) {
//     this.installationCloudId = installationCloudId;
//     this.name = name;
//     this.testItems = testItems;
//     this.requestsRepository = requestsRepository;
//
//     _initializeHive();
//     updateReady();
//   }
//
//   Future<void> _initializeHive() async {
//     try {
//       await Hive.initFlutter();
//       testBox = await Hive.openBox<TestInfo>('testBox');
//     } catch (e) {
//       print('Erro na inicialização do Hive: $e');
//     }
//   }
//
//   void updateReady() {
//     bool ready = true;
//     String message = "";
//
//     for (var i = 0; i < this.testItems.length; i++) {
//       var test = this.testItems[i];
//
//       if (test.status == null || test.status <= TestStatus.Pending || test.status == TestStatus.Partial) {
//         if (!ready) message += '\n';
//         message += '${test.description} não realizado ou ignorado';
//         ready = false;
//       }
//     }
//
//     if (ready) {
//       readyStream.add(ReadyState.ready());
//     } else {
//       readyStream.add(ReadyState.notReady(message));
//     }
//   }
//
//   Future<void> saveTestItem(TestInfo testInfo) async {
//     try {
//       await testBox.put(testInfo.key, testInfo);
//     } catch (e) {
//       print('Erro ao salvar item de teste no Hive: $e');
//     }
//   }
//
//   Future<TestInfo> getTestItem(String key) async {
//     try {
//       return testBox.get(key);
//     } catch (e) {
//       print('Erro ao recuperar item de teste do Hive: $e');
//       return null;
//     }
//   }
//
//   void updateItem(TestInfo testUpdated, int index) {
//     this.testItems[index] = testUpdated;
//     saveTestItem(testUpdated);
//     updateReady();
//   }
//
//   void clearAllDataTests() {
//     try {
//       this.testItems.forEach((e) {
//         e.status = 0;
//         e.statusResult = null;
//         e.analyzeItens = null;
//         e.jsonResult = null;
//         saveTestItem(e);
//       });
//     } catch (e) {
//       print('Erro ao limpar todos os dados de testes: $e');
//     }
//   }
//
//   void updateStartingTest(int index) {
//     this.testItems[index].status = TestStatus.Running;
//   }
//
//   Future<void> updateSucessTestAndEvidence(
//       int index, String newUrl, int technicalVisitId) async {
//     this.testItems[index].status = TestStatus.Success;
//     this.testItems[index].statusResult = newUrl;
//     this.testItems[index].technicalVisitId = technicalVisitId;
//
//     this.updateEquipmentTest(this.testItems[index]);
//   }
//
//   void updateJustification(String justification) {
//     if (justification.isEmpty) {
//       this.auxJustify = "";
//     } else {
//       this.auxJustify = "Ignorado: " + justification;
//     }
//   }
//
//   void updateAcceptedJustification(index) {
//     this.testItems[index].statusResult = this.auxJustify;
//   }
//
//   bool enabledIgnoreButton(index) {
//     return testItems[index].require == false ||
//         (testItems[index].require && auxJustify.length > 20);
//   }
//
//   void clearDataTest(index) {
//     this.testItems[index].status = 0;
//     this.testItems[index].statusResult = null;
//     this.testItems[index].analyzeItens = null;
//     this.testItems[index].jsonResult = null;
//   }
//
//   void updateStatusCamTestItem(index, String url) {
//     this.testItems[index].status =
//     (url != null && url.isNotEmpty) ? TestStatus.Partial : TestStatus.Error;
//     this.testItems[index].statusResult = url;
//     this.testItems[index].statusDate = new DateTime.now();
//     this.testItems[index].technicalVisitId = installationCloudId;
//     updateReady();
//   }
//
//   TestConfig build() {
//     return TestConfig(
//       name: name,
//       tests: testItems,
//     );
//   }
//
//   Future<TestInfo> startEquipmentTest(TestInfo testInfo) async {
//     try {
//       testInfo.technicalVisitId = installationCloudId;
//       return await requestsRepository.startEquipmentTest(testInfo);
//     } catch (e) {
//       print('Erro ao iniciar teste de equipamento: $e');
//       return null;
//     }
//   }
//
//   Future<String> getWowzaStreamUrl(int localId, int cameraId) async {
//     var wowzaStreamUrl = await requestsRepository.getWowzaStreamUrl(
//       localId,
//       cameraId,
//       false,
//     );
//
//     return wowzaStreamUrl;
//   }
//
//   Future<TestInfo> updateEquipmentTest(TestInfo testInfo) async {
//     try {
//       return await requestsRepository.updateEquipmentTest(testInfo);
//     } catch (e) {
//       print('Erro ao atualizar teste de equipamento: $e');
//       return null;
//     }
//   }
//
//   Future<String> saveVCEvidenceImage(TestInfo testInfo) async {
//     try {
//       if (testInfo.statusResult != null && testInfo.statusResult.isNotEmpty) {
//         return await requestsRepository.saveEvidenceCamTest(
//             testInfo.statusResult, testInfo.technicalVisitId, testInfo.key);
//       } else {
//         return null;
//       }
//     } catch (e) {
//       print('Erro ao salvar imagem de evidência VC: $e');
//       return null;
//     }
//   }
//
//   Future<String> saveDVREvidenceImages(
//       int index, TechnicalVisitCam cam, String serial) async {
//     try {
//       return await requestsRepository.getEvidenceDVRCamTest(cam, index);
//     } catch (e) {
//       print('Erro ao salvar imagens de evidência DVR: $e');
//       return null;
//     }
//   }
//
//   Future<TestInfo> ignoreTest(TestInfo testInfo) async {
//     try {
//       if (testInfo.require == false) {
//         testInfo.status = TestStatus.IgnoredNonMandatory;
//       } else {
//         testInfo.status = TestStatus.IgnoredMandatory;
//       }
//     } catch (e) {
//       print('Erro ao ignorar teste: $e');
//     }
//     return testInfo;
//   }
//
//   void analizeResultJson() {}
// }


import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/installation_step.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TestController with InstallationPart<TestConfig> {
  int installationCloudId;
  String id; // novo
  String name;
  List<TestInfo> testItems;
  RequestsRepository requestsRepository;
  bool waitingTest = false;
  bool containsCamera = true;
  String auxJustify = "";
  Box<TestInfo> testBox;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  TestController(
      {int installationCloudId,
        String name,
        this.testItems,
        this.requestsRepository}) {
    this.installationCloudId = installationCloudId;
    this.name = name;
    this.testItems = testItems;
    this.requestsRepository = requestsRepository;

    _initializeHive();
    _initializeConnectivity();
    updateReady();
  }

  Future<void> _initializeHive() async {
    try {
      await Hive.initFlutter();
      testBox = await Hive.openBox<TestInfo>('testBox');
    } catch (e) {
      _showErrorDialog('Erro na inicialização do Hive: $e');
      print('Erro na inicialização do Hive: $e');
    }
  }

  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  void _showErrorDialog(dynamic e) {
    showDialog(
      context: navigatorKey.currentState.overlay.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Take a PRINT of the error',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Error in: $e'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _initializeConnectivity() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        _showConnectionError();
        return;
      }
    });
  }

  void _showConnectionError() {
    // Implementar lógica para exibir uma tela de erro ou notificar o usuário
    _showErrorDialog('Falha na conexão de internet.');
    print('Conexão de internet perdida. Exibindo tela de erro.');
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void updateReady() {
    bool ready = true;
    String message = "";

    for (var i = 0; i < this.testItems.length; i++) {
      var test = this.testItems[i];

      if (test.status == null || test.status <= TestStatus.Pending || test.status == TestStatus.Partial) {
        if (!ready) message += '\n';
        message += '${test.name} não realizado ou ignorado';
        ready = false;
      }
    }

    // if (kDebugMode) {
    //   //Sem Origatoriedade do Auto Teste
    //   readyStream.add(ReadyState.ready(message));


      // //Origatoriedade do Auto Teste
      // bool isCamOrDvr = false;
      //
      // for (var i = 0; i < this.testItems.length; i++) {
      //   var test = this.testItems[i];
      //
      //   if (test.status == null || test.status <= TestStatus.Pending || test.status == TestStatus.Partial) {
      //     if (test.name == 'Câmera DMS' || test.name == 'Câmeras DVR') {
      //       isCamOrDvr = true;
      //     } else {
      //       ready = false;
      //       message += '${test.description} não realizado ou ignorado\n';
      //     }
      //   }
      // }


      // if (ready || isCamOrDvr) {
      //   readyStream.add(ReadyState.ready());
      // } else {
      //   readyStream.add(ReadyState.notReady(message));
      // }

    // }
    // else
    //   {

        if(ready) {
          readyStream.add(ReadyState.ready());
        }
        else {
          readyStream.add(ReadyState.notReady(message));
        }

      // }

  }

  Future<void> saveTestItem(TestInfo testInfo) async {
    try {
      await testBox.put(testInfo.key, testInfo);
    } catch (e) {
      print('Erro ao salvar item de teste no Hive: $e');
    }
  }

  Future<TestInfo> getTestItem(String key) async {
    try {
      return testBox.get(key);
    } catch (e) {
      print('Erro ao recuperar item de teste do Hive: $e');
      return null;
    }
  }

  void updateItem(TestInfo testUpdated, int index) {
    this.testItems[index] = testUpdated;
    saveTestItem(testUpdated);
    updateReady();
  }

  void clearAllDataTests() {
    try {
      this.testItems.forEach((e) {
        e.status = 0;
        e.statusResult = null;
        e.analyzeItens = null;
        e.jsonResult = null;
        saveTestItem(e);
      });
    } catch (e) {
      print('Erro ao limpar todos os dados de testes: $e');
    }
  }

  void updateStartingTest(int index) {
    this.testItems[index].status = TestStatus.Running;
  }

  Future<void> updateSucessTestAndEvidence(
      int index, String newUrl, int technicalVisitId) async {
    this.testItems[index].status = TestStatus.Success;
    this.testItems[index].statusResult = newUrl;
    this.testItems[index].technicalVisitId = technicalVisitId;

    this.updateEquipmentTest(this.testItems[index]);
  }

  void updateJustification(String justification) {
    if (justification.isEmpty) {
      this.auxJustify = "";
    } else {
      this.auxJustify = "Ignorado: " + justification;
    }
  }

  void updateAcceptedJustification(index) {
    this.testItems[index].statusResult = this.auxJustify;
  }

  bool enabledIgnoreButton(index) {
    return testItems[index].require == false ||
        (testItems[index].require && auxJustify.length > 20);
  }

  void clearDataTest(index) {
    this.testItems[index].status = 0;
    this.testItems[index].statusResult = null;
    this.testItems[index].analyzeItens = null;
    this.testItems[index].jsonResult = null;
  }

  void updateStatusCamTestItem(index, String url) {
    this.testItems[index].status =
    (url != null && url.isNotEmpty) ? TestStatus.Partial : TestStatus.Error;
    this.testItems[index].statusResult = url;
    this.testItems[index].statusDate = new DateTime.now();
    this.testItems[index].technicalVisitId = installationCloudId;
    updateReady();
  }

  TestConfig build() {
    return TestConfig(
      name: name,
      tests: testItems,
    );
  }

  Future<TestInfo> startEquipmentTest(TestInfo testInfo) async {
    try {
      testInfo.technicalVisitId = installationCloudId;
      return await requestsRepository.startEquipmentTest(testInfo);
    } catch (e) {
      print('Erro ao iniciar teste de equipamento: $e');
      return null;
    }
  }

  Future<String> getWowzaStreamUrl(int localId, int cameraId) async {
    var wowzaStreamUrl = await requestsRepository.getWowzaStreamUrl(
      localId,
      cameraId,
      false,
    );

    return wowzaStreamUrl;
  }

  Future<TestInfo> updateEquipmentTest(TestInfo testInfo) async {
    try {
      return await requestsRepository.updateEquipmentTest(testInfo);
    } catch (e) {
      print('Erro ao atualizar teste de equipamento: $e');
      return null;
    }
  }

  Future<String> saveVCEvidenceImage(TestInfo testInfo) async {
    try {
      if (testInfo.statusResult != null && testInfo.statusResult.isNotEmpty) {
        return await requestsRepository.saveEvidenceCamTest(
            testInfo.statusResult, testInfo.technicalVisitId, testInfo.key);
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao salvar imagem de evidência VC: $e');
      return null;
    }
  }

  Future<String> saveDVREvidenceImages(
      int index, TechnicalVisitCam cam, String serial) async {
    try {
      return await requestsRepository.getEvidenceDVRCamTest(cam, index);
    } catch (e) {
      print('Erro ao salvar imagens de evidência DVR: $e');
      return null;
    }
  }

  Future<TestInfo> ignoreTest(TestInfo testInfo) async {
    try {
      if (testInfo.require == false) {
        testInfo.status = TestStatus.IgnoredNonMandatory;
      } else {
        testInfo.status = TestStatus.IgnoredMandatory;
      }
    } catch (e) {
      print('Erro ao ignorar teste: $e');
    }
    return testInfo;
  }

  void analizeResultJson() {}
}


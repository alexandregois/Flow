import 'dart:async';
import 'package:dartx/dartx.dart';
import 'package:flow_flutter/controller/V2Controllers/devices_controller.dart';
import 'package:flow_flutter/controller/basic_controller.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/device_listing.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/installation_step.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flutter/foundation.dart';

class DeviceNewController with InstallationPart<Tracker> {
  AutomatedTest _automatedTest;

  String _configName;
  String _serialNew;

  String _qrCodeApiError, _automatedTestError;
  bool _isProcessingQrCode;
  bool _isProcessingAutomatedTest;
  final bool isEditable;
  Tracker _tracker;

  final RequestsRepository requestsRepository;

  DeviceNewController(
    Tracker tracker, {
    this.requestsRepository,
    this.isEditable = true,
  }) {
    _tracker = tracker;

    _qrCodeApiError = qrCodeError;
    _isProcessingQrCode = false;
    _isProcessingAutomatedTest = false;

    updateReady();
  }

  DeviceNewController.forQrCode(
    String codeRead,
    this.requestsRepository,
    // this.hasInstallationLocals = false,
  ) : isEditable = true {
    isProcessingQrCode = true;
    _isProcessingAutomatedTest = false;
    _requestCodeOnApi(codeRead);
  }

  AutomatedTest get automatedTest => _automatedTest;

  set automatedTest(AutomatedTest automatedTest) {
    if (isEditable) {
      _automatedTest = automatedTest;
    }
    updateReady();
  }

  String get automatedTestError => _automatedTestError;

  String get configName => _configName;

  set configName(String configName) {
    if (isEditable) {
      _configName = configName;
    }
    updateReady();
  }

  bool get isProcessingAutomatedTest => _isProcessingAutomatedTest;

  bool get isProcessingQrCode => _isProcessingQrCode;

  set isProcessingQrCode(bool isProcessing) {
    if (isEditable) {
      this._isProcessingQrCode = isProcessing;
    }
    updateReady();
  }

  String get qrCodeError => _qrCodeApiError;

  set qrCodeError(String error) {
    if (isEditable) {
      this._qrCodeApiError = error;
    }
    updateReady();
  }

  Tracker get tracker => _tracker;

  set tracker(Tracker tracker) {
    if (isEditable) {
      _tracker = tracker;
    }

    updateReady();
  }

  String get serialNew => _serialNew;

  set serialNew(String serialNew) {
    if (isEditable) {
      _serialNew = serialNew;
    }
  }

  Tracker build() => this.tracker;

  // mudar condição de equipamento pronto para caber com certas configs e deixar "vazio"
  void startAutomatedTest() {
    if (!_isProcessingAutomatedTest) {
      _isProcessingAutomatedTest = true;
      _automatedTestError = null;
      _requestAutomatedTestResult(10);
      updateReady();
    }
  }

  void updateReady() {
    // final isReady = this.brandId != null &&
    //     this.modelId != null &&
    //     // (!hasInstallationLocals || this.installationLocal != null) &&
    //     this.serial?.isNotBlank == true &&
    //     !this._isProcessingQrCode;
    final isReady = this.tracker.deviceId != null && !this._isProcessingQrCode;

    if (!isReady) {
      readyStream.add(
        ReadyState.notReady(
            'As informações dos equipamentos estão incompletas'),
      );
      return;
    }

    if (_isProcessingQrCode) {
      readyStream.add(
        ReadyState.notReady(
          'Aguarde o processamento de alguns equipamentos.',
        ),
      );
      return;
    }

    if (_automatedTest == null &&
        this.tracker.serial?.isNotBlank == true &&
        this.tracker.brandId != null &&
        this.tracker.modelId != null &&
        this.tracker.installationLocal != null) {
      readyStream.add(
        ReadyState.warning(
          'É recomendado fazer testes automatizados em todos os equipamentos',
        ),
      );
      return;
    }

    readyStream.add(ReadyState.ready());
  }

  void _requestAutomatedTestResult(int remainingTries) async {
    if (readyStream.isClosed) return;
    if (!_isProcessingAutomatedTest) return; //test was internally cancelled
    if (remainingTries == 0) {
      _isProcessingAutomatedTest = false;
      _automatedTestError = 'Tempo limite excedido';
      updateReady();
      return;
    }

    try {
      final result =
          await requestsRepository.getTrackerAutomatedTest(this.tracker.serial);

      if (result != null && _isProcessingAutomatedTest) {
        _isProcessingAutomatedTest = false;
        automatedTest = result;
        updateReady();
        return;
      }
    } catch (e) {
      print(e);
    }

    // if (isDebug()) {
    //   _isProcessingAutomatedTest = false;
    //   automatedTest = AutomatedTest();
    //   updateReady();
    //   return;
    // }

    await Future.delayed(isDebug() ? 100.milliseconds : 4.seconds);
    _requestAutomatedTestResult(remainingTries - 1);
  }

  void _requestCodeOnApi(String codeRead) async {
    final result = await requestsRepository.getTrackerForCode(codeRead);

    this.tracker.brandId = result?.tracker?.brandId ?? this.tracker.brandId;
    this.tracker.modelId = result?.tracker?.modelId ?? this.tracker.modelId;
    this.tracker.serial = result?.tracker?.serial ?? this.tracker.serial;

    _qrCodeApiError = result?.error;

    _isProcessingQrCode = false;
    updateReady();
  }
}

class DevicesNewController extends Stream<List<DeviceNewController>>
    with
        InstallationPart<DeviceChanges>,
        BasicController<List<DeviceNewController>> {
  Map<DeviceNewController, StreamSubscription> _subscriptions = {};

  final List<Brand> brands; //Just for cache purposes
  final List<Model> models; //Just for cache purposes
  final List<Groups> groups;
  final List<Devices> devices;
  final RequestsRepository requestsRepository;
  // final bool hasInstallationLocals;
  bool isEditable;
  bool slotRemoved;
  String visitType;
  bool waiting = false;
  int technicalVisitId;
  bool containsTrackerForRemoval = false;

  DevicesNewController(
      {@required this.technicalVisitId,
      this.devices,
      this.groups,
      this.brands,
      this.models,
      this.requestsRepository,
      List<Tracker> currentTrackers,
      this.isEditable = true,
      String name,
      this.visitType}) {
    slotRemoved = false;
    this.name = name;
    add([]);
    currentTrackers?.forEach((tracker) => addTracker(true, tracker, false));

    add(get());
    updateReady();
  }

  void addCodeRead(String codeRead) {
    var controller = DeviceNewController.forQrCode(
      codeRead,
      requestsRepository,
      // hasInstallationLocals: hasInstallationLocals,
    );
    get().add(controller);

    // ignore: cancel_subscriptions
    var subscription = controller.readyStream.listen((value) => updateReady());

    _subscriptions[controller] = subscription;

    add(get());
    updateReady();
  }

  Future<DeviceNewController> addCodeReadTechVisit(String codeRead) async {
    DeviceNewController controller = await _requestCodeOnApiTechVisit(codeRead);
    // var controller = DeviceController(tracker);
    return controller;
  }

  void updateDeviceList(
      Tracker tracker, Operation operation, String oldSerial) {
    String state;
    bool trackerExists = false;

    if (operation == Operation.ADDED)
      state = "ADDED";
    else if (operation == Operation.CHANGED)
      state = "CHANGED";
    else if (operation == Operation.REMOVED)
      state = "REMOVED";
    else if (operation == Operation.NOT_CHANGED) state = "NOT_CHANGED";

    devices?.forEach((element) {
      if (element.deviceId == tracker.deviceId && state != null) {
        if (element.state == "NOT_CHANGED") {
          element.state = state;
          element.deviceId = tracker.deviceId;
          if (tracker.modelName != null) element.modelName = tracker.modelName;
          if (oldSerial != null) element.oldSerial = oldSerial;
          if (tracker.serial != null) element.serial = tracker.serial;
        }
        if (element.state == "ADDED" && state == "CHANGED") {
          state = "ADDED";
          element.oldSerial = element.serial;
          if (tracker.serial != null) element.serial = tracker.serial;
        }
        if (element.state == "ADDED" && state == "REMOVED") {
          element.state = state;
        }
        if (element.state == "CHANGED" && state == "CHANGED") {
          element.oldSerial = element.serial;
          if (tracker.serial != null) element.serial = tracker.serial;
        }
        if (element.state == "CHANGED" && state == "REMOVED") {
          element.state = state;
        }
        if (element.state == "REMOVED" &&
            (state == "CHANGED" || state == 'ADDED')) {
          element.oldSerial = element.serial;
          if (tracker.serial != null) element.serial = tracker.serial;
          element.state = state;
        }
        if (element.state == "REMOVED" && state == "REMOVED") {
          element.state = "SLOT_REMOVED";
          slotRemoved = true;
        }
        trackerExists = true;
      }
    });

    if (!trackerExists && state != null) {
      devices.add(Devices(
        deviceId: tracker.deviceId,
        modelName: tracker.modelName,
        oldSerial: oldSerial,
        serial: tracker.serial,
        state: state,
      ));
    }
  }

  void addTracker(bool isAdd, Tracker tracker,
      [bool updateReadyStream = true, Operation operation, String oldSerial]) {
    // mode 0 = add novo device, mode 1 change existing device, mode 2 delete e add slot vazio
    // print("Add tracker Device Id: " + tracker.deviceId.toString());
    String state;
    bool trackerExists = false;
    bool isAdding = false;
    if (isAdding == false) {
      isAdding = true;
      var controller = DeviceNewController(
        tracker,
        requestsRepository: requestsRepository,
        // hasInstallationLocals: hasInstallationLocals,
        isEditable: isEditable,
      );
      if (operation == Operation.ADDED)
        state = "ADDED";
      else if (operation == Operation.CHANGED)
        state = "CHANGED";
      else if (operation == Operation.REMOVED) state = "REMOVED";

      devices?.forEach((element) {
        //se device ja está no log
        if (element.deviceId == tracker.deviceId && state != null) {
          if (element.state == "NOT_CHANGED") {
            element.state = state;
            element.deviceId = tracker.deviceId;
            if (tracker.modelName != null)
              element.modelName = tracker.modelName;
            if (oldSerial != null) element.oldSerial = oldSerial;
            if (tracker.serial != null) element.serial = tracker.serial;
          }
          if (element.state == "ADDED" && state == "CHANGED") {
            state = "ADDED";
            element.oldSerial = element.serial;
            if (tracker.serial != null) element.serial = tracker.serial;
          }
          if (element.state == "ADDED" && state == "REMOVED") {
            element.state = state;
          }
          if (element.state == "CHANGED" && state == "CHANGED") {
            element.oldSerial = element.serial;
            if (tracker.serial != null) element.serial = tracker.serial;
          }
          if (element.state == "CHANGED" && state == "REMOVED") {
            element.state = state;
          }
          if (element.state == "REMOVED" &&
              (state == "CHANGED" || state == 'ADDED')) {
            element.oldSerial = element.serial;
            if (tracker.serial != null) element.serial = tracker.serial;
            element.state = state;
          }
          if (element.state == "REMOVED" && state == "REMOVED") {
            element.state = "SLOT_REMOVED";
            slotRemoved = true;
          }
          trackerExists = true;
        }
      });
      if (!trackerExists && state != null) {
        devices.add(Devices(
          deviceId: tracker.deviceId,
          modelName: tracker.modelName,
          oldSerial: oldSerial,
          serial: tracker.serial,
          state: state,
        ));
      }

      if (isAdd) get().add(controller);

      // ignore: cancel_subscriptions
      var subscription =
          controller.readyStream.listen((value) => updateReady());

      _subscriptions[controller] = subscription;

      if (updateReadyStream) {
        add(get());
        updateReady();
      }
      isAdding = false;
    }
  }

  DeviceChanges build() => DeviceChanges(
      devices: get().map((e) => e.build()).toList(), deviceList: devices);

  @override
  void dispose() {
    _subscriptions.forEach((key, value) => value.cancel());
    get().forEach((element) => element.dispose());
    super.dispose();
  }

  void removeTracker(DeviceNewController tracker) {
    final trackerToRemove = get().firstWhere((element) => element == tracker);

    trackerToRemove.dispose();
    _subscriptions[trackerToRemove]?.cancel();

    get().remove(trackerToRemove);

    add(get());
    updateReady();
  }

  void validTrackers(List<Tracker> trackers) async {
    var validOk = true;
    this.containsTrackerForRemoval = false;

    var validationMessage = "";

    trackers.forEach((tracker) {
      if (!tracker.associate) {
        validationMessage +=
            'Equipamento ${tracker.groupName} não associado \n';

        validOk = false;
      }

      if (tracker.forRemoval) {
        this.containsTrackerForRemoval = true;
        validationMessage +=
            'Por favor remova todos os equipamentos a serem removidos';
        validOk = false;
      }

      // tracker.items.forEach((trackerChild) {
      //   if (trackerChild.required &&
      //       trackerChild.groupId != null &&
      //       (trackerChild.serial == null || trackerChild.serial.isEmpty)) {
      //     validationMessage +=
      //         'Periférico ${trackerChild.groupName} no equipamento ${tracker.groupName} não associado \n';

      //     validOk = false;
      //   }

      //   if (trackerChild.forRemoval) {
      //     this.containsTrackerForRemoval = true;
      //     validationMessage +=
      //         'Por favor remova todos os equipamentos a serem removidos';
      //     validOk = false;
      //   }
      // });
    });

    if (!validOk) {
      readyStream.add(
        ReadyState.notReady(validationMessage),
      );
    } else {
      readyStream.add(ReadyState.ready());
    }
  }

  void updateReady() async {
    if (get().isEmpty && visitType != 'U') {
      if (!slotRemoved)
        readyStream.add(
          ReadyState.notReady('Pelo menos um equipamento é necessário'),
        );
      else
        readyStream.add(
          ReadyState.warning('Não tem nenhum equipamento associado.'),
        );
      return;
    } else {
      if (containsTrackerForRemoval) {
        readyStream.add(
          ReadyState.notReady('Ainda há equipamentos a serem removidos'),
        );
      }
    }

    for (var controller in get()) {
      var controllerReadyState = await controller.readyStream.first;
      if (controllerReadyState.status == ReadyStatus.notReady) {
        readyStream.add(controllerReadyState);
        return;
      }
    }

    for (var controller in get()) {
      var controllerReadyState = await controller.readyStream.first;
      if (controllerReadyState.status == ReadyStatus.warning) {
        readyStream.add(controllerReadyState);
        return;
      }
    }

    readyStream.add(ReadyState.ready());
  }

  void updateWaiting(bool waiting) {
    this.waiting = waiting;
  }

  Future<DeviceNewController> _requestCodeOnApiTechVisit(
      String codeRead) async {
    final result = await requestsRepository.getTrackerForCode(codeRead);
    DeviceNewController controller = DeviceNewController(result?.tracker);
    print(result?.error);
    controller.qrCodeError = result?.error;
    return controller;
  }
}

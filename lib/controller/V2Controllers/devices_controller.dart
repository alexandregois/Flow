import 'dart:async';
import 'package:dartx/dartx.dart';
import 'package:flow_flutter/controller/basic_controller.dart';
import 'package:flow_flutter/models/device_listing.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/installation_step.dart';
import 'package:flow_flutter/utils/utils.dart';

enum Operation { ADDED, CHANGED, REMOVED, NOT_CHANGED }

class DevicesController extends Stream<List<DeviceController>>
    with
        InstallationPart<DeviceChanges>,
        BasicController<List<DeviceController>> {
  Map<DeviceController, StreamSubscription> _subscriptions = {};

  final List<Brand> brands; //Just for cache purposes
  final List<Model> models; //Just for cache purposes
  final List<Group> groups;
  final List<Devices> devices;
  final RequestsRepository requestsRepository;
  // final bool hasInstallationLocals;
  bool isEditable;
  bool slotRemoved;
  String visitType;
  bool waiting = false;

  DevicesController(
      {this.devices,
      this.groups,
      this.brands,
      this.models,
      this.requestsRepository,
      List<Tracker> currentTrackers,
      // this.hasInstallationLocals = true,
      this.isEditable = true,
      String name,
      this.visitType}) {
    slotRemoved = false;
    this.name = name;
    add([]);
    currentTrackers?.forEach((tracker) => addTracker(tracker, false));
    add(get());
    updateReady();
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

  void addTracker(Tracker tracker,
      [bool updateReadyStream = true, Operation operation, String oldSerial]) {
    String state;
    bool trackerExists = false;
    bool isAdding = false;
    if (isAdding == false) {
      isAdding = true;
      var controller = DeviceController(
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
        print("alo");
      }

      get().add(controller);

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

  void addCodeRead(String codeRead) {
    var controller = DeviceController.forQrCode(
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

  Future<DeviceController> _requestCodeOnApiTechVisit(String codeRead) async {
    final result = await requestsRepository.getTrackerForCode(codeRead);
    DeviceController controller = DeviceController(result?.tracker);
    print(result?.error);
    controller.qrCodeError = result?.error;
    return controller;
  }

  Future<DeviceController> addCodeReadTechVisit(String codeRead) async {
    DeviceController controller = await _requestCodeOnApiTechVisit(codeRead);
    // var controller = DeviceController(tracker);
    return controller;
  }

  void removeTracker(DeviceController tracker) {
    final trackerToRemove = get().firstWhere((element) => element == tracker);

    trackerToRemove.dispose();
    _subscriptions[trackerToRemove]?.cancel();

    get().remove(trackerToRemove);

    add(get());
    updateReady();
  }

  @override
  void dispose() {
    _subscriptions.forEach((key, value) => value.cancel());
    get().forEach((element) => element.dispose());
    super.dispose();
  }

  DeviceChanges build() => DeviceChanges(
      devices: get().map((e) => e.build()).toList(), deviceList: devices);
}

class DeviceController with InstallationPart<Tracker> {
  AutomatedTest _automatedTest;
  String _serial;
  int _modelId, _brandId, _installationLocal;
  int _deviceId;

  bool _main;
  String _configName;
  int _groupId;
  String _groupName, _brandName, _modelName, _modelType, _modelTechName;
  int _equipmentItemId;
  String _serialNew;

  String _qrCodeApiError, _automatedTestError;
  bool _isProcessingQrCode;
  bool _isProcessingAutomatedTest;
  // bool hasInstallationLocals;
  final bool isEditable;

  final RequestsRepository requestsRepository;

  DeviceController(
    Tracker tracker, {
    this.requestsRepository,
    // this.hasInstallationLocals = false,
    this.isEditable = true,
  }) {
    _serial = tracker?.serial;
    _modelId = tracker?.modelId;
    _brandId = tracker?.brandId;
    _installationLocal = tracker?.installationLocal;

    _modelName = tracker?.modelName;
    _modelType = tracker?.modelType;
    _modelTechName = tracker?.modelTechName;
    _equipmentItemId = tracker?.equipmentItemId;
    _brandName = tracker?.brandName;
    _groupName = tracker?.groupName;
    _groupId = tracker?.groupId;
    _configName = tracker?.configName;
    _deviceId = tracker?.deviceId;
    _main = tracker?.main;

    _qrCodeApiError = qrCodeError;
    _isProcessingQrCode = false;
    _isProcessingAutomatedTest = false;
    updateReady();
  }

  DeviceController.forQrCode(
    String codeRead,
    this.requestsRepository,
    // this.hasInstallationLocals = false,
  ) : isEditable = true {
    isProcessingQrCode = true;
    _isProcessingAutomatedTest = false;
    _requestCodeOnApi(codeRead);
  }

  String get serial => _serial;

  set serial(String serial) {
    if (isEditable) {
      _serial = serial;
      automatedTest = null;
      _isProcessingAutomatedTest = false;
    }
    updateReady();
  }

  String get serialNew => _serialNew;

  set serialNew(String serialNew) {
    if (isEditable) {
      _serialNew = serialNew;
    }
  }

  int get modelId => _modelId;

  set modelId(int modelId) {
    if (isEditable) {
      _modelId = modelId;
    }
    updateReady();
  }

  int get deviceId => _deviceId;

  set deviceId(int deviceId) {
    if (isEditable) {
      _deviceId = deviceId;
    }
    updateReady();
  }

  int get brandId => _brandId;

  set brandId(int brandId) {
    if (_brandId != brandId) {
      if (isEditable) {
        _brandId = brandId;
        modelId = null;
      }
    } else {
      updateReady();
    }
  }

  int get installationLocal => _installationLocal;

  set installationLocal(int installationLocal) {
    if (isEditable) {
      _installationLocal = installationLocal;
    }
    updateReady();
  }

  bool get main => _main;

  set main(bool main) {
    if (isEditable) {
      _main = main;
    }
    updateReady();
  }

  String get configName => _configName;

  set configName(String configName) {
    if (isEditable) {
      _configName = configName;
    }
    updateReady();
  }

  int get groupId => _groupId;

  set groupId(int groupId) {
    if (isEditable) {
      _groupId = groupId;
    }
    updateReady();
  }

  String get groupName => _groupName;

  set groupName(String groupName) {
    if (isEditable) {
      _groupName = groupName;
    }
    updateReady();
  }

  String get brandName => _brandName;

  set brandName(String brandName) {
    if (isEditable) {
      _brandName = brandName;
    }
    updateReady();
  }

  String get modelName => _modelName;

  set modelName(String modelName) {
    if (isEditable) {
      _modelName = modelName;
    }
    updateReady();
  }

  String get modelType => _modelType;

  set modelType(String modelType) {
    if (isEditable) {
      _modelType = modelType;
    }
    updateReady();
  }

  String get modelTechName => _modelTechName;

  set modelTechName(String modelTechName) {
    if (isEditable) {
      _modelTechName = modelTechName;
    }
    updateReady();
  }

  int get equipmentItemId => _equipmentItemId;

  set equipmentItemId(int equipmentItemId) {
    if (isEditable) {
      _equipmentItemId = equipmentItemId;
    }
    updateReady();
  }

  AutomatedTest get automatedTest => _automatedTest;

  set automatedTest(AutomatedTest automatedTest) {
    if (isEditable) {
      _automatedTest = automatedTest;
    }
    updateReady();
  }

  String get qrCodeError => _qrCodeApiError;

  String get automatedTestError => _automatedTestError;

  set qrCodeError(String error) {
    if (isEditable) {
      this._qrCodeApiError = error;
    }
    updateReady();
  }

  bool get isProcessingQrCode => _isProcessingQrCode;

  bool get isProcessingAutomatedTest => _isProcessingAutomatedTest;

  set isProcessingQrCode(bool isProcessing) {
    if (isEditable) {
      this._isProcessingQrCode = isProcessing;
    }
    updateReady();
  }

  void startAutomatedTest() {
    if (!_isProcessingAutomatedTest) {
      _isProcessingAutomatedTest = true;
      _automatedTestError = null;
      _requestAutomatedTestResult(10);
      updateReady();
    }
  }

  // mudar condição de equipamento pronto para caber com certas configs e deixar "vazio"
  void updateReady() {
    // final isReady = this.brandId != null &&
    //     this.modelId != null &&
    //     // (!hasInstallationLocals || this.installationLocal != null) &&
    //     this.serial?.isNotBlank == true &&
    //     !this._isProcessingQrCode;
    final isReady = this.deviceId != null && !this._isProcessingQrCode;

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
        this.serial?.isNotBlank == true &&
        this.brandId != null &&
        this.modelId != null &&
        this.installationLocal != null) {
      readyStream.add(
        ReadyState.warning(
          'É recomendado fazer testes automatizados em todos os equipamentos',
        ),
      );
      return;
    }

    readyStream.add(ReadyState.ready());
  }

  Tracker build() => Tracker(
        deviceId: deviceId,
        modelId: modelId,
        brandId: brandId,
        installationLocal: installationLocal,
        serial: serial,
        modelType: modelType,
        modelTechName: modelTechName,
        equipmentItemId: equipmentItemId,
        brandName: brandName,
        groupName: groupName,
        groupId: groupId,
        configName: configName,
        main: main,
      );

  void _requestCodeOnApi(String codeRead) async {
    final result = await requestsRepository.getTrackerForCode(codeRead);

    _brandId = result?.tracker?.brandId ?? _brandId;
    _modelId = result?.tracker?.modelId ?? _modelId;
    _serial = result?.tracker?.serial ?? _serial;

    _qrCodeApiError = result?.error;

    _isProcessingQrCode = false;
    updateReady();
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
      final result = await requestsRepository.getTrackerAutomatedTest(_serial);

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
}

class AutomatedTest {
  double latitude, longitude;
  int gsmLevel, loraLevel;
  DateTime date;

  AutomatedTest({
    this.latitude,
    this.longitude,
    this.gsmLevel,
    this.loraLevel,
    this.date,
  });
}

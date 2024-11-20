import 'dart:async';

import 'package:collection/collection.dart' as collection;
import 'package:dartx/dartx.dart';
import 'package:flow_flutter/controller/V2Controllers/checklist_controller_V2.dart';
import 'package:flow_flutter/controller/V2Controllers/devices_controller.dart';
import 'package:flow_flutter/controller/V2Controllers/devices_new_controller.dart';
import 'package:flow_flutter/controller/V2Controllers/pictures_controller.dart';
import 'package:flow_flutter/controller/V2Controllers/register_controller.dart';
import 'package:flow_flutter/controller/V2Controllers/test_controller.dart';
import 'package:flow_flutter/controller/V2Controllers/devices_controller_V3.dart';
import 'package:flow_flutter/controller/basic_controller.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/customer.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/models/pictures_to_take_listing.dart';
import 'package:flow_flutter/models/uf_city_Listing.dart';
import 'package:flow_flutter/models/vehicle_listing.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/installation_step.dart';
import 'package:flow_flutter/utils/technichal_visit_stage.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:rxdart/rxdart.dart';

import 'finish_controller.dart';

Function listsAreEqual = const collection.ListEquality().equals;

class CustomPageController extends Stream<List<InstallationPart>>
    with BasicController<List<InstallationPart>> {
  // final _hascustomerEmailController = BehaviorSubject.seeded(false);
  // final _hasCustomer = BehaviorSubject.seeded(false);

  InstallationRepository installationRepository;
  AppDataRepository appDataRepository;

  Installation installation;
  InstallationTypes installationTypes;
  DateTime finishDate;
  // String _customerEmail;
  String _comments;
  // int _customer;

  StreamSubscription _autoSaveSubscription;
  List<Customer> customers;
  Function(int) changeTabs;

  CustomPageController(
    this.changeTabs,
    this.installation,
    this.installationTypes,
    this.appDataRepository, {
    this.installationRepository,
  });

  bool get isEditable => true;

// init é executado diversas vezes para chamar o _initAutoSave e salvar todos
// os dados no repositorio a cada pequena mudança
  Future init({
    PictureToTakeRepository pictureRepository,
    ChecklistRepository checklistRepository,
    DevicesRepository deviceRepository,
    VehiclesRepository vehiclesRepository,
    RequestsRepository requestsRepository,
    TestRepository testRepository,
  }) async {
    customers = (await appDataRepository.getCustomers()) ?? [];

    _comments = installation.comments;
    List<Features> features = installationTypes?.config?.features;
    bool orderIsNotNull =
        features.firstOrNullWhere((feature) => feature.order != null) != null;
    if (orderIsNotNull) features.sort((a, b) => a?.order?.compareTo(b?.order));
    var steps = await Future.wait(features
        .map((feature) => getStep(
            pictureRepository,
            checklistRepository,
            deviceRepository,
            vehiclesRepository,
            requestsRepository,
            testRepository,
            feature))
        .toList());
    add(steps);
    100.milliseconds.delay.then((it) => _initAutoSave());
  }

  Stream<bool> get readyStream {
    final innerControllersStream =
        Rx.combineLatestList(get().map((e) => e.readyStream)).map((event) =>
            event.all((element) => element.status != ReadyStatus.notReady));

    return innerControllersStream;
  }

  // método a ser chamado após enviar uma foto para setar o id retornado pela API
  //também é usado após tirar uma foto novamente e resetar "sent" e o Id
  //mode = 0 -- CHECKLIST SIGNATURE
  //mode = 1 -- FINISH SIGNATURE
  //mode = 2 -- PICTURE
  void setFileIdforPicture(
      int cloudFileId, String featureId, String imageId, bool set, int mode) {
    if (mode == 0) {
      if (set)
        installationRepository.putInstallation(
          installation
            ..installationType
                .installationTypes
                .config
                .features
                .firstOrNullWhere((feature) => feature.id == featureId)
                .checklistConfig
                .currentCheckList
                .cloudFileId = cloudFileId,
        );
      else
        installationRepository.putInstallation(
          installation
            ..installationType
                .installationTypes
                .config
                .features
                .firstOrNullWhere((feature) => feature.id == featureId)
                .checklistConfig
                .currentCheckList
                .cloudFileId = null,
        );
    }
    if (mode == 1) {
      if (set)
        installationRepository.putInstallation(
          installation
            ..installationType
                .installationTypes
                .config
                .features
                .firstOrNullWhere((feature) => feature.id == featureId)
                .finishConfig
                .cloudFileId = cloudFileId,
        );
      else
        installationRepository.putInstallation(
          installation
            ..installationType
                .installationTypes
                .config
                .features
                .firstOrNullWhere((feature) => feature.id == featureId)
                .finishConfig
                .cloudFileId = null,
        );
    }
    if (mode == 2) {
      if (set)
        installationRepository.putInstallation(
          installation
            ..installationType
                .installationTypes
                .config
                .features
                .firstOrNullWhere((feature) => feature.id == featureId)
                .pictureConfig
                .currentPicturesInfo
                .firstOrNullWhere((picture) => picture.imageId == imageId)
                .sent = true
            ..installationType
                .installationTypes
                .config
                .features
                .firstOrNullWhere((feature) => feature.id == featureId)
                .pictureConfig
                .items
                .firstOrNullWhere((item) => item.id == imageId)
                .cloudFileId = cloudFileId,
        );
      else
        installationRepository.putInstallation(
          installation
            ..installationType
                .installationTypes
                .config
                .features
                .firstOrNullWhere((feature) => feature.id == featureId)
                .pictureConfig
                .currentPicturesInfo
                .firstOrNullWhere((picture) => picture.imageId == imageId)
                .sent = false
            ..installationType
                .installationTypes
                .config
                .features
                .firstOrNullWhere((feature) => feature.id == featureId)
                .pictureConfig
                .items
                .firstOrNullWhere((item) => item.id == imageId)
                .cloudFileId = null,
        );
    }
  }

  Future<Installation> finish(LatLong finishPosition) async {
    print("latitude:${finishPosition.latitude} longitude:${finishPosition.longitude}");

    var installation = await _buildInstallation(finish: true, finishPosition: finishPosition);

    installation.stage.stage = TechnicalVisitStage.FINISHED;

    await installationRepository.putInstallation(installation).then((value) {
      return installation;
    });
    
    return installation;
  }

  String get comments => _comments;

  set comments(String value) {
    _comments = value;
    if (installationRepository != null) {
      _buildInstallation().then(installationRepository.putInstallation);
    }
  }

  Future<Installation> _buildInstallation({bool finish = false, LatLong finishPosition}) async {
    
    DeviceChanges deviceChanges;
    Checklist checklist;
    RegisterConfig registerConfig;
    TestConfig testConfig;
    List<PictureInfo> currentPicturesInfo;
    FinishConfig finishConfig;
    // print("buildInstallation");
    installation.installationType.installationTypes.config.features
        .forEach((feature) {
      checklist = get()
          .firstOrNullWhere((element) =>
              (element is ChecklistControllerV2 && element?.id == feature?.id))
          ?.build();
      if (checklist != null && feature?.checklistConfig != null)
        feature.checklistConfig.currentCheckList = checklist;

      registerConfig = get()
          .firstOrNullWhere((element) =>
              (element is RegisterController && element?.id == feature?.id))
          ?.build();
      if (registerConfig != null && feature?.registerConfig != null)
        feature.registerConfig = registerConfig;

      currentPicturesInfo = get()
          .firstOrNullWhere((element) =>
              (element is PicturesController && element?.id == feature?.id))
          ?.build();
      if (currentPicturesInfo != null && feature?.pictureConfig != null)
        feature.pictureConfig.currentPicturesInfo = currentPicturesInfo;

      testConfig = get()
          .firstOrNullWhere((element) =>
              (element is TestController && element?.id == feature?.id))
          ?.build();
      if (testConfig != null && feature?.testConfig != null) {
        feature.testConfig.name = testConfig.name;
        feature.testConfig.tests = testConfig.tests;
      }

      deviceChanges = get()
          .firstOrNullWhere((element) => element is DevicesController)
          ?.build();
      if (deviceChanges != null && feature.deviceConfig != null) {
        feature.deviceConfig.devices = deviceChanges.deviceList;
        deviceChanges.deviceList
            .forEach((element) => print("deviceList: " + element.toString()));
      }

      if (deviceChanges != null && feature.deviceNewConfig != null) {
        feature.deviceNewConfig.devices = deviceChanges.deviceList;
        deviceChanges.deviceList
            .forEach((element) => print("deviceList: " + element.toString()));
      }

      if (feature.deviceNewConfig != null) {
        printDebug('Device config new');
      }

      if (feature.deviceConfigV3 != null) {
        printDebug('Device config V3');
      }

      finishConfig = get()
          .firstOrNullWhere((element) =>
              (element is FinishController && element?.id == feature?.id))
          ?.build();
      if (finishConfig != null && feature.finishConfig != null)
        feature.finishConfig = finishConfig;
    });

    print("progresso:");
    var steps = get();
    double prog = 0;
    int numberOfSteps = steps.length;
    steps.forEach((step) {
      if (step.readyStream.value.status == ReadyStatus.ready ||
          step.readyStream.value.status == ReadyStatus.warning) {
        prog += 1;
      }
    });
    print(
        "progresso calculado: ${prog / numberOfSteps}, registrado: ${installation.progress}");
    return Installation.forValues(
        company: installation.company,
        agreementId: installation.agreementId,
        progress: prog / numberOfSteps,
        appId: installation.appId,
        cloudId: installation.cloudId,
        stage: finish
            ? InstallationStage(stage: TechnicalVisitStage.FINISHED)
            : InstallationStage(stage: TechnicalVisitStage.IN_PROGRESS),
        installationType: installation.installationType,
        startDate: installation.startDate,
        finishDate: finish ? DateTime.now() : installation.finishDate,
        finishLocation: finish ? finishPosition : installation.finishLocation,
        startLocation: installation.startLocation,
        trackers: deviceChanges != null
            ? deviceChanges.devices
            : installation.trackers,
        customerEmail: installation.customerEmail,
        customerId: installation.customerId,
        comments: _comments,
        visitType: installation.visitType);
  }

  void dispose() {
    _autoSaveSubscription?.cancel();
    get()?.forEach((element) => element.dispose());
    super.dispose();
  }

  void _initAutoSave() {
    if (installationRepository != null && !this.isClosed) {
      _autoSaveSubscription = readyStream.listen((event) async {
        installationRepository.putInstallation(await _buildInstallation());
      });
    }
  }

  Future<InstallationPart> getStep(
      PictureToTakeRepository pictureRepository,
      ChecklistRepository checklistRepository,
      DevicesRepository deviceRepository,
      VehiclesRepository vehiclesRepository,
      RequestsRepository requestsRepository,
      TestRepository testRepository,
      Features features) async {

    if (features.featureType.id.contains("REGISTER")) {
      
      var states = await requestsRepository?.getUfs();
      var initialSelectedStateName = features.registerConfig?.currentInfo?.stateName;
      var selectedStateId = 1;

      if (initialSelectedStateName != null && initialSelectedStateName.isNotEmpty) {
        var selectedState = states.ufList?.firstWhere(
            (state) =>
                (state.name == initialSelectedStateName) ||
                (state.acronym == initialSelectedStateName),
            orElse: () => null);
        if (selectedState != null) {
          selectedStateId = selectedState.id;
        } else {
          selectedStateId = null;
        }
      }

      print("vehicleType: ${installation?.installationType?.installationTypes?.config?.vehicleType?.id}");

      var brands = await requestsRepository.getBrands(installation?.installationType?.installationTypes?.config?.vehicleType?.id);
      var brandId = features.registerConfig?.currentInfo?.brandId;

      RegisterController registerController = RegisterController(
        technicalVisitId: installation?.cloudId,
        isVehicle: (installation?.installationType?.installationTypes?.config?.vehicleType?.id != null),
        requestsRepository: requestsRepository,
        name: features?.featureType?.name,
        currentInfo: installation?.installationType?.installationTypes?.config?.features?.first?.registerConfig?.currentInfo,
        brands: brands,
        models: brandId != null ? await requestsRepository.getModels(brandId) : VehicleModelListing(),
        states: states,
        cities: selectedStateId != null ? await requestsRepository?.getCities(selectedStateId) : CityListing(),
        isEditable: isEditable,
        aditionalFields: features?.registerConfig?.aditionalFields,
        recordType: features?.registerConfig?.recordType,
        id: features?.id,
        localTypeId: installation?.installationType?.installationTypes?.config?.localType?.id,
        vehicleTypeId: installation?.installationType?.installationTypes?.config?.vehicleType?.id
      );

      await registerController.initialize();

      return registerController;
    } else if (features.featureType.id.contains("CHECKLIST") && checklistRepository != null) {
      return ChecklistControllerV2(
        features?.checklistConfig?.items,
        isEditable,
        currentChecklist: installation
            ?.installationType?.installationTypes?.config?.features
            ?.firstOrNullWhere((element) => listsAreEqual(
                element?.checklistConfig?.items,
                features?.checklistConfig?.items))
            ?.checklistConfig
            ?.currentCheckList,
        checklistConfig: features?.checklistConfig,
        id: features?.id,
        name: features?.featureType?.name,
      );
    } else if (features.featureType.id == "DEVICE_NEW" &&
        deviceRepository != null) {
      return DevicesNewController(
          technicalVisitId: installation?.cloudId,
          devices: features?.deviceNewConfig?.devices,
          groups: features?.deviceNewConfig?.groups,
          currentTrackers: installation?.trackers,
          brands: await deviceRepository?.getBrands(),
          models: await deviceRepository?.getModels(),
          requestsRepository: requestsRepository,
          isEditable: isEditable,
          name: features?.featureType?.name,
          visitType: installation.visitType);
    } else if (features.featureType.id == "DEVICE" &&
        deviceRepository != null) {
      return DevicesController(
          devices: features?.deviceConfig?.devices,
          currentTrackers: installation?.trackers,
          brands: await deviceRepository?.getBrands(),
          models: await deviceRepository?.getModels(),
          requestsRepository: requestsRepository,
          isEditable: isEditable,
          name: features?.featureType?.name,
          visitType: installation.visitType);
    } else if (features.featureType.id == "DEVICE_V3" && deviceRepository != null) {
      return DevicesControllerV3(
        technicalVisitId: installation?.cloudId,
        requestsRepository: requestsRepository,
        isEditable: isEditable,
        name: features?.featureType?.name,
        visitType: installation.visitType
      );
    } else if (features.featureType.id.contains("PICTURE") &&
        pictureRepository != null) {
      return PicturesController(
        fromPictureConfig(features.pictureConfig) ?? [],
        currentPictures: installation
            ?.installationType?.installationTypes?.config?.features
            ?.firstOrNullWhere((element) => listsAreEqual(
                element?.pictureConfig?.items, features?.pictureConfig?.items))
            ?.pictureConfig
            ?.currentPicturesInfo,
        requestsRepo: requestsRepository,
        installationCloudId: installation.cloudId,
        setFileIdforPicture: setFileIdforPicture,
        addNewCustomPicture: addNewCustomPicture,
        // currentCustomPictures: null,
        mandatoryPictures: true,
        id: features.id,
        name: _getFeatureName(features),
        customPicturesCount: features.pictureConfig.customPicturesCount,
        onlyCameraSource: installation
            ?.installationType?.installationTypes?.config?.features
            ?.firstOrNullWhere((element) => listsAreEqual(
                element?.pictureConfig?.items, features?.pictureConfig?.items))
            ?.pictureConfig
            ?.onlyCameraSource,
      );
    } else if (features.featureType.id.contains("TEST") &&
        testRepository != null) {
      return TestController(
        installationCloudId: installation.cloudId,
        name: features?.testConfig?.name,
        testItems: features?.testConfig?.tests,
        requestsRepository: requestsRepository,
      );
    } else if (features.featureType.id.contains("FINISH")) {
      return FinishController(
        changeTabs: changeTabs,
        finishConfig: features?.finishConfig,
        id: features.id,
        name: features?.featureType?.name,
      );
    } else {
      return null;
    }
  }

  _getFeatureName(Features features) {
    switch (features?.featureType?.id) {
      case "PICTURE":
        return features?.pictureConfig?.name;
        break;
      case "CHECKLIST":
        return features?.checklistConfig?.name;
        break;
      case "TEST":
        return features?.testConfig?.name;
        break;
      default:
        return features?.featureType?.name;
    }
  }

  Future<List<Picture>> addNewCustomPicture(
      Picture newPicture, String featureId, int customPictureCount) async {
    List<PictureItems> list = [];

    PictureConfig pictureConfig = installation
        .installationType.installationTypes.config.features
        .firstOrNullWhere((feature) => feature.id == featureId)
        ?.pictureConfig;

    pictureConfig.items.forEach((picture) {
      list.add(PictureItems(
        onlyCameraSource: picture.onlyCameraSource,
        id: picture.id,
        name: picture.name,
        description: picture.description,
        order: picture.order,
        required: picture.required,
        observationRequired: picture.observationRequired,
        observationDesc: picture.observationDesc,
        isCoverPicture: picture.isCoverPicture,
        orientation: picture.orientation,
      ));
    });
    list.add(PictureItems(
      isCoverPicture: newPicture.isCoverPicture,
      onlyCameraSource: newPicture.onlyCameraSource,
      id: newPicture.id,
      name: newPicture.name,
      description: newPicture.description,
      order: newPicture.order,
      required: newPicture.required,
      observationRequired: newPicture.observationRequired,
      observationDesc: newPicture.observationDesc,
      orientation: newPicture.orientation,
    ));
    if (installationRepository != null) {
      installation.installationType.installationTypes.config.features
          .firstOrNullWhere((feature) => feature.id == featureId)
          ?.pictureConfig
          ?.customPicturesCount = customPictureCount;
      installation
        ..installationType
            .installationTypes
            .config
            .features
            .firstOrNullWhere((feature) => feature.id == featureId)
            ?.pictureConfig
            ?.items = list;
      // installation
      //   .installationType
      //       .installationTypes
      //       .config
      //       .features
      //       .firstOrNullWhere((feature) => feature.id == featureId)
      //       ?.pictureConfig
      //       ?.currentPicturesInfo
      //       ?.add(PictureInfo(
      //         imageId: newPicture.id,
      //         fileLocation: null,
      //         observation: '',
      //         isCustom: true,
      //         sent: false,
      //       ));

      installationRepository.putInstallation(await _buildInstallation());
    }
    return list
        .map((picture) => Picture.fromValues(
          isCoverPicture: picture.isCoverPicture,
          onlyCameraSource: picture.onlyCameraSource,
          id: picture.id,
          name: picture.name,
          description: picture.description,
          order: picture.order,
          required: picture.required,
          sent: false,
          observationRequired: picture.observationRequired,
          observationDesc: picture.observationDesc,
          orientation: picture.orientation))
        .toList();
  }
}

List<Picture> fromPictureConfig(PictureConfig pictureConfig) {
  List<Picture> list = [];

  pictureConfig.items.forEach((picture) {
    var sent = pictureConfig?.currentPicturesInfo
        ?.firstOrNullWhere((element) => element.imageId == picture.id)
        ?.sent;

    list.add(Picture.fromValues(
      isCoverPicture: picture.isCoverPicture,
      onlyCameraSource: picture.onlyCameraSource,
      id: picture.id,
      name: picture.name,
      description: picture.description,
      order: picture.order,
      required: picture.required,
      sent: sent == null ? false : sent,
      observationRequired: picture.observationRequired,
      observationDesc: picture.observationDesc,
      orientation: picture.orientation));
  });
  printDebug("PictureConfig tem ${list.count()} fotos");
  return list;
}

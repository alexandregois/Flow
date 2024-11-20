import 'dart:io';

import 'package:flow_flutter/controller/V2Controllers/devices_controller.dart';
import 'package:flow_flutter/models/asset_model.dart';
import 'package:flow_flutter/models/asset_tree_listing.dart';
import 'package:flow_flutter/models/car_api_response.dart';
import 'package:flow_flutter/models/checklist_listing.dart';
import 'package:flow_flutter/models/code_read_api_result.dart';
import 'package:flow_flutter/models/company.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/customer.dart';
import 'package:flow_flutter/models/device_listing.dart' as device;
import 'package:flow_flutter/models/device_listing.dart';
import 'package:flow_flutter/models/get_all_info.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/models/installation_type.dart';
import 'package:flow_flutter/models/nfe_api_response.dart';
import 'package:flow_flutter/models/photos_by_installation.dart';
import 'package:flow_flutter/models/pictures_to_take_listing.dart';
import 'package:flow_flutter/models/poi_listing.dart';
import 'package:flow_flutter/models/poi_model.dart';
import 'package:flow_flutter/models/reason_finish_technical_visit.dart';
import 'package:flow_flutter/models/technical_visit_edit.dart';
import 'package:flow_flutter/models/technical_visit_list.dart';
import 'package:flow_flutter/models/uf_city_Listing.dart';
import 'package:flow_flutter/models/vehicle_listing.dart' as vehicle;
import 'package:flow_flutter/models/vehicle_listing.dart';
import 'package:flow_flutter/utils/better_classes.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../models/reasonFinish.dart';

abstract class RequestsRepository {

  Future<bool> updateLocalInfoPlate(int technicalVisitId, String plate);

  Future<CarApiResponse> getCarInfo(String plate, String fleetId, String chassis, File pictureFile, String vehicleTypeId);

  Future<NfeApiResponse> getNfeInfo(String value);

  Future<GetAllInfo> getAllInfo();

  Future<CompanyList> getCompanyList();

  Future<CompanyConfig> getCompanyConfig();

  Future<UfListing> getUfs();

  Future<CityListing> getCities(int ufId);

  Future<VehicleBrandListing> getBrands(String vehicleTypeId);

  Future<VehicleModelListing> getModels(int brandId);

  Future<VehicleListing> getVehicleListing([DateTime lastRequestDate]);

  Future<ReasonFinishTechnicalVisitListing> getReasonFinishTechnicalVisit([DateTime lastRequestDate]);

  Future<DeviceListing> getDeviceListing([DateTime lastRequestDate]);

  Future<PicturesListing> getPicturesListing([DateTime lastRequestDate]);

  Future<ChecklistListing> getChecklistListing([DateTime lastRequestDate]);

  Future<AssetTreeNode> getAssetTreeNode(int assetId);

  Future<PoiListing> getPoiListing([DateTime lastRequestDate]);

  Future<TechnicalVisitList> getTechnicalVisit(bool isHistory, {String filter, bool companyFilter, int page});

  Future<List<AssetModel>> getAssetList({String filter, @required bool selectPage});

  Future<List<Tracker>> getGroupsByTechnicalVisit({@required int technicalVisitId, @required List<Groups> groups});

  Future<List<Slot>> getSlotsByTechnicalVisit({@required int technicalVisitId});

  Future<String> fileUrl({String fileId});

  Future<List<PoiModel>> getPoiList({String filter});

  Future<AssetModel> getAsset({int assetId});

  Future<bool> addPoiInAsset({int poiId, int assetId});

  Future<bool> addChildInAsset({int assetChildId, int assetId});

  Future<bool> deleteChildInAsset({int assetChildId, int assetId});

  Future<bool> deletePoiInAsset({int assetId});

  Future<List<AssetModel>> getAssetByPicture({File pictureFile});

  Future<List<AssetModel>> getAssetByQrCode({String qrCode});

  Future<TechnicalVisitEdit> getTechnicalVisitById(int id);

  Future<BetterInt> startNewInstallation(LatLong latLong, int installationTypeId, int customerId);

  Future<String> getVisityTypeByDevice(String serial, String qrCode);

  Future<BetterInt> cancelInstallation(int installationId, int reasonId, String reason, double latitutde, double longitude);

  Future<String> finishTechnicalVisit(int id, LatLong position);

  Future<Tracker> addTrackerTechnicalVisit(int technicalVisitEditId,
      DeviceController tracker, int installationLocal);

  Future<Tracker> addTrackerTechnicalVisitV2(int technicalVisitEditId, Tracker tracker);

  Future<Tracker> addTrackerTechnicalVisitV3(int technicalVisitEditId, Slot slot);

  Future<Tracker> changeTrackerTechnicalVisit(int technicalVisitEditId,
      DeviceController trackerOld, String serialNovo, int installationLocal);

  Future<Tracker> changeTrackerTechnicalVisitV2(int technicalVisitEditId, Tracker trackerOld, String serialNovo);

  Future<Tracker> changeTrackerTechnicalVisitV3(int technicalVisitEditId, Slot slot, String serialNew);

  Future<bool> deleteTrackerTechnicalVisit(int technicalVisitEditId, String serial, int deviceId);

  Future<bool> deleteTrackerSlot(int deviceId);

  //Motivos Finalização Visita
  Future<ReasonFinishList> getReasonFinishList([DateTime lastRequestDate]);


  Future<InstallationStart> startInstallationCargo(
      LatLong latLong,
      int installationTypeId,
      int companyId,
      int customerId,
      String visitType,
      String serial,
      String qrCode);

  Future<InstallationStart> startInstallation(LatLong latLong, int installationTypeId, int companyId);

  Future<String> sendInstallation(Installation installation);

  Future<CodeReadApiResult> getTrackerForCode(String codeRead);

  Future<AutomatedTest> getTrackerAutomatedTest(String identifier);

  Future<PhotosForInstallation> getPhotosForInstallation(int installationId);

  Future<bool> forgotPassword(String email);

  Future<bool> signUp(
      String name, String email, String password, String passwordValidation);

  Future<int> sendInstallationPicture(
    int technicalVisitId,
    String featureId,
    String fileKey,
    File file,
  );

  Future<bool> sendInstallationFinalChecklistPhoto(
    int installationId,
    File file,
  );

  Future<http.Response> performLogin(String email, String password);

  Future setEnvironment(String emailSuffix);

  Future<TestInfo> startEquipmentTest(TestInfo testInfo);

  Future<ListCams> getCamsByTechnicalVisitId(int technicalVisitId);

  Future<String> getVCCAMBySerial(
      int technicalVisitId, String serial, int thumb);

  Future<String> getWowzaStreamUrl(int localId, int cameraId,
      [bool preferHLSStreaming = true]);

  Future<TestInfo> updateEquipmentTest(TestInfo testInfo);

  Future<String> saveEvidenceCamTest(
      String pathImage, int technicalVisitId, String key);

  Future<ListCams> getUrlPathEvidenceDVR(
      int technicalVisitId, String serial, ListCams cams);

  Future<String> getEvidenceDVRCamTest(
      TechnicalVisitCam cam, int technicalVisitId);
}

abstract class AppDataRepository {
  Future setAccessToken(String token);

  Future<String> getAccessToken();

  Future setRefreshToken(String token);

  Future<String> getRefreshToken();

  Future<String> getEnvironment();

  Future<Configuration> getConfiguration();

  Future setConfiguration(Configuration configuration);

  Future setEnvironment(String environment);

  Future<List<Customer>> getCustomers();

  Future setCustomers(List<Customer> customers);

// Future<int> getCustomerId();
//
// Future setCustomerId(int customerId);
//
// Stream<int> customerIdStream();

}

abstract class InstallationRepository {
  Future deleteAllBoxInfo();

  Future<Installation> getInstallation(int installationId);

  Future<List<Installation>> getInstallations();

  Future putInstallation(Installation installation);

  Future deleteInstallations([List<Installation> installation]);

  Stream<List<Installation>> listen();
}

//serve para guardar a lista de checklist items, ficou obsoleto. REMOVER
abstract class ChecklistRepository {
  Future<DateTime> getLastDateRequest();

  Future<String> getLastVersionRequest();

  Future setLastVersionRequest(String appVersion);

  Future setLastDateRequest(DateTime dateRequest);

  Future<List<ChecklistListingItem>> getChecklistItems(
      [InstallationType installationType]);

  Future addChecklistItems(List<ChecklistListingItem> items);

  Future deleteChecklistItems([List<ChecklistListingItem> items]);
}

abstract class DevicesRepository {
  Future<DateTime> getLastDateRequest();

  Future<String> getLastVersionRequest();

  Future setLastDateRequest(DateTime dateRequest);

  Future setLastVersionRequest(String appVersion);

  Future<List<device.Brand>> getBrands();

  Future<List<device.Model>> getModels();

  Future<List<device.Group>> getGroups();

  Future setGroups(List<device.Group> groups);

  Future setBrands(List<device.Brand> brands);

  Future setModels(List<device.Model> models);

  Future deleteBrands([List<device.Brand> brands]);

  Future deleteModels([List<device.Model> models]);

  Future deleteGroups([List<device.Group> groups]);
}

//
abstract class PictureToTakeRepository {
  Future<DateTime> getLastDateRequest();

  Future<String> getLastVersionRequest();

  Future setLastDateRequest(DateTime dateRequest);

  Future setLastVersionRequest(String appVersion);

  Future<List<Picture>> getPictures([InstallationType installationType]);

  Future addPictures(List<Picture> pictures);

  Future deletePictures([List<Picture> pictures]);
}

abstract class TestRepository {
  Future<DateTime> getLastDateRequest();

  Future<String> getLastVersionRequest();

  Future setLastDateRequest(DateTime dateRequest);

  Future setLastVersionRequest(String appVersion);

  Future<TestConfig> getTest();
}

// Deprecated, deve ser deletado
abstract class VehiclesRepository {
  Future<DateTime> getLastDateRequest();

  Future<String> getLastVersionRequest();

  Future setLastDateRequest(DateTime dateRequest);

  Future setLastVersionRequest(String appVersion);

  Future<List<vehicle.Brand>> getBrands();

  Future<List<vehicle.Model>> getModels();

  Future setBrands(List<vehicle.Brand> brands);

  Future setModels(List<vehicle.Model> models);

  Future deleteBrands([List<vehicle.Brand> brands]);

  Future deleteModels([List<vehicle.Model> models]);
}

abstract class LocationRepository {
  Future<LatLong> getCurrentLatLong();
}

abstract class TechVisitRepository {
  Future<List<TechnicalVisit>> getTechVisitList();

  Future<TechnicalVisitEdit> getTechVisitEdit(int techVisitId);

  Future putTechVisit(TechnicalVisit technicalVisit);

  Future putTechVisitEdit(TechnicalVisitEdit technicalVisitEdit);

  Future deleteTechnicalVisit([List<TechnicalVisit> models]);

  Future deleteTechnicalVisitEdit([List<TechnicalVisitEdit> models]);
  // Stream<List<Installation>> listen();
}

abstract class CompanyConfigRepository {
  Future<DateTime> getLastDateRequest();

  Future<String> getLastVersionRequest();

  Future setLastDateRequest(DateTime dateRequest);

  Future setLastVersionRequest(String appVersion);

  Future<CompanyConfig> getCompanyConfig(); //recebe parametro Id Company depois

  Future putCompanyConfig(CompanyConfig companyConfig);
  Future clearBox();
}

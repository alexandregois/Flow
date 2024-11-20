import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flow_flutter/controller/V2Controllers/devices_controller.dart';
import 'package:flow_flutter/models/asset_model.dart';
import 'package:flow_flutter/models/asset_tree_listing.dart';
import 'package:flow_flutter/models/car_api_response.dart';
import 'package:flow_flutter/models/checklist_listing.dart';
import 'package:flow_flutter/models/code_read_api_result.dart';
import 'package:flow_flutter/models/company.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/custom_error.dart';
import 'package:flow_flutter/models/device_listing.dart';
import 'package:flow_flutter/models/exceptions.dart';
import 'package:flow_flutter/models/get_all_info.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/models/nfe_api_response.dart';
import 'package:flow_flutter/models/operation_equipment.dart';
import 'package:flow_flutter/models/photos_by_installation.dart';
import 'package:flow_flutter/models/pictures_to_take_listing.dart';
import 'package:flow_flutter/models/poi_listing.dart';
import 'package:flow_flutter/models/poi_model.dart';
import 'package:flow_flutter/models/reason_finish_technical_visit.dart';
import 'package:flow_flutter/models/technical_visit_state_enum.dart';
import 'package:flow_flutter/models/technical_visit_edit.dart';
import 'package:flow_flutter/models/technical_visit_list.dart';
import 'package:flow_flutter/models/uf_city_Listing.dart';
import 'package:flow_flutter/models/vehicle_listing.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/better_classes.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as Http;
//import 'package:package_info/package_info.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../models/reasonFinish.dart';

const PRODUCTION_BASE_URL = "https://api.denox.com.br";
const TEST_BASE_URL = "https://my-test.denox.com.br";
const TEST_LOCAL = "http://172.16.8.165:9002"; //To localhost test
const TEST_LOCAL_EMULATOR = "http://10.0.2.2:9002"; //To localhost test

class DenoxRequests implements RequestsRepository {
  static var urlBase = PRODUCTION_BASE_URL;
  static const _auth =
      "Basic QW5kcm9pZDo5N2U3NDY3NS03YzNmLTQyMzAtYThjNy05OGM2OWZiM2EyYjQ=";
  static Companies selectedCompany;

  // ignore: unused_field
  static const _platformChannel = MethodChannel("http_requests");

  AppDataRepository _appDataRepository;

  static void setCompany(Companies company) {
    selectedCompany = company;
    print("Selected Company Id: " +
        selectedCompany?.id.toString() +
        ", Name: " +
        selectedCompany?.name);
  }

  void setAppDataRepository(AppDataRepository appDataRepository) {
    _appDataRepository = appDataRepository;
  }

  Future setEnvironment(String emailSuffix) async {
    switch (emailSuffix) {
      case "&&&":
        urlBase = TEST_BASE_URL;
        break;
      case "%%%":
        urlBase = TEST_LOCAL;
        break;
      case "!!!":
        urlBase = TEST_LOCAL_EMULATOR;
        break;
      default:
        urlBase = PRODUCTION_BASE_URL;
        break;
    }
  }

  Future<Map<String, String>> _authHeader(
      {int localId, String contentType}) async {
    var accessToken = await _appDataRepository.getAccessToken();

    if (accessToken != null) {
      var header = {
        "Authorization": "Bearer $accessToken",
        "Encoding": "gzip",
        "Content-Type": contentType ?? "application/json",
      };

      if (localId != null) {
        header["Local"] = localId.toString();
      }

      return header;
    } else {
      throw Exception("No access token found.");
    }
  }

  Future<bool> basicPutRequest(
      String url, int localId, Map<String, dynamic> body) async {
    assert(!url.contains("+"),
    "The url provided contains a undecoded query component: $url");

    try {
      String urlAux = Uri.encodeFull(urlBase + url);
      var response = await Http.put(
        Uri.parse(urlAux),
        headers: await _authHeader(),
        body: json.encode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        _checkRefreshTokenNeeded(response);
        return false;
      }
    } catch (e) {
      print(e);
    }

    return false;
  }

  Future<bool> requestWowzaStreamOpening(
      int localId,
      int cameraId,
      bool useSpiderUrl,
      ) async {
    if (useSpiderUrl) {
      return basicPutRequest("/v2/spider/$cameraId/stream", localId, null);
    } else {
      try {
        String url = Uri.encodeFull(
            urlBase + "/v1/ipcamera/$cameraId/create/stream/file");
        final response = await Http.get(
          Uri.parse(url),
          headers: await _authHeader(),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return true;
        } else {
          if (response.statusCode == 500 &&
              json.decode(response.body)['errorCode'] == 216) {
            return true;
          }
          _checkRefreshTokenNeeded(response);
        }
      } catch (e) {
        print(e);
      }

      return false;
    }
  }

//original era static
  Future<String> getWowzaStreamUrl(int localId, int cameraId,
      [bool preferHLSStreaming = true]) async {
    try {
      //chamada wowza
      String url = Uri.encodeFull(
          urlBase + "/cameras/api/ipcamera/stream_url/$cameraId");

      var header = await _authHeader();

      var response = await Http.get(
        Uri.parse(url),
        headers: header,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        printDebug('Response from wowza: ${response.body}');
        return jsonDecode(response.body)[preferHLSStreaming ? 'hls' : 'url'];
      } else {
        _checkRefreshTokenNeeded(response);
        return null;
      }
    } catch (e) {
      print(e);
    }

    return null;
  }

  Future<bool> forgotPassword(String email) async {
    var url = urlBase + "/apipublic/accounts/forgotpassword";

    try {
      var response = await Http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(
          {
            "email": email,
            "application": 'denox',
          },
        ),
      ).timeout(10.seconds);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      print(e);
    }

    return false;
  }

  @override
  Future<bool> signUp(String name, String email, String password,
      String passwordValidation) async {
    var body = json.encode(
      {
        "name": name,
        "email": email,
        "password": password,
        "passwordValidation": passwordValidation,
        "companyName": "maxtrack_demo",
        "isTechnical": true
      },
    );

    var url = urlBase + "/apipublic/accounts/signup";

    try {
      var response = await Http.post(
        Uri.parse(url),
        headers: {
          "Encoding": "gzip",
          "Content-Type": "application/json",
        },
        body: body,
      );

      var jsonResult = json.decode(response.body);

      print("SignUp return: [${response.statusCode}] $jsonResult");

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> setInstallationMode(String serial, bool active) async {

    var url = "$urlBase/v1/flow/installationmode";

    var body = json.encode({
      "serial": serial,
      "active": active.toString(),
    });

    try {
      var response = await Http.put(
        Uri.parse(url),
        headers: await _authHeader(contentType: "image/jpeg"),
        body: body,
      );

      if (response.statusCode == 200) {
        var jsonResult = json.decode(response.body);
        return jsonResult['success'] == "true";
      } else {
        await _checkRefreshTokenNeeded(response);
        return false;
      }
    } catch (e) {
      print("Error setting installation mode: $e");
      return false;
    }
  }

  Future<GetAllInfo> getAllInfo() async {
    print('Performing GetAllInfo...');

    var url = urlBase +
        "/v2/flow/account" +
        (selectedCompany != null ? '?companyId=${selectedCompany.id}' : '');

    var response = await Http.get(
      Uri.parse(url),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      Map jsonResult = json.decode(response.body);
      jsonResult.printAsJsonPretty();

      // try {
      //   _platformChannel.invokeMethod("getAllInfo", response.body);
      // } catch (e) {
      //   print(e);
      // }

      var getAllInfo = GetAllInfo.fromJson(jsonResult);
      return getAllInfo;
    } else {
      print("GetAllInfo fail: [${response.statusCode}]" + response.body);
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<CarApiResponse> getCarInfo(String plate, String fleetId, String chassis, File pictureFile, String vehicleTypeId) async {

    var url = urlBase + "/v2/flow/installation/carinfo/";

    url += "?vehicleTypeId=$vehicleTypeId";

    if(!plate.isNullOrEmpty)
      url += "&plate=$plate";

    if(!fleetId.isNullOrEmpty)
      url += "&fleetId=$fleetId";

    if(!chassis.isNullOrEmpty)
      url += "&chassis=$chassis";

    final openFile = pictureFile != null ? await pictureFile.readAsBytes() : null;

    var response = await Http.put(
      Uri.parse(url),
      headers: await _authHeader(contentType: "image/jpeg"),
      body: openFile,
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      Map jsonResult = json.decode(response.body);
      return CarApiResponse.fromJson(jsonResult);
    } else {
      log("Api Carros fail: [${response.statusCode}]" + response.body);
      Map<String, dynamic> jsonResult = json.decode(response.body);
      if (jsonResult['errorCode'] == 216) {
        var response = CarApiResponse();
        response.message = 'Não foi possível obter dados da placa';
        response.pictureUnrecognized = true;
        return response;
      }

      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<NfeApiResponse> getNfeInfo(String nfeKey) async {
    var url = urlBase + "/v1/flow/installation/nfeinfo?nfeKey=$nfeKey";

    var response = await Http.get(Uri.parse(url), headers: await _authHeader());

    if (response.statusCode == 200) {
      Map jsonResult = json.decode(response.body);
      return NfeApiResponse.fromJson(jsonResult);
    } else {
      print("Nfe info fail: [${response.statusCode}]" + response.body);
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<CityListing> getCities(int ufId) async {
    var url = urlBase + "/v1/address/locality/$ufId";

    var response = await Http.get(
      Uri.parse(url),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      Map jsonResult = json.decode(response.body);
      print('Received City Listing with success!');

      return CityListing.fromJson(jsonResult);
    } else {
      print("CityListing fail: [${response.statusCode}]" + response.body);
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  // aqui
  @override
  Future<UfListing> getUfs() async {
    var url = urlBase + "/v2/address/uf";

    var response = await Http.get(
      Uri.parse(url),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      Map jsonResult = json.decode(response.body);
      print('Received Uf Listing with success!');

      return UfListing.fromJson(jsonResult);
    } else {
      print("UfListing fail: [${response.statusCode}]" + response.body);
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<VehicleBrandListing> getBrands(String vehicleTypeId) async {
    var url = urlBase + "/v1/flow/vehiclebrand/list?vehicleTypeId=$vehicleTypeId";

    var response = await Http.get(
      Uri.parse(url),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      Map jsonResult = json.decode(response.body);
      print('Received Vehicle Brand Listing with success!');

      return VehicleBrandListing.fromJson(jsonResult);
    } else {
      print("BrandListing fail: [${response.statusCode}]" + response.body);
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<VehicleModelListing> getModels(int brandId) async {
    var url = urlBase + "/v1/flow/vehiclemodel/list?brandId=$brandId";

    var response = await Http.get(
      Uri.parse(url),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      Map jsonResult = json.decode(response.body);
      print('Received Vehicle Model Listing with success!');

      return VehicleModelListing.fromJson(jsonResult);
    } else {
      print("VehicleModelListing fail: [${response.statusCode}]" + response.body);
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  Future<VehicleListing> getVehicleListing([DateTime lastRequestDate]) async {
    var url = urlBase +
        "/v1/flow/vehicle/listing" +
        (lastRequestDate != null
            ? '?lastRequestDate=${lastRequestDate.millisecondsSinceEpoch}'
            : '');

    // print('Listing vehicles $url');

    var response = await Http.get(
      Uri.parse(url),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      Map jsonResult = json.decode(response.body);
      print('Received vehicle listing with success!');

      return VehicleListing.fromJson(jsonResult);
    } else {
      print("Listing vehicles fail: [${response.statusCode}]" + response.body);
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  Future<ReasonFinishTechnicalVisitListing> getReasonFinishTechnicalVisit(
      [DateTime lastRequestDate]) async {
    var url = urlBase +
        "/v1/flow/reasonfinishtechnicalvisit/listing" +
        (lastRequestDate != null
            ? '?lastRequestDate=${lastRequestDate.millisecondsSinceEpoch}'
            : '');

    var response = await Http.get(
      Uri.parse(url),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      Map jsonResult = json.decode(response.body);
      return ReasonFinishTechnicalVisitListing.fromJson(jsonResult);
    } else {
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  // @override
  // Future<PoiListing> getPoiListing([DateTime lastRequestDate]) async {
  //   final String response =
  //       await rootBundle.loadString('assets/json/poi_list_example.json');
  //   Map jsonResult = await json.decode(response);
  //   return PoiListing.fromJson(jsonResult);
  // }

  Future<bool> sendRequestPositionForInstallationMode(
      String serial, String transportType, List<String> responseTransportTypes) async {
    var url = urlBase + "/v1/flow/installationmode";

    try {
      // Corpo da requisição com os parâmetros necessários
      var body = json.encode({
        "serial": serial,
        "transportType": transportType,
        "responseTransportTypes": responseTransportTypes,
      });

      // Enviando a requisição HTTP PUT
      var response = await Http.put(
        Uri.parse(url),
        headers: await _authHeader(contentType: "application/json"),
        body: body,
      );

      // Verificando o status da resposta
      if (response.statusCode == 200) {
        var jsonResult = json.decode(response.body);

        // Retornando true se "success" for "true"
        if (jsonResult["success"] == "true") {
          return true;
        } else {
          return false;
        }
      } else {
        await _checkRefreshTokenNeeded(response);
        return false;
      }
    } catch (e) {
      print("Error in sendTransportTypeForInstallationMode: $e");
      return false;
    }
  }

  Future<List<TestInfo>> fetchTestItemsFromApi() async {
    try {
      var url = urlBase + "/v1/flow/test/list";  // Suponha que este seja o endpoint correto
      var response = await Http.get(
        Uri.parse(url),
        headers: await _authHeader(),
      );

      if (response.statusCode == 200) {
        var jsonResult = json.decode(response.body);
        return (jsonResult as List).map((item) => TestInfo.fromJson(item)).toList();
      } else {
        print("Falha ao buscar os dados: [${response.statusCode}] ${response.body}");
        await _checkRefreshTokenNeeded(response);
        return [];
      }
    } catch (e) {
      print("Erro ao buscar dados da API: $e");
      return [];
    }
  }


  //Motivos Finalização Visita
  Future<ReasonFinishList> getReasonFinishList([DateTime lastRequestDate]) async {
    // var url = urlBase +
    //     "/v2/flow/reasonfinishtechnicalvisit/listing?lastRequestDate=$lastRequestDate";

    var url = urlBase +
        "/v2/flow/reasonfinishtechnicalvisit/listing" +
        (lastRequestDate != null
            ? '?lastRequestDate=${lastRequestDate.millisecondsSinceEpoch}'
            : '');

    try {
      // Enviando a requisição HTTP GET
      var response = await Http.get(
        Uri.parse(url),
        headers: await _authHeader(),
      );

      // Verificando o status da resposta
      if (response.statusCode == 200) {
        var jsonResult = json.decode(response.body);
        return ReasonFinishList.fromJson(jsonResult);
      } else {
        await _checkRefreshTokenNeeded(response);
        return null;
      }
    } catch (e) {
      print("Error in getReasonFinishList: $e");
      return null;
    }
  }


  Future<bool> sendAudioForInstallationMode(String serial) async {
    var url = urlBase + "/v1/flow/installationmode";

    try {
      // Corpo da requisição com os parâmetros necessários
      var body = json.encode({
        "serial": serial,
        "audioId": 31,
      });

      // Enviando a requisição HTTP PUT
      var response = await Http.put(
        Uri.parse(url),
        headers: await _authHeader(contentType: "application/json"),
        body: body,
      );

      // Verificando o status da resposta
      if (response.statusCode == 200) {
        var jsonResult = json.decode(response.body);

        // Retornando true se "success" for "true"
        if (jsonResult["success"] == "true") {
          return true;
        } else {
          return false;
        }
      } else {
        await _checkRefreshTokenNeeded(response);
        return false;
      }
    } catch (e) {
      print("Error in sendAudioForInstallationMode: $e");
      return false;
    }
  }


  @override
  Future<PoiListing> getPoiListing([DateTime lastRequestDate]) async {
    var url = urlBase +
        "/v1/flow/poi" +
        (lastRequestDate != null
            ? '?lastRequestDate=${lastRequestDate.millisecondsSinceEpoch}'
            : '') +
        (selectedCompany != null ? '?companyId=${selectedCompany.id}' : '');

    print('Listing pois $url');

    var response = await Http.get(
      Uri.parse(url),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      Map jsonResult = json.decode(response.body);
      print('Received device listing with success!');
      jsonResult.printAsJsonPretty();

      return PoiListing.fromJson(jsonResult);
    } else {
      print("Listing pois fail: [${response.statusCode}]" + response.body);
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  Future<DeviceListing> getDeviceListing([DateTime lastRequestDate]) async {
    // incluir companyId como parametro na chamada
    var url = urlBase +
        "/v1/flow/device/listing" +
        (lastRequestDate != null
            ? '?lastRequestDate=${lastRequestDate.millisecondsSinceEpoch}'
            : '');

    print('Listing devices $url');

    var response = await Http.get(
      Uri.parse(url),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      Map jsonResult = json.decode(response.body);
      print('Received device listing with success!');
      jsonResult.printAsJsonPretty();

      return DeviceListing.fromJson(jsonResult);
    } else {
      print("Listing devices fail: [${response.statusCode}]" + response.body);
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  Future<PicturesListing> getPicturesListing([DateTime lastRequestDate]) async {
    // incluir companyId
    var url = urlBase +
        "/v1/flow/picture/listing" +
        (lastRequestDate != null
            ? '?lastRequestDate=${lastRequestDate.millisecondsSinceEpoch}'
            : '');

    print('Listing pictures $url');

    var response = await Http.get(
      Uri.parse(url),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      Map jsonResult = json.decode(response.body);
      print('Received pictures listing with success!');

      return PicturesListing.fromJson(jsonResult);
    } else {
      print("Listing pictures fail: [${response.statusCode}]" + response.body);
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  Future<ChecklistListing> getChecklistListing(
      [DateTime lastRequestDate]) async {
    // incluir companyId
    var url = urlBase +
        "/v1/flow/checklistitem/listing" +
        (lastRequestDate != null
            ? '?lastRequestDate=${lastRequestDate.millisecondsSinceEpoch}'
            : '');

    print('Listing checklist $url');

    var response = await Http.get(
      Uri.parse(url),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      Map jsonResult = json.decode(response.body);
      print('Received checklist listing with success!');

      return ChecklistListing.fromJson(jsonResult);
    } else {
      print("Listing checklist fail: [${response.statusCode}]" + response.body);
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<AssetTreeNode> getAssetTreeNode(int assetId) async {
    final String response =
    await rootBundle.loadString('assets/json/asset_tree_example.json');
    Map jsonResult = await json.decode(response);
    return AssetTreeListing.fromJson(jsonResult).asset;
  }

  @override
  Future<AssetModel> getAsset({int assetId}) async {
    printDebug('Get asset by id $assetId');

    var url = urlBase + "/v1/flow/asset";

    print(url);

    var response = await Http.post(
      Uri.parse(url),
      headers: await _authHeader(),
      body: json.encode({"assetId": assetId}),
    );

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      return AssetModel.fromJson(jsonResult);
    } else {
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<List<Tracker>> getGroupsByTechnicalVisit({@required int technicalVisitId, @required List<Groups> groups}) async {
    printDebug('Buscando devices por visita técnica $technicalVisitId');

    var url = urlBase + "/v1/flow/technicalvisit/devices?technicalVisitId=$technicalVisitId";

    var response = await Http.get(
      Uri.parse(url),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      Map jsonResult = json.decode(response.body);
      print('Received device listing with success!');
      jsonResult.printAsJsonPretty();

      var trackersInstalled = DeviceListing.fromJson(jsonResult)?.trackers;
      var trackersFromInstalled = Tracker.getTrackerListByGroup(groups, trackersInstalled);

      printDebug('Trackers instalados: ${trackersInstalled.length}');
      printDebug('Trackers para instalar: ${trackersFromInstalled.length}');

      return trackersFromInstalled;
    } else {
      print("Listing devices fail: [${response.statusCode}]" + response.body);
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<List<AssetModel>> getAssetList({String filter, @required bool selectPage}) async {
    printDebug('Filter asset $filter');

    var companyId = selectedCompany?.id;
    var url = urlBase + "/v1/flow/asset/list";

    var response = await Http.post(
      Uri.parse(url),
      headers: await _authHeader(),
      body: json.encode(
          {"filter": filter, "companyId": companyId, "selectPage": selectPage}),
    );
    print(url);

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      var assetList = AssetModel.fromJsonList(jsonResult);

      assetList.forEach((asset) {
        if (asset.fileId != null) {
          fileUrl(fileId: asset.fileId)
              .then((fileUrl) => asset.fileUrl = fileUrl);
        }
      });

      return assetList;
    } else {
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  Future<String> fileUrl({String fileId}) async {
    var accessToken = await _appDataRepository.getAccessToken();
    return urlBase + "/v1/files/$fileId?access_token=$accessToken";
  }

  @override
  Future<List<PoiModel>> getPoiList({String filter}) async {
    printDebug('Filter poi $filter');

    var url = urlBase +
        "/v1/flow/poi" +
        (selectedCompany != null ? '?companyId=${selectedCompany.id}' : '') +
        (filter != null ? '&filter=$filter' : '');

    print('Listing pois $url');

    var response = await Http.get(
      Uri.parse(url),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      Map jsonResult = json.decode(response.body);
      jsonResult.printAsJsonPretty();

      return PoiModel.fromJsonList(jsonResult);
    } else {
      print("Listing pois fail: [${response.statusCode}]" + response.body);
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<List<AssetModel>> getAssetByPicture({File pictureFile}) async {
    printDebug('Filter asset by picture');

    var companyId = selectedCompany?.id;
    var url = urlBase +
        "/v1/flow/asset/listbypicture" +
        (companyId != null ? '?companyId=$companyId' : '');

    print(url);

    final openFile =
    pictureFile != null ? await pictureFile.readAsBytes() : null;

    var response = await Http.put(
      Uri.parse(url),
      headers: await _authHeader(contentType: "image/jpeg"),
      body: openFile,
    );

    // var response = await Http.post(
    //   Uri.parse(url),
    //   headers: await _authHeader(),
    //   body: json.encode({"filter": filter, "companyId": companyId}),
    // );

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      return AssetModel.fromJsonList(jsonResult);
    } else {
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<bool> addPoiInAsset({int poiId, int assetId}) async {
    printDebug('Add poi in asset');

    var url = urlBase + "/v1/flow/asset/add/poi";

    print(url);

    var response = await Http.put(
      Uri.parse(url),
      headers: await _authHeader(),
      body: json.encode({'poiId': poiId, 'assetId': assetId}),
    );

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      return jsonResult['success'];
    } else {
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<bool> addChildInAsset({int assetChildId, int assetId}) async {
    printDebug('Add asset child in asset');

    var url = urlBase + "/v1/flow/asset/addchild";

    print(url);

    var response = await Http.put(
      Uri.parse(url),
      headers: await _authHeader(),
      body: json.encode({'assetChildId': assetChildId, 'assetId': assetId}),
    );

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      return jsonResult['success'];
    } else {
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<bool> deletePoiInAsset({int assetId}) async {
    printDebug('Delete poi in asset');

    var url = urlBase + "/v1/flow/asset/delete/poi";

    print(url);

    var response = await Http.delete(
      Uri.parse(url),
      headers: await _authHeader(),
      body: json.encode({'assetId': assetId}),
    );

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      return jsonResult['success'];
    } else {
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<bool> deleteChildInAsset({int assetChildId, int assetId}) async {
    printDebug('Delete asset child in asset');

    var url = urlBase + "/v1/flow/asset/deletechild";

    print(url);

    var response = await Http.delete(
      Uri.parse(url),
      headers: await _authHeader(),
      body: json.encode({'assetChildId': assetChildId, 'assetId': assetId}),
    );

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      return jsonResult['success'];
    } else {
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<List<AssetModel>> getAssetByQrCode({String qrCode}) async {
    printDebug('Filter asset by qrcode');

    var companyId = selectedCompany?.id;
    var url = urlBase +
        "/v1/flow/asset/listbyqrcode" +
        (companyId != null ? '?companyId=$companyId' : '');

    print(url);

    var response = await Http.put(
      Uri.parse(url),
      headers: await _authHeader(),
      body: json.encode({'value': qrCode}),
    );

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      return AssetModel.fromJsonList(jsonResult);
    } else {
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<TechnicalVisitList> getTechnicalVisit(bool isHistory, {String filter, bool companyFilter, int page}) async {
    var companyId = selectedCompany?.id;
    var url = urlBase + "/v2/flow/technicalvisit/list";

    var response = await Http.post(
      Uri.parse(url),
      headers: await _authHeader(),
      body: json.encode({
        "page": page,
        "pageSize": 20,
        "filter": filter ?? null,
        "companyId": companyFilter ? companyId : null,
        "installationMode": ["M", "U", "I", "A"],
        "technicalVisitState": (isHistory
            ? [
          TechnicalVisitStateEnum.CANCELED.id,
          TechnicalVisitStateEnum.CLOSE_AUTOMATIC.id,
          TechnicalVisitStateEnum.COMPLETED.id,
          TechnicalVisitStateEnum.CLOSE_AUTOMATIC.id,
          TechnicalVisitStateEnum.HOUR_EXCEDDED.id,
          TechnicalVisitStateEnum.UNPRODUCTIVE.id,
          TechnicalVisitStateEnum.WAITING_FOR_MANAGER_ACTION.id,
          TechnicalVisitStateEnum.CANCELED_DISPLACEMENT.id
        ]
            : [
          TechnicalVisitStateEnum.WAITING.id,
          TechnicalVisitStateEnum.SCHEDULED.id,
          TechnicalVisitStateEnum.IN_PROGRESS.id
        ]), //Agora a lista em aberto pode voltar o 4 - concluido com pendencia TRUE
        "picturePending": (isHistory ? "false" : "true")
      }),
    );
    print(url);

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      var returned = TechnicalVisitList.fromJson(jsonResult);
      return returned;
    } else {
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<bool> updateLocalInfoPlate(int technicalVisitId, String plate) async {
    var response = await Http.post(
      Uri.parse(urlBase + "/v1/flow/techinicalvisit/update/localinfo/plate"),
      headers: await _authHeader(),
      body: json.encode(
        {"technicalVisitId": technicalVisitId, "plate": plate},
      ),
    );

    print("Status code:" + response.statusCode.toString());

    var jsonResult = json.decode(response.body);
    printDebug("Resultado atualização localinfo $jsonResult");

    if (response.statusCode == 200) {
      print("Visita Técnica: [${response.statusCode}] ");
      return true;
    } else {
      await _checkRefreshTokenNeeded(response);
    }

    return false;
  }

  @override
  Future<String> finishTechnicalVisit(int id, LatLong position) async {
    var latLongJson = json.encode(
      {
        "id": id,
        "latitude": position.latitude,
        "longitude": position.longitude,
      },
    );
    printDebug('Json to send: $latLongJson');
    printDebug(urlBase + "/v1/flow/techinicalvisit/finish");
    var headers = await _authHeader();
    printDebug(headers);
    var response = await Http.post(
      Uri.parse(urlBase + "/v1/flow/techinicalvisit/finish"),
      headers: headers,
      body: latLongJson,
    );
    print("Status code:" + response.statusCode.toString());
    var jsonResult = json.decode(response.body);
    if (response.statusCode == 200) {
      print("Visita Técnica: [${response.statusCode}] ");
      return "No error";
    } else if (jsonResult['customError'] != null) {
      final message = jsonResult['customError']["messageText"];
      return message;

      // throw InstallationRefusedException(message);
    } else {
      await _checkRefreshTokenNeeded(response);
    }

    return "No error";
  }

  @override
  Future<TechnicalVisitEdit> getTechnicalVisitById(int id) async {
    var response = await Http.get(
      Uri.parse(urlBase + "/v1/flow/techinicalvisit/edit/$id"),
      headers: await _authHeader(),
    );
    print(urlBase + "/v1/flow/techinicalvisit/edit/$id");

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      print("Visita Técnica: [${response.statusCode}] $jsonResult");
      var returned = TechnicalVisitEdit.fromJson(jsonResult);
      return returned;
    } else {
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<CodeReadApiResult> getTrackerForCode(String codeRead) async {
    Http.Response response;

    try {
      response = await Http.put(
        Uri.parse(urlBase + "/v1/flow/device/qrcode"),
        headers: await _authHeader(),
        body: json.encode({'value': codeRead}),
      );
    } catch (e) {
      print('Error on qr code result: $e');
    }

    print("Qr code result [${response?.statusCode}]: ${response?.body}");

    if (response?.statusCode == 200) {
      Map<String, dynamic> jsonResult = json.decode(response.body);

      if (jsonResult.containsKey('associationError')) {
        return CodeReadApiResult(error: jsonResult['associationError']);
      }

      if (!jsonResult.containsKey('brandId') ||
          !jsonResult.containsKey('modelId')) {
        return CodeReadApiResult(error: 'Equipamento não encontrado.');
      } else {
        final tracker = Tracker()
          ..serial = jsonResult["serial"]
          ..modelId = jsonResult["modelId"]
          ..brandId = jsonResult["brandId"]
          ..installationLocal = jsonResult["installationLocal"];

        return CodeReadApiResult(tracker: tracker);
      }
    } else {
      if (response != null) {
        try {
          await _checkRefreshTokenNeeded(response);
        } catch (e) {
          print(e);

          return CodeReadApiResult(
            tracker: Tracker(
              serial: codeRead,
            ),
            error: 'Token inválido.\nRefaça login no aplicativo.',
          );
        }
      }

      return CodeReadApiResult(
        tracker: Tracker(
          serial: codeRead,
        ),
        error: 'Erro de conexão. Preencha manualmente.',
      );
    }
  }

  @override
  Future<AutomatedTest> getTrackerAutomatedTest(String identifier) async {
    var response = await Http.get(
      Uri.parse(urlBase + "/v1/flow/tracker/$identifier/unregistered"),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);

      var returned = AutomatedTest(
        latitude: double.tryParse(jsonResult['latitude'] ?? ''),
        longitude: double.tryParse(jsonResult['longitude'] ?? ''),
        gsmLevel: jsonResult['gsmLevel'],
        loraLevel: jsonResult['loraLevel'],
        date: DateTime.fromMillisecondsSinceEpoch(jsonResult['date']),
      );

      return returned;
    } else {
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<PhotosForInstallation> getPhotosForInstallation(
      int installationId) async {
    var response = await Http.get(
      Uri.parse(urlBase + "/v2/flow/installation/files/$installationId"),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      printDebug('Photos for installation $installationId: $jsonResult');
      return PhotosForInstallation.fromJson(jsonResult);
    } else {
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<String> sendInstallation(Installation installation) async {
    printDebug('Sending installation ${installation.appId} to cloud...');
    var installationJsonToSend = json.encode(installation.toJson());
    String message = "Ocorreu um erro ao enviar a instalação";
    var url = urlBase + '/v1/flow/techinicalvisit/finish';
    printDebug(url);
    printDebug('Json to send: ');
    var response = await Http.post(
      // urlBase + '/v1/flow/installation',
      Uri.parse(url),
      headers: await _authHeader(),
      body: installationJsonToSend,
    );
    var jsonDecoded = json.decode(installationJsonToSend);
    JsonEncoder.withIndent(' ').convert(jsonDecoded).split('\n').forEach(print);
    print(
        'Sending installation ${installation.appId} response: ${response.body}');

    printDebug('QUAL FOI O STATUS CODE: ${response.statusCode}');
    var jsonResult = json.decode(response.body);
    if (response.statusCode == 200) {
      return "";
    } else {
      if (jsonResult['customError'] != null) {
        message = jsonResult['customError']["messageText"];
        throw InstallationRefusedException(message);
      } else {
        await _checkRefreshTokenNeeded(response);
      }

      return message;
    }
  }

  @Deprecated('Método não utilizado')
  Future<bool> sendInstallationFinalChecklistPhoto(
      int installationId,
      File file,
      ) async {
    try {
      String url = Uri.parse(urlBase +
          "/v1/flow/installation/$installationId/photo/finalChecklist")
          .toString();

      print("Processing local photo...");
      var jpgByteArray =
      await processPhoto(file); //await compute(processPhoto, file);
      print(
          "Trying to send photo of size ${(jpgByteArray.length / 1024).floor()} Kb");

      Http.Response response = await Http.put(
        Uri.parse(url),
        headers: await _authHeader(contentType: "image/jpeg"),
        body: jpgByteArray,
      );

      print("Resposta da foto: ${response.statusCode} -> ${response.body}");
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error uploading photo: $e");
    }

    return false;
  }

  @override
  Future<int> sendInstallationPicture(
      int technicalVisitId,
      String featureId,
      String fileKey,
      File file,
      ) async {
    // Uri.parse(urlBase +
    //         '/v1/flow/installation/$installationId/custom/photo/$pictureId')
    //     .toString();
    var uri = Uri.parse(urlBase +
        "/v1/flow/installation/$technicalVisitId/technicalvisit/$featureId/$fileKey");

    final openFile = await file.readAsBytes();

    print(
        "Trying to send photo of size ${(openFile.length / 1024).floor()} Kb");

    Http.Response response = await Http.put(
      uri,
      headers: await _authHeader(contentType: "image/jpeg"),
      body: openFile,
    );

    print("Resposta da foto: ${response.statusCode} -> ${response.body}");

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      var id = jsonResult['fileId'];
      return id;
    } else {
      return null;
    }
  }

  _checkRefreshTokenNeeded(Http.Response response) async {
    if (response.statusCode == 401 && response.body.contains("invalid_token")) {
      await _performRefreshToken();
    } else {
      throw Exception("${response.body}");
    }
  }

  Future<Http.Response> performLogin(
      String email,
      String password,
      ) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    var heads = {
      "Authorization": _auth,
      "Client": "flow",
      "Version": packageInfo.version
    };

    var response = await Http.post(
      Uri.parse(DenoxRequests.urlBase + "/oauth/token"),
      headers: heads,
      body: {
        "username": "$email",
        "password": "$password",
        "grant_type": "password",
      },
    ).timeout(Duration(seconds: 10));

    var decode = json.decode(response.body);

    var accessToken = decode["access_token"];
    var refreshToken = decode["refresh_token"];

    await _appDataRepository.setAccessToken(accessToken);
    await _appDataRepository.setRefreshToken(refreshToken);

    return response;
  }

  _performRefreshToken() async {
    var token = await _appDataRepository.getRefreshToken();
    print("Realizando refresh token com $token");
    var heads = {"Authorization": _auth};

    var refreshToken = token;
    var response = await Http.post(
      Uri.parse(DenoxRequests.urlBase + "/oauth/token"),
      headers: heads,
      body: {
        "refresh_token": refreshToken,
        "grant_type": "refresh_token",
      },
    );

    if (response.statusCode == 200) {
      var decode = json.decode(response.body);

      assert(() {
        print(decode);
        return true;
      }());

      _appDataRepository.setAccessToken(decode["access_token"]);
      _appDataRepository.setRefreshToken(decode["refresh_token"]);
      throw Exception("${response.body}");
    } else {
      print("Error on refresh_token: ${response.body}");
      throw RefreshTokenException("${response.body}");
    }
  }

  @override
  Future<Tracker> addTrackerTechnicalVisit(int technicalVisitEditId,
      DeviceController tracker, int installationLocal) async {
    String url = "/v1/flow/techinicalvisit/equipment/add";
    Http.Response response = await Http.put(
      Uri.parse(urlBase + url),
      headers: await _authHeader(),
      body: jsonEncode({
        "serial": tracker.serial,
        "deviceId": tracker.deviceId,
        "technicalVisitId": technicalVisitEditId,
        "installationLocal": installationLocal,
      }),
    );

    print({
      "serial": tracker.serial,
      "deviceId": tracker.deviceId,
      "technicalVisitId": technicalVisitEditId,
      "installationLocal": installationLocal,
    });

    print("Resposta da api: ${response.statusCode} -> ${response.body}");
    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      return Tracker.fromJson(jsonResult);
    } else {
      return Tracker(serial: "Error");
    }
  }

  @override
  Future<Tracker> addTrackerTechnicalVisitV3(int technicalVisitEditId, Slot slot) async {
    String url = "/v2/flow/technicalvisit/equipment/add";
    Http.Response response = await Http.put(
      Uri.parse(urlBase + url),
      headers: await _authHeader(),
      body: jsonEncode({
        "serial": slot.serial,
        "deviceId": slot.operation == OperationEquipmentEnum.ADD.id ? null : slot.deviceId,
        "technicalVisitId": technicalVisitEditId,
        "installationLocal": slot?.installationLocalId,
        "hardwareFeatureId": slot?.hardwareFeature?.id,
        "peripheralId": slot?.peripheral?.id,
        "groupId": slot?.group?.id,
        "deviceParentId": slot?.parentId,
        "virtual": slot.virtual,
        "equipmentId": slot?.equipment?.id
      }),
    );

    print("Resposta da api: ${response.statusCode} -> ${response.body}");
    var jsonResult = json.decode(response.body);
    if (response.statusCode == 200) {
      return Tracker.fromJson(jsonResult);
    } else {
      var customError = CustomError.fromJson(jsonResult['customError']);
      throw Exception('${customError.messageText}');
    }

  }

  @override
  Future<Tracker> addTrackerTechnicalVisitV2(int technicalVisitEditId, Tracker tracker) async {
    String url = "/v2/flow/technicalvisit/equipment/add";
    Http.Response response = await Http.put(
      Uri.parse(urlBase + url),
      headers: await _authHeader(),
      body: jsonEncode({
        "serial": tracker.serial,
        "deviceId": tracker.deviceId,
        "technicalVisitId": technicalVisitEditId,
        "installationLocal": tracker?.installationLocal,
        "hardwareFeatureId": tracker?.hardwareFeature?.id,
        "peripheralId": tracker?.peripheral?.id,
        "groupId": tracker.groupId,
        "deviceParentId": tracker.parent != null ? tracker.parent.deviceId : null,
        "virtual": tracker.virtual
      }),
    );

    print({
      "Adicionando tracker - serial": tracker.serial,
      "deviceId": tracker.deviceId,
      "technicalVisitId": technicalVisitEditId,
      "installationLocal": tracker?.installationLocal,
      "hardwareFeatureId": tracker?.hardwareFeature?.id,
      "peripheralId": tracker?.peripheral?.id,
      "groupId": tracker.groupId,
      "deviceParentId": tracker.parent != null ? tracker.parent.deviceId : null,
      "virtual": tracker.virtual
    });

    print("Resposta da api: ${response.statusCode} -> ${response.body}");
    var jsonResult = json.decode(response.body);
    if (response.statusCode == 200) {
      return Tracker.fromJson(jsonResult);
    } else {
      var customError = CustomError.fromJson(jsonResult['customError']);
      throw Exception('${customError.messageText}');
    }
  }

  @override
  Future<Tracker> changeTrackerTechnicalVisit(
      int technicalVisitEditId,
      DeviceController trackerOld,
      String serialNovo,
      int installationLocal) async {
    String url = urlBase + "/v1/flow/techinicalvisit/equipment/change";
    Http.Response response = await Http.post(
      Uri.parse(url),
      headers: await _authHeader(),
      body: jsonEncode({
        "serialOld": trackerOld.serial,
        "serialNew": serialNovo,
        "deviceId": trackerOld.deviceId,
        "technicalVisitId": technicalVisitEditId,
        "installationLocal": installationLocal,
      }),
    );

    print({
      "serialOld": trackerOld.serial,
      "serialNew": serialNovo,
      "deviceId": trackerOld.deviceId,
      "technicalVisitId": technicalVisitEditId,
      "installationLocal": installationLocal,
    });

    print("Resposta da api: ${response.statusCode} -> ${response.body}");
    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      return Tracker.fromJson(jsonResult);
    } else {
      return Tracker(serial: "Error");
    }
  }

  @override
  Future<Tracker> changeTrackerTechnicalVisitV2(
      int technicalVisitEditId,
      Tracker trackerOld,
      String serialNovo) async {

    String url = urlBase + "/v2/flow/technicalvisit/equipment/change";
    Http.Response response = await Http.post(
      Uri.parse(url),
      headers: await _authHeader(),
      body: jsonEncode({
        "serialOld": trackerOld.serial,
        "serialNew": serialNovo,
        "deviceId": trackerOld.deviceId,
        "technicalVisitId": technicalVisitEditId,
        "installationLocal": trackerOld?.installationLocal,
        "groupId": trackerOld.groupId
      }),
    );

    print({
      "serialOld": trackerOld.serial,
      "serialNew": serialNovo,
      "deviceId": trackerOld.deviceId,
      "technicalVisitId": technicalVisitEditId,
      "installationLocal": trackerOld?.installationLocal,
      "hardwareFeatureId": trackerOld?.hardwareFeature?.id,
      "peripheralId": trackerOld?.peripheral?.id,
      "groupId": trackerOld.groupId,
      "deviceParentId": trackerOld.parent != null ? trackerOld.parent.deviceId : null,
    });

    print("Resposta da api: ${response.statusCode} -> ${response.body}");
    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      return Tracker.fromJson(jsonResult);
    } else {
      var jsonResult = json.decode(response.body);
      var message = jsonResult['message'];
      throw Exception(message);
    }
  }

  @override
  Future<Tracker> changeTrackerTechnicalVisitV3(
      int technicalVisitEditId,
      Slot slot,
      String serialNew) async {

    String url = urlBase + "/v2/flow/technicalvisit/equipment/change";
    Http.Response response = await Http.post(
      Uri.parse(url),
      headers: await _authHeader(),
      body: jsonEncode({
        "serialOld": slot.serial,
        "serialNew": serialNew,
        "deviceId": slot.deviceId,
        "technicalVisitId": technicalVisitEditId,
        "installationLocal": slot?.installationLocalId,
        "groupId": slot.groupAlter != null ? slot.groupAlter.id : slot.group.id,
        "equipmentId": slot.equipmetAlter != null ? slot.equipmetAlter.id : slot.equipment != null ? slot.equipment.id : null
      }),
    );

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      return Tracker.fromJson(jsonResult);
    } else {
      var jsonResult = json.decode(response.body);
      var message = jsonResult['message'];
      throw Exception(message);
    }
  }

  @override
  Future<bool> deleteTrackerTechnicalVisit(int technicalVisitEditId, String serial, int deviceId) async {
    Uri uri = Uri.parse(urlBase + "/v1/flow/techinicalvisit/equipment/delete");
    var request = Http.Request("DELETE", uri);
    request.headers.addAll(await _authHeader());
    request.body = jsonEncode({
      "serial": serial,
      "deviceId": deviceId,
      "technicalVisitId": technicalVisitEditId,
    });

    final response = await request.send();
    print(response);
    if (response.statusCode == 200)
      return true;
    else {
      print("error: status code ${response.statusCode} -> ${request.body}");
      return false;
    }
  }

  @override
  Future<bool> deleteTrackerSlot(int deviceId) async {
    Uri uri = Uri.parse(urlBase + "/v1/flow/technicalvisit/removeslot");
    var request = Http.Request("DELETE", uri);
    request.headers.addAll(await _authHeader());
    request.body = jsonEncode({
      "deviceId": deviceId,
    });

    final response = await request.send();
    print(response);
    if (response.statusCode == 200)
      return true;
    else {
      print("error: status code ${response.statusCode} -> ${request.body}");
      return false;
    }
  }

  @override
  Future<CompanyList> getCompanyList() async {
    // incluir companyId como parametro na chamada
    var url = urlBase + "/v1/flow/account/company";

    print('Getting CompanyList $url');

    var response = await Http.get(
      Uri.parse(url),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      Map jsonResult = json.decode(response.body);
      print('Received CompanyList with success!');
      jsonResult.printAsJsonPretty();

      return CompanyList.fromJson(jsonResult);
    } else {
      print("Get CompanyList fail: [${response.statusCode}]" +
          urlBase +
          response.body);
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<CompanyConfig> getCompanyConfig() async {
    var companyId = selectedCompany?.id;
    var url =
        urlBase + "/v1/flow/installationtypes?companyId=$companyId&type=I";
    print(url);
    // var url = "https://run.mocky.io/v3/03f49c60-34a4-4a93-9f22-6c563a462e5c";
    // var response = await Http.get(url);

    var response = await Http.get(
      Uri.parse(url),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      print("Company Config Recebido com sucesso!");
      // JsonEncoder.withIndent(' ')
      //     .convert(jsonResult)
      //     .split('\n')
      //     .forEach(print);
      var returned = CompanyConfig.fromJson(jsonResult);
      return returned;
    } else {
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  @override
  Future<InstallationStart> startInstallationCargo(
      LatLong latLong,
      int installationTypeId,
      int companyId,
      int customerId,
      String visitTypeId,
      String serial,
      String qrCode) async {
    var cmpId = companyId;
    if (companyId == null) cmpId = selectedCompany.id;

    var url = urlBase + "/v1/flow/technicalvisit/cargo/start";
    var response = await Http.post(Uri.parse(url),
        headers: await _authHeader(),
        body: json.encode(
          {
            "companyId": cmpId,
            "installationTypeId": installationTypeId,
            "latitude": latLong.latitude,
            "longitude": latLong.longitude,
            "customerId": customerId,
            "serial": serial,
            "qrCode": qrCode,
            "visitTypeId": visitTypeId
          },
        ));
    print(url);
    var jsonResult = json.decode(response.body);

    if (response.statusCode == 200) {
      var installationStart = InstallationStart.fromJson(jsonResult);
      return installationStart;
    } else {
      try {
        await _checkRefreshTokenNeeded(response);
        return InstallationStart(error: jsonResult['message']);
      } catch (e) {
        print(jsonResult['message']);
        return InstallationStart(error: jsonResult['message']);
      }
    }
  }

  @override
  Future<InstallationStart> startInstallation(LatLong latLong, int installationTypeId, int companyId) async {
    var cmpId = companyId;
    if (companyId == null) cmpId = selectedCompany.id;

    var url = urlBase + "/v3/flow/technicalvisit/start";
    var response = await Http.post(Uri.parse(url),
        headers: await _authHeader(),
        body: json.encode({
          "id": installationTypeId,
          "companyId": cmpId,
          "latitude": latLong.latitude,
          "longitude": latLong.longitude,
        })
    );
    print(url);
    var jsonResult = json.decode(response.body);
    if (response.statusCode == 200) {
      var installationStart = InstallationStart.fromJson(jsonResult);
      _updateInstallationStart(installationStart);
      return installationStart;
    } else {
      try {
        await _checkRefreshTokenNeeded(response);
        return InstallationStart(
            error: "Erro ao conectar com o sistema para iniciar a instalação");
      } catch (e) {
        print(jsonResult['message']);
        return InstallationStart(error: jsonResult['message']);
      }
    }
  }

  Future<BetterInt> cancelInstallation(int installationId, int reasonId,
      String observation, double latitutde, double longitude) async {
    Uri uri = Uri.parse(urlBase + "/v2/flow/technicalvisit/cancel");
    var request = Http.Request("DELETE", uri);
    request.headers.addAll(await _authHeader());
    request.body = jsonEncode({
      "id": installationId,
      "reasonId": reasonId,
      "observation": observation,
      "latitude": latitutde,
      "longitude": longitude
    });

    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    final jsonResult = json.decode(respStr);

    if (response.statusCode == 200)
      return BetterInt(intValue: 1);
    else {
      var customError = CustomError.fromJson(jsonResult['customError']);

      if (customError != null) {
        return BetterInt(
            intValue: customError.messageCode,
            errorMessage: customError.messageText);
      } else {
        return BetterInt(intValue: response.statusCode, errorMessage: respStr);
      }
    }
  }

  @override
  Future<String> getVisityTypeByDevice(String serial, String qrCode) async {
    var body = json.encode(
      {"serial": serial, "qrCode": qrCode},
    );
    var url = urlBase + "/v1/flow/technicalvisit/cargo/visittype";
    var response = await Http.post(
      Uri.parse(url),
      headers: await _authHeader(),
      body: body,
    );
    print(url);

    var jsonResult = json.decode(response.body);

    if (response.statusCode == 200) {
      var visitType = jsonResult['visitType'];
      return visitType;
    } else {
      try {
        await _checkRefreshTokenNeeded(response);
        return null;
      } catch (e) {
        print(jsonResult['message']);
        return null;
      }
    }
  }

  // O técnico inicia a visita sem haver agendamento prévio
  @override
  Future<BetterInt> startNewInstallation(
      LatLong latLong, int installationTypeId, int customerId) async {
    var companyId = selectedCompany.id;

    var body = json.encode(
      {
        "installationTypeId": installationTypeId,
        "companyId": companyId,
        "latitude": latLong.latitude,
        "longitude": latLong.longitude,
        "customerId": customerId,
      },
    );
    var url = urlBase + "/v1/flow/technicalvisit/new";
    var response = await Http.post(
      Uri.parse(url),
      headers: await _authHeader(),
      body: body,
    );
    print(url);

    var jsonResult = json.decode(response.body);
    JsonEncoder.withIndent(' ').convert(jsonResult).split('\n').forEach(print);
    print("Installation Start New: [${response.statusCode}] $jsonResult");
    if (response.statusCode == 200) {
      var id = jsonResult['id'];
      return BetterInt(intValue: id, errorMessage: null);
    } else {
      try {
        await _checkRefreshTokenNeeded(response);
        return BetterInt(
            intValue: null,
            errorMessage:
            "Erro ao conectar com o sistema para iniciar a instalação");
      } catch (e) {
        print(jsonResult['message']);
        return BetterInt(
            intValue: null,
            errorMessage:
            jsonResult['message'].toString().replaceAll("<br/>", "\n"));
      }
    }
  }

  @override
  Future<String> getVCCAMBySerial(
      int technicalVisitId, String serial, int thumb) async {
    var url = urlBase +
        "/v1/flow/technicalvisit/vccam/$technicalVisitId/$serial/$thumb";
    var response = await Http.get(
      Uri.parse(url),
      headers: await _authHeader(),
    );

    printDebug(url);
    var jsonResult = json.decode(response.body);
    if (response.statusCode == 200) {
      var returned = jsonResult["url"];
      return returned;
    } else {
      try {
        await _checkRefreshTokenNeeded(response);
        return null;
      } catch (e) {
        print(jsonResult['message']);
        return null;
      }
    }
  }

  @override
  Future<ListCams> getCamsByTechnicalVisitId(int technicalVisitId) async {
    var url = urlBase + "/v1/flow/technicalvisit/camdvr/$technicalVisitId";
    var response = await Http.get(
      Uri.parse(url),
      headers: await _authHeader(),
    );

    printDebug(url);
    var jsonResult = json.decode(response.body);
    if (response.statusCode == 200) {
      var returned = ListCams.fromJson(jsonResult);
      return returned;
    } else {
      try {
        await _checkRefreshTokenNeeded(response);
        return null;
      } catch (e) {
        print(jsonResult['message']);
        return null;
      }
    }
  }

  @override
  Future<ListCams> getUrlPathEvidenceDVR(
      int technicalVisitId, String serial, ListCams cams) async {
    //localId = 3000876;
    var camsList = json.encode(cams.toJson());
    var url = urlBase +
        "/v1/flow/technicalvisit/camdvr/evidence/$technicalVisitId/$serial";

    try {
      var response = await Http.post(Uri.parse(url),
          headers: await _authHeader(), body: camsList);

      var jsonResult = json.decode(response.body);
      if (response.statusCode == 200) {
        var returned = ListCams.fromJson(jsonResult);
        return returned;
      } else {
        try {
          await _checkRefreshTokenNeeded(response);
          return null;
        } catch (e) {
          print(jsonResult['message']);
          return null;
        }
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<TestInfo> startEquipmentTest(TestInfo testInfo) async {
    testInfo.statusDate = new DateTime.now();
    var testInfoJSON = json.encode(testInfo.toJson());
    var url = urlBase + "/v1/flow/technicalvisit/equipmenttest";
    var response = await Http.post(
      Uri.parse(url),
      headers: await _authHeader(),
      body: testInfoJSON,
    ).timeout(30.seconds);
    printDebug(url);
    var jsonResult = json.decode(response.body);

    if (response.statusCode == 200) {
      var returned = TestInfo.fromJson(jsonResult);
      returned.statusDate = new DateTime.now();
      return returned;
    } else {
      try {
        await _checkRefreshTokenNeeded(response);
        testInfo.status = TestStatus.Error;
        return testInfo;
      } catch (e) {
        print(jsonResult['message']);
        testInfo.status = TestStatus.Error;
        return testInfo;
      }
    }
  }

  @override
  Future<TestInfo> updateEquipmentTest(TestInfo testInfo) async {
    testInfo.statusDate = new DateTime.now();
    var testInfoJSON = json.encode(testInfo.toJson());
    var url = urlBase + "/v1/flow/technicalvisit/updateequipmenttest";
    var response = await Http.post(
      Uri.parse(url),
      headers: await _authHeader(),
      body: testInfoJSON,
    );
    printDebug(url);
    var jsonResult = json.decode(response.body);

    if (response.statusCode == 200) {
      var returned = TestInfo.fromJson(jsonResult);
      returned.statusDate = new DateTime.now();
      return returned;
    } else {
      try {
        await _checkRefreshTokenNeeded(response);
        return TestInfo(status: -1);
      } catch (e) {
        print(jsonResult['message']);
        return TestInfo(status: -1);
      }
    }
  }

  @override
  Future<String> saveEvidenceCamTest(
      String pathImage, int technicalVisitId, String key) async {
    final ByteData imageData =
    await NetworkAssetBundle(Uri.parse(pathImage)).load("");
    final Uint8List openFile = imageData.buffer.asUint8List();

    var url = urlBase +
        "/v1/flow/technicalvisit/saveevidencecamtest/$technicalVisitId/$key";

    Http.Response response = await Http.put(
      Uri.parse(url),
      headers: await _authHeader(contentType: "image/jpg"),
      body: openFile,
    );

    var jsonResult = json.decode(response.body);

    if (response.statusCode == 200) {
      var returned = jsonResult["url"];
      return returned;
    } else {
      try {
        await _checkRefreshTokenNeeded(response);
        return null;
      } catch (e) {
        print(jsonResult['message']);
        return null;
      }
    }
  }

  @override
  Future<String> getEvidenceDVRCamTest(
      TechnicalVisitCam cam, int technicalVisitId) async {
    final ByteData imageData =
    await NetworkAssetBundle(Uri.parse(cam.path)).load("");
    final Uint8List openFile = imageData.buffer.asUint8List();

    var url = urlBase +
        "/v1/flow/technicalvisit/saveevidencecamtest/$technicalVisitId/TEST_DVRCAM";

    Http.Response response = await Http.put(
      Uri.parse(url),
      headers: await _authHeader(contentType: "image/jpg"),
      body: openFile,
    );

    var jsonResult = json.decode(response.body);

    if (response.statusCode == 200) {
      var returned = jsonResult["url"];
      return returned;
    } else {
      try {
        await _checkRefreshTokenNeeded(response);
        return null;
      } catch (e) {
        print(jsonResult['message']);
        return null;
      }
    }
  }

  @override
  Future<List<Slot>> getSlotsByTechnicalVisit({int technicalVisitId}) async {
    printDebug('Buscando slots por visita técnica $technicalVisitId');

    var url = urlBase + "/v1/flow/technicalvisit/slots?technicalVisitId=$technicalVisitId";

    var response = await Http.get(
      Uri.parse(url),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
      return parsed.map<Slot>((json) => Slot.fromJson(json)).toList();
    } else {
      print("Listing devices fail: [${response.statusCode}]" + response.body);
      await _checkRefreshTokenNeeded(response);
      return null;
    }
  }

  Future<void> _updateInstallationStart(InstallationStart installationStart) async {

    if(installationStart.installationTypes.infoData != null) {

      var featureDeviceV3 = installationStart.installationTypes.infoData.features.firstWhere(
            (feature) => feature.featureType.id == 'DEVICE_V3',
        orElse: () => null,
      );

      if(featureDeviceV3 != null) {

        for (var i = 0; i < installationStart.installationTypes.config.features.length; i++) {

          var feature = installationStart.installationTypes.config.features[i];

          if (feature.featureType.id == 'DEVICE' || feature.featureType.id == 'DEVICE_NEW') {

            var featureDevice = installationStart.installationTypes.config.features[i];

            featureDeviceV3.order = featureDevice.order;

            installationStart.installationTypes.config.features[i] = featureDeviceV3;
          }

        }

      }

    }


  }

}

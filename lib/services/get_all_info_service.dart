import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flow_flutter/models/get_all_info.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:device_info_plus/device_info_plus.dart';

class GetAllInfoService {
  String appVersion;
  RequestsRepository requestsRepo;
  AppDataRepository appData;
  DevicesRepository devicesRepo;
  ChecklistRepository checklistRepo;
  PictureToTakeRepository picturesToTakeRepo;
  VehiclesRepository vehiclesRepo;
  CompanyConfigRepository companyConfigRepo;

  GetAllInfoService(
    this.appVersion,
    this.requestsRepo, {
    this.appData,
    this.devicesRepo,
    this.checklistRepo,
    this.picturesToTakeRepo,
    this.vehiclesRepo,
    this.companyConfigRepo,
  });

  Future<GetAllInfo> performGetAllInfo([
    bool performAllListing,
    bool awaitAllResponses = false,
  ]) async {
    var allInfo = requestsRepo.getAllInfo()
      ..then((info) {
        appData?.setCustomers(info.customers);
        appData?.setConfiguration(info.configuration);
      });

    if (performAllListing) {
      Future deviceFuture;
      Future vehiclesFuture;
      // Future checklistsFuture;
      // Future picturesToTakeFuture;

      // CompanyConfig companyConfig = await performCompanyConfig(companyId);

      if (devicesRepo != null) {
        deviceFuture = performDeviceListing();
      }

      if (vehiclesRepo != null) {
        vehiclesFuture = performVehicleListing();
      }

      // if (checklistRepo != null) {
      //   checklistsFuture = performChecklistListing();
      // }

      // if (picturesToTakeRepo != null) {
      //   picturesToTakeFuture = performPicturesToTakeListing();
      // }

      if (awaitAllResponses) {
        await Future.wait([
          deviceFuture,
          vehiclesFuture,
          // checklistsFuture,
          // picturesToTakeFuture,
        ].filter((element) => element != null));
      }
    }

    return allInfo;
  }

  Future<bool> performPicturesToTakeListing() async {
    DateTime lastRequestDate;

    if (appVersion == await picturesToTakeRepo.getLastVersionRequest()) {
      lastRequestDate = await picturesToTakeRepo.getLastDateRequest();
    }

    return requestsRepo
        .getPicturesListing(lastRequestDate)
        .then((listing) async {
      if (listing != null) {
        var partition =
            listing.pictures.partition((element) => element.deleted);

        var itemsToDelete = partition.first;
        var itemsToAdd = partition.second;

        await picturesToTakeRepo
            .addPictures(itemsToAdd); //adicionar direto do installationtypes
        await picturesToTakeRepo.deletePictures(itemsToDelete); // manter?
        await picturesToTakeRepo
            .setLastDateRequest(listing.requestDate.toDateTime);
        await picturesToTakeRepo.setLastVersionRequest(appVersion);
        return true;
      } else {
        return false;
      }
    });
  }

  Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;  // Unique ID on Android
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor;  // Unique ID on iOS
    } else {
      // Outras plataformas podem ser adicionadas aqui
      throw Exception('Plataforma não suportada');
    }

    return deviceId;
  }

  Future<bool> performChecklistListing() async {
    DateTime lastRequestDate;

    if (appVersion == await checklistRepo.getLastVersionRequest()) {
      lastRequestDate = await checklistRepo.getLastDateRequest();
    }

    return requestsRepo
        .getChecklistListing(lastRequestDate)
        .then((listing) async {
      if (listing != null) {
        var partition = listing.items.partition((element) => element.deleted);

        var itemsToDelete = partition.first;
        var itemsToAdd = partition.second;

        await checklistRepo.addChecklistItems(itemsToAdd);
        await checklistRepo.deleteChecklistItems(itemsToDelete);
        await checklistRepo.setLastDateRequest(listing.requestDate.toDateTime);
        await checklistRepo.setLastVersionRequest(appVersion);

        return true;
      } else {
        return false;
      }
    });
  }

  Future<bool> performVehicleListing() async {
    DateTime lastRequestDate;

    if (appVersion == await vehiclesRepo.getLastVersionRequest()) {
      lastRequestDate = await vehiclesRepo.getLastDateRequest();
    }

    return requestsRepo
        .getVehicleListing(lastRequestDate)
        .then((listing) async {
      if (listing != null) {
        await vehiclesRepo.setBrands(listing.brands);
        await vehiclesRepo.setModels(listing.models);
        await vehiclesRepo.setLastDateRequest(listing.requestDate.toDateTime);
        await vehiclesRepo.setLastVersionRequest(appVersion);
        return true;
      } else {
        return false;
      }
    });
  }

  Future<bool> performDeviceListing() async {
    DateTime lastRequestDate;

    if (appVersion == await devicesRepo.getLastVersionRequest()) {
      lastRequestDate = await devicesRepo.getLastDateRequest();
    }

    return requestsRepo.getDeviceListing(lastRequestDate).then((listing) async {
      if (listing != null) {
        await devicesRepo.setBrands(listing.brands);
        await devicesRepo.setModels(listing.models);
        await devicesRepo.setLastDateRequest(listing.requestDate.toDateTime);
        await devicesRepo.setLastVersionRequest(appVersion);
        return true;
      } else {
        return false;
      }
    });
  }
}

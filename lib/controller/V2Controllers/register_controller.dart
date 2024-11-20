import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flow_flutter/models/car_api_response.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/models/nfe_api_response.dart';
import 'package:flow_flutter/models/uf_city_Listing.dart';
import 'package:flow_flutter/models/vehicle_listing.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/installation_step.dart';

class RegisterController with InstallationPart<RegisterConfig> {
  RequestsRepository requestsRepository;
  String id;
  int technicalVisitId;

  RecordType recordType;
  List<AditionalFields> _aditionalFields;
  bool isVehicle;
  String _modelName;
  String _plate;
  String _plateSync;
  String _year;
  String _state;
  String _stateName;
  String _color;
  String _chassis;
  String _modelYear;
  String _cityName;
  String _brandName;
  String _odometer;
  String localTypeId;
  String _fleetId;
  Uf _uf;
  City _city;
  Brand _brand;
  Model _model;
  String vehicleTypeId;

  int _modelId;
  int _vehicleId;

  final VehicleBrandListing brands;
  VehicleModelListing models;
  final UfListing states;
  CityListing cities;

  bool isEditable;

  RegisterController(
      {
        this.technicalVisitId,
        VehicleInfo currentInfo,
        String name,
        List<AditionalFields> aditionalFields,
        this.isVehicle,
        this.brands,
        this.models,
        this.states,
        this.cities,
        this.isEditable = true,
        this.recordType,
        this.id,
        this.requestsRepository,
        this.localTypeId,
        this.vehicleTypeId
      }
  ) {
    this.name = name;
    print(currentInfo.toString());
    _aditionalFields = aditionalFields != null ? aditionalFields : [];
    _modelName = currentInfo?.modelName;
    if (localTypeId != 'G') _plate = currentInfo?.plate;
    _year = currentInfo?.year;
    _state = currentInfo?.stateName;
    _stateName =
        (currentInfo?.stateName != null && currentInfo.stateName.trim().isNotEmpty)
            ? getStateNameByAcronym(currentInfo.stateName)
            : null;
    _color = currentInfo?.color;
    _chassis = currentInfo?.chassis;
    _modelYear = currentInfo?.modelYear;
    _cityName = currentInfo?.cityName;
    _brandName = currentInfo?.brand;
    _odometer = currentInfo?.odometer;
    _fleetId = currentInfo?.fleetId;
    _uf = getUfById(currentInfo?.ufId);
    _city = new City(id: currentInfo?.cityId);
    _brand = getBrandById(currentInfo?.brandId);
    _model = getModelById(currentInfo?.modelId);

    updateReady();
  }

  Future<void> initialize() async {
    await updateCities(_uf?.id);
    _city = getCityById(_city.id);

    updateReady();
  }

  String get modelName => _modelName;

  set modelName(String model) {
    if (isEditable) {
      _modelName = model;
    }
    updateReady();
  }

  String get plate => _plate;

  set plate(String plate) {
    if (isEditable) {
      _plate = plate;
    }
    updateReady();
  }

  String get year => _year;

  set year(String year) {
    if (isEditable) {
      _year = year;
    }
    updateReady();
  }

  String get state => _state;

  set state(String state) {
    if (isEditable) {
      _state = state;
    }
    updateReady();
  }

  String get stateName => _stateName;

  set stateName(String stateName) {
    if (isEditable) {
      _stateName = stateName;
    }
  }

  Uf get uf => _uf;

  set uf(Uf uf) {
    if (isEditable) {
      _uf = uf;
    }
  }

  City get city => _city;

  set city(City city) {
    if (isEditable) {
      _city = city;
    }
  }

  Brand get brand => _brand;

  set brand(Brand brand) {
    if (isEditable) {
      _brand = brand;
    }
  }

  Model get model => _model;

  set model(Model model) {
    if (isEditable) {
      _model = model;
    }
    updateReady();
  }

  int get modelId => _modelId;

  set modelId(int modelId) {
    if (isEditable) {
      _modelId = modelId;
    }
  }

  String get color => _color;

  set color(String color) {
    if (isEditable) {
      _color = color;
    }
    updateReady();
  }

  String get chassis => _chassis;

  set chassis(String chassis) {
    if (isEditable) {
      _chassis = chassis;
    }
    updateReady();
  }

  int get vehicleId => _vehicleId;

  set vehicleId(int vehicleId) {
    if (isEditable) {
      _vehicleId = vehicleId;
    }
  }

  String get modelYear => _modelYear;

  set modelYear(String modelYear) {
    if (isEditable) {
      _modelYear = modelYear;
    }
    updateReady();
  }

  String get cityName => _cityName;

  set cityName(String cityName) {
    if (isEditable) {
      _cityName = cityName;
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

  String get odometer => _odometer;

  set odometer(String odometer) {
    if (isEditable) {
      _odometer = odometer;
    }
    updateReady();
  }

  String get fleetId => _fleetId;

  set fleetId(String fleetId) {
    if (isEditable) {
      _fleetId = fleetId;
    }
    updateReady();
  }

  List<AditionalFields> get aditionalFields => _aditionalFields;

  set aditionalFields(List<AditionalFields> aditionalFields) {
    if (isEditable) {
      aditionalFields.forEach((element) {
        var index = aditionalFields.indexOf(element);
        _aditionalFields[index].value = element.value;
      });
    }
    updateReady();
  }

  void updateLocalInfoPlate() {
    if (technicalVisitId != null && plate != null && plate != _plateSync) {
      requestsRepository.updateLocalInfoPlate(technicalVisitId, plate);
      _plateSync = plate;
    }
  }

  void updateReady() {
    bool aditionalFieldsIsReady = true;
    print("update ready");

    if (aditionalFields != null) {
      aditionalFields.forEach((element) {
        if (element.required &&
            (element.value == null || element.value == "")) {
          print(element.name + ": é nulo");
          aditionalFieldsIsReady = false;
        }
      });
    }

    if (plate == null && isVehicle) {
      readyStream.add(
        ReadyState.notReady('Existem campos obrigatórios não preenchidos.'),
      );
    } else if ((!isVehicle || (plate.length >= 7 && plate.length <= 8)) && aditionalFieldsIsReady) {
      readyStream.add(ReadyState.ready());
    } else {
      readyStream.add(
        ReadyState.notReady('Existem campos obrigatórios não preenchidos.'),
      );
    }

    if(model == null && isVehicle) {
      readyStream.add(
        ReadyState.notReady('O modelo é obrigatório.'),
      );
    }

    if(year == null && isVehicle) {
      readyStream.add(
        ReadyState.notReady('O ano é obrigatório.'),
      );
    }

    if(year != null && year.length < 4 && isVehicle) {
      readyStream.add(
        ReadyState.notReady('O ano deve conter 4 caracteres.'),
      );
    }

    if(modelYear == null && isVehicle) {
      readyStream.add(
        ReadyState.notReady('O ano do modelo é obrigatório.'),
      );
    }

    if(modelYear != null && modelYear.length < 4 && isVehicle) {
      readyStream.add(
        ReadyState.notReady('O ano do modelo deve conter 4 caracteres.'),
      );
    }

    if(chassis != null && chassis.length < 17) {
      readyStream.add(
        ReadyState.notReady('O chassi deve conter 17 caracteres.'),
      );
    }

  }

  RegisterConfig build() {
    return RegisterConfig(
      currentInfo: VehicleInfo(
        color: color,
        modelYear: modelYear,
        modelName: modelName,
        plate: plate,
        brand: brandName,
        chassis: chassis,
        cityName: cityName,
        odometer: odometer,
        stateName: stateName,
        year: year,
        fleetId: fleetId,
        cityId: city?.id,
        ufId: uf?.id,
        modelId: model?.id,
        brandId: brand?.id,
        vehicleId: vehicleId
      ),
      aditionalFields: aditionalFields,
      recordType: recordType,
    );
  }

  Future<void> updateCities(int ufId) async {
    if (ufId != null) {
      cities = await requestsRepository.getCities(ufId);
    }
  }

  Future<void> updateModels(int brandId) async {
    if (brandId != null) {
        models = await requestsRepository.getModels(brandId);
    }
  }

  String getStateAcronymByName(String name) {
    return states.ufList.firstWhere((state) => state.name == name).acronym;
  }

  String getStateNameByAcronym(String acronym) {
    var stateFinded = states.ufList.firstWhere(
        (state) => (state.acronym == acronym || state.name == acronym),
        orElse: () => null);

    return stateFinded != null ? stateFinded.name : "";
  }

  Uf getUfById(int ufId) {
    return states.ufList.firstWhereOrNull((state) => state.id == ufId);
  }

  City getCityById(int cityId) {
    return cities.citiesList.firstWhereOrNull((city) => city.id == cityId);
  }

  Model getModelById(int modelId) {

    if(models == null || models.models == null) return null;

    return models.models.firstWhereOrNull((model) => model.id == modelId);
  }

  Brand getBrandById(int brandId) {

    if(brands == null || brands.brands == null) return null;

    return brands.brands.firstWhereOrNull((brand) => brand.id == brandId);
  }

  Future<CarApiResponse> getCarInfo(String plate, String fleetId, String chassis, File pictureFile) async {
    try {
      return await requestsRepository.getCarInfo(plate, fleetId, chassis, pictureFile, vehicleTypeId);
    } on TimeoutException catch (e) {
      print('Get car info timeout: $e');
      return null;
    } catch (e) {
      print('Get car info error: $e');
      return null;
    }
  }

  Future<NfeApiResponse> getNfeInfo(String value) async {
    try {
      return await requestsRepository.getNfeInfo(value);
    } catch (e) {
      print('Get nfe info error: $e');
      return null;
    }
  }
}

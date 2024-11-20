class CarApiResponse {
  int vehicleId;
  String chassis;
  String fleetId;
  String plate;
  int year;
  int yearModel;
  String color;
  int ufId;
  int cityId;
  int modelId;
  int brandId;
  String equipmentInstalled;
  bool pictureUnrecognized = false;
  String message;

  CarApiResponse();

  CarApiResponse.fromJson(Map<String, dynamic> json) {
    vehicleId = json['vehicleId'];
    chassis = json['chassis'];
    fleetId = json['fleetId'];
    plate = json['plate'];
    year = json['year'];
    yearModel = json['yearModel'];
    color = json['color'];
    ufId = json['ufId'];
    cityId = json['cityId'];
    modelId = json['modelId'];
    brandId = json['brandId'];
    equipmentInstalled = json['equipmentInstalled'];
  }
  
}
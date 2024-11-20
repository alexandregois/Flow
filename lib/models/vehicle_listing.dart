class VehicleBrandListing {
  
  List<Brand> brands;

  VehicleBrandListing.fromJson(Map<String, dynamic> json) {
    if (json['brandList'] != null) {
      brands = [];
      json['brandList'].forEach((v) {
        brands.add(new Brand.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.brands != null) {
      data['brandList'] = this.brands.map((v) => v.toJson()).toList();
    }
    return data;
  }

}

class VehicleModelListing {

  VehicleModelListing();
  
  List<Model> models;

  VehicleModelListing.fromJson(Map<String, dynamic> json) {
    if (json['modelList'] != null) {
      models = [];
      json['modelList'].forEach((v) {
        models.add(new Model.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.models != null) {
      data['modelList'] = this.models.map((v) => v.toJson()).toList();
    }
    return data;
  }

}

class VehicleListing {
  List<Brand> brands;
  List<Model> models;
  int requestDate;

  VehicleListing();

  VehicleListing.fromJson(Map<String, dynamic> json) {
    if (json['brands'] != null) {
      brands = [];
      json['brands'].forEach((v) {
        brands.add(new Brand.fromJson(v));
      });
    }
    if (json['models'] != null) {
      models = [];
      json['models'].forEach((v) {
        models.add(new Model.fromJson(v));
      });
    }
    requestDate = json['requestDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.brands != null) {
      data['brands'] = this.brands.map((v) => v.toJson()).toList();
    }
    if (this.models != null) {
      data['models'] = this.models.map((v) => v.toJson()).toList();
    }
    data['requestDate'] = this.requestDate;
    return data;
  }
}

class Brand {
  int id;
  String name;
  String fipeName;
  String key;
  String vehicleType;

  Brand();

  Brand.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    fipeName = json['fipeName'];
    key = json['key'];
    vehicleType = json['vehicleType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['fipeName'] = this.fipeName;
    data['key'] = this.key;
    data['vehicleType'] = this.vehicleType;
    return data;
  }

  @override
  String toString() => name;
}

class Model {
  int id;
  String name;
  String fipeName;
  int brandId;
  String key;

  Model({this.id, this.name, this.fipeName, this.brandId, this.key});

  Model.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    fipeName = json['fipeName'];
    brandId = json['brandId'];
    key = json['key'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['fipeName'] = this.fipeName;
    data['brandId'] = this.brandId;
    data['key'] = this.key;
    return data;
  }

  @override
  String toString() => name;
}

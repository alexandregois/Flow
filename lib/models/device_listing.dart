import 'package:flow_flutter/models/installation.dart';

class DeviceListing {
  List<Brand> brands;
  List<Model> models;
  List<Group> groups;
  int requestDate;
  List<Tracker> trackers;

  DeviceListing();

  DeviceListing.fromJson(Map<String, dynamic> json) {
    if (json['brands'] != null) {
      brands = [];
      json['brands'].forEach((v) {
        brands.add(new Brand.fromJson(v));
      });
    }
    if (json['groups'] != null) {
      groups = [];
      json['groups'].forEach((v) {
        groups.add(new Group.fromJson(v));
      });
    }
    if (json['models'] != null) {
      models = [];
      json['models'].forEach((v) {
        models.add(new Model.fromJson(v));
      });
    }
    if (json['devices'] != null) {
      trackers = [];
      json['devices'].forEach((device) {
        if(device['hardwareFeatureId'] != 'DVR_CAM_MOSAIC')
          trackers.add(new Tracker.fromJson(device));
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
    if (this.groups != null) {
      data['groups'] = this.groups.map((v) => v.toJson()).toList();
    }
    data['requestDate'] = this.requestDate;
    return data;
  }
}

class Brand {
  int id;
  String name;

  Brand();

  Brand.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }

  @override
  String toString() => name;
}

class Model {
  int id;
  String model;
  String name;
  int brandId;
  bool deleted;

  Model();

  Model.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    model = json['model'];
    name = json['name'];
    brandId = json['brandId'];
    deleted = json['deleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['model'] = this.model;
    data['name'] = this.name;
    data['brandId'] = this.brandId;
    data['deleted'] = this.deleted;
    return data;
  }

  @override
  String toString() => name;
}

class Group {
  int id;
  String name;

  Group();

  Group.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }

  @override
  String toString() => name;
}

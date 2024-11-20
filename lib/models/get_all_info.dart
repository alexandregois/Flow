import 'package:flow_flutter/models/customer.dart';

class GetAllInfo {
  int id;
  String name;
  String email;
  Configuration configuration;
  List<Customer> customers;

//  List<Null> uninstallation;

  int requestDate;

  GetAllInfo({
    this.id,
    this.name,
    this.email,
    this.requestDate,
    this.configuration,
  });

  GetAllInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    requestDate = json['requestDate'];
    configuration = json['configuration'] != null
        ? new Configuration.fromJson(json['configuration'])
        : null;
    if (json['uninstallation'] != null) {
//      uninstallation = new List<Null>();
//      json['uninstallation'].forEach((v) {
//        uninstallation.add(new Null.fromJson(v));
//      });
    }

    if (json['customers'] != null) {
      customers = [];
      json['customers'].forEach((v) {
        customers.add(Customer.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'name': this.name,
        'email': this.email,
        'requestDate': this.requestDate,
        if (this.configuration != null)
          'configuration': this.configuration.toJson(),
        if (this.customers != null)
          'customers': this.customers.map((v) => v.toJson()).toList(),
      };
}

class Configuration {
  bool mandatoryPictures;
  bool checklistEasyCheck;
  bool isTechnical;
  bool isReadyAnswer;
  bool isAsset;

  Configuration({this.mandatoryPictures, this.checklistEasyCheck});

  Configuration.fromJson(Map<String, dynamic> json) {
    mandatoryPictures = json['mandatoryPictures'];
    checklistEasyCheck = json['checklistEasyCheck'];
    isTechnical = json['technical'];
    isReadyAnswer = json['readyAnswer'];
    isAsset = json['asset'];
  }

  Map<String, dynamic> toJson() => {
        'mandatoryPictures': this.mandatoryPictures,
        'checklistEasyCheck': this.checklistEasyCheck,
        'technical': this.isTechnical,
        'readyAnswer': this.isReadyAnswer,
        'asset': this.isAsset
      };

  bool get checklistItemsRequired => !(checklistEasyCheck ?? false);
}

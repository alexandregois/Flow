class UfListing {
  List<Uf> ufList;

  UfListing.fromJson(Map<String, dynamic> json) {
    if (json['ufs'] != null) {
      ufList = [];
      json['ufs'].forEach((v) {
        ufList.add(new Uf.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.ufList != null) {
      data['ufs'] = this.ufList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Uf {
  int id;
  String acronym;
  String name;

  Uf({this.id, this.acronym, this.name});

  Uf.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    acronym = json['acronym'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['acronym'] = this.acronym;
    data['name'] = this.name;
    return data;
  }
}

class CityListing {
  List<City> citiesList = [];

  CityListing();

  CityListing.fromJson(Map<String, dynamic> json) {
    if (json['localities'] != null) {
      citiesList = [];
      json['localities'].forEach((v) {
        citiesList.add(new City.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.citiesList != null) {
      data['localities'] = this.citiesList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class City {
  int id;
  String cityName;

  City({this.id, this.cityName});

  City.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cityName = json['cityName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['cityName'] = this.cityName;
    return data;
  }
}

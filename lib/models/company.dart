class CompanyList {
  List<Companies> companies;

  CompanyList({this.companies});

  CompanyList.fromJson(Map<String, dynamic> json) {
    if (json['companies'] != null) {
      companies = <Companies>[];
      json['companies'].forEach((v) {
        companies.add(new Companies.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.companies != null) {
      data['companies'] = this.companies.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Companies {
  int id;
  String name;
  String logoURL;
  String technicalname;
  String color;
  bool createNewInstallation;

  Companies(
      {this.id,
      this.name,
      this.logoURL,
      this.technicalname,
      this.color,
      this.createNewInstallation});

  Companies.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logoURL = json['logoURL'];
    technicalname = json['technicalname'];
    color = json['color'];
    createNewInstallation = json['createNewInstallation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['logoURL'] = this.logoURL;
    data['technicalname'] = this.technicalname;
    data['color'] = this.color;
    data['createNewInstallation'] = this.createNewInstallation;
    return data;
  }
}

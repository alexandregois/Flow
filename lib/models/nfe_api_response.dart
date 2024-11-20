class NfeApiResponse {
  String ufCode;
  String ufName;
  String year;
  String month;
  String cnpj;
  String model;
  String serie;
  String number;
  String code;
  String digit;

  NfeApiResponse();

  NfeApiResponse.fromJson(Map<String, dynamic> json) {
    ufCode = json['ufCode'];
    ufName = json['ufName'];
    year = json['year'];
    month = json['month'];
    cnpj = json['cnpj'];
    model = json['model'];
    serie = json['serie'];
    number = json['number'];
    code = json['code'];
    digit = json['digit'];
  }
}

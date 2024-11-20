class Customer {
  int id;
  String name;
  String customerEmail;

  Customer();

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    customerEmail = json['customerEmail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['customerEmail'] = this.customerEmail;
    return data;
  }

  @override
  String toString() => name;
}

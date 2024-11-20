class TestInfoListing {
  List<TestInfoListingItem> items;
  int requestDate;

  TestInfoListing();

  TestInfoListing.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <TestInfoListingItem>[];
      json['items'].forEach((v) {
        items.add(new TestInfoListingItem.fromJson(v));
      });
    }
    requestDate = json['requestDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    data['requestDate'] = this.requestDate;
    return data;
  }
}

class TestInfoListingItem {
  int id;
  String name;
  int order = 0;
  int installationType;
  bool deleted = false;

  TestInfoListingItem();

  TestInfoListingItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    order = json['order'];
    installationType = json['installationType'];
    deleted = json['deleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['order'] = this.order;
    data['installationType'] = this.installationType;
    data['deleted'] = this.deleted;
    return data;
  }

  @override
  String toString() => name;
}

class PoiListing {
  List<Poi> items;
  int requestDate;

  PoiListing();

  PoiListing.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Poi>[];
      json['items'].forEach((v) {
        items.add(new Poi.fromJson(v));
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

class Poi {
  int id;
  String name;

  Poi();

  Poi.fromJson(Map<String, dynamic> json) {
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

class PicturesListing {
  int requestDate;
  List<Picture> pictures;

  PicturesListing({
    this.requestDate,
    this.pictures,
  });

  PicturesListing.fromJson(Map<String, dynamic> json) {
    requestDate = json['requestDate'];
    if (json['pictures'] != null) {
      pictures = [];
      json['pictures'].forEach((v) {
        pictures.add(new Picture.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['requestDate'] = this.requestDate;
    if (this.pictures != null) {
      data['pictures'] = this.pictures.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Picture {
  String id;
  String name;
  String description;
  int order = 0;
  int installationType;
  bool isCoverPicture;
  bool required = false;
  bool deleted = false;
  bool sent = false;
  bool observationRequired = false;
  bool onlyCameraSource = false;
  String observationDesc;
  String orientation;

  Picture();

  Picture.fromValues(
      {this.id,
      this.onlyCameraSource,
      this.name,
      this.description,
      this.order,
      this.installationType,
      this.required,
      this.deleted,
      this.sent,
      this.observationDesc,
      this.isCoverPicture,
      this.observationRequired,
      this.orientation}) {
    onlyCameraSource = onlyCameraSource;
    print("onlyCameraSource: $onlyCameraSource");
    id = id;
    name = name;
    description = description;
    order = order;
    sent = sent;
    isCoverPicture = isCoverPicture;
    // installationType = installationType;
    required = required;
    deleted = false;
    observationRequired = observationRequired;
    observationDesc = observationDesc;
    orientation = orientation;
  }

  // Picture.newCustom()
  //     : id = DateTime.now().millisecondsSinceEpoch,
  //       name = 'Foto personalizada',
  //       required = false,
  //       observationRequired = true;

  Picture.fromJson(Map<String, dynamic> json) {
    isCoverPicture = json['isCoverPicture'];
    id = json['key'];
    name = json['name'];
    description = json['description'];
    order = json['order'];
    installationType = json['installationType'];
    required = json['required'];
    deleted = json['deleted'];
    observationRequired = json['observationRequired'];
    observationDesc = json['observationDesc'];
    orientation = json['orientation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isCoverPicture'] = this.isCoverPicture;
    data['key'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['order'] = this.order;
    data['installationType'] = this.installationType;
    data['required'] = this.required;
    data['deleted'] = this.deleted;
    data['observationRequired'] = this.observationRequired;
    data['observationDesc'] = this.observationDesc;
    data['orientation'] = this.orientation;
    return data;
  }

  @override
  String toString() => '[$id] $name';
}

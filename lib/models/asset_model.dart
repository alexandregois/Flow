class AssetModel {
  final int id;
  final String identifier;
  final String fleetId;
  final AssetType type;
  final AssetModel assetParent;
  final Poi poi;
  final List<AssetChildResume> assetChildResumeList;
  final List<AssetModel> assetChildList;
  final String fileId;
  String fileUrl;

  AssetModel(
      {this.id,
      this.identifier,
      this.fleetId,
      this.type,
      this.assetParent,
      this.poi,
      this.assetChildResumeList,
      this.assetChildList,
      this.fileId,
      this.fileUrl});

  static List<AssetModel> fromJsonList(Map<String, dynamic> json) {
    return json['assetList'] != null
        ? json['assetList']
            .map((item) => AssetModel.fromJson(item))
            .toList()
            .cast<AssetModel>()
        : null;
  }

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return json == null || json.isEmpty
        ? null
        : AssetModel(
            id: json['id'],
            identifier: json['identifier'],
            fleetId: json['fleetId'],
            type: AssetType.fromJson(json['type']),
            assetParent: AssetModel.fromJson(json['assetParent']),
            poi: (json['poi'] == null || json['poi'].isEmpty)
                ? null
                : Poi.fromJson(json['poi']),
            assetChildResumeList: AssetChildResume.fromJsonList(json),
            assetChildList: AssetModel.fromJsonList(json),
            fileId: json['fileId']);
  }

  @override
  String toString() => "$identifier";

  @override
  operator ==(o) => o is AssetModel && o.id == id;

  @override
  int get hashCode => id.hashCode ^ identifier.hashCode;
}

class AssetType {
  final String name;
  final String icon;
  final String color;

  AssetType({this.name, this.icon, this.color});

  factory AssetType.fromJson(Map<String, dynamic> json) {
    return json == null || json.isEmpty
        ? null
        : AssetType(
            name: json['name'],
            icon: json['icon'],
            color: json['color'],
          );
  }
}

class Poi {
  final int id;
  final String name;
  final double latitude;
  final double longitude;

  Poi({this.id, this.name, this.latitude, this.longitude});

  factory Poi.fromJson(Map<String, dynamic> json) {
    return json == null
        ? null
        : Poi(
            id: json['id'],
            name: json['name'],
            latitude: json['latitude'],
            longitude: json['longitude'],
          );
  }
}

class AssetChildResume {
  final int count;
  final AssetType type;

  AssetChildResume({this.count, this.type});

  factory AssetChildResume.fromJson(Map<String, dynamic> json) {
    return AssetChildResume(
      count: json['count'],
      type: AssetType.fromJson(json['type']),
    );
  }

  static List<AssetChildResume> fromJsonList(Map<String, dynamic> json) {
    return json['assetChildResumeList'] != null
        ? json['assetChildResumeList']
            .map((item) => AssetChildResume.fromJson(item))
            .toList()
            .cast<AssetChildResume>()
        : null;
  }
}

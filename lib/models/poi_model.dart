class PoiModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;

  PoiModel({this.id, this.name, this.latitude, this.longitude});

  static List<PoiModel> fromJsonList(Map<String, dynamic> json) {
    return json['items'] != null
        ? json['items']
            .map((item) => PoiModel.fromJson(item))
            .toList()
            .cast<PoiModel>()
        : null;
  }

  factory PoiModel.fromJson(Map<String, dynamic> json) {
    return json == null || json.isEmpty
        ? null
        : PoiModel(
            id: json['id'],
            name: json['name'],
            latitude: json['latitude'],
            longitude: json['longitude']);
  }

  @override
  String toString() => "$id";

  @override
  operator ==(o) => o is PoiModel && o.id == id;

  @override
  int get hashCode => id.hashCode ^ id.hashCode;
}

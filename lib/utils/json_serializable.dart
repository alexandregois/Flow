abstract class JsonSerializable {
  Map<String, dynamic> toJson();

  void fromJson(Map<String, dynamic> json);
}

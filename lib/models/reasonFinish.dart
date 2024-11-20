class ReasonFinish {

  final int id;
  final String name;
  final String key;

  ReasonFinish({this.id, this.name, this.key});

  factory ReasonFinish.fromJson(Map<String, dynamic> json) {
    return ReasonFinish(
      id: json['id'],
      name: json['name'],
      key: json['key'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'key': key,
    };
  }
}

class ReasonFinishList {

  final List<ReasonFinish> reasons;
  ReasonFinishList({this.reasons});

  factory ReasonFinishList.fromJson(Map<String, dynamic> json) {
    var list = json['reasons'] as List;
    List<ReasonFinish> reasonList =
    list.map((i) => ReasonFinish.fromJson(i)).toList();

    return ReasonFinishList(reasons: reasonList);
  }


  Map<String, dynamic> toJson() {
    return {
      'reasons': reasons.map((e) => e.toJson()).toList(),
    };
  }
}

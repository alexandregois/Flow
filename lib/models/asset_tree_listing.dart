import 'package:list_treeview/list_treeview.dart';

class AssetTreeListing {
  AssetTreeNode asset;

  AssetTreeListing();

  AssetTreeListing.fromJson(Map<String, dynamic> json) {
    asset = AssetTreeNode.fromJson(json);
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   if (this.items != null) {
  //     data['items'] = this.items.map((v) => v.toJson()).toList();
  //   }
  //   data['requestDate'] = this.requestDate;
  //   return data;
  // }

}

class AssetTreeNode extends NodeData {
  int id;
  String name;
  String icon;
  String type;
  String color;
  String description;

  AssetTreeNode();

  AssetTreeNode.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    icon = json['icon'];
    type = json['type'];
    color = json['color'];
    description = json['description'];

    if (json['childs'] != null) {
      json['childs'].forEach((v) {
        addChild(new AssetTreeNode.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['icon'] = this.icon;
    data['type'] = this.type;
    data['color'] = this.color;
    data['description'] = this.description;
    return data;
  }

  @override
  String toString() => name;
}

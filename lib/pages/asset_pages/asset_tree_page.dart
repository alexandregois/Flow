import 'dart:math';

import 'package:flow_flutter/go_installation_icons_icons.dart';
import 'package:flow_flutter/models/asset_model.dart';
import 'package:flow_flutter/models/asset_tree_listing.dart';
import 'package:flow_flutter/pages/asset_pages/asset_selection_page.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/app_bar_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:list_treeview/list_treeview.dart';

class AssetTreePage extends StatefulWidget {
  final AssetModel asset;
  const AssetTreePage({Key key, this.asset}) : super(key: key);

  @override
  _AssetTreePageState createState() => _AssetTreePageState();
}

class _AssetTreePageState extends State<AssetTreePage> {
  TreeViewController _controller;
  List<Color> _colors = [];
  // PoiListing _pois;
  Future<AssetTreeNode> _asset;

  @override
  void initState() {
    super.initState();

    _controller = TreeViewController();

    for (int i = 0; i < 100; i++) {
      if (randomColor() != null) {
        _colors.add(randomColor());
      }
    }

    _asset =
        context.provide<RequestsRepository>().getAssetTreeNode(widget.asset.id);

    getData();
  }

  void getData() async {
    print('start get data');

    await Future.delayed(Duration(seconds: 2));

    // _pois = await context.provide<RequestsRepository>().getPoiListing();

    // var colors1 = TreeNodeData(label: 'Colors1');
    // var color11 = TreeNodeData(
    //     label: 'rgb(0,139,69)', color: Color.fromARGB(255, 0, 139, 69));
    // var color12 = TreeNodeData(
    //     label: 'rgb(0,139,69)', color: Color.fromARGB(255, 0, 191, 255));
    // var color13 = TreeNodeData(
    //     label: 'rgb(0,139,69)', color: Color.fromARGB(255, 255, 106, 106));
    // var color14 = TreeNodeData(
    //     label: 'rgb(0,139,69)', color: Color.fromARGB(255, 160, 32, 240));
    // colors1.addChild(color11);
    // colors1.addChild(color12);
    // colors1.addChild(color13);
    // colors1.addChild(color14);

    // var colors2 = TreeNodeData(label: 'Colors2');
    // var color21 = TreeNodeData(
    //     label: 'rgb(0,139,69)', color: Color.fromARGB(255, 255, 64, 64));
    // var color22 = TreeNodeData(
    //     label: 'rgb(0,139,69)', color: Color.fromARGB(255, 28, 134, 238));
    // var color23 = TreeNodeData(
    //     label: 'rgb(0,139,69)', color: Color.fromARGB(255, 255, 106, 106));
    // var color24 = TreeNodeData(
    //     label: 'rgb(0,139,69)', color: Color.fromARGB(255, 205, 198, 115));
    // colors2.addChild(color21);
    // colors2.addChild(color22);
    // colors2.addChild(color23);
    // colors2.addChild(color24);

    // /// set data

    print('set treeData suceess');
  }

  void selectAllChild(dynamic item) {
    _controller.selectAllChild(item);
  }

  Color getColor(int level) {
    return _colors[level % _colors.length];
  }

  Color randomColor() {
    int r = Random.secure().nextInt(200);
    int g = Random.secure().nextInt(200);
    int b = Random.secure().nextInt(200);
    return Color.fromARGB(255, r, g, b);
  }

  /// Add
//   void add(TreeNodeData dataNode) {
//     /// create New node
// //    DateTime time = DateTime.now();
// //    int milliseconds = time.millisecondsSinceEpoch ~/ 1000;
//     int r = Random.secure().nextInt(255);
//     int g = Random.secure().nextInt(255);
//     int b = Random.secure().nextInt(255);

//     var newNode = TreeNodeData(
//         label: 'rgb($r,$g,$b)', color: Color.fromARGB(255, r, g, b));

//     _controller.insertAtFront(dataNode, newNode);
// //    _controller.insertAtRear(dataNode, newNode);
// //    _controller.insertAtIndex(1, dataNode, newNode);
//   }

  void delete(dynamic item) {
    _controller.removeItem(item);
  }

  void select(dynamic item) {
    _controller.selectItem(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarFlow(title: "Árvore de Ativos"),
        body: FutureBuilder<AssetTreeNode>(
            future: _asset,
            builder:
                (BuildContext context, AsyncSnapshot<AssetTreeNode> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SpinKitWave(
                    color: Theme.of(context).colorScheme.secondary,
                    size: 30,
                  ),
                );
              }
              if (snapshot.hasData) {
                _controller.treeData([snapshot.data]);

                return ListTreeView(
                  controller: _controller,
                  shrinkWrap: false,
                  padding: EdgeInsets.all(0),
                  itemBuilder: (BuildContext context, NodeData data) {
                    AssetTreeNode item = data;
//              double width = MediaQuery.of(context).size.width;
                    double offsetX = item.level * 16.0;
                    return Container(
                      height: 54,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(width: 1, color: Colors.grey))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: offsetX),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: InkWell(
                                      splashColor:
                                          Colors.amberAccent.withOpacity(1),
                                      highlightColor: Colors.red,
                                      onTap: () {
                                        selectAllChild(item);
                                      },
                                      child: data.isSelected
                                          ? Icon(
                                              GoInstallationIcons.getIcon(
                                                  item.icon),
                                              color: _getColor(item.color),
                                              size: 30,
                                            )
                                          : Icon(
                                              GoInstallationIcons.getIcon(
                                                  item.icon),
                                              color: _getColor(item.color),
                                              size: 30,
                                            ),
                                    ),
                                  ),
                                  Text(
                                    item.type,
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: getColor(item.level)),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
//                          Text(
//                            '${item.label}',
//                            style: TextStyle(color: item.color),
//                          ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: item.isExpand,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return AssetSelectionPage();
                                  // return AssetEditPage(
                                  //   controller:
                                  //       AssetEditController(pois: _pois),
                                  //   // asset: asset,
                                  // );
                                }));
                                // add(item);
                              },
                              child: Icon(
                                Icons.add,
                                size: 30,
                              ),
                            ),
                          ),
                          item.isExpand
                              ? InkWell(
                                  onTap: () {
                                    _controller.expandOrCollapse(item.index);
                                    // Navigator.push(context,
                                    //     MaterialPageRoute(builder: (context) {
                                    //   return AssetEditPage(
                                    //     controller:
                                    //         AssetEditController(pois: _pois),
                                    //     // asset: asset,
                                    //   );
                                    // }));
                                    // add(item);
                                  },
                                  child: Icon(
                                    Icons.expand_more,
                                    size: 30,
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    _controller.expandOrCollapse(item.index);
                                    // Navigator.push(context,
                                    //     MaterialPageRoute(builder: (context) {
                                    //   return AssetEditPage(
                                    //     controller:
                                    //         AssetEditController(pois: _pois),
                                    //     // asset: asset,
                                    //   );
                                    // }));
                                    // add(item);
                                  },
                                  child: Icon(
                                    Icons.expand_less,
                                    size: 30,
                                  ),
                                ),
                        ],
                      ),
                    );
                  },
                  onTap: (NodeData data) {
                    print('index = ${data.index}');
                  },
                  onLongPress: (data) {
                    delete(data);
                  },
                );
              } else {
                return SizedBox();
              }
            }));
  }
}

_getColor(String color) {
  return HexColor.fromHex(color);
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
// class TreeNodeData extends NodeData {
//   TreeNodeData({this.label, this.color}) : super();

//   /// Other properties that you want to define
//   final String label;
//   final Color color;

//   String property1;
//   String property2;
//   String property3;

//   ///...
// }

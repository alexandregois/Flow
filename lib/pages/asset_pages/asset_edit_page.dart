import 'package:flow_flutter/go_installation_icons_icons.dart';
import 'package:flow_flutter/models/asset_model.dart';
import 'package:flow_flutter/models/poi_model.dart';
import 'package:flow_flutter/pages/asset_pages/asset_search_page.dart';
import 'package:flow_flutter/pages/asset_pages/poi_search_page.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/app_bar_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AssetEditPage extends StatefulWidget {
  final int assetId;

  const AssetEditPage({Key key, this.assetId}) : super(key: key);

  @override
  _AssetEditPageState createState() => _AssetEditPageState();
}

class _AssetEditPageState extends State<AssetEditPage> {
  Future<AssetModel> _asset;

  @override
  void initState() {
    super.initState();

    _updateAsset();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AssetModel>(
        future: _asset,
        builder: (BuildContext context, AsyncSnapshot<AssetModel> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitWave(
                color: Theme.of(context).colorScheme.secondary,
                size: 30,
              ),
            );
          } else if (snapshot.hasData) {
            AssetModel asset = snapshot.data;

            return Scaffold(
                appBar: AppBarFlow(
                  title: "Edição Ativo",
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(50),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 16, 5),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
                            child: Icon(
                              GoInstallationIcons.getIcon(asset.type.icon),
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  asset.identifier,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(asset.type.name,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold))
                              ],
                            ),
                          ),
                          asset.fleetId != null
                              ? Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            child: Text(
                                              asset.fleetId,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13),
                                            )),
                                      )
                                    ],
                                  ),
                                )
                              : SizedBox()
                        ],
                      ),
                    ),
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return AssetSearchPage();
                    })).then(
                      (assetModel) => this._addAsset(assetModel, asset.id),
                    );
                  },
                  tooltip: 'Adicionar ativo',
                  child: Icon(Icons.add),
                ),
                body: ListView(
                  padding: const EdgeInsets.all(8),
                  children: _getWidgets(
                      asset: asset,
                      addPoi: _addPoi,
                      deletePoi: _deletePoi,
                      updateAsset: _updateAsset),
                ));
          } else {
            return SizedBox();
          }
        });
  }

  void _addPoi(PoiModel poi, int assetId) {
    if (poi != null) {
      printDebug('Add POI poiid ' + poi.id.toString() + ', assetId: $assetId');

      context
          .provide<RequestsRepository>()
          .addPoiInAsset(poiId: poi.id, assetId: assetId)
          .then((response) => {
                if (response) {_updateAsset()}
              });
    }
  }

  void _addAsset(AssetModel assetChild, int assetId) {
    if (assetChild != null) {
      printDebug('Add Asset child id: ' +
          assetChild.id.toString() +
          ', assetId: $assetId');

      context
          .provide<RequestsRepository>()
          .addChildInAsset(assetChildId: assetChild.id, assetId: assetId)
          .then((response) => {
                if (response) {_updateAsset()}
              });
    }
  }

  void _deletePoi(int assetId) {
    if (assetId != null) {
      printDebug('Delete POI in assetId: $assetId');

      context
          .provide<RequestsRepository>()
          .deletePoiInAsset(assetId: assetId)
          .then((response) => {
                if (response) {_updateAsset()}
              });
    }
  }

  void _updateAsset() {
    setState(() {
      _asset = context
          .provide<RequestsRepository>()
          .getAsset(assetId: widget.assetId);
    });
  }
}

List<Widget> _getWidgets(
    {AssetModel asset,
    Function updateAsset,
    Function addPoi,
    Function deletePoi}) {
  List<Widget> list = [];

  if (asset.assetParent != null) {
    list.add(CardParent(
      asset: asset.assetParent,
      updateAsset: updateAsset,
    ));
  }

  // if (asset.poi != null) {
  //   list.add(CardPoi(
  //     poi: asset.poi,
  //   ));
  // }

  (asset.assetChildList != null && asset.assetChildList.length > 0)
      ? list.add(Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Text(
            'Ativos Relacionados',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ))
      : SizedBox();

  list.addAll(asset.assetChildList
      .map((assetChild) => CardChild(
            addPoi: addPoi,
            updateAsset: updateAsset,
            deletePoi: deletePoi,
            asset: assetChild,
          ))
      .toList());

  return list;
}

class CardParent extends StatelessWidget {
  final AssetModel asset;
  final Function updateAsset;

  const CardParent({Key key, @required this.asset, @required this.updateAsset})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(12.0)),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      GoInstallationIcons.getIcon(asset.type.icon),
                      color: getColor(asset.type.color),
                      size: 40,
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            asset.identifier,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        asset.fleetId != null
                            ? Container(
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    child: Text(
                                      asset.fleetId,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 13),
                                    )),
                              )
                            : SizedBox()
                      ],
                    ),
                    Text(
                      'Nível Superior - ' + asset.type.name,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                      icon: Icon(Icons.arrow_upward),
                      onPressed: () {
                        printDebug('On click menu poi');
                      }),
                ],
              )
            ],
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AssetEditPage(
                assetId: asset.id,
              );
            })).whenComplete(() => updateAsset());
          },
        ),
      ),
    );
  }
}

class CardPoi extends StatelessWidget {
  final Poi poi;

  const CardPoi({Key key, this.poi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      child: Card(
        child: InkWell(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 40,
                      color: Colors.green[300],
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ponto de desacoplamento',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      poi.name,
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () {
                        printDebug('On click menu poi');
                      }),
                ],
              )
            ],
          ),
          onTap: () {
            printDebug('On poi tap');
          },
        ),
      ),
    );
  }
}

class CardChild extends StatelessWidget {
  final Function addPoi;
  final Function deletePoi;
  final Function updateAsset;
  final AssetModel asset;

  const CardChild(
      {Key key,
      @required this.addPoi,
      @required this.deletePoi,
      @required this.updateAsset,
      @required this.asset})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: double.infinity),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: InkWell(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(12.0)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            GoInstallationIcons.getIcon(asset.type.icon),
                            color: getColor(asset.type.color),
                            size: 40,
                          )
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.identifier,
                          style: TextStyle(fontSize: 18),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(
                                asset.type.name,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          asset.fleetId != null
                              ? Container(
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      child: Text(
                                        asset.fleetId,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13),
                                      )),
                                )
                              : SizedBox()
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              asset.poi == null
                                  ? PopupMenuItem(
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_on_outlined),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Text('Incluir local'),
                                          )
                                        ],
                                      ),
                                      value: 1,
                                    )
                                  : null,
                              asset.poi != null
                                  ? PopupMenuItem(
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_off_outlined),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Text('Remover local'),
                                          )
                                        ],
                                      ),
                                      value: 2,
                                    )
                                  : null,
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(Icons.delete),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text('Remover Ativo'),
                                    )
                                  ],
                                ),
                                value: 3,
                              ),
                            ],
                            onSelected: (value) {
                              switch (value) {

                                //Add local
                                case 1:
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return PoiSearchPage();
                                  })).then(
                                    (poi) => this.addPoi(poi, asset.id),
                                  );
                                  break;

                                //Delete local
                                case 2:
                                  this.deletePoi(this.asset.id);
                                  break;
                                //Delete asset
                                case 3:
                                  print('Delete child click');
                                  context
                                      .provide<RequestsRepository>()
                                      .deleteChildInAsset(
                                          assetChildId: asset.id,
                                          assetId: asset.assetParent.id)
                                      .then((success) => {
                                            if (success) {updateAsset()}
                                          });
                                  break;

                                default:
                              }
                            },
                          )
                          // PopupMenuButton(itemBuilder: itemBuilder)
                          // IconButton(
                          //     icon: Icon(Icons.more_vert),
                          //     onPressed: () {
                          //       printDebug('On click menu child');
                          //     }),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              (asset.poi != null ||
                      (asset.assetChildResumeList != null &&
                          asset.assetChildResumeList.length > 0))
                  ? Divider(
                      thickness: 2,
                      color: Colors.grey[300],
                    )
                  : SizedBox(),
              asset.poi != null
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 8, 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.green[300],
                                  size: 30,
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: Text(
                              asset.poi.name,
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        ],
                      ),
                    )
                  : SizedBox(),
              asset.assetChildResumeList != null &&
                      asset.assetChildResumeList.length > 0
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Row(
                        children: [
                          Wrap(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.start,
                              children: asset.assetChildResumeList
                                  .map((assetChild) => Container(
                                        width: 80,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 5, 5, 5),
                                                child: Icon(
                                                  GoInstallationIcons.getIcon(
                                                      assetChild.type.icon),
                                                  color: getColor(
                                                      assetChild.type.color),
                                                  size: 25,
                                                )),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Text(
                                                  assetChild.count.toString(),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  )),
                                            )
                                          ],
                                        ),
                                      ))
                                  .toList())
                        ],
                      ),
                    )
                  : SizedBox()
            ],
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AssetEditPage(
                assetId: asset.id,
              );
            })).whenComplete(() => updateAsset());
          },
        ),
      ),
    );
  }
}

// void _addPoiInAsset(

//     TechnicalVisit technicalVisit, BuildContext context) async {
//   var image = await ImagePicker().getImage(source: ImageSource.camera);

//   if (image != null) {
//     var requestFuture = context
//         .provide<RequestsRepository>()
//         .sendInstallationFinalChecklistPhoto(
//           technicalVisit.id,
//           File(image.path),
//         )..then((success) {
//             if (success) {
//               technicalVisit.finalChecklistPhotoURL = "";
//               refresh();
//               Timer(1.seconds, () => Navigator.of(context).pop());
//             } else {
//               Timer(2.seconds, () => Navigator.of(context).pop());
//             }
//           });

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flow_flutter/go_installation_icons_icons.dart';
import 'package:flow_flutter/models/asset_model.dart';
import 'package:flow_flutter/models/poi_model.dart';
import 'package:flow_flutter/pages/asset_pages/asset_edit_page.dart';
import 'package:flow_flutter/pages/asset_pages/poi_search_page.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/app_bar_flow.dart';
import 'package:flow_flutter/widget/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';

class AssetListPage extends StatefulWidget {
  const AssetListPage({Key key}) : super(key: key);

  @override
  _AssetListPageState createState() => _AssetListPageState();
}

class _AssetListPageState extends State<AssetListPage>
    with SingleTickerProviderStateMixin {
  Future<List<AssetModel>> _assets;
  String filter = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(110),
          child: AppBarFlow(
              title: "Ativos",
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: SearchWidget(
                  text: filter,
                  hintText: 'Serial, placa ou id da frota',
                  onSearchTap: () {
                    if (filter != '') {
                      setState(() {
                        _assets = context
                            .provide<RequestsRepository>()
                            .getAssetList(filter: filter, selectPage: false);
                      });
                    }
                  },
                  onSearchKeyboard: (filter) {
                    if (filter != '') {
                      setState(() {
                        _assets = context
                            .provide<RequestsRepository>()
                            .getAssetList(filter: filter, selectPage: false);
                      });
                    }
                  },
                  onCameraTap: () async {
                    printDebug('OnCamera tap');

                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                      imageQuality: 90,
                      maxWidth: 1000,
                      maxHeight: 1000,
                    );

                    if (pickedFile != null) {
                      setState(() {
                        _assets = context
                            .provide<RequestsRepository>()
                            .getAssetByPicture(
                                pictureFile: File(pickedFile.path));
                      });
                    }
                  },
                  onQrCodeTap: () async {
                    printDebug('OnQrCode tap');

                    final scanned = await FlutterBarcodeScanner.scanBarcode(
                      "#ff6666",
                      "Cancelar",
                      true,
                      ScanMode.QR,
                    );

                    printDebug('Código scaneado $scanned');

                    if (scanned != '-1') {
                      setState(() {
                        _assets = context
                            .provide<RequestsRepository>()
                            .getAssetByQrCode(qrCode: scanned);
                      });
                    }
                  },
                  onChanged: (filter) => setState(() => this.filter = filter),
                ),
              )),
        ),
        body: FutureBuilder<List<AssetModel>>(
            future: _assets,
            builder: (BuildContext context,
                AsyncSnapshot<List<AssetModel>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SpinKitWave(
                    color: Theme.of(context).colorScheme.secondary,
                    size: 30,
                  ),
                );
              }
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      final asset = snapshot.data[index];

                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CardAsset(
                            asset: asset,
                            deletePoi: _deletePoi,
                            addPoi: _addPoi,
                          ));
                    });
              } else {
                return SizedBox();
              }
            }));
  }

  void _deletePoi(int assetId) {
    if (assetId != null) {
      printDebug('Delete POI in assetId: $assetId');

      context
          .provide<RequestsRepository>()
          .deletePoiInAsset(assetId: assetId)
          .then((response) => {
                if (response) {_updateAssetList()}
              });
    }
  }

  void _addPoi(PoiModel poi, int assetId) {
    if (poi != null) {
      printDebug('Add POI poiid ' + poi.id.toString() + ', assetId: $assetId');

      context
          .provide<RequestsRepository>()
          .addPoiInAsset(poiId: poi.id, assetId: assetId)
          .then((response) => {
                if (response) {_updateAssetList()}
              });
    }
  }

  void _updateAssetList() {
    setState(() {
      _assets = context
          .provide<RequestsRepository>()
          .getAssetList(filter: filter, selectPage: false);
    });
  }
}

class CardAsset extends StatelessWidget {
  const CardAsset(
      {Key key,
      @required this.asset,
      @required this.deletePoi,
      @required this.addPoi})
      : super(key: key);

  final AssetModel asset;
  final Function deletePoi;
  final Function addPoi;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
          onTap: () {
            print("Click asset: " + asset.identifier);
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AssetEditPage(
                assetId: asset.id,
              );
            }));
          },
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Icon(
                    GoInstallationIcons.getIcon(asset.type.icon),
                    color: getColor(asset.type.color),
                    size: 40,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(asset.identifier,
                          style: TextStyle(
                            fontSize: 20,
                          )),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(asset.type.name,
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                          ),
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
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        asset.poi == null
                            ? PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on_outlined),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
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
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text('Remover local'),
                                    )
                                  ],
                                ),
                                value: 2,
                              )
                            : null
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

                          default:
                        }
                      },
                    )
                  ],
                )
              ],
            ),
            asset.fileId != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: CachedNetworkImageProvider(
                            asset.fileUrl,
                          ),
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
            asset.poi != null
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(4, 15, 0, 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
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
                          flex: 7,
                          child: Text(
                            asset.poi.name,
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      ],
                    ),
                  )
                : SizedBox(),
            Row(
              children: [
                Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.start,
                    children: asset.assetChildResumeList
                        .map((assetChild) => Container(
                              width: 80,
                              padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Icon(
                                        GoInstallationIcons.getIcon(
                                            assetChild.type.icon),
                                        color: getColor(assetChild.type.color),
                                        size: 25,
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(assetChild.count.toString(),
                                        style: TextStyle(
                                          fontSize: 15,
                                        )),
                                  ),
                                ],
                              ),
                            ))
                        .toList())
              ],
            )
          ]),
        ));
  }
}

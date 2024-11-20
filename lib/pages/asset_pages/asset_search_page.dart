import 'package:flow_flutter/go_installation_icons_icons.dart';
import 'package:flow_flutter/models/asset_model.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/app_bar_flow.dart';
import 'package:flow_flutter/widget/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AssetSearchPage extends StatefulWidget {
  const AssetSearchPage({Key key}) : super(key: key);

  @override
  _AssetSearchPageState createState() => _AssetSearchPageState();
}

class _AssetSearchPageState extends State<AssetSearchPage> {
  Future<List<AssetModel>> _assets;
  String filter = '';

  @override
  void initState() {
    super.initState();

    // this._assets = context
    //     .provide<RequestsRepository>()
    //     .getAssetList(filter: filter, selectPage: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarFlow(
          title: "Selecione um Ativo",
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: SearchWidget(
              text: filter,
              hintText: 'Serial, placa ou id da frota',
              onSearchTap: () {
                setState(() {
                  this._assets = context
                      .provide<RequestsRepository>()
                      .getAssetList(filter: filter, selectPage: true);
                });
              },
              onSearchKeyboard: (filter) {
                setState(() {
                  this._assets = context
                      .provide<RequestsRepository>()
                      .getAssetList(filter: filter, selectPage: true);
                });
              },
              onChanged: (filter) => setState(() => this.filter = filter),
            ),
          ),
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
              } else if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      final asset = snapshot.data[index];

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                        child: CardAsset(asset: asset, onSelect: _selectAsset),
                      );
                    });
              } else {
                return SizedBox();
              }
            }));
  }

  void _selectAsset(BuildContext context, AssetModel assetModel) {
    Navigator.pop(context, assetModel);
  }
}

class CardAsset extends StatelessWidget {
  final AssetModel asset;
  final Function onSelect;

  const CardAsset({Key key, this.asset, this.onSelect}) : super(key: key);

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
                      GoInstallationIcons.getIcon(asset.type.icon),
                      color: getColor(asset.type.color),
                      size: 30,
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
                      asset.type.name,
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      asset.identifier,
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ),
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     IconButton(
              //         icon: Icon(Icons.access_alarm),
              //         onPressed: () {
              //           printDebug('On click menu poi');
              //         }),
              //   ],
              // )
            ],
          ),
          onTap: () => onSelect(context, asset),
        ),
      ),
    );
  }
}

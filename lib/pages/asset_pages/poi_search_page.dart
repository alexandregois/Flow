import 'package:flow_flutter/models/poi_model.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/app_bar_flow.dart';
import 'package:flow_flutter/widget/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PoiSearchPage extends StatefulWidget {
  const PoiSearchPage({Key key}) : super(key: key);

  @override
  _PoiSearchPageState createState() => _PoiSearchPageState();
}

class _PoiSearchPageState extends State<PoiSearchPage> {
  Future<List<PoiModel>> _pois;
  String filter = '';

  @override
  void initState() {
    super.initState();

    this._pois =
        context.provide<RequestsRepository>().getPoiList(filter: filter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarFlow(
          title: "Busca de POI",
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: SearchWidget(
              text: filter,
              hintText: 'Digite o nome',
              onSearchTap: () {
                setState(() {
                  this._pois = context
                      .provide<RequestsRepository>()
                      .getPoiList(filter: filter);
                });
              },
              onSearchKeyboard: (filter) {
                setState(() {
                  this._pois = context
                      .provide<RequestsRepository>()
                      .getPoiList(filter: filter);
                });
              },
              onChanged: (filter) => setState(() => this.filter = filter),
            ),
          ),
        ),
        body: FutureBuilder<List<PoiModel>>(
            future: _pois,
            builder:
                (BuildContext context, AsyncSnapshot<List<PoiModel>> snapshot) {
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
                      final poi = snapshot.data[index];

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                        child: CardPoi(poi: poi, onSelect: _selectPoi),
                      );
                    });
              } else {
                return SizedBox();
              }
            }));
  }

  void _selectPoi(BuildContext context, PoiModel poiModel) {
    Navigator.pop(context, poiModel);
  }
}

class CardPoi extends StatelessWidget {
  final PoiModel poi;
  final Function onSelect;

  const CardPoi({Key key, this.poi, this.onSelect}) : super(key: key);

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
                      color: Colors.green,
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
          onTap: () => onSelect(context, poi),
        ),
      ),
    );
  }
}

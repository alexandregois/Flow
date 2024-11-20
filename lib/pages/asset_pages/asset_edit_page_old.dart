import 'package:flow_flutter/controller/V2Controllers/asset_edit_controller.dart';
import 'package:flow_flutter/models/asset_model.dart';
import 'package:flow_flutter/utils/no_glow_behavior.dart';
import 'package:flow_flutter/widget/app_bar_flow.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AssetEditPage extends StatefulWidget {
  final AssetEditController controller;

  const AssetEditPage({Key key, @required this.controller}) : super(key: key);

  @override
  _AssetEditPageState createState() => _AssetEditPageState();
}

class _AssetEditPageState extends State<AssetEditPage> {
  List<AssetModel> assetsSelected = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFlow(title: "Edição Ativo"),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Adicionar ativo',
        child: Icon(Icons.add),
      ),
      body: ScrollConfiguration(
        behavior: NoGlowBehavior(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ListView(
            children: [
              Expanded(
                  child: DropdownSearch(
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    hintText: "Poi",
                    hintStyle: Theme.of(context)
                        .textTheme
                        .titleLarge
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                onChanged: (value) async {
                  // await widget.controller.updateCities(value);
                  // setState(() {
                  //   if (widget.controller.state != value) {
                  //     var acronym =
                  //         widget.controller.getStateAcronymByName(value);
                  //     _state.text = acronym;
                  //     widget.controller.state = acronym;

                  //     _city.text =
                  //         widget.controller.cities.citiesList.first.cityName;
                  //     widget.controller.city =
                  //         widget.controller.cities.citiesList.first.cityName;
                  //   }
                  // });
                },
                items: [
                  ...widget.controller.pois.items.map((e) {
                    return e.name;
                  })
                ],
              )),
              // Padding(
              //   padding: EdgeInsets.all(8.0),
              //   child: SearchableDropdown.single(
              //     searchHint: Text(
              //       "Poi",
              //       style: Theme.of(context)
              //           .textTheme
              //           .headline6
              //           .copyWith(color: Theme.of(context).colorScheme.primary),
              //     ),
              //     closeButton: "Fechar",
              //     label: Text(
              //       "Poi",
              //       style: Theme.of(context)
              //           .textTheme
              //           .subtitle1
              //           .copyWith(color: Theme.of(context).colorScheme.primary),
              //     ),
              //     isExpanded: true,
              //     value: widget.controller.poiText,
              //     displayClearIcon: false,
              //     onChanged: (value) async {
              //       // await widget.controller.updateCities(value);
              //       // setState(() {
              //       //   if (widget.controller.state != value) {
              //       //     var acronym =
              //       //         widget.controller.getStateAcronymByName(value);
              //       //     _state.text = acronym;
              //       //     widget.controller.state = acronym;

              //       //     _city.text =
              //       //         widget.controller.cities.citiesList.first.cityName;
              //       //     widget.controller.city =
              //       //         widget.controller.cities.citiesList.first.cityName;
              //       //   }
              //       // });
              //     },
              //     items: [
              //       ...widget.controller.pois.items.map((e) => DropdownMenuItem(
              //             child: Text('${e.name}'),
              //             value: e.name,
              //           ))
              //     ],
              //   ),
              // ),
              ElevatedButton(
                  onPressed: _addAsset,
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.blue),
                      ))),
                  child: Text("Confirmar")),
            ],
          ),
        ),
      ),
    );
  }

  void _addAsset() {
    // SelectDialog.showModal<AssetModel>(
    //   context,
    //   label: "Ativos",
    //   searchHint: "Buscar",
    //   multipleSelectedValues: assetsSelected,
    //   onFind: (String filter) => getData(filter),
    //   itemBuilder: (BuildContext context, AssetModel item, bool isSelected) {
    //     return Container(
    //       decoration: !isSelected
    //           ? null
    //           : BoxDecoration(
    //               borderRadius: BorderRadius.circular(5),
    //               color: Colors.white,
    //               border: Border.all(color: Theme.of(context).primaryColor),
    //             ),
    //       child: ListTile(
    //         leading: Icon(Icons.directions_car),
    //         selected: isSelected,
    //         title: Text(item.name),
    //         subtitle: Text('ABC12'),
    //         trailing: isSelected ? Icon(Icons.check) : null,
    //       ),
    //     );
    //   },
    //   onMultipleItemsChange: (List<AssetModel> selected) {
    //     setState(() {
    //       assetsSelected = selected;
    //     });
    //   },
    // );
  }
}

// Future<List<AssetModel>> getData(String filter) async {
//   var response = await Dio().get(
//     "http://5d85ccfb1e61af001471bf60.mockapi.io/user",
//     queryParameters: {"filter": filter},
//   );

//   var models = AssetModel.fromJsonList(response.data);
// // var  response =
// //       await rootBundle.loadString('assets/json/asset_list_example.json');
// //   Map jsonResult = await response.decode(response);
//   return models;
// }

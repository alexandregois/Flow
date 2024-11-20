import 'dart:developer';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flow_flutter/controller/V2Controllers/pictures_controller.dart';
import 'package:flow_flutter/controller/V2Controllers/register_controller.dart';
import 'package:flow_flutter/models/car_api_response.dart';
import 'package:flow_flutter/models/nfe_api_response.dart';
import 'package:flow_flutter/models/vehicle_listing.dart';
import 'package:flow_flutter/repository/impl/picture_plate_bloc.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/no_glow_behavior.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:provider/provider.dart';

import '../../models/uf_city_Listing.dart';

class RegisterInfoPage extends StatefulWidget {
  final RegisterController controller;

  RegisterInfoPage({Key key, @required this.controller}) : super(key: key);

  @override
  _RegisterInfoPageState createState() => _RegisterInfoPageState();
}

class _RegisterInfoPageState extends State<RegisterInfoPage> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  PicturePlateBloc picturePlateBloc;
  var _performingCarInfo = false;
  var _textSpinkWave = 'Atualizando...';
  TextEditingController _plate;
  TextEditingController _brandName;
  TextEditingController _modelName;
  TextEditingController _chassis;
  TextEditingController _year;
  TextEditingController _modelYear;
  TextEditingController _state;
  //TextEditingController _stateName;
  TextEditingController _cityName;
  TextEditingController _odometer;
  TextEditingController _color;
  Map<String, TextEditingController> _aditionalFieldsControllers = {};
  List formKeyList = [];

  TextEditingController _nfeNumberController;
  TextEditingController _identifierBoxController;
  TextEditingController _nfeUfNameController;
  TextEditingController _nfeMonthYearController;
  TextEditingController _nfeCNPJController;
  TextEditingController _nfeModelController;
  TextEditingController _nfeSerieController;
  TextEditingController _nfeCodeController;
  TextEditingController _nfeDigitController;

  Uf _uf;
  City _city;
  Brand _brand;
  Model _model;

  @override
  void initState() {
    _plate = TextEditingController(text: widget.controller.plate);
    _brandName = TextEditingController(text: widget.controller.brandName);
    _modelName = TextEditingController(text: widget.controller.modelName);
    _modelYear = TextEditingController(text: widget.controller.modelYear);
    _chassis = TextEditingController(text: widget.controller.chassis);
    _odometer = TextEditingController(text: widget.controller.odometer);
    _color = TextEditingController(text: widget.controller.color);
    _year = TextEditingController(text: widget.controller.year);
    _cityName = TextEditingController(text: widget.controller.cityName);
    _state = TextEditingController(text: widget.controller.state);
    _uf = widget.controller.uf;
    _identifierBoxController = TextEditingController(text: widget.controller.fleetId);

    widget.controller.aditionalFields.forEach((element) {
      _aditionalFieldsControllers[element.tag] = TextEditingController(text: element.value);
      formKeyList.add(GlobalKey<FormState>());
    });

    _nfeNumberController = TextEditingController();

    _nfeUfNameController = TextEditingController();
    _nfeMonthYearController = TextEditingController();
    _nfeCNPJController = TextEditingController();
    _nfeModelController = TextEditingController();
    _nfeSerieController = TextEditingController();
    _nfeCodeController = TextEditingController();
    _nfeDigitController = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var ctx = context;
    picturePlateBloc = Provider.of<PicturePlateBloc>(context);
    // final installationController = context.provide<InstallationController>();

    // await widget.controller.updateCities(widget.controller.uf?.id);
    // _city = widget.controller.getCityById(widget.controller?.city?.id);

    final _formKeyPlate = GlobalKey<FormState>();
    final _formKeyChassi = GlobalKey<FormState>();
    final _formKeyOdometer = GlobalKey<FormState>();
    final _formKeyColor = GlobalKey<FormState>();
    final _formKeyYear = GlobalKey<FormState>();
    final _formKeyYearModel = GlobalKey<FormState>();
    final bool isVehicle = widget.controller.isVehicle;
    print("isVehicle: $isVehicle");

    var borderDefault = UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFE3E3E6)),
    );

    var theme = Theme.of(context);
    var primaryLabelStyle = TextStyle(fontSize: 20, color: theme.primaryColor);
    return ScrollConfiguration(
      behavior: NoGlowBehavior(),
      child: _performingCarInfo
          ? SizedBox(
              width: 20.0,
              height: 20.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SpinKitWave(
                    color: Theme.of(context).colorScheme.secondary,
                    size: 15.0,
                  ),
                  Text(_textSpinkWave)
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  if (isVehicle) ...{
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 8, 0, 8),
                      child: Form(
                        key: _formKeyPlate,
                        child: TextFormField(
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp('[A-Z0-9]')),
                          ],
                          maxLength: 7,
                          controller: _plate,
                          enabled: widget.controller.isEditable,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'Placa',
                            labelStyle: primaryLabelStyle,
                            enabledBorder: borderDefault,
                            suffixIcon: IconButton(
                              icon: Icon(Icons.camera_alt),
                              onPressed: () async {
                                return showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.red,
                                      title: const Text('Atenção',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 20)),
                                      content: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.07,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: const Text(
                                          "Essa foto deve ser tirada na HORIZONTAL!",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blue.shade700),
                                            child: const Text("Ok"),
                                            onPressed: () async {
                                              Navigator.pop(context);

                                              try {
                                                final pickedFile = await ImagePicker().pickImage(
                                                  source: ImageSource.camera,
                                                  imageQuality: 90,
                                                  maxWidth: 1000,
                                                  maxHeight: 1000,
                                                );

                                                if(pickedFile != null) {
                                                  File rotatedImage = await FlutterExifRotation.rotateImage(path: pickedFile.path);
                                                  final size = ImageSizeGetter.getSize(FileInput(File(rotatedImage.path)));

                                                  if (pickedFile != null) {
                                                    if (size.height > size.width) {
                                                      final snackBar = SnackBar(
                                                        duration: Duration(seconds: 4),
                                                        backgroundColor: Colors.red,
                                                        content: Padding(
                                                          padding: const EdgeInsets.all(35),
                                                          child: Text(
                                                              'A foto está na orientação incorreta, tire novamente.',
                                                              style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 20)),
                                                        ),
                                                      );
                                                      ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
                                                      return;
                                                    }

                                                    var picturePlateTaken =
                                                        new PictureTaken(
                                                            id: "PLATE",
                                                            isCustom: false,
                                                            observation: "",
                                                            sent: false,
                                                            isProcessing: false,
                                                            fileLocation: Uri.parse(pickedFile.path),
                                                            isRegister: true);

                                                    picturePlateBloc.add(picturePlateTaken);

                                                    log(pickedFile.path);

                                                    setState(() {
                                                      _performingCarInfo = true;
                                                      _textSpinkWave = 'Buscando informações do veículo';
                                                    });

                                                    CarApiResponse carApiResponse;
                                                    int attempts = 0;
                                                    bool firstTime = true;

                                                    while (checkCarApiFields(carApiResponse) && attempts != 3) {
                                                      attempts++;

                                                      setState(() {
                                                        _textSpinkWave = 'Buscando informações do veículo - Tentativa $attempts';
                                                      });

                                                      if (!firstTime) {
                                                        sleep(Duration(seconds: 3));
                                                      } else {
                                                        firstTime = false;
                                                      }

                                                      carApiResponse = await widget.controller.getCarInfo(
                                                        null,
                                                        null,
                                                        null,
                                                        File(pickedFile.path)
                                                      );
                                                    }

                                                    if (checkCarApiFields(carApiResponse)) {
                                                      final snackBar = SnackBar(
                                                        duration: Duration(seconds: 5),
                                                        content: Padding(
                                                          padding: const EdgeInsets.all(35),
                                                          child: Text('Nenhum dado foi encontrado, preencha os campos manualmente.',
                                                              style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 20)),
                                                        ),
                                                        backgroundColor: Colors.red,
                                                      );
                                                      ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
                                                    } else {
                                                      showDialog<String>(
                                                        context: ctx,
                                                        builder: (BuildContext context) =>
                                                            AlertDialog(
                                                              title: const Text('A placa encontrada está correta?'),
                                                              content: Text(
                                                                carApiResponse.plate,
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 20),
                                                              ),
                                                              actions: <Widget>[
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context,
                                                                          'Cancel'),
                                                                  child: const Text(
                                                                      'Cancelar'),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () async {
                                                                    Navigator.pop(
                                                                        context, 'OK');
                                                                  },
                                                                  child: const Text(
                                                                      'Confirmar'),
                                                                ),
                                                              ],
                                                            ),
                                                      ).then((value) async {
                                                        if (value == 'OK') {
                                                          await _updateCarInfo(carApiResponse);

                                                          if (carApiResponse.equipmentInstalled != null &&
                                                              carApiResponse.equipmentInstalled.isNotEmpty) {
                                                            _equipmentInstalledDialog(carApiResponse.equipmentInstalled);
                                                          }

                                                          setState(() {});
                                                        }
                                                      });
                                                    }

                                                    setState(() {});

                                                    setState(() {
                                                      _performingCarInfo = false;
                                                    });
                                                  }
                                                }
                                                
                                              } catch (e) {
                                                _errorDialog(e.toString());
                                              }
                                              
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          onChanged: (plate) async {
                            log('Entrou placa');

                            if (_formKeyPlate.currentState.validate()) {
                              log('Placa: $plate');
                              widget.controller.plate = plate;

                              await _getCarInfo(
                                plate: plate, 
                                ctx: ctx
                              );
                            }
                          },
                          validator: (value) {
                            if (value.length != 7) {
                              return 'Insira um placa válida';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formKeyColor,
                        child: TextFormField(
                          controller: _color,
                          enabled: widget.controller.isEditable,
                          decoration: InputDecoration(
                            labelText: 'Cor',
                            labelStyle: primaryLabelStyle,
                            enabledBorder: borderDefault,
                          ),
                          textCapitalization: TextCapitalization.characters,
                          onChanged: (value) {
                            if (_formKeyColor.currentState.validate())
                              widget.controller.color = value;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'O campo cor deve ser preenchido';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: DropdownSearch<Uf>(
                        items: [
                          ...widget.controller.states.ufList
                        ],
                        itemAsString: (item) => item.name,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Estado",
                            labelStyle: theme.textTheme.titleLarge.copyWith(color: theme.colorScheme.primary),
                            border: borderDefault,
                          ),
                        ),
                        selectedItem: widget.controller.uf,
                        popupProps: PopupProps.dialog(
                          showSearchBox: true,
                          // showSelectedItems: true,
                          title: Padding(
                            padding: const EdgeInsets.only(top: 8, left: 10),
                            child: Text(
                              "Estado",
                              style: TextStyle(color: theme.colorScheme.primary, fontSize: 18)
                            ),
                          ),
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              border: borderDefault,
                            ),
                           ),
                          dialogProps: DialogProps(actions: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 20),
                              child: InkWell(
                                child: Text("Fechar",
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 17)),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ]),
                        ),
                        onChanged: (ufSelected) async {
                            await widget.controller.updateCities(ufSelected.id);
                            widget.controller.city = null;
                            setState(() {});
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: DropdownSearch<City>(
                        items: [
                          ...widget.controller.cities.citiesList
                        ],
                        itemAsString: (item) => item.cityName,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Cidade",
                            labelStyle: theme.textTheme.titleLarge.copyWith(color: theme.colorScheme.primary),
                            border: borderDefault,
                          ),
                        ),
                        selectedItem: widget.controller.city,
                        popupProps: PopupProps.dialog(
                          showSearchBox: true,
                          // showSelectedItems: true,
                          title: Padding(
                            padding: const EdgeInsets.only(top: 8, left: 10),
                            child: Text(
                              "Cidade",
                              style: TextStyle(color: theme.colorScheme.primary, fontSize: 18)
                            ),
                          ),
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              border: borderDefault,
                            ),
                          ),
                          dialogProps: DialogProps(actions: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 20),
                              child: InkWell(
                                child: Text("Fechar",
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 17)),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ]),
                        ),
                        onChanged: (citySelected) async {
                          setState(() {
                            widget.controller.city = citySelected;
                          });
                        },
                      ),
                    ),
                    
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: DropdownSearch<Brand>(
                        items: [
                          ...widget.controller.brands.brands
                        ],
                        itemAsString: (item) => item.name,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Marca",
                            labelStyle: theme.textTheme.titleLarge.copyWith(color: theme.colorScheme.primary),
                            border: borderDefault,
                          ),
                        ),
                        selectedItem: widget.controller.brand,
                        popupProps: PopupProps.dialog(
                          showSearchBox: true,
                          title: Padding(
                            padding: const EdgeInsets.only(top: 8, left: 10),
                            child: Text(
                              "Marca",
                              style: TextStyle(color: theme.colorScheme.primary, fontSize: 18)
                            ),
                          ),
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              border: borderDefault,
                            ),
                           ),
                          dialogProps: DialogProps(actions: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 20),
                              child: InkWell(
                                child: Text("Fechar",
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 17)),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ]),
                        ),
                        onChanged: (brandSelected) async {
                            await widget.controller.updateModels(brandSelected.id);
                            widget.controller.brand = brandSelected;
                            widget.controller.model = null;
                            setState(() {});
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: DropdownSearch<Model>(
                        items: [
                          ...widget.controller?.models?.models != null ? widget.controller.models.models : []
                        ],
                        itemAsString: (item) => item.name,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Modelo",
                            labelStyle: theme.textTheme.titleLarge.copyWith(color: theme.colorScheme.primary),
                            border: borderDefault,
                          ),
                        ),
                        selectedItem: widget.controller.model,
                        popupProps: PopupProps.dialog(
                          showSearchBox: true,
                          title: Padding(
                            padding: const EdgeInsets.only(top: 8, left: 10),
                            child: Text(
                              "Modelo",
                              style: TextStyle(color: theme.colorScheme.primary, fontSize: 18)
                            ),
                          ),
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              border: borderDefault,
                            ),
                          ),
                          dialogProps: DialogProps(actions: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 20),
                              child: InkWell(
                                child: Text("Fechar",
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 17)),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ]),
                        ),
                        onChanged: (modelSelected) async {
                          setState(() {
                            widget.controller.model = modelSelected;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formKeyChassi,
                        child: TextFormField(
                          maxLength: 17,
                          controller: _chassis,
                          enabled: widget.controller.isEditable,
                          decoration: InputDecoration(
                            labelText: 'Chassi',
                            labelStyle: primaryLabelStyle,
                            enabledBorder: borderDefault,
                          ),
                          textCapitalization: TextCapitalization.characters,
                          onFieldSubmitted: (value) async {
                              await _getCarInfo(
                                chassis: value,
                                ctx: ctx
                              );
                          }, 
                          onChanged: (value) {
                            _formKeyChassi.currentState.validate();
                            // if (_formKeyChassi.currentState.validate())
                            widget.controller.chassis = value;
                          },
                          validator: (value) {
                            if (value.length != 17) {
                              return 'O chassi deve conter exatamente 17 caracteres';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formKeyOdometer,
                        child: TextFormField(
                          maxLength: 10,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          keyboardType: TextInputType.number,
                          controller: _odometer,
                          enabled: widget.controller.isEditable,
                          decoration: InputDecoration(
                            labelText: 'Odômetro',
                            labelStyle: primaryLabelStyle,
                            enabledBorder: borderDefault,
                          ),
                          textCapitalization: TextCapitalization.characters,
                          onChanged: (value) {
                            if (_formKeyOdometer.currentState.validate())
                              widget.controller.odometer = value;
                          },
                          validator: (value) {
                            if (int.parse(value.trim()) > 2147483647) {
                              return 'O odômetro não pode ser maior que 2.147.483.647';
                            }

                            return null;
                          },
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Form(
                              key: _formKeyYear,
                              child: TextFormField(
                                maxLength: 4,
                                controller: _year,
                                enabled: widget.controller.isEditable,
                                decoration: InputDecoration(
                                  labelText: 'Ano fab.',
                                  labelStyle: primaryLabelStyle,
                                  enabledBorder: borderDefault,
                                ),
                                onChanged: (value) {
                                  _formKeyYear.currentState.validate();
                                  widget.controller.year = value;
                                },
                                validator: (value) {
                                  if (value.isNotEmpty && int.parse(value) > DateTime.now().year + 1) {
                                    return 'Ano de fabricação inválido';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Form(
                              key: _formKeyYearModel,
                              child: TextFormField(
                                maxLength: 4,
                                controller: _modelYear,
                                enabled: widget.controller.isEditable,
                                decoration: InputDecoration(
                                  labelText: 'Ano mod.',
                                  labelStyle: primaryLabelStyle,
                                  enabledBorder: borderDefault,
                                ),
                                onChanged: (value) {
                                  if (_formKeyYearModel.currentState.validate())
                                    widget.controller.modelYear = value;
                                },
                                validator: (value) {
                                  print(DateTime.now().year);
                                  if (value.isNotEmpty && (int.parse(value) > DateTime.now().year + 1 || (int.parse(value) < int.parse(widget.controller.year)))) {
                                    return 'Ano do modelo inválido';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  } else if (widget.controller?.localTypeId == 'G')
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Form(
                            key: _formKeyPlate,
                            child: TextFormField(
                              maxLength: 44,
                              keyboardType: TextInputType.number,
                              controller: _plate,
                              enabled: widget.controller.isEditable,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                labelText: 'Nota Fiscal',
                                labelStyle: primaryLabelStyle,
                                enabledBorder: borderDefault,
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.document_scanner),
                                  onPressed: () async {
                                    printDebug('Nota Fiscal Scan click');
                                    final scanned =
                                        await FlutterBarcodeScanner.scanBarcode(
                                      "#ff6666",
                                      "Cancelar",
                                      true,
                                      ScanMode.BARCODE,
                                    );

                                    if (scanned != '-1' &&
                                        scanned.length == 44) {
                                      await _updateNfeFields(scanned);
                                    }
                                  },
                                ),
                              ),
                              textCapitalization: TextCapitalization.characters,
                              onChanged: (value) async {
                                if (value.length == 44) {
                                  if (!chaveNfeValida(value)) {
                                    _nfeCodeController.text = '';
                                    _nfeUfNameController.text = '';
                                    _nfeMonthYearController.text = '';
                                    _nfeCNPJController.text = '';
                                    _nfeModelController.text = '';
                                    _nfeSerieController.text = '';
                                    _nfeNumberController.text = '';
                                    _nfeDigitController.text = '';
                                    _nfeSerieController.text = '';

                                    return 'Insira um número de nota fiscal válida';
                                  }

                                  await _updateNfeFields(value);
                                }
                              },
                              validator: (value) {
                                printDebug('Validado nota $value');
                                if (value.length == 44 &&
                                    !chaveNfeValida(value)) {
                                  return 'Insira um número de nota fiscal válida';
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                        ),
                        TextField(
                          controller: _identifierBoxController,
                          enabled: widget.controller.isEditable,
                          decoration: InputDecoration(
                            labelText: 'Identificador Caixa',
                          ),
                          onChanged: (value) {
                            widget.controller.fleetId = value;
                          },
                        ),
                        TextField(
                          controller: _nfeNumberController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Número Nota Fiscal',
                          ),
                        ),
                        TextField(
                          controller: _nfeUfNameController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Estado',
                          ),
                        ),
                        TextField(
                          controller: _nfeMonthYearController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Mês/Ano',
                          ),
                        ),
                        TextField(
                          controller: _nfeCNPJController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'CNPJ',
                          ),
                        ),
                        TextField(
                          controller: _nfeModelController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Modelo',
                          ),
                        ),
                        TextField(
                          controller: _nfeSerieController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Série',
                          ),
                        ),
                        TextField(
                          controller: _nfeCodeController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Código',
                          ),
                        ),
                        TextField(
                          controller: _nfeDigitController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Dígito',
                          ),
                        )
                      ],
                    )
                  else
                    Container(),
                  ...widget.controller.aditionalFields.map((additionalField) {
                    var index = widget.controller.aditionalFields.indexOf(additionalField);
                    return additionalField.required
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Form(
                              autovalidateMode: AutovalidateMode.always,
                              key: formKeyList[index],
                              child: TextFormField(
                                  controller: _aditionalFieldsControllers[additionalField.tag],
                                  enabled: widget.controller.isEditable,
                                  decoration: InputDecoration(
                                    labelText: additionalField.name,
                                    labelStyle: primaryLabelStyle,
                                    enabledBorder: borderDefault,
                                  ),
                                  textCapitalization: TextCapitalization.words,                                  
                                  onFieldSubmitted: (value) async {
                                    if(additionalField.tag == 'FLEET_ID' && value != null && value.isNotEmpty) {
                                      await _getCarInfo(
                                        fleetId: value,
                                        ctx: ctx
                                      );
                                    }
                                  },                                  
                                  onChanged: (value) async {
                                    formKeyList[index].currentState.validate();
                                    additionalField.value = value;
                                    widget.controller.aditionalFields = widget.controller.aditionalFields.map((field) {
                                      if (field.tag == additionalField.tag)
                                        field.value = additionalField.value;
                                      return field;
                                    }).toList();

                                    // if(additionalField.tag == 'FLEET_ID') {
                                    //   await _getCarInfo(null, value, ctx);
                                    // }

                                  },
                                  validator: (value) {
                                    if (value.isEmpty ||
                                        value == "" ||
                                        value == null) {
                                      return 'Campo Obrigatório';
                                    }
                                    return null;
                                  }),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _aditionalFieldsControllers[additionalField.tag],
                              enabled: widget.controller.isEditable,
                              decoration: InputDecoration(
                                labelText: additionalField.name,
                                labelStyle: primaryLabelStyle,
                                enabledBorder: borderDefault,
                              ),
                              textCapitalization: TextCapitalization.words,
                              onChanged: (value) => additionalField.value = value,
                            ),
                          );
                  }),
                  if (!isVehicle &&
                      (widget.controller.localTypeId != null &&
                          widget.controller.localTypeId != 'G') &&
                      (widget.controller.aditionalFields.isEmpty ||
                          widget.controller.aditionalFields == null))
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 100),
                        child: Text("Nenhum dado de Cadastro registrado para este tipo de instalação"),
                      ),
                    )
                ],
              ),
            ),
    );
  }

  Future<void> _getCarInfo({String plate, String fleetId, String chassis, @required BuildContext ctx}) async {
    setState(() {
      _performingCarInfo = true;
      _textSpinkWave = 'Buscando informações do veículo';
    });
    
    CarApiResponse carApiResponse;
    int attempts = 0;
    bool firstTime = true;
    
    while (checkCarApiFields(carApiResponse) && attempts != 3) {
      attempts++;
    
      setState(() {
        _textSpinkWave = 'Buscando informações do veículo - Tentativa $attempts';
      });
    
      if (!firstTime) {
        sleep(Duration(seconds: 3));
      } else {
        firstTime = false;
      }
    
      carApiResponse = await widget.controller.getCarInfo(plate, fleetId, chassis, null);
    }
    
    if (checkCarApiFields(carApiResponse)) {
      final snackBar = SnackBar(
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red,
        content: Padding(
          padding: const EdgeInsets.all(35),
          child: Text(
            'Dado(s) não encontrado(s), preencha os campos manualmente.',
            style: TextStyle(
              color: Colors.white, 
              fontSize: 20
            )
          ),
        ),
      );
      ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
    } else {
      await _updateCarInfo(carApiResponse);
    
      if (carApiResponse.equipmentInstalled != null && carApiResponse.equipmentInstalled.isNotEmpty) {
        _equipmentInstalledDialog(carApiResponse.equipmentInstalled);
      }
    }

    setState(() {});

    setState(() {
      _performingCarInfo = false;
    });
  }

  void _errorDialog(String text) {
    showDialog(
      context: context,
      barrierColor: Colors.red.withOpacity(0.8),
      builder: (context) => ShowUp.tenth(
        duration: 200,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          title: Text("Erro"),
          content: Text(text),
        ),
      ),
    );
  }

  void _equipmentInstalledDialog(String equipmentInstalled) {
    showDialog(
      context: context,
      barrierColor: Colors.yellow.withOpacity(0.8),
      builder: (context) => ShowUp.tenth(
        duration: 200,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(
              color: Colors.yellow,
              width: 2,
            ),
          ),
          title: Text("Equipamento instalado"),
          content: Text(
              "Já existe equipamento instalado $equipmentInstalled, gostaria de continuar a visita técnica?"),
          actions: [
            TextButton(
              child: Text("Sim"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text("Não"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        ),
      ),
    ).then((value) {
      if (value) Navigator.of(context).pop();
    });
  }

  Future<void> _updateNfeFields(String value) async {
    _plate.text = value;
    widget.controller.plate = value;

    NfeApiResponse response = await widget.controller.getNfeInfo(value);

    if (response != null) {
      _nfeCodeController.text = response.code;
      _nfeUfNameController.text = response.ufName;
      _nfeMonthYearController.text = response.month + '/' + response.year;
      _nfeCNPJController.text = response.cnpj;
      _nfeModelController.text = response.model;
      _nfeSerieController.text = response.serie;
      _nfeNumberController.text = response.number;
      _nfeDigitController.text = response.digit;
      _nfeSerieController.text = response.serie;
    }
  }

  bool checkCarApiFields(CarApiResponse carApiResponse) {
    if (carApiResponse == null) {
      return true;
    }

    if (carApiResponse.pictureUnrecognized == true) {
      return true;
    }

    if (carApiResponse.year == null &&
        carApiResponse.yearModel == null &&
        carApiResponse.color == null &&
        carApiResponse.modelId == null &&
        carApiResponse.brandId == null &&
        carApiResponse.ufId == null &&
        carApiResponse.cityId == null &&
        carApiResponse.chassis == '') {
      return true;
    }

    return false;
  }

  Future<void> _updateCarInfo(CarApiResponse carApiResponse) async {

    widget.controller.vehicleId = carApiResponse.vehicleId;
    _plate.text = carApiResponse.plate;
    widget.controller.plate = carApiResponse.plate;
    _color.text = carApiResponse.color;
    widget.controller.color = carApiResponse.color;

    _uf = widget.controller.getUfById(carApiResponse.ufId);
    widget.controller.uf = _uf;

    await widget.controller.updateCities(_uf.id);

    _city = widget.controller.getCityById(carApiResponse.cityId);
    widget.controller.city = _city;

    _brand = widget.controller.getBrandById(carApiResponse.brandId);
    widget.controller.brand = _brand;

    _model = widget.controller.getModelById(carApiResponse.modelId);
    widget.controller.model = _model;
    await widget.controller.updateModels(carApiResponse.brandId);

    widget.controller.model = widget.controller.getModelById(carApiResponse.modelId);
    
    _chassis.text = carApiResponse.chassis;
    widget.controller.chassis = carApiResponse.chassis;

    _year.text = carApiResponse.year.toString();
    widget.controller.year = carApiResponse.year.toString();

    _modelYear.text = carApiResponse.yearModel.toString();
    widget.controller.modelYear = carApiResponse.yearModel.toString();

    if(carApiResponse.fleetId != null && carApiResponse.fleetId.isNotEmpty) {
      widget.controller.aditionalFields = widget.controller.aditionalFields.map((field) {
        if (field.tag == 'FLEET_ID')
          field.value = carApiResponse.fleetId;
        return field;
      }).toList();

      _aditionalFieldsControllers['FLEET_ID'].text = carApiResponse.fleetId;
    }

    widget.controller.updateReady();
  }

  // Iterable<Model> _modelList() {
  //   List<Brand> brands = widget.controller.brands
  //       .where((brand) => brand.name == _brand.text.trim())
  //       .toList();

  //   List<Model> models;

  //   if (_modelapi != null &&
  //       _modelapi.isNotEmpty &&
  //       _groupapi != null &&
  //       _groupapi.isNotEmpty) {
  //     if (_modelapi.contains("/")) {
  //       var modelsSearch = _modelapi.split("/");

  //       if (modelsSearch.length > 0) {
  //         models = widget.controller.models.where((model) {
  //           if (brands.any((brand) => (brand.id == model.brandId &&
  //               model.name.toLowerCase().contains(_groupapi.toLowerCase()) &&
  //               model.name
  //                   .toLowerCase()
  //                   .contains(modelsSearch[1].toLowerCase())))) {
  //             return true;
  //           }

  //           return false;
  //         }).toList();
  //       }
  //     } else {
  //       models = widget.controller.models.where((model) {
  //         if (brands.any((brand) => (brand.id == model.brandId &&
  //             model.name.toLowerCase().contains(_groupapi.toLowerCase()) &&
  //             model.name.toLowerCase().contains(_modelapi.toLowerCase())))) {
  //           return true;
  //         }

  //         return false;
  //       }).toList();
  //     }
  //   }

  //   if ((models == null || models.length == 0) &&
  //       _groupapi != null &&
  //       _groupapi.isNotEmpty) {
  //     models = widget.controller.models.where((model) {
  //       if (brands.any((brand) => (brand.id == model.brandId &&
  //           model.name.toLowerCase().contains(_groupapi.toLowerCase())))) {
  //         return true;
  //       }

  //       return false;
  //     }).toList();
  //   }

  //   if (models == null || models.length == 0) {
  //     models = widget.controller.models.where((model) {
  //       if (brands.any((brand) => brand.id == model.brandId)) {
  //         return true;
  //       }
  //       return false;
  //     }).toList();
  //   }

  //   return models;
  // }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    var toRemove = [];
    _plate.dispose();
    _brandName.dispose();
    _modelName.dispose();
    _modelYear.dispose();
    _chassis.dispose();
    _color.dispose();
    _odometer.dispose();
    _year.dispose();
    _cityName.dispose();
    _state.dispose();

    _nfeNumberController.dispose();
    _identifierBoxController.dispose();
    _nfeUfNameController.dispose();
    _nfeMonthYearController.dispose();
    _nfeCNPJController.dispose();
    _nfeModelController.dispose();
    _nfeSerieController.dispose();
    _nfeCodeController.dispose();
    _nfeDigitController.dispose();

    for (String key in _aditionalFieldsControllers.keys) {
      TextEditingController controller = _aditionalFieldsControllers[key];
      toRemove.add(controller);
      controller.dispose();
    }

    _aditionalFieldsControllers.clear();

    super.dispose();
  }
}

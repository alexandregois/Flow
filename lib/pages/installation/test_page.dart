import 'package:auto_size_text/auto_size_text.dart';
import 'package:flow_flutter/controller/V2Controllers/custom_page_controller.dart';
import 'package:flow_flutter/controller/V2Controllers/test_controller.dart';
import 'package:flow_flutter/go_installation_icons_icons.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/pages/vlc/single_tab.dart';
import 'package:flow_flutter/repository/impl/equipment_test_bloc.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/util_extensions.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/pair_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TestPage extends StatefulWidget {
  final TestController controller;

  TestPage({Key key, @required this.controller}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage>
    with AutomaticKeepAliveClientMixin {
  TextEditingController _name;
  EquipmentTestBloc equipmentTestBloc;
  List<TestInfo> _testList;
  bool ready;
  int auxStatus;
  int technicalVisitId;

  bool dataLoaded = false;
  ListCams _cams;
  String urlImage;
  static final _format = DateFormat('E dd/MM, HH:mm', 'pt_BR');

  @override
  void initState() {
    super.initState();
    _loadCamList();
    _name = TextEditingController(text: widget.controller.name);
  }

  Future<void> _loadCamList() async {
    _testList = widget.controller.testItems;

    technicalVisitId = _testList[0].technicalVisitId == null
        ? widget.controller.installationCloudId
        : _testList[0].technicalVisitId;

    //Producao
    //technicalVisitId = 149148;

    //Test Lab
    //technicalVisitId = 1129;

    if (_testList[0].technicalVisitId == null)
      _testList[0].technicalVisitId = technicalVisitId;

    printDebug('Id da visita: $technicalVisitId');

    var result = await context
        .provide<RequestsRepository>()
        .getCamsByTechnicalVisitId(technicalVisitId);

    printDebug('Resultado cams: $result');

    setState(() {
      this._cams = result;
      this.dataLoaded = true;
    });
    printDebug("Terminou de carregar");
  }

  Future<String> _loadVCCAM(
      int technicalVisitId, String serial, int thumb) async {
    var result = await context
        .provide<RequestsRepository>()
        .getVCCAMBySerial(technicalVisitId, serial, thumb);

    if (result != null && result.isNotEmpty) {
      printDebug('Requisitou imagem cam serial: $serial');
      return result;
    } else {
      printDebug('Erro na requisicao VCCAM: $serial');
      return null;
    }
  }

  void updateState() {
    _testList = widget.controller.testItems;
  }

  Color getColorByStatus(int status) {
    if (status == -1) {
      return Colors.red;
    }

    if (status == 1) {
      return Colors.green;
    }

    return Colors.yellow[600];
  }

  IconData getIconByStatus(int status) {
    if (status == -1) {
      return Icons.error_outline_outlined;
    }

    if (status == 1) {
      return Icons.check_circle;
    }

    return Icons.warning_rounded;
  }

  Future<void> _onViewCamDVRClick(int index, String serial) async {
    if (this._cams != null && this._cams.listCams.length > 0) {
      showDialog(
        context: context,
        builder: (context) => ShowUp.tenth(
          child: Dialog(
            insetPadding: EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            child: SingleTab(
                cams: _cams,
                controller: widget.controller,
                index: index,
                serial: serial),
          ),
        ),
      );
    }
  }

  Future<void> _onViewCamVCClick(
      int index, int technicalVisitId, String serial, int thumb) async {
    super.setState(() {
      widget.controller.clearDataTest(index);
      widget.controller.updateStartingTest(index);
    });

    var url = await _loadVCCAM(technicalVisitId, serial, thumb);

    super.setState(() {
      urlImage = url;
      widget.controller.updateStatusCamTestItem(index, url);
    });

    if (urlImage != null && urlImage.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => ShowUp.tenth(
          child: Dialog(
            insetPadding: EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            child: Center(
              heightFactor: 1,
              child: Column(
                children: [
                  urlImage == null || urlImage == ""
                      ? Text("Teste de Câmera VC - Imagem não encontrada")
                      : Image.network(urlImage),
                  Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, //Center Column contents vertically,
                      crossAxisAlignment: CrossAxisAlignment
                          .center, //Center Column contents horizontally,
                      children: [
                        TextButton(
                            onPressed: () => this.adjustedAction(
                                index, urlImage, context, TestStatus.Pending),
                            child: Text("Fechar")),
                        TextButton(
                            onPressed: () => this.adjustedAction(
                                index,
                                urlImage,
                                context,
                                TestStatus.IgnoredNonMandatory),
                            child: Text("Ignorar")),
                        TextButton(
                            onPressed: () => this.adjustedAction(
                                index, urlImage, context, TestStatus.Success),
                            child: Text("Ajustado"))
                      ])
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      this.adjustedAction(
          index, "Erro ao requisitar imagem", context, TestStatus.Error);
    }
  }

  void adjustedAction(index, urlImage, context, int status) async {
    widget.controller.testItems[index].status = status;

    var newUrl = "";
    if (status == TestStatus.Pending) {
      newUrl = urlImage;
    } else {
      newUrl = await widget.controller
          .saveVCEvidenceImage(widget.controller.testItems[index]);
    }

    super.setState(() {
      var testInfo = widget.controller.testItems[index];
      testInfo.status = status;
      testInfo.statusResult = newUrl != null ? newUrl : urlImage;
      widget.controller.updateItem(testInfo, index);
      widget.controller.updateEquipmentTest(testInfo);
    });

    if (status != TestStatus.Error) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var customPageController = context.provide<CustomPageController>();

    var theme = Theme.of(context);

    equipmentTestBloc = Provider.of<EquipmentTestBloc>(context);

    this.updateState();

    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: _testList.length,
        itemBuilder: (BuildContext context, int index) {
          TestInfo testInfo = _testList[index];

          return InkWell(
            borderRadius: const BorderRadius.all(
              Radius.circular(12),
            ),
            child: Theme(
              data: theme,
              child: ListTileTheme(
                dense: true,
                child: ExpansionTile(
                  tilePadding: EdgeInsets.only(right: 8),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                            child: Icon(
                              GoInstallationIcons.getIcon(testInfo.icon),
                              color: (testInfo.iconColor != null)
                                  ? getColor(testInfo.iconColor)
                                  : Colors.grey,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  testInfo.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  testInfo.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: _statusColor(index),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    _statusText(index),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_enableIgnoreOption(_testList[index].status, _testList[index].key) &&
                              _testList[index].key != "TEST_VCCAM" &&
                              _testList[index].key != "TEST_DVRCAM" && _testList[index].key != "TEST_ADASCAM")
                            TextButton(
                              child: Text(
                                "Ignorar",
                                textAlign: TextAlign.right,
                                style: TextStyle(color: context.theme.primaryColor),
                              ),
                              onPressed: () async => _confirmationPageIgnoreTest(
                                  context, testInfo, index, customPageController),
                            ),
                          if (_testList[index].status == TestStatus.Running)
                            SizedBox(
                              width: 100.0,
                              height: 40.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SpinKitWave(
                                    color: Theme.of(context).colorScheme.secondary,
                                    size: 15.0,
                                  )
                                ],
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.all(0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: _actionsButtons(index, testInfo, customPageController),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 8),
                      Visibility(
                        visible: _stepText(index).isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _stepText(index),
                            style: theme.textTheme.bodyLarge
                                .copyWith(color: Colors.black),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                      if (testInfo.statusDate != null &&
                          !_changedEquipment(testInfo.serial, index))
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Text("Atualizado em"),
                              SizedBox(width: 4),
                              Text(_format.format(testInfo.statusDate)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          color: _statusColor(index),
                          height: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Resultado do teste"),
                              _resultTest(testInfo),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: testInfo.analyzeItens != null
                              ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...testInfo.analyzeItens.map((e) {
                                return Row(
                                  children: [
                                    if (e.iconColor != null)
                                      Icon(
                                        GoInstallationIcons.getIcon(e.icon),
                                        color: getColor(e.iconColor),
                                      ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(e.name ?? "-"),
                                          Text(e.translate ?? "-"),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          )
                              : _isCamTest(testInfo.key)
                              ? Container()
                              : Text("Sem parâmetros extras analisados"),
                        ),
                        if (testInfo.statusDate != null &&
                            !_changedEquipment(testInfo.serial, index))
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Text("Atualizado em"),
                                SizedBox(width: 4),
                                Text(_format.format(testInfo.statusDate)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );

  }

  Widget _resultTest(TestInfo testInfo) {
    if (testInfo.key.contains("CAM") &&
        testInfo.status != TestStatus.Error &&
        testInfo.status != TestStatus.IgnoredMandatory &&
        testInfo.status != TestStatus.IgnoredNonMandatory &&
        testInfo.statusResult != null &&
        testInfo.statusResult.isNotEmpty) {
      return Image.network(testInfo.statusResult);
    } else {
      return AutoSizeText(
        testInfo.statusResult != null
            ? testInfo.statusResult
            : "Sem informação",
        minFontSize: 12,
      );
    }
  }

  bool _isCamTest(String key) {
    return key.contains("TEST_DVRCAM") ||
        key.contains("TEST_ADASCAM") ||
        key.contains("TEST_VCCAM");
  }


  bool _changedEquipment(String oldSerial, int index) {
    //Caso equipamento seja trocado devera limpar a tela de teste
    if (oldSerial != null &&
        equipmentTestBloc.get() != null &&
        equipmentTestBloc.get() != oldSerial) {
      widget.controller.clearDataTest(index);
      return true;
    }
    return false;
  }

  _actionsButtons(
      int index, TestInfo testInfo, CustomPageController customPageController) {
    var serial =
    _mainEquipmentSerial(customPageController, testInfo.serial, index);
    // if (serial != null || testInfo.key == "TEST_QUERY") {
    switch (testInfo.key) {
      case "TEST_DVRCAM":
        return Row(children: [
          Visibility(
            visible: false, // Torna o botão "Ignorar" invisível
            child: TextButton(
              child: Text(
                "Ignorar",
                textAlign:
                TextAlign.right, //_getStartButtonText(technicalVisit),
                style: TextStyle(color: context.theme.primaryColor),
              ),
              onPressed: () async => _confirmationPageIgnoreTest(
                  context, testInfo, index, customPageController),
            ),
          ),
          dataLoaded
              ? TextButton(
              child: Text(
                this._cams == null || this._cams.listCams.length == 0
                    ? "Sem Câmeras"
                    : "Ver Câmeras",
                textAlign: TextAlign.center,
                style: TextStyle(color: context.theme.primaryColor),
              ),
              onPressed: () async => _onViewCamDVRClick(index, serial))
              : Container()
        ]);
        break;
      case "TEST_ADASCAM":
        return Row(children: [
          Visibility(
            visible: false, // Torna o botão "Ignorar" invisível
            child: TextButton(
              child: Text(
                "Ignorar",
                textAlign:
                TextAlign.right, //_getStartButtonText(technicalVisit),
                style: TextStyle(color: context.theme.primaryColor),
              ),
              onPressed: () async => _confirmationPageIgnoreTest(
                  context, testInfo, index, customPageController),
            ),
          ),
          TextButton(
              child: Text(
                "Ver Foto",
                textAlign: TextAlign.center,
                style: TextStyle(color: context.theme.primaryColor),
              ),
              onPressed: () async =>
                  _onViewCamVCClick(index, technicalVisitId, serial, 2))
        ]);
        break;

      case "TEST_VCCAM":
        return Row(
          children: [
            Visibility(
              visible: false, // Torna o botão "Ignorar" invisível
              child: TextButton(
                child: Text(
                  "Ignorar",
                  textAlign:
                  TextAlign.right, //_getStartButtonText(technicalVisit),
                  style: TextStyle(color: context.theme.primaryColor),
                ),
                onPressed: () async => _confirmationPageIgnoreTest(
                    context, testInfo, index, customPageController),
              ),
            ),
            TextButton(
                child: Text(
                  "Motorista",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.theme.primaryColor),
                ),
                onPressed: () async =>
                    _onViewCamVCClick(index, technicalVisitId, serial, 1)),
            TextButton(
                child: Text(
                  "Inteira",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.theme.primaryColor),
                ),
                onPressed: () async =>
                    _onViewCamVCClick(index, technicalVisitId, serial, 4))
          ],
        );
        break;

      case "TEST_QUERY":
        return TextButton(
          child: Text(
            "Testar JSON",
            textAlign: TextAlign.right,
            style: TextStyle(color: context.theme.primaryColor),
          ),
          onPressed: () async => _confirmationPage(
              context, _testList[index], index, customPageController),
        );
        break;
      default:
        return TextButton(
          child: Text(
            _actionText(index),
            textAlign: TextAlign.right, //_getStartButtonText(technicalVisit),
            style: TextStyle(color: context.theme.primaryColor),
          ),
          onPressed: () async => _confirmationPage(
              context, _testList[index], index, customPageController),
        );
    }
  }


  String _mainEquipmentSerial(
      CustomPageController customPageController, String oldSerial, int index) {
    //Producao
    //return "8019569150";

    //Test Lab
    //return "8019702915";

    if (equipmentTestBloc.get() != null) {
      _changedEquipment(oldSerial, index);
      return equipmentTestBloc.get();
    } else {
      if (customPageController.installation.trackers != null &&
          customPageController.installation.trackers.length > 0) {
        return customPageController.installation.trackers
            .firstWhere((tracker) => tracker.main == true)
            .serial;
      } else {
        return null;
      }
    }
  }

  bool _enableIgnoreOption(int status, String key) {
    if (status != null && status < 0 && key != null && !key.contains("CAM")) {
      return true;
    } else {
      return false;
    }
  }

  String _statusText(int index) {
    if (_changedEquipment(_testList[index].serial, index)) {
      _testList[index].status = TestStatus.Pending;
      return "Pendente";
    }

    switch (_testList[index].status) {
      case -4:
      case -3:
      case -2:
      case -1:
        return "Erro";
        break;
      case 0:
        return "Pendente";
        break;
      case 1:
        return "Sucesso";
        break;
      case 2:
      case 3:
        return "Ignorado";
        break;
      case 4:
        return "Parcial";
        break;
      case 5:
        return "Executando";
        break;
      default:
        return "Pendente";
    }
  }

  String _stepText(int index) {
    return _testList[index].stepDescription != null &&
            _testList[index].stepDescription.isNotEmpty
        ? (_testList[index].step > 0
            ? "Passo " +
                _testList[index].step.toString() +
                ": " +
                _testList[index].stepDescription
            : _testList[index].stepDescription)
        : "";
  }

  String _actionText(int index) {
    if (_testList[index].statusDate == null) {
      return "Iniciar";
    } else {
      switch (_testList[index].status) {
        case -4:
        case -3:
        case -2:
        case -1:
          return "Retestar";
          break;
        case 0:
          return "Iniciar";
          break;
        case 1:
        case 2:
        case 3:
          return "Retestar";
          break;
        case 4:
          return "Continuar";
          break;
        default:
          return "Iniciar";
      }
    }
  }

  Color _statusColor(int index) {
    if (_changedEquipment(_testList[index].serial, index)) {
      _testList[index].status = TestStatus.Pending;
      return Colors.grey[600];
    }

    switch (_testList[index].status) {
      case -4:
        return Colors.purple;
        break;
      case -3:
        return Colors.blue;
        break;
      case -2:
        return Colors.orange;
        break;
      case -1:
        return Colors.red;
        break;
      case 0:
        return Colors.grey[600];
        break;
      case 1:
        return Colors.green;
        break;
      case 2:
        return Colors.orange;
        break;
      case 3:
        return Colors.blue;
        break;
      case 4:
        return Colors.purple;
        break;
      case 5:
        return Colors.grey[700];
        break;
      default:
        return Colors.grey[600];
    }
  }

  void _confirmationPageIgnoreTest(context, TestInfo testInfo, int index,
      CustomPageController customPageController) async {
    widget.controller.updateJustification("");
    showDialog(
      context: context,
      barrierColor: Colors.blue.withOpacity(0.8),
      builder: (context) => ShowUp.tenth(
        duration: 200,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
          title: Text("Ignorar teste"),
          content:
              //Text("O teste será ignorado e salvo com status de erro."),
              SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  ('Você está prestes a ignorar um teste importante.\n' +
                      "Para realizar esta ação informe o motivo logo abaixo."),
                ),
                SizedBox(
                  height: 6,
                ),
                TextField(
                  // style: TextStyle(color: Colors.white),
                  //controller: controller,
                  onChanged: (value) {
                    widget.controller.updateJustification(value);
                    setState(() {});
                  },
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      gapPadding: 2,
                    ),
                    labelText: 'Motivo',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                  ),
                ),
                Visibility(
                    visible: testInfo.require,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        "*Justificativa obrigatória (min 20 caracteres)",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
                child: Text("Sair"), onPressed: Navigator.of(context).pop),
            TextButton(
              child: Text(
                "Ignorar",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              onPressed: () async {
                //Serial default de teste basico
                if (widget.controller.enabledIgnoreButton(index)) {
                  widget.controller.updateAcceptedJustification(index);
                  testInfo.serial = _mainEquipmentSerial(
                      customPageController, null, null); //"1309230873";

                  if (testInfo.technicalVisitId == null) {
                    testInfo.technicalVisitId = technicalVisitId;
                  }

                  if (testInfo.serial != null) {
                    Navigator.of(context).pop();
                    printDebug("Ignorando teste: " + testInfo.name);

                    super.setState(() {
                      widget.controller.updateStartingTest(index);
                    });

                    testInfo = await widget.controller.ignoreTest(testInfo);

                    testInfo =
                        await widget.controller.updateEquipmentTest(testInfo);

                    //Buscar lista de camIds

                    super.setState(() {
                      widget.controller.updateItem(testInfo, index);
                    });
                  } else {
                    printDebug("Sem justificativa");
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmationPage(context, TestInfo testInfo, int index,
      CustomPageController customPageController) async {
    String tipo = (testInfo.statusDate == null
        ? "um teste"
        : testInfo.status == TestStatus.Partial
            ? "próximo passo"
            : "o reteste");
    showDialog(
      context: context,
      barrierColor: Colors.blue.withOpacity(0.8),
      builder: (context) => ShowUp.tenth(
        duration: 200,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
          title: Text("Iniciar " + tipo),
          content: Text("Ao iniciar " +
              tipo +
              " as informações do teste antigo serão perdidas.\nDeseja continuar?"),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text(
                "Não",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            TextButton(
              child: Text(
                "Sim",
              ),
              onPressed: () async {
                Navigator.of(context).pop();

                testInfo.serial = _mainEquipmentSerial(
                    customPageController, null, null); //"1309230873";

                if (testInfo.serial != null || testInfo.key == "TEST_QUERY") {
                  super.setState(() {
                    widget.controller.clearDataTest(index);
                    widget.controller.updateStartingTest(index);
                  });

                  TestInfo testInfoResponse =
                      await widget.controller.startEquipmentTest(testInfo);

                  if (testInfoResponse == null) {
                    testInfo.status = TestStatus.Error;
                  } else {
                    testInfo = testInfoResponse;
                  }

                  super.setState(() {
                    widget.controller.updateItem(testInfo, index);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }
}


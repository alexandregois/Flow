import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dartx/dartx.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flow_flutter/controller/V2Controllers/tech_visit_list_controller.dart';
import 'package:flow_flutter/controller/installation_send_controller.dart';
import 'package:flow_flutter/models/company.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/customer.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/models/installation_type.dart';
import 'package:flow_flutter/models/technical_visit_list.dart';
import 'package:flow_flutter/pages/installation/installation_requirements_page.dart';
import 'package:flow_flutter/pages/tech_visit_list_page.dart';
import 'package:flow_flutter/repository/impl/http_requests.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/installations_icons.dart'
    as installationsIconsDefault;
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/app_bar_flow.dart';
import 'package:flow_flutter/widget/pair_widget.dart';
import 'package:flow_flutter/widget/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import '../installation_list_page.dart';

class BaseTechVisit extends StatefulWidget {
  final bool companyFilter;
  final bool isHistory;

  const BaseTechVisit({
    Key key,
    @required this.companyFilter,
    @required this.isHistory,
  }) : super(key: key);

  @override
  _BaseTechVisitState createState() => _BaseTechVisitState();
}

class _BaseTechVisitState extends State<BaseTechVisit>
    with SingleTickerProviderStateMixin {
  Timer timer;
  CompanyConfigRepository companyConfigRepo;
  Future<CompanyConfig> _companyConfig;
  Future<List<Installation>> _installationList;
  bool finished;
  Companies _selectedCompany;
  ValueNotifier<String> _notifier = ValueNotifier(null);
  String filter = '';
  bool isHistory;

  @override
  void initState() {
    super.initState();

    _selectedCompany = DenoxRequests.selectedCompany;
    companyConfigRepo = context.provide<CompanyConfigRepository>();
    _installationList =
        context.provide<InstallationRepository>().getInstallations();
    if (widget.companyFilter)
      _companyConfig = performCompanyConfig(context);
    else
      _companyConfig = companyConfigRepo.getCompanyConfig();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    this.isHistory = widget.isHistory;

    return Scaffold(
      appBar: AppBarFlow(
          title: 'Visitas Técnicas',
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: SearchWidget(
              text: filter,
              hintText: 'Filtro por placa ou cliente',
              onSearchTap: () {
                if (filter != '') {
                  setState(() {
                    _notifier.value = filter;
                  });
                }
              },
              onSearchKeyboard: (filter) {
                if (filter != '') {
                  setState(() {
                    _notifier.value = filter;
                  });
                }
              },
              onHistoryTap: !this.isHistory
                  ? () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => BaseTechVisit(
                                companyFilter: widget.companyFilter,
                                isHistory: true,
                              )));
                    }
                  : null,
              onChanged: (filter) {
                if (filter.isNotEmpty) {
                  setState(() {
                    this.filter = filter;
                    _notifier.value = filter;
                  });
                }
              },
            ),
          )),
      floatingActionButton: widget.companyFilter &&
              widget.isHistory == false &&
              _selectedCompany.createNewInstallation != null &&
              _selectedCompany.createNewInstallation
          ? FloatingActionButton.extended(
              label: Text("Nova instalação"),
              icon: Icon(Icons.add),
              backgroundColor:
                  Theme.of(context).colorScheme.secondary.withAlpha(230),
              onPressed: () => _onFabClick(context),
            )
          : null,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: FutureBuilder(
              future: _companyConfig,
              builder: (context, snapshot) {
                if (snapshot.hasData)
                  return Column(
                    children: [
                      widget.isHistory == false
                          ? InstallationListPage(
                              companyFilter: widget.companyFilter,
                              baseTechRefresh: refresh,
                              companyConfig: snapshot.data,
                              controller: new TechVisitListController(
                                  requestsRepository:
                                      context.provide<RequestsRepository>(),
                                  installationRepository: context
                                      .provide<InstallationRepository>()))
                          : Container(),
                      ValueListenableBuilder(
                          valueListenable: _notifier,
                          builder: (context, String filter, Widget child) {
                            print("Valor Notifier: " +
                                (_notifier.value ?? "null"));
                            return Expanded(
                                child: TechnicalVisitListPage(
                              isHistory: widget.isHistory,
                              filter: _notifier.value,
                              companyFilter: widget.companyFilter,
                            ));
                          }),
                    ],
                  );
                else
                  return Center(
                    child: SpinKitWave(
                      color: Theme.of(context).colorScheme.secondary,
                      size: 30,
                    ),
                  );
              }),
        ),
      ),
    );
  }

  _onFabClick(BuildContext context) async {
    InstallationType installationType = InstallationType();
    List<InstallationType> installationTypesList = [];
    CompanyConfig companyConfig;
    var list = await _installationList;
    if (widget.companyFilter)
      _companyConfig = performCompanyConfig(context);
    else
      _companyConfig = companyConfigRepo.getCompanyConfig();
    if (list != null && list.count() > 3)
      _errorDialog(context,
          "O limite de instalações abertas simultaneamente foi atingido, por favor termine suas instalações em andamento antes de iniciar outras.");
    else
      showDialog<InstallationType>(
        context: context,
        barrierColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        builder: (context) => ShowUp.tenth(
          duration: 200,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            title: Text("Selecione o tipo da instalação"),
            content: FutureBuilder(
                future: _companyConfig,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    companyConfig = snapshot.data;
                    if (companyConfig.installationTypes.isEmpty)
                      return Text(
                          "Esta empresa não configurou Tipos de Instalação.");
                    companyConfig.installationTypes.forEach((e) {
                      installationTypesList.add(
                          installationType.transform(installationTypes: e));
                    });
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: installationTypesList
                            .map((e) => ListTile(
                                  title: PairWidget(
                                    child1: installationsIconsDefault
                                        .getInstallationIcon(
                                            e.installationTypes, false),
                                    // SizedBox(width: 15),
                                    child2: Flexible(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Text(
                                          e.name,
                                          // minFontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () => Navigator.of(context).pop(e),
                                ))
                            .toList(),
                      ),
                    );
                  }
                  return SpinKitWave(
                    color: Theme.of(context).colorScheme.secondary,
                    size: 30,
                  );
                }),
          ),
        ),
      ).then((type) async {
        if (type == null) return;
        //-----------------------------------------------------------------------------

        AppDataRepository appDataRepository =
            context.provide<AppDataRepository>();
        Future<List<Customer>> customers = appDataRepository.getCustomers();
        Customer currentCustomer = Customer();
        TextEditingController customerEmail = TextEditingController(
          text: currentCustomer.customerEmail,
        );

        if (type.installationTypes.config.isIncludeCustomer == null) {
          type.installationTypes.config.isIncludeCustomer = false;
          print("isIncludeCustomer é nulo");
        }
        if (!type.installationTypes.config.isIncludeCustomer) {
          if (type.installationTypes.config.localType.id == 'G') {
            await processInstallationTypeCargo(
                context, customers, currentCustomer, type, null);
          } else {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => InstallationRequirementsPage(
                  installation: Installation.start(type),
                  installationTypes: type.installationTypes,
                  isContinuation: false,
                ),
              ),
            )
                .then((value) {
              if (value is Installation) {
                context
                    .provide<InstallationSendController>()
                    .start(value.appId);
              }
            });
          }
        } else
          showDialog<Customer>(
            context: context,
            barrierColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.5),
            builder: (context) => ShowUp.tenth(
              duration: 200,
              child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  title: Text("Informe os Dados do Cliente"),
                  actions: [
                    TextButton(
                      child: Text(
                        "Ok",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(currentCustomer);
                      },
                    ),
                  ],
                  content: Container(
                    height: 180,
                    width: MediaQuery.of(context).size.width,
                    child: FutureBuilder(
                        future: customers,
                        builder: (context, snapshot) {
                          if (snapshot.hasData)
                            return Column(
                              children: [
                                DropDownClient(
                                    customerEmail: customerEmail,
                                    currentCustomer: currentCustomer,
                                    customerList: snapshot.data),
                                Expanded(
                                  child: Form(
                                    child: TextFormField(
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      controller: customerEmail,
                                      decoration: InputDecoration(
                                        labelText: 'Email do cliente',
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                      textCapitalization:
                                          TextCapitalization.none,
                                      validator: (value) => EmailValidator
                                              .validate(value)
                                          ? null
                                          : "Por favor insira um email válido",
                                      onChanged: (value) {
                                        currentCustomer.customerEmail = value;
                                        // customerEmail.text = value;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          else
                            return Container();
                        }),
                  )),
            ),
          ).then((customer) async {
            if (customer != null) {
              if (type.installationTypes.config.localType.id == 'G') {
                await processInstallationTypeCargo(
                    context, customers, currentCustomer, type, customer);
              } else {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => InstallationRequirementsPage(
                      installation: Installation.start(type),
                      installationTypes: type.installationTypes,
                      isContinuation: false,
                      customer: customer,
                    ),
                  ),
                )
                    .then((value) {
                  if (finished) {
                    successDialog();
                    Navigator.of(context).pop();
                  }
                });
              }
            } else {
              print("Customer nulo");
            }
          });

        //-----------------------------------------------------------------------------
      });
  }

  Future<void> processInstallationTypeCargo(
      BuildContext context,
      Future<List<Customer>> customers,
      Customer currentCustomer,
      InstallationType type,
      Customer customer) async {
    showDialog<DeviceResponse>(
      context: context,
      barrierColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
      builder: (context) => ShowUp.tenth(
        duration: 200,
        child: DeviceDialog(
            customers: customers, currentCustomer: currentCustomer),
      ),
    ).then((value) async {
      if (value != null) {
        BuildContext dialogContext;

        showDialog(
            context: context,
            barrierColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
            builder: (BuildContext context) {
              dialogContext = context;

              return ShowUp.tenth(
                duration: 200,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    side: BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  title: Text("Iniciando Visita Técnica"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SpinKitWave(
                        color: Theme.of(context).colorScheme.secondary,
                        size: 30,
                      ),
                      Center(
                        child: Text(
                          "Por favor aguarde alguns momentos",
                        ),
                      )
                    ],
                  ),
                ),
              );
            });

        var initialLocation =
            await context.provide<LocationRepository>().getCurrentLatLong();

        var installationStart = await context
            .provide<RequestsRepository>()
            .startInstallationCargo(initialLocation, type.id, null,
                customer?.id, value.visitTypeId, value.serial, value.qrCode);

        Navigator.pop(dialogContext);

        if (installationStart.error != null) {
          _errorDialog(context, installationStart.error);
        } else {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => InstallationRequirementsPage(
                installation: Installation.startFromCloud(
                    installationStart,
                    TechnicalVisit(
                        id: installationStart.id, company: _selectedCompany),
                    initialLocation),
                installationTypes: type.installationTypes,
                isContinuation: true,
                customer: customer,
              ),
            ),
          )
              .then((value) {
            if (finished) {
              successDialog();
              Navigator.of(context).pop();
            }
          });
        }
      }
    });
  }

  bool get wantKeepAlive => true;

  successDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.green.withOpacity(0.9),
      builder: (context) => ShowUp.tenth(
        duration: 200,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(
              color: Colors.green,
              width: 2,
            ),
          ),
          title: ShowUp.fifth(
            key: ValueKey("success"),
            child: Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 40,
            ),
          ),
          content: ShowUp.fifth(
            key: ValueKey("successText"),
            delay: 200,
            child: Text("Instalação enviada com sucesso"),
          ),
        ),
      ),
    );
  }

  void _errorDialog(BuildContext context, String message) {
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
          content: Text(message),
        ),
      ),
    );
  }
}

class DeviceDialog extends StatelessWidget {
  const DeviceDialog({
    Key key,
    @required this.customers,
    @required this.currentCustomer,
  }) : super(key: key);

  final Future<List<Customer>> customers;
  final Customer currentCustomer;

  @override
  Widget build(BuildContext context) {
    TextEditingController _identifier = TextEditingController();

    return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        title: Text("Identificação equipamento"),
        actions: [
          TextButton(
            child: Text(
              "Ok",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            onPressed: () async {
              await processDeviceInfo(
                  _identifier.text.trim().replaceAll(" ", ""), null, context);
            },
          ),
        ],
        content: Container(
          height: 60,
          width: MediaQuery.of(context).size.width,
          child: FutureBuilder(
              future: customers,
              builder: (context, snapshot) {
                if (snapshot.hasData)
                  return Column(
                    children: [
                      Expanded(
                        child: Form(
                          child: TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: _identifier,
                            decoration: InputDecoration(
                              labelText: 'Identificador',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.qr_code),
                                onPressed: () async {
                                  printDebug('qr code scan click');
                                  final scanned =
                                      await FlutterBarcodeScanner.scanBarcode(
                                    "#ff6666",
                                    "Cancelar",
                                    true,
                                    ScanMode.QR,
                                  );

                                  printDebug('Equipamento scaneada: $scanned');
                                  if (scanned != '-1') {
                                    await processDeviceInfo(
                                        null, scanned, context);
                                  }
                                },
                              ),
                            ),
                            textCapitalization: TextCapitalization.none,
                            onChanged: (value) {
                              currentCustomer.customerEmail = value;
                              // customerEmail.text = value;
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                else
                  return Container();
              }),
        ));
  }

  Future<void> processDeviceInfo(
      String serial, String qrCodeScan, BuildContext context) async {
    var visitType = await context
        .provide<RequestsRepository>()
        .getVisityTypeByDevice(serial, qrCodeScan);

    var deviceResponse = DeviceResponse(
        serial: serial, visitTypeId: visitType, qrCode: qrCodeScan);

    Navigator.of(context).pop(deviceResponse);
  }
}

class DropDownClient extends StatefulWidget {
  final TextEditingController customerEmail;
  final Customer currentCustomer;
  final List<Customer> customerList;
  DropDownClient(
      {Key key, this.customerEmail, this.currentCustomer, this.customerList})
      : super(key: key);

  @override
  _DropDownClientState createState() => _DropDownClientState();
}

class _DropDownClientState extends State<DropDownClient> {
  @override
  Widget build(BuildContext context) {
    return OutlineDropdownButton(
      hint: Text("Cliente"),
      inputDecoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        labelText: (widget.currentCustomer == null) ? null : 'Cliente',
      ),
      onChanged: (value) {
        setState(() {
          widget.currentCustomer.id = value;
        });
      },
      value: widget.currentCustomer.id,
      items: widget.customerList
          .map<DropdownMenuItem>(
            (e) => DropdownMenuItem(
              child: AutoSizeText(
                e.name,
                minFontSize: 8,
                maxLines: 2,
              ),
              value: e.id,
            ),
          )
          .toList(),
    );
  }
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

class DeviceResponse {
  String serial;
  String visitTypeId;
  String qrCode;

  DeviceResponse({this.serial, this.visitTypeId, this.qrCode});
}

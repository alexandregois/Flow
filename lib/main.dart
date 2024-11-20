
// lib/main.dart
import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flow_flutter/background_service.dart'; // Adicione esta linha
import 'package:flow_flutter/controller/installation_send_controller.dart';
import 'package:flow_flutter/models/hive/hive_models.dart';
import 'package:flow_flutter/repository/impl/equipment_test_bloc.dart';
import 'package:flow_flutter/repository/impl/geolocator_repository.dart';
import 'package:flow_flutter/repository/impl/hive/app_data_database.dart';
import 'package:flow_flutter/repository/impl/hive/checklist_database.dart';
import 'package:flow_flutter/repository/impl/hive/company_config_database.dart';
import 'package:flow_flutter/repository/impl/hive/device_database.dart';
import 'package:flow_flutter/repository/impl/hive/installation_database.dart';
import 'package:flow_flutter/repository/impl/hive/pictures_to_take_database.dart';
import 'package:flow_flutter/repository/impl/hive/test_database.dart';
import 'package:flow_flutter/repository/impl/hive/vehicle_database.dart';
import 'package:flow_flutter/repository/impl/http_requests.dart';
import 'package:flow_flutter/repository/impl/picture_plate_bloc.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/flow_navigator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(HiveDeviceBrandAdapter());
  Hive.registerAdapter(HiveDeviceModelAdapter());
  Hive.registerAdapter(HiveChecklistItemAdapter());
  Hive.registerAdapter(HivePictureToTakeAdapter());
  Hive.registerAdapter(HiveVehicleBrandAdapter());
  Hive.registerAdapter(HiveVehicleModelAdapter());
  Hive.registerAdapter(HiveCustomerAdapter());
  Hive.registerAdapter(HiveConfigurationAdapter());

  //Installation
  Hive.registerAdapter(HiveTrackerAdapter());
  Hive.registerAdapter(HiveTrackerTechVisitAdapter());
  Hive.registerAdapter(HivePictureInfoAdapter());
  Hive.registerAdapter(HiveLatLongAdapter());
  Hive.registerAdapter(HiveTestInfoAdapter());
  Hive.registerAdapter(HiveTestItemsAdapter());
  Hive.registerAdapter(HiveAnalyzeItemsAdapter());
  Hive.registerAdapter(HiveVehicleInfoAdapter());
  Hive.registerAdapter(HiveChecklistInstallationItemAdapter());
  Hive.registerAdapter(HiveChecklistAdapter());
  Hive.registerAdapter(HiveInstallationStageAdapter());
  Hive.registerAdapter(HiveInstallationAdapter());

  //Company Configuration
  Hive.registerAdapter(HiveCompanyConfigAdapter());
  Hive.registerAdapter(HiveInstallationTypesAdapter());
  Hive.registerAdapter(HiveVehicleTypeAdapter());
  Hive.registerAdapter(HiveLocalTypeAdapter());
  Hive.registerAdapter(HiveFeaturesAdapter());
  Hive.registerAdapter(HiveConfigAdapter());
  Hive.registerAdapter(HiveTestConfigAdapter());
  Hive.registerAdapter(HiveAditionalFieldsAdapter());
  Hive.registerAdapter(HiveBrandsAdapter());
  Hive.registerAdapter(HiveModelsAdapter());
  Hive.registerAdapter(HiveRegisterConfigAdapter());
  Hive.registerAdapter(HiveChecklistConfigAdapter());
  Hive.registerAdapter(HiveCheckListItemsAdapter());
  Hive.registerAdapter(HiveDeviceConfigAdapter());
  Hive.registerAdapter(HivePictureConfigAdapter());
  Hive.registerAdapter(HivePictureItemsAdapter());
  Hive.registerAdapter(HiveFinishConfigAdapter());
  Hive.registerAdapter(HiveRecordTypeAdapter());
  Hive.registerAdapter(HiveFeatureTypeAdapter());
  Hive.registerAdapter(HiveDeviceLogAdapter());
  Hive.registerAdapter(HiveDevicesAdapter());
  Hive.registerAdapter(HiveCompaniesAdapter());
  Hive.registerAdapter(HiveDeviceNewConfigAdapter());
  Hive.registerAdapter(HiveGroupsAdapter());
  Hive.registerAdapter(HiveGroupItemAdapter());
  Hive.registerAdapter(HivePeripheralAdapter());
  Hive.registerAdapter(HiveHardwareFeatureAdapter());
  Hive.registerAdapter(HiveReasonFinishAdapter());


  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final appData = HiveAppData();
  final requestsRepo = DenoxRequests();

  if (await appData.getAccessToken() == null) {
    requestsRepo.setEnvironment(null);
  } else {
    requestsRepo.setEnvironment(await appData.getEnvironment());
  }

  requestsRepo.setAppDataRepository(appData);

  // Inicialização do Firebase
  //await Firebase.initializeApp();

  await SentryFlutter.init(
        (options) {
      options
        ..debug = true
        ..dsn = 'https://fe8a2ec0c54e4058b770a43d037eeca5@o559399.ingest.sentry.io/5721419';
    },
    appRunner: () => runApp(MyApp(
      appData: appData,
      requestsRepo: requestsRepo,
    )),
  );

  //await initializeService(); // Inicializa o serviço em segundo plano
}

class MyApp extends StatefulWidget {
  final AppDataRepository appData;
  final RequestsRepository requestsRepo;

  MyApp({this.appData, this.requestsRepo});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  // Key _mainAppKey = ValueKey(randomInt());
  Future<String> _hasAccessToken;

  @override
  void initState() {
    _hasAccessToken ??= widget.appData.getAccessToken();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await verificarExecucaoMetodo();
    });

    super.initState();
  }

  Future<void> verificarExecucaoMetodo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ultimaExecucaoStr = prefs.getString('ultima_execucao') ?? '';
    DateTime ultimaExecucao = DateTime.tryParse(ultimaExecucaoStr) ?? DateTime(0);
    DateTime now = DateTime.now();

    if (now.hour >= 0 && now.hour < 3 && now.day == ultimaExecucao.day) {
      // Deslogar o usuário
      _performLogout(context);

      // Redirecionar para a tela de login
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }

    await prefs.setString('ultima_execucao', now.toString());
  }

  void _performLogout(BuildContext context) {
    Timer(300.milliseconds, () {
      performLogout(
        appData: Provider.of<AppDataRepository>(context, listen: false),
        devicesRepo: Provider.of<DevicesRepository>(context, listen: false),
        checklistRepo: Provider.of<ChecklistRepository>(context, listen: false),
        picturesRepo: Provider.of<PictureToTakeRepository>(context, listen: false),
        vehiclesRepo: Provider.of<VehiclesRepository>(context, listen: false),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var appName = 'Flow';

    assert(() {
      appName += " Devel";
      return true;
    }());

    var colorScheme = ColorScheme.light(
      primary: const Color(0xFF085394),
      secondary: const Color(0xFFf27800),
      primaryContainer: const Color(0xFF002b66),
      onSecondary: Colors.white,
      onPrimary: Colors.white,
      onError: Colors.white,
    );

    var textTheme = GoogleFonts.quicksandTextTheme();

    var baseTheme = ThemeData(
      primaryColor: colorScheme.primary,
      primaryColorDark: colorScheme.primaryContainer,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        color: colorScheme.primary,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        textTheme: _buildTextTheme(textTheme, color: colorScheme.onPrimary),
      ),
      buttonTheme: ButtonThemeData(
        colorScheme: colorScheme,
        textTheme: ButtonTextTheme.primary,
      ),
    );

    baseTheme = baseTheme.copyWith(
      textTheme: _buildTextTheme(textTheme),
      primaryTextTheme: _buildTextTheme(textTheme, color: colorScheme.onPrimary),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PicturePlateBloc>.value(
          value: PicturePlateBloc(),
        ),
        ChangeNotifierProvider<EquipmentTestBloc>.value(
          value: EquipmentTestBloc(),
        ),
        Provider<AppDataRepository>(create: (_) => widget.appData),
        Provider<RequestsRepository>(create: (_) => widget.requestsRepo),
        Provider<DevicesRepository>(create: (_) => HiveDeviceDatabase()),
        Provider<VehiclesRepository>(create: (_) => HiveVehicleDatabase()),
        Provider<ChecklistRepository>(create: (_) => HiveChecklistDatabase()),
        Provider<TestRepository>(create: (_) => HiveTestDatabase()),
        Provider<CompanyConfigRepository>(create: (_) => HiveCompanyConfigDatabase()),
        Provider<InstallationRepository>(create: (_) => HiveInstallationDatabase()),
        Provider<PictureToTakeRepository>(create: (_) => HivePicturesToTakeDatabase()),
        Provider<LocationRepository>(create: (_) => GeolocatorRepository()),
        InheritedProvider<InstallationSendController>(
          create: (context) => InstallationSendController(
            widget.requestsRepo,
            context.provide<InstallationRepository>(),
          ),
        ),
      ],
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: appName,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'US'), // English
          const Locale('pt', 'PT'), // Portuguese
        ],
        theme: baseTheme,
        home: FlowNavigator(),
      ),
    );
  }

  TextTheme _buildTextTheme(TextTheme baseTheme, {Color color}) =>
      baseTheme.copyWith(
        labelSmall: baseTheme.labelSmall.copyWith(fontSize: 10, color: color),
        bodySmall: baseTheme.bodySmall.copyWith(fontSize: 12, color: color),
        bodyLarge: baseTheme.bodyLarge.copyWith(fontSize: 15, color: color),
        bodyMedium: baseTheme.bodyMedium.copyWith(fontSize: 15, color: color),
        titleSmall: baseTheme.titleSmall.copyWith(fontSize: 13, color: color),
        titleMedium: baseTheme.titleMedium.copyWith(fontSize: 16, color: color),
        titleLarge: baseTheme.titleLarge.copyWith(fontSize: 20, color: color),
        headlineSmall: baseTheme.headlineSmall.copyWith(fontSize: 24, color: color),
        headlineMedium: baseTheme.headlineMedium.copyWith(fontSize: 34, color: color),
        displaySmall: baseTheme.displaySmall.copyWith(fontSize: 48, color: color),
        displayMedium: baseTheme.displayMedium.copyWith(fontSize: 60, color: color),
        displayLarge: baseTheme.displayLarge.copyWith(fontSize: 96, color: color),
      );
}

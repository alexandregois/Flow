import 'package:flow_flutter/pages/asset_pages/asset_list_page.dart';
import 'package:flow_flutter/pages/base_pages/base_tech_visit.dart';
import 'package:flow_flutter/pages/company_page.dart';
import 'package:flow_flutter/pages/funcionality_page.dart';
import 'package:flow_flutter/pages/login_page.dart';
import 'package:flow_flutter/repository/impl/hive/app_data_database.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FlowNavigator extends StatefulWidget {
  @override
  FlowNavigatorState createState() => FlowNavigatorState();
}

class FlowNavigatorState extends State<FlowNavigator> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  FlowPage _selectedPage;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !await _navigatorKey.currentState.maybePop(),
      child: ValueListenableBuilder<Box<String>>(
        valueListenable: Hive.box<String>(HiveAppData.boxAppData).listenable(),
        builder: (context, box, widget) {
          final accessToken = box.get(HiveAppData.appDataAccessToken);

          return Navigator(
            key: _navigatorKey,
            pages: [
              if (accessToken == null)
                MaterialPage(
                  key: ValueKey('loginPage'),
                  child: LoginPage(),
                ),
              if (accessToken != null) ...[
                MaterialPage(
                  key: ValueKey('menusPage'),
                  child: CompanyPage(),
                  // child: FunctionalityPage(),
                ),
                // if (_selectedPage == FlowPage.installationList)
                //   MaterialPage(
                //     key: ValueKey('installation'),
                //     child: BaseInstallationList(),
                //   ),
                if (_selectedPage == FlowPage.techVisit)
                  MaterialPage(
                    key: ValueKey('techVisit'),
                    child: BaseTechVisit(
                      companyFilter: true,
                      isHistory: false,
                    ),
                  ),
                if (_selectedPage == FlowPage.funcionality)
                  MaterialPage(
                      key: ValueKey('funcionality'),
                      child: FunctionalityPage()),
                if (_selectedPage == FlowPage.asset)
                  MaterialPage(
                    key: ValueKey('asset'),
                    child: AssetListPage(),
                  )
                // if (_selectedPage == FlowPage.installationHistory)
                //   MaterialPage(
                //     key: ValueKey('installationHistory'),
                //     child: BaseInstallationHistory(),
                //   ),
              ],
            ],
            onPopPage: _onPopPage,
          );
        },
      ),
    );
  }

  bool _onPopPage(Route route, result) {
    if (!route.didPop(result)) {
      return false;
    }

    setState(() {
      _selectedPage = null;
    });

    return true;
  }

  void selectPage(FlowPage page) {
    setState(() {
      _selectedPage = page;
    });
  }

  static FlowNavigatorState of(BuildContext context) =>
      context.findAncestorStateOfType<FlowNavigatorState>();
}

enum FlowPage {
  installationList,
  techVisit,
  funcionality,
  asset,
  installationHistory
}

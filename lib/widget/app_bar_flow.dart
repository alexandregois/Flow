import 'package:flow_flutter/models/company.dart';
import 'package:flow_flutter/repository/impl/http_requests.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flutter/material.dart';

class AppBarFlow extends StatefulWidget with PreferredSizeWidget {
  const AppBarFlow({Key key, @required this.title, this.bottom})
      : super(key: key);

  final String title;
  final PreferredSizeWidget bottom;

  @override
  _AppBarFlowState createState() => _AppBarFlowState();

  @override
  Size get preferredSize => Size.fromHeight(100.0);
}

class _AppBarFlowState extends State<AppBarFlow> {
  Companies _selectedCompany;

  @override
  void initState() {
    super.initState();

    _selectedCompany = DenoxRequests.selectedCompany;
  }

  @override
  Widget build(BuildContext context) {
    printDebug("Size prefer $kToolbarHeight");

    return AppBar(
      backgroundColor: Colors.white,
      shape: appBarBottomShape,
      centerTitle: true,
      flexibleSpace: gradientAppBar(),
      title: Row(children: [
        Expanded(
            child: Center(
          child: FittedBox(fit: BoxFit.fitWidth, child: Text(widget.title)),
        )),
        _selectedCompany != null
            ? Container(
                height: 30,
                width: 50,
                // color: Colors.white,
                child: Image.network(
                  _selectedCompany.logoURL.contains("http://")
                      ? _selectedCompany.logoURL
                          .replaceFirst("http://", "https://")
                      : _selectedCompany.logoURL,
                ),
              )
            : SizedBox(
                width: 50,
              ),
      ]),
      bottom: widget.bottom,
    );
  }
}

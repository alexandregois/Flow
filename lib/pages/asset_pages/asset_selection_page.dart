import 'package:flow_flutter/utils/util_extensions.dart';
import 'package:flow_flutter/widget/app_bar_flow.dart';
import 'package:flow_flutter/widget/pair_widget.dart';
import 'package:flow_flutter/widget/search_widget.dart';
import 'package:flutter/material.dart';

class AssetSelectionPage extends StatefulWidget {
  const AssetSelectionPage() : super();

  @override
  _AssetSelectionPageState createState() => _AssetSelectionPageState();
}

class _AssetSelectionPageState extends State<AssetSelectionPage> {
  // TextEditingController _filter;
  // ValueNotifier<String> _notifier = ValueNotifier(null);
  String text = '';

  @override
  void initState() {
    super.initState();

    // _filter = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFlow(
          title: "Seleção Ativos",
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: SearchWidget(
              text: text,
              hintText: 'Serial, placa ou id da frota',
              onQrCodeTap: () {},
              onCameraTap: () {},
              onSearchTap: () {},
              onSearchKeyboard: () {},
              onChanged: (text) => setState(() => this.text = text),
            ),
          )),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: PairWidget.horizontal(
                            child1: Icon(
                              Icons.app_registration,
                              size: 22,
                            ),
                            spacing: 8,
                            child2: Text(
                              "Ativos encontrados",
                              style: context.theme.textTheme.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: PairWidget.horizontal(
                            child1: Icon(
                              Icons.app_registration,
                              size: 22,
                            ),
                            spacing: 8,
                            child2: Text(
                              "Ativos selecionados",
                              style: context.theme.textTheme.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}

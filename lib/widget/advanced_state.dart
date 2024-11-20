import 'package:flow_flutter/utils/util_extensions.dart';
import 'package:flutter/material.dart';

abstract class AdvancedState<T extends StatefulWidget> extends State<T> {
  ThemeData get theme => context.theme;

  MediaQueryData get media => context.mediaQuery;

  NavigatorState get navigator => context.navigator;
}

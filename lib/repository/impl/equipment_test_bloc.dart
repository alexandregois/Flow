import 'package:flutter/widgets.dart';

class EquipmentTestBloc extends ChangeNotifier {
  var serialEquipmentTest;

  get() {
    return serialEquipmentTest;
  }

  add(String serialEquipmentTest) {
    this.serialEquipmentTest = serialEquipmentTest;
    notifyListeners();
  }

  remove() {
    this.serialEquipmentTest = null;
  }
}

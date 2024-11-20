import 'package:flow_flutter/controller/basic_controller.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/repository/repositories.dart';

class LocationController extends Stream<LatLong> with BasicController<LatLong> {
  LocationRepository repository;

  LocationController(this.repository) {
    loadLocation();
  }

  void loadLocation() async {
    try {
      var latLong = await repository.getCurrentLatLong();
      print('LatLong received: $latLong');
      add(latLong);
    } catch (e) {
      print(e);
      addError(e);
    }
  }
}

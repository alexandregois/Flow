import 'package:flow_flutter/controller/basic_controller.dart';
import 'package:flow_flutter/controller/location_controller.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/repository/repositories.dart';

enum RequirementStep { geolocation, done }

class TechVisitRequirement {
  RequirementStep step;
  dynamic data;
  bool hasError;

  TechVisitRequirement.geolocation([bool hasError = false])
      : this.step = RequirementStep.geolocation;

  TechVisitRequirement.done(this.data)
      : this.step = RequirementStep.done,
        this.hasError = false;

  @override
  String toString() => '$step [$hasError] [$data]';
}

class TechVisitRequirementsController extends Stream<TechVisitRequirement>
    with BasicController<TechVisitRequirement> {
  LocationController _locationController;

  TechVisitRequirementsController(
    LatLong latlong,
    LocationRepository locationRepository,
  ) {
    add(TechVisitRequirement.geolocation());

    if (latlong != null) {
      add(TechVisitRequirement.done(latlong));
      return;
    }

    _locationController = LocationController(locationRepository);
    _locationController.listen(
      (event) {
        add(
          TechVisitRequirement.done(latlong = event),
        );
      },
      onError: (e) {
        add(TechVisitRequirement.geolocation(true));
      },
    );
  }

  void retryGetLocation() {
    _locationController?.loadLocation();
  }

  @override
  void dispose() {
    _locationController?.dispose();
    super.dispose();
  }
}

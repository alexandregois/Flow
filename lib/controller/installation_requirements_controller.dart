import 'package:flow_flutter/controller/basic_controller.dart';
import 'package:flow_flutter/controller/location_controller.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/repository/repositories.dart';

enum RequirementStep { geolocation, /*preChecklist,*/ done }

class InstallationRequirement {
  RequirementStep step;
  dynamic data;
  bool hasError;

  InstallationRequirement.geolocation([bool hasError = false])
      : this.step = RequirementStep.geolocation;

  InstallationRequirement.done(this.data)
      : this.step = RequirementStep.done,
        this.hasError = false;

  @override
  String toString() => '$step [$hasError] [$data]';
}

class InstallationRequirementsController extends Stream<InstallationRequirement>
    with BasicController<InstallationRequirement> {
  LocationController _locationController;

  InstallationRequirementsController(
    Installation installation,
    LocationRepository locationRepository,
  ) {
    add(InstallationRequirement.geolocation());

    if (installation?.startLocation != null) {
      add(InstallationRequirement.done(installation));
      return;
    }

    _locationController = LocationController(locationRepository);
    _locationController.listen(
      (event) {
        add(
          InstallationRequirement.done(installation..startLocation = event),
        );
      },
      onError: (e) {
        add(InstallationRequirement.geolocation(true));
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

import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/repository/repositories.dart';

class UserLocationService {
  LocationRepository locationRepository;

  UserLocationService(this.locationRepository);

  Future<LatLong> getUserLastLocation() =>
      locationRepository.getCurrentLatLong();
}

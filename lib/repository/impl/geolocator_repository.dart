import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dartx/dartx.dart';

class GeolocatorRepository extends LocationRepository {
  @override
  Future<LatLong> getCurrentLatLong() async {
    var currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: 1.minutes,
    );

    return LatLong(
      latitude: currentPosition.latitude,
      longitude: currentPosition.longitude,
    );
  }
}

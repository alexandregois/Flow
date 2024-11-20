import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/services/user_location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockUserLocation extends Mock implements LocationRepository {}

void main() {
  final mockUserLocation = MockUserLocation();
  UserLocationService service;

  test('User location', () async {
    service = UserLocationService(mockUserLocation);

    when(mockUserLocation.getCurrentLatLong())
        .thenAnswer((realInvocation) async => LatLong(
              latitude: 100,
              longitude: 200,
            ));

    expect(service.getUserLastLocation(), completion(isA<LatLong>()));
  });
}

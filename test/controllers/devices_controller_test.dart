import 'package:dartx/dartx.dart';
import 'package:flow_flutter/controller/V2Controllers/devices_controller.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/utils/installation_step.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ready state', () {
    test('Is not ready with missing information', () async {
      var controller = DevicesController();

      controller.addTracker(Tracker(serial: '1'));

      expect(controller.readyStream.map((e) => e.status),
          emits(ReadyStatus.notReady));
    });

    test('Is not ready with missing installation local', () async {
      var controller = DevicesController(
          // hasInstallationLocals: true,
          );

      controller.addTracker(Tracker(
        serial: '1',
        brandId: 1,
        modelId: 1,
      ));

      await 1.milliseconds.delay;

      expect(controller.readyStream.map((e) => e.status),
          emits(ReadyStatus.notReady));
    });

    test('Is warning with missing automatedTest', () async {
      var controller = DevicesController();

      controller.addTracker(Tracker(
        serial: '1',
        // installationLocal: 1,
        brandId: 1,
        modelId: 1,
      ));

      await 1.milliseconds.delay;

      expect(controller.readyStream.map((e) => e.status),
          emits(ReadyStatus.warning));
    });

    test('Is ready', () async {
      var controller = DevicesController();

      controller.addTracker(Tracker(
        serial: '1',
        installationLocal: 1,
        brandId: 1,
        modelId: 1,
      ));

      var items = await controller.first;
      items.first.automatedTest = AutomatedTest();

      await 10.milliseconds.delay;
      expect(controller.readyStream.map((e) => e.status),
          emits(ReadyStatus.ready));
    });
  });
}

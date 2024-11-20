import 'package:flutter/services.dart';

class BatteryOptimization {
  static const MethodChannel _channel = MethodChannel('com.denox.flow/battery_optimization');

  static Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (e) {
      print("Erro ao solicitar ignorar otimizações de bateria: $e");
    }
  }
}
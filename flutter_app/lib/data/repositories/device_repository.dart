import 'package:flutter/foundation.dart';
import '../models/device_model.dart';
import '../services/demo_data_service.dart';

/// Repository managing ESP32 connection state, heartbeats, and device simulation.
class DeviceRepository extends ChangeNotifier {
  DeviceModel _device = DemoDataService.demoDevice;

  DeviceModel get device => _device;
  bool get isConnected => _device.isConnected;

  /// Simulates heartbeat update from ESP32 or Firebase listener
  void recordHeartbeat() {
    _device = _device.copyWith(
      lastSeen: DateTime.now(),
      status: 'connected',
    );
    notifyListeners();
  }

  /// Toggles device connectivity state for hardware testing / demo
  void toggleConnectionState() {
    if (_device.status == 'connected') {
      _device = _device.copyWith(
        status: 'offline',
        lastSeen: DateTime.now().subtract(const Duration(minutes: 15)),
      );
    } else {
      _device = _device.copyWith(
        status: 'connected',
        lastSeen: DateTime.now(),
      );
    }
    notifyListeners();
  }
}

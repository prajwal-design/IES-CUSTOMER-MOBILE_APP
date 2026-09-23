import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:ies_mobile/models/previous_sensor_value_model.dart';
import 'package:ies_mobile/services/secure_storage_service.dart';
import 'package:ies_mobile/utils/constants.dart';
import 'package:ies_mobile/webservises/rest_api.dart';

class MqttSensorDataProvider extends ChangeNotifier {
  bool isLoading = true;
  bool isNoData = false;
  bool isError = false;
  double R = 0.0;
  double V = 0.0;
  double I = 0.0;

  

  WebSocket? _socket;
  String? _currentSensorId;

  Future<void> fetchAndConnect(String sensorId, String sensorName) async {
    isLoading = true;
    notifyListeners();

    try {
      PreviousSensorValueModel result =
          await RestApi().getSensorPreviousValue(sensorName);

      debugPrint("inside getPreviousResult :");

      R = result.R;
      V = result.V;
      I = result.I;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching previous result: $e");
    }

    await getWebSocketData(sensorId, sensorName, showLoading: false);
  }

  Future<void> getWebSocketData(String? sensorId, String? sensorName, {bool showLoading = true}) async {
    if (showLoading) {
      isLoading = true;
      notifyListeners();
    }

    if (sensorId == null || sensorName == null) {
      debugPrint(
          'getWebSocketData: sensorId or sensorName is null, will not connect');
      isLoading = false;
      notifyListeners();
      return;
    }

    // If already connected to the same sensor, do nothing
    if (_currentSensorId == sensorId && _socket != null) {
      debugPrint('Already connected to $sensorId');
      isLoading = false;
      notifyListeners();
      return;
    }

    // Close existing socket before opening new one
    await _socket?.close();
    _socket = null;

    final token = await SecureStorageService.getAccessToken();

    try {
      _socket = await WebSocket.connect("${ApiEndPoints.webSocketUrl}$token");
      _currentSensorId = sensorId;

      _socket!.listen(
        (data) {
          try {
            final decodedData = jsonDecode(data);
            // Match against either ID or Name to be safe
            if (decodedData["sensor"] == sensorId ||
                decodedData["deviceId"] == sensorName) {
              debugPrint(
                  'sensor data for $sensorName ($sensorId) : $decodedData');

              V = double.tryParse(decodedData["V"]?.toString() ?? "0") ?? 0.0;
              I = double.tryParse(decodedData["I"]?.toString() ?? "0") ?? 0.0;
              R = double.tryParse(decodedData["R"]?.toString() ?? "0") ?? 0.0;

              isLoading = false;
              notifyListeners();
            }
          } catch (e) {
            debugPrint("Error parsing websocket payload: $e");
          }
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          if (_currentSensorId == sensorId) {
            isLoading = false;
            notifyListeners();
          }
          _socket = null;
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          if (_currentSensorId == sensorId) {
            isLoading = false;
            notifyListeners();
          }
          _socket = null;
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('WebSocket connect error: $e');
      isLoading = false;
      notifyListeners();
      _socket = null;
    }
  }

  void disposeSocket() {
    if (_socket != null) {
      R = 0.0;
      V = 0.0;
      I = 0.0;
      isLoading = false;
      notifyListeners();
      debugPrint('Disposing WebSocket');
      _socket!.close();
      _socket = null;
      _currentSensorId = null;
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:ies_mobile/models/previous_sensor_value_model.dart';
import 'package:ies_mobile/utils/constants.dart';
import 'package:ies_mobile/webservises/rest_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MqttSensorDataProvider extends ChangeNotifier {
  bool isLoading = true;
  bool isNoData = false;
  bool isError = false;
  double R = 0.0;
  double V = 0.0;
  double I = 0.0;

  WebSocket? _socket;
  String? _currentSensorId;

  Future getPreviousResult(String sensorName) async {
    PreviousSensorValueModel result =
        await RestApi().getSensorPreviousValue(sensorName);

    debugPrint("inside getPreviousResult :");

    R = result.R;
    V = result.V;
    I = result.I;
    isLoading = false;

    notifyListeners();
  }

  Future<void> getWebSocketData(String? sensorId, String? sensorName) async {
    isLoading = true;
    notifyListeners();

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

    final sp = await SharedPreferences.getInstance();
    final token = sp.getString("AccessToken");

    try {
      _socket = await WebSocket.connect("${ApiEndPoints.webSocketUrl}$token");
      _currentSensorId = sensorId;

      _socket!.listen(
        (data) {
          final decodedData = jsonDecode(data);
          // Match against either ID or Name to be safe
          if (decodedData["sensor"] == sensorId ||
              decodedData["sensor"] == sensorName) {
            debugPrint(
                'sensor data for $sensorName ($sensorId) : $decodedData');

            V = (decodedData["V"] ?? 0).toDouble();
            I = (decodedData["I"] ?? 0).toDouble();
            R = (decodedData["R"] ?? 0).toDouble();

            isLoading = false;
            notifyListeners();
          }
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          if (_currentSensorId == sensorId) {
            isLoading = true;
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

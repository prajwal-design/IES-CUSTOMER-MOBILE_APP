import 'package:flutter/material.dart';
import '../models/all_sensor_model.dart';
import '../webservises/rest_api.dart';


class AllSensorProvider extends ChangeNotifier {
  List<AllSensorModel>? systems;
  bool isLoading = true;
  bool isNoData = false;
  bool isError = false;

  getAllSensors() {

    RestApi().getAllSensors().then((value) {
      isLoading = false;
      systems = value;
      isLoading = false;
      isNoData = false;
      isError = false;
      notifyListeners();

    }).catchError((e,stackTrace) {
      debugPrint("error : $e");
      debugPrint(stackTrace.toString());
      isLoading = false;
      isError = true;
      notifyListeners();
    });

  }
}

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pit_status_model.dart';
import '../webservises/rest_api.dart';

class PitStatusProvider extends ChangeNotifier {

  PitStatusModel? data;
  bool isLoading = true;
  bool isNoData = false;
  bool isError = false;

   getPitStatusFromProvider(String userId) {

    RestApi().getPitStatus(userId).then((value) {
      data = value;
      isLoading = false;
      isNoData = false;
      isError = false;
      notifyListeners();
    }).onError((error, stackTrace) {
      isLoading = false;
      isError = true;
      notifyListeners();
    });
  }

}

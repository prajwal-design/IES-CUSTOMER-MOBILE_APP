import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ies_mobile/webservises/rest_api.dart';
import '../models/user_details_model.dart';

class UserInfoProvider extends ChangeNotifier {
  UserDetailsModel? userDetails;
  bool isLoading = true;
  bool isNoData = false;
  bool isError = false;
  List<Systems> systemsList = [];
  List<Sensors> sensors = [];

  Future<void> getUserInfo(id) async {
    try {
      isLoading = true;
      notifyListeners();

      final value = await RestApi().getUserDetails(id);

      isLoading = false;
      isNoData = false;
      isError = false;
      userDetails = value;

      // systems and sensors
      systemsList = userDetails!.sites!
          .where((site) => site.systems != null)
          .expand((site) => site.systems!)
          .toList();

      sensors = userDetails!.sites!
          .where((site) => site.systems != null)
          .expand((site) => site.systems!)
          .where((system) => system.sensors != null)
          .expand((system) => system.sensors!)
          .toList();

      debugPrint("User details: ${jsonEncode(userDetails!.toJson())}");
      debugPrint("Total Systems: ${systemsList.length}");
      debugPrint("Total Sensors: ${sensors.length}");

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint("system error $e");
      debugPrint(stackTrace.toString());
      isLoading = false;
      isError = true;
      notifyListeners();
    }
  }

  // Use .clear() so UI references keep the same list instance
  void resetActiveInactiveSensors() {
    debugPrint("resetActiveInactiveSensors called");
    notifyListeners();
  }
}

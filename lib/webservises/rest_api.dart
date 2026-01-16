import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ies_mobile/data/base_api_services.dart';
import 'package:ies_mobile/data/network_api_services.dart';
import 'package:ies_mobile/models/previous_sensor_value_model.dart';
import 'package:ies_mobile/models/report_model.dart';
import 'package:ies_mobile/models/sensor_model.dart';
import 'package:ies_mobile/utils/constants.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../models/all_sensor_model.dart';
import '../models/pit_status_model.dart';
import '../models/user_details_model.dart';

class RestApi {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<dynamic> loginUser(email, password) async {
    var data = {"phoneOrEmail": email, "password": password};
    debugPrint("data :$data");
    try {
      dynamic response = await _apiServices.userLogin(ApiEndPoints.login, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AllSensorModel>> getAllSensors() async {
    try {
      dynamic repsponse =
          await _apiServices.postApiResponse(ApiEndPoints.getAllSensors, {});
      return repsponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<PitStatusModel> getPitStatus(String userId) async {
    try {
      final response = await _apiServices.postApiResponse(
          "${ApiEndPoints.getDashBoardData}/$userId", null);

      return PitStatusModel.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint("Error in RestApi.getPitStatus: $e\n$stackTrace");
      rethrow;
    }
  }

  Future<UserDetailsModel> getUserDetails(id) async {
    var response =
        await _apiServices.getApiResponse("${ApiEndPoints.getUserDetails}/$id");
    debugPrint("response : $response");

    UserDetailsModel systemModel = UserDetailsModel.fromJson(response);

    return systemModel;
  }

  Future<List<SensorModel>> getSensorsBySystemId(systemUid) async {
    var response = await _apiServices
        .getApiResponse("${ApiEndPoints.getSensorsBySystemUid}/$systemUid");
    return (response as List)
        .map((system) => SensorModel.fromJson(system))
        .toList();
  }

  Future<ReportModel> getReportsFromApi(data) async {
    var response =
        await _apiServices.postApiResponse(ApiEndPoints.getReports, data);
    ReportModel reportModel = ReportModel.fromJson(response);
    return reportModel;
  }

  Future<PreviousSensorValueModel> getSensorPreviousValue(sensorName) async {
    debugPrint("inside getSensorPreviousValue :");

    var response = await _apiServices
        .getApiResponse("${ApiEndPoints.getSensorPreviousValue}=$sensorName");
    PreviousSensorValueModel previousSensorValueModel =
        PreviousSensorValueModel.fromJson(response);
    return previousSensorValueModel;
  }

  Future<void> downloadReport(Map<String, dynamic> data) async {
    debugPrint("data : $data");
    try {
      final sp = await SharedPreferences.getInstance();
      final bearer = sp.getString('AccessToken');

      if (bearer == null || bearer.isEmpty) {
        debugPrint("AccessToken is missing!");
        return;
      }

      final url = ApiEndPoints.downloadReport;
      debugPrint("Making POST request to $url with payload: $data");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearer',
          'Content-Type': 'application/json',
          'Accept': 'text/csv',
        },
        body: jsonEncode(data),
      );

      debugPrint("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final csvContent = response.body;
        if (csvContent.isEmpty) {
          debugPrint("Empty CSV content received");
          return;
        }

        final bytes = response.bodyBytes;

        String? savePath;

        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          // 🖥 Desktop — show Save As dialog
          savePath = await FilePicker.platform.saveFile(
            dialogTitle: 'Save Report As',
            fileName: 'IES_Report_${DateTime.now().millisecondsSinceEpoch}$reportFileExtension',
            type: FileType.custom,
            allowedExtensions: ['xlsx'],
          );

        } else {
          // 📱 Mobile — ask user to pick a folder
          final directoryPath = await FilePicker.platform.getDirectoryPath(
            dialogTitle: 'Select Folder to Save Report',
          );

          if (directoryPath != null) {
            savePath =
                '$directoryPath/IES_Report_${DateTime.now().millisecondsSinceEpoch}$reportFileExtension';
          } else {
            debugPrint("User canceled folder selection");
            return;
          }
        }

        if (savePath == null) {
          debugPrint("User canceled file/folder selection");
          return;
        }

        final file = File(savePath);
        await file.writeAsBytes(bytes, flush: true);

        debugPrint("File saved successfully at: $savePath");
        await OpenFile.open(savePath);

        final context = navigatorKey.currentContext;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Report saved to: $savePath")),
          );
        }
      } else {
        debugPrint("Failed to download report: ${response.statusCode}");
        debugPrint("Body: ${response.body}");
      }
    } catch (e, st) {
      debugPrint("Error during report download: $e\n$st");
    }
  }
}

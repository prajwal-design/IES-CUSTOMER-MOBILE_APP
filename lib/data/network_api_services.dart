import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:ies_mobile/data/app_exeptions.dart';

import 'package:ies_mobile/data/base_api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetworkApiServices extends BaseApiServices {
  @override
  Future getApiResponse(String url) async {
    dynamic responseJson;

    var sp = await SharedPreferences.getInstance();
    final bearer = sp.getString('AccessToken');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $bearer',
        },
      );
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    }
    return responseJson;
  }

  @override
  Future<dynamic> postApiResponse(String url, dynamic data) async {

    dynamic responseJson;
    final sp = await SharedPreferences.getInstance();
    final bearer = sp.getString('AccessToken');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearer',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      responseJson = returnResponse(response);

    } on SocketException {
      throw FetchDataException("No Internet Connection");
    } catch (e) {
      debugPrint("Error in postApiResponse: $e");
    }
    return responseJson;
  }


  @override
  Future userLogin(String url, data) async {
    dynamic responseJson;

    debugPrint("URL : $url data : $data");

    try {
      final response = await http.post(Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(data));
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    }
    return responseJson;
  }

}

dynamic returnResponse(http.Response response) {
  switch (response.statusCode) {
    case 200:
    case 201:
      dynamic responseJson = jsonDecode(response.body);
      return responseJson;
    case 400:
      throw BadRequestException(response.body.toString());
    case 500:
    case 404:
      throw UnauthorisedException(response.body.toString());
    default:
      throw FetchDataException('Error accured while communicating with server' +
          'with status code' +
          response.statusCode.toString());
  }

}

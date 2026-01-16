import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ies_mobile/view/login_screen.dart';
import 'package:ies_mobile/webservises/rest_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../view/home.dart';

class LoginLogout extends ChangeNotifier{
  dynamic data;
  bool isLoading = true;
  bool isNoData = false;
  bool isError = false;

   Future loginUser(context,email,password)async {

     var sp = await SharedPreferences.getInstance();

    RestApi().loginUser(email, password).then((value){
      data = value;
      isLoading = false;
      isNoData = false;
      isError = false;
      debugPrint("login response : $data");

      sp.setString("UserId", data["user"]["id"], );
      sp.setString("UserName", data["user"]["name"]);
      sp.setString("AccessToken", data["token"]);

      Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const Home(),));
      notifyListeners();

    }).catchError((e,stackTrace){
      debugPrint("error : $e");
      debugPrint(stackTrace.toString());
      isLoading = false;
      isError = true;
      notifyListeners();
    });
  }

  Future<bool> onBackPressed(context) async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text(
          'Do you  want to Logout the App ?',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'No',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => getlogout(context),
            child: const Text(
              'Yes',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    )) ??
        false;
  }

  getlogout(context) async {
    var sp = await SharedPreferences.getInstance();

    sp.clear();
    sp.remove("CustomerId");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) =>
          const LoginScreen()),
          (route) => false,
    );
  }

}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ies_mobile/view/login_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../view/home.dart';

class SplashServices {

   redirectAfter(BuildContext context) async{
     var sp = await SharedPreferences.getInstance();
     Future.delayed(Duration(seconds: 4), () async {
       if (sp.containsKey("AccessToken")) {
         debugPrint("Access token : ${sp.get("AccessToken")}");
         final token = sp.get("AccessToken").toString();

         if (isTokenExpired(token)) {
           debugPrint("Token expired");
           Navigator.pushAndRemoveUntil(context,MaterialPageRoute(
               builder: (BuildContext context) =>
               //LoadingScreen(),
               const LoginScreen()),
                 (route) => false,
           );
         } else {
           debugPrint("Token still valid");
           Navigator.pushAndRemoveUntil(
             context,
             MaterialPageRoute(
                 builder: (BuildContext context) =>
                 //LoadingScreen(),
                 const Home()),
                 (route) => false,
           );
         }

         // Navigator.pushAndRemoveUntil(
         //   context,
         //   MaterialPageRoute(
         //       builder: (BuildContext context) =>
         //       //LoadingScreen(),
         //       const Home()),
         //       (route) => false,
         // );
       } else {
         Navigator.pushAndRemoveUntil(context,MaterialPageRoute(
               builder: (BuildContext context) =>
               //LoadingScreen(),
               const LoginScreen()),
               (route) => false,
         );
       }
     });
  }

   bool isTokenExpired(String token) {
     return JwtDecoder.isExpired(token);
   }
}
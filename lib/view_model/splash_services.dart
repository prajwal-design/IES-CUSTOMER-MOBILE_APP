import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ies_mobile/services/secure_storage_service.dart';
import 'package:ies_mobile/view/login_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../view/home.dart';

class SplashServices {

   redirectAfter(BuildContext context) async {
     Future.delayed(const Duration(seconds: 4), () async {
       final token = await SecureStorageService.getAccessToken();
       if (token != null && token.isNotEmpty) {
         debugPrint("Access token retrieved from secure storage");

         if (isTokenExpired(token)) {
           debugPrint("Token expired");
           if (context.mounted) {
             Navigator.pushAndRemoveUntil(
               context,
               MaterialPageRoute(
                 builder: (BuildContext context) => const LoginScreen(),
               ),
               (route) => false,
             );
           }
         } else {
           debugPrint("Token still valid");
           if (context.mounted) {
             Navigator.pushAndRemoveUntil(
               context,
               MaterialPageRoute(
                 builder: (BuildContext context) => const Home(),
               ),
               (route) => false,
             );
           }
         }
       } else {
         if (context.mounted) {
           Navigator.pushAndRemoveUntil(
             context,
             MaterialPageRoute(
               builder: (BuildContext context) => const LoginScreen(),
             ),
             (route) => false,
           );
         }
       }
     });
  }

   bool isTokenExpired(String token) {
     if (token.isEmpty) return true;
     try {
       return JwtDecoder.isExpired(token);
     } catch (e) {
       return true;
     }
   }
}
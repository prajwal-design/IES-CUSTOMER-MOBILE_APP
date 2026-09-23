import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ies_mobile/res/colors.dart';
import 'package:ies_mobile/view/login_screen.dart';
import 'package:ies_mobile/webservises/rest_api.dart';
import 'package:ies_mobile/services/secure_storage_service.dart';

import '../view/home.dart';

class LoginLogout extends ChangeNotifier {
  dynamic data;
  bool isLoading = true;
  bool isNoData = false;
  bool isError = false;

  Future loginUser(context, email, password) async {
    RestApi().loginUser(email, password).then((value) async {
      data = value;
      isLoading = false;
      isNoData = false;
      isError = false;
      debugPrint("login response : $data");

      if (data["user"] != null && data["user"]["id"] != null) {
        await SecureStorageService.setUserId(data["user"]["id"]);
      }
      if (data["user"] != null && data["user"]["name"] != null) {
        await SecureStorageService.setUserName(data["user"]["name"]);
      }
      if (data["token"] != null) {
        await SecureStorageService.setAccessToken(data["token"]);
      }

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(),
          ));
      notifyListeners();
    }).catchError((e, stackTrace) {
      debugPrint("error : $e");
      debugPrint(stackTrace.toString());
      isLoading = false;
      isError = true;
      notifyListeners();
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Unauthorised request', 'Unauthorized: ')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });
  }

  Future<bool> onBackPressed(context) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: CustomColors.cardColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Logout',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              'Are you sure you want to logout from the app?',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            actions: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'No',
                        style: GoogleFonts.outfit(
                          color: Colors.white60,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => getlogout(context),
                      child: Text(
                        'Yes, Logout',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          ),
        )) ??
        false;
  }

  getlogout(context) async {
    await SecureStorageService.clearAll();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => const LoginScreen()),
      (route) => false,
    );
  }
}

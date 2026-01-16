import "dart:io";

import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:ies_mobile/providers/user_info_provider.dart";
import "package:ies_mobile/view/login_screen.dart";
import "package:ies_mobile/view/reports.dart";
import "package:ies_mobile/view/site_list.dart";
import "package:ies_mobile/view_model/firebase_services.dart";
import "package:jwt_decoder/jwt_decoder.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../providers/loin_logout.dart";
import "../providers/pit_status_provider.dart";
import "../res/colors.dart";
import "dashboard_items.dart";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _index = 0;
  String? name;
  SharedPreferences? sharedPreferences;
  LoginLogout? log;
  PitStatusProvider? pitStatusProvider;
  FireBaseServices fireBaseServices = FireBaseServices();
  UserInfoProvider? userInfoProvider;

  @override
  void initState() {
    super.initState();
    userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
    fireBaseServices.requestNotificationPermission();
    fireBaseServices.firebaseInit();
    fireBaseServices.getFcmTocken().then((value) {
      debugPrint('FCM : $value');
      // saveFcmTokenToFile(value!);
    });
    log = Provider.of<LoginLogout>(context, listen: false);
    getUserInfo().then((val) => {
          setState(() {}),
        });
  }

  Future<String?> getUserInfo() async {
    var sp = await SharedPreferences.getInstance();
    name = sp.getString("UserName");
    var accessToken = sp.getString("AccessToken");

    bool isExpired = JwtDecoder.isExpired(accessToken!);
    if (isExpired) {
      debugPrint("Token is expired ❌");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen(),));
    } else {
      DateTime expirationDate = JwtDecoder.getExpirationDate(accessToken);
      debugPrint("Token is still valid ✅");
      debugPrint("Expires at: $expirationDate");
    }
    var id = sp.get("UserId");
    userInfoProvider!.getUserInfo(id);
    return null;
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: CustomColors.appThemeColor,
      appBar: AppBar(
        backgroundColor: CustomColors.appBarColor,
        elevation: 5,
        shadowColor: Colors.black,
        leading: Container(
            margin: const EdgeInsets.only(left: 20),
            child: CircleAvatar(
                backgroundColor: CustomColors.appThemeColor,
                child: (_index == 0
                    ? const Icon(
                        Icons.home,
                        color: Colors.white,
                      )
                    : _index == 1
                        ? const Icon(Icons.settings, color: Colors.white)
                        : _index == 2
                            ? const Icon(Icons.report, color: Colors.white)
                            : const Icon(Icons.message, color: Colors.white)))),
        title: _index == 0
            ? Text(
                "Home",
                style: textStyle,
              )
            : _index == 1
                ? Text(
                    "Site",
                    style: textStyle,
                  )
                : _index == 2
                    ? Text("Generate Reports", style: textStyle)
                    : Text(
                        "Complaints",
                        style: textStyle,
                      ),
        actions: [

          InkWell(
              onTap: () {
                log!.onBackPressed(context);
              },
              child: const Icon(
                Icons.logout,
                color: Colors.white,
              )),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      body: _index == 0
          ? userDashBoard(width)
          : _index == 1
              ? const SiteList()
              : _index == 2
                  ? const Reports()
                  : const SizedBox(),
      bottomNavigationBar: bottomNavBar(),
    );
  }

  Widget bottomNavBar() {
    return BottomNavigationBar(
      unselectedItemColor: Colors.white70,
      selectedItemColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      backgroundColor: CustomColors.appBarColor,
      elevation: 10,
      currentIndex: _index,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Site",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.report), label: "Reports"),
      ],
      onTap: (value) {
        setState(() {
          _index = value;
        });
      },
    );
  }

  Widget userDashBoard(width) {
    String cutomerId = sharedPreferences != null
        ? sharedPreferences!.getString("UserId")!
        : "";

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 15,
              ),
              Text(
                "Welcome $name",
                style: GoogleFonts.roboto(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(
                height: 10,
              ),
              DashboardItem(
                customerID: cutomerId,
                displayTitle: "No of Earth Pits",
                filter: "All",
              ),
              DashboardItem(
                customerID: cutomerId,
                displayTitle: "Active Earth Pits",
                filter: "Active",
              ),
              DashboardItem(
                customerID: cutomerId,
                displayTitle: "Critical Earth Pits",
                filter: "Critical",
              ),
              DashboardItem(
                customerID: cutomerId,
                displayTitle: "Inactive Earth Pits",
                filter: "Inactive",
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ));
  }
}

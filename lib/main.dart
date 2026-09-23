// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ies_mobile/providers/all_sensor_provider.dart';
import 'package:ies_mobile/providers/loin_logout.dart';
import 'package:ies_mobile/providers/mqtt_sensor_data_provider.dart';
import 'package:ies_mobile/providers/pit_status_provider.dart';
import 'package:ies_mobile/providers/report_provider.dart';
import 'package:ies_mobile/providers/sensor_provider.dart';
import 'package:ies_mobile/providers/user_info_provider.dart';
import 'package:ies_mobile/view/splash_screen.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const Soukhya());
}

class Soukhya extends StatelessWidget {
  const Soukhya({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginLogout>(create: (context) => LoginLogout()),
        ChangeNotifierProvider<PitStatusProvider>(
            create: (context) => PitStatusProvider()),
        ChangeNotifierProvider<AllSensorProvider>(
            create: (context) => AllSensorProvider()),
        ChangeNotifierProvider<UserInfoProvider>(
            create: (context) => UserInfoProvider()),
        ChangeNotifierProvider<SensorProvider>(
            create: (context) => SensorProvider()),
        ChangeNotifierProvider<MqttSensorDataProvider>(
            create: (context) => MqttSensorDataProvider()),
        ChangeNotifierProvider<ReportProvider>(
            create: (context) => ReportProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        title: "IES",
        home: SplashScreen(),
      ),
    );
  }
}

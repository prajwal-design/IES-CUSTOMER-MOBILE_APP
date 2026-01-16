import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:permission_handler/permission_handler.dart';


import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main()async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await requestStoragePermission();
  runApp( Soukhya());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async{
  await Firebase.initializeApp();
}

Future<void> requestStoragePermission() async {
  if (await Permission.storage.request().isGranted) {
    print('Storage permission granted');
  } else {
    print('Storage permission denied');
  }
}


class Soukhya extends StatelessWidget{
   Soukhya({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
        providers: [
          ChangeNotifierProvider<LoginLogout>(create: (context) => LoginLogout()),
          ChangeNotifierProvider<PitStatusProvider>(create: (context) => PitStatusProvider()),
          ChangeNotifierProvider<AllSensorProvider>(create: (context) => AllSensorProvider()),
          ChangeNotifierProvider<UserInfoProvider>(create: (context) => UserInfoProvider()),
          ChangeNotifierProvider<SensorProvider>(create: (context) => SensorProvider()),
          ChangeNotifierProvider<MqttSensorDataProvider>(create: (context) => MqttSensorDataProvider()),
          ChangeNotifierProvider<ReportProvider>(create: (context) => ReportProvider()),
        ],
      child:  MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey:navigatorKey,
        title: "IES",
        home: SplashScreen(),
      ),
    );
  }
}
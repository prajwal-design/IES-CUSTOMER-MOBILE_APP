
import 'package:flutter/cupertino.dart';
import 'package:ies_mobile/webservises/rest_api.dart';

import '../models/sensor_model.dart';

class SensorProvider extends ChangeNotifier{
  List<SensorModel>? sensorLists;
  bool isLoading=true;
  bool isNoData=false;
  bool isError=false;

  getSensorList(systemUid){
    RestApi().getSensorsBySystemId(systemUid).then((value) {
      sensorLists=value;
      isLoading= false;
      isError = false;
      isNoData = false;
      notifyListeners();

    }).catchError((error){
      isLoading=false;
      isError=true;
      notifyListeners();
    });
  }

}
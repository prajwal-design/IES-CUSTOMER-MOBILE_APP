import 'package:flutter/cupertino.dart';
import 'package:ies_mobile/models/report_model.dart';

import '../webservises/rest_api.dart';

class ReportProvider extends ChangeNotifier{
  ReportModel? reportData;
  bool isLoading = true;
  bool isNoData = false;
  bool isError = false;

  getReports(data){
    RestApi().getReportsFromApi(data).then((value){
      reportData = value;
      isLoading = false;
      isError = false;
      isNoData = false;
      debugPrint("data : $data");
      notifyListeners();
    }).onError((error, stackTrace) {
      isLoading = false;
      isError = true;
      notifyListeners();
    });

  }
}
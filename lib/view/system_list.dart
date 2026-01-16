import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ies_mobile/models/user_details_model.dart';
import 'package:ies_mobile/view/sensor_list.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/user_info_provider.dart';
import '../res/colors.dart';

class SystemList extends StatefulWidget {
  final List<Systems> systemList;

  const SystemList({super.key, required this.systemList});

  @override
  State<SystemList> createState() => _SystemListState();
}

class _SystemListState extends State<SystemList> {
  UserInfoProvider? userInfoProvider;

  @override
  void initState() {
    super.initState();
    userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
    getUidNCallGetSystems();
  }

  Future getUidNCallGetSystems() async {
    var sp = await SharedPreferences.getInstance();
    var uid = sp.get("UserId");
    userInfoProvider?.getUserInfo(uid);
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CustomColors.appThemeColor,
        appBar: AppBar(
          backgroundColor: CustomColors.appBarColor,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "Systems",
            style: textStyle,
          ),
          centerTitle: true,
        ),
        body: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.systemList.isEmpty ? 0 : widget.systemList.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.white,width: 1)
                  )
              ),
              child: ListTile(
                onTap: () {
                  final sensors = widget.systemList[index].sensors;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SensorList(
                          sensors: sensors!,
                          systemName: widget.systemList[index].name!,
                        ),
                      ));
                },
                leading: Icon(Icons.settings,
                    color: Colors.greenAccent[200], size: 25),
                trailing: const Icon(Icons.arrow_forward_ios_outlined,
                    color: Colors.white54, size: 20),
                title: Text(
                  widget.systemList[index].name!,
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400),
                ),
              ),
            );
          },
        ));
  }
}

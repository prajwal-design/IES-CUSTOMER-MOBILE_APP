
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ies_mobile/providers/user_info_provider.dart';
import 'package:ies_mobile/res/colors.dart';
import 'package:ies_mobile/view/system_list.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SiteList extends StatefulWidget {
  const SiteList({super.key});

  @override
  State<SiteList> createState() => _SiteListState();
}

class _SiteListState extends State<SiteList> {
  UserInfoProvider? userInfoProvider;
  @override
  void initState() {
    // TODO: implement initState
    userInfoProvider = Provider.of<UserInfoProvider>(context,listen: false);
    getUserInfo();
    super.initState();
  }

  Future getUserInfo()async{
    final sp =await SharedPreferences.getInstance();
    var id = sp.get("UserId");
    userInfoProvider!.getUserInfo(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.appThemeColor,
      body: Consumer<UserInfoProvider>(
          builder: (context, value, child) {
            return ListView.builder(
              itemCount:value.userDetails==null||value.userDetails!.sites!.isEmpty?0:value.userDetails!.sites!.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.white,width: 1)
                      )
                    ),
                    child: ListTile(
                      onTap: (){
                        final systems = value.userDetails!.sites![index].systems;
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SystemList(systemList: systems!,),));
                      },
                       title: Text("${value.userDetails!.sites![index].name}",style: GoogleFonts.roboto(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w400))
                    ),
                  );
                },
            );
          },
      )
    );
  }
}

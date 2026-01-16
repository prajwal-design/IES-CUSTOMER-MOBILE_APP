import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ies_mobile/models/user_details_model.dart';
import 'package:ies_mobile/providers/user_info_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/all_sensor_model.dart';
import '../providers/all_sensor_provider.dart';
import '../providers/pit_status_provider.dart';
import '../res/colors.dart';

class DashboardItem extends StatefulWidget {
  final String customerID;
  final String displayTitle;
  final String filter;

  const DashboardItem({
    super.key,
    required this.customerID,
    required this.displayTitle,
    required this.filter,
  });

  @override
  State<DashboardItem> createState() => _DashboardItemState();
}

class _DashboardItemState extends State<DashboardItem> {
  PitStatusProvider? pitStatusProvider;
  AllSensorProvider? allSensorProvider;
  UserInfoProvider? userInfoProvider;

  @override
  void initState() {
    super.initState();
    pitStatusProvider = Provider.of<PitStatusProvider>(context, listen: false);
    allSensorProvider = Provider.of<AllSensorProvider>(context, listen: false);
    userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);

    getUserID().then((value) {
      pitStatusProvider!.getPitStatusFromProvider(value);
    });
  }

  Future getUserID() async {
    var sp = await SharedPreferences.getInstance();
    return sp.getString("UserId");
  }

  void showPitStatusAlert(double width, List<Sensors> pitS, String displayTitle) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: CustomColors.cardColor,
              title: Text(
                displayTitle,
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              content: SizedBox(
                width: width * 0.4,
                height: width,
                child: ListView.builder(
                  itemCount: pitS.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(
                        Icons.sensors_outlined,
                        color: Colors.greenAccent[200],
                        size: 28,
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Text(
                          pitS[index].name ?? '',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    ).then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    debugPrint("dispose method is called");
    userInfoProvider?.resetActiveInactiveSensors();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () {
        if (widget.filter == "All") {
          showPitStatusAlert(width, userInfoProvider!.sensors, "All sensors");
        } else if (widget.filter == "Active") {
          showPitStatusAlert(width, userInfoProvider!.activeSensors, "Active sensors");
        } else if (widget.filter == "Critical") {
          showPitStatusAlert(width, [], "Critical sensors");
        } else {
          showPitStatusAlert(width, userInfoProvider!.inactiveSensors, "Inactive sensors");
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        width: double.infinity,
        height: width * 0.5,
        decoration: const BoxDecoration(
          color: CustomColors.cardColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(top: width * 0.03),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: widget.filter == "Active"
                    ? Colors.green[800]
                    : widget.filter == "Inactive"
                    ? Colors.red[800]
                    : widget.filter == "Critical"
                    ? Colors.yellow[800]
                    : Colors.blueAccent[800],
                child: const ImageIcon(
                  AssetImage("assets/earth_pit.png"),
                  size: 35,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Consumer<UserInfoProvider>(
              builder: (context, value, child) {
                final count = widget.filter == "All"
                    ? value.sensors.length
                    : widget.filter == "Active"
                    ? value.activeSensors.length
                    : widget.filter == "Inactive"
                    ? value.inactiveSensors.length
                    : 0;

                return Text(
                  count.toString(),
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.displayTitle,
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

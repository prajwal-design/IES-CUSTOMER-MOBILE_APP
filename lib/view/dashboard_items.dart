import 'dart:ui';
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

  void showPitStatusAlert(
      double width, List<Sensors> pitS, String displayTitle) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: CustomColors.cardColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayTitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: pitS.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              "No sensors found",
                              style: GoogleFonts.outfit(
                                color: Colors.white60,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: pitS.length,
                            separatorBuilder: (context, index) =>
                                Divider(color: Colors.white.withOpacity(0.05)),
                            itemBuilder: (context, index) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.sensors_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                title: Text(
                                  pitS[index].name ?? 'Unnamed Sensor',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      backgroundColor: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      "Close",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((value) {
      if (mounted) setState(() {});
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

    final Color accentColor = widget.filter == "Active"
        ? Colors.greenAccent
        : widget.filter == "Inactive"
            ? Colors.redAccent
            : widget.filter == "Critical"
                ? Colors.orangeAccent
                : Colors.blueAccent;

    final IconData cardIcon = widget.filter == "Active"
        ? Icons.check_circle_rounded
        : widget.filter == "Inactive"
            ? Icons.cancel_rounded
            : widget.filter == "Critical"
                ? Icons.warning_rounded
                : Icons.sensors_rounded;

    return InkWell(
      onTap: () {
        if (widget.filter == "All") {
          showPitStatusAlert(width, userInfoProvider!.sensors, "All sensors");
        } else if (widget.filter == "Active") {
          showPitStatusAlert(
              width, userInfoProvider!.activeSensors, "Active sensors");
        } else if (widget.filter == "Critical") {
          showPitStatusAlert(width, [], "Critical sensors");
        } else {
          showPitStatusAlert(
              width, userInfoProvider!.inactiveSensors, "Inactive sensors");
        }
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CustomColors.cardColor.withOpacity(0.45),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: accentColor.withOpacity(0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(cardIcon, color: accentColor, size: 22),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.filter,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: accentColor.withOpacity(0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
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
                  style: GoogleFonts.outfit(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              widget.displayTitle,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: Colors.white54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

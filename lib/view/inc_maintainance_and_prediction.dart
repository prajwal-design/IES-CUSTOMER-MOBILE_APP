import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/mantainance_line_chart.dart';
import '../res/colors.dart';

class IncidentPredAndMain extends StatefulWidget {
  const IncidentPredAndMain({super.key});

  @override
  State<IncidentPredAndMain> createState() => _IncidentPredAndMainState();
}

class _IncidentPredAndMainState extends State<IncidentPredAndMain> {
  String? _selectedValue;
  bool isExpanded=false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: CustomColors.appThemeColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        backgroundColor: CustomColors.appBarColor,
        centerTitle: true,
        title: const Text(
          "Maintenance Details",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        width: width,
        padding: EdgeInsets.only(
            left: width * 0.03,
            right: width * 0.03,
            top: width * 0.1,
            bottom: width * 0.1),
        child: Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: CustomColors.cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      "Pit Name        :  ",
                      style: GoogleFonts.mulish(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "SENSOR - A",
                      style: GoogleFonts.mulish(
                          color: Colors.white54,
                          fontSize: 24,
                          fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      "Recent Serv..  :\ndate                  ",
                      style: GoogleFonts.mulish(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "20/10/2023",
                      style: GoogleFonts.mulish(
                          color: Colors.white54,
                          fontSize: 24,
                          fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      "Next Service  :\ndate                  ",
                      style: GoogleFonts.mulish(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "24/12/2025",
                      style: GoogleFonts.mulish(
                          color: Colors.white54,
                          fontSize: 24,
                          fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      "Valid Till         :",
                      style: GoogleFonts.mulish(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "  23/12/2025",
                      style: GoogleFonts.mulish(
                          color: Colors.white54,
                          fontSize: 24,
                          fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(0),
                margin: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CustomColors.appBarColor, // Border color
                    width: 2, // Border width
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: CustomColors.appBarColor, // Background color of the dropdown button
                ),
                child:  ExpansionTile(
                  dense: true,
                  tilePadding: EdgeInsets.only(left: 5,right: 5),
                  childrenPadding: EdgeInsets.all(0),
                  onExpansionChanged: (val){

                  },
                  title: Text("Service History",
                    style: GoogleFonts.mulish(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w400),),
                  // children: [
                  //   ListTile(title: Text("1st service   : 30/06/2023",
                  //     style: GoogleFonts.mulish(
                  //         color: Colors.white,
                  //         fontSize: 24,
                  //         fontWeight: FontWeight.w400),)),
                  //   ListTile(title: Text("2nd service  : 30/07/2023",
                  //     style: GoogleFonts.mulish(
                  //         color: Colors.white,
                  //         fontSize: 24,
                  //         fontWeight: FontWeight.w400),),),
                  //   ListTile(title: Text("3rd service   : 30/08/2023",
                  //     style: GoogleFonts.mulish(
                  //         color: Colors.white,
                  //         fontSize: 24,
                  //         fontWeight: FontWeight.w400),),),
                  //   ListTile(title: Text("4th service   : 30/09/2023",
                  //     style: GoogleFonts.mulish(
                  //         color: Colors.white,
                  //         fontSize: 24,
                  //         fontWeight: FontWeight.w400),),)
                  // ],
                ),
              ),
              LineChartSample3()
            ],
          ),
        ),
      ),
    );
  }
}

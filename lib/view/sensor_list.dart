import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ies_mobile/models/user_details_model.dart';
import 'package:ies_mobile/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/mqtt_sensor_data_provider.dart';
import '../providers/sensor_provider.dart';
import '../res/colors.dart';
import '../utils/utils.dart';
import 'inc_maintainance_and_prediction.dart';

class SensorList extends StatefulWidget {
  final List<Sensors> sensors;
  final String systemName;
  const SensorList({super.key,required this.sensors,required this.systemName});

  @override
  State<SensorList> createState() => _SensorListState();
}

class _SensorListState extends State<SensorList> {

  SensorProvider? sensorProvider;
  MqttSensorDataProvider? mqttSensorDataProvider;
  int _expandedTileIndex = -1;

  void _handleTileTap( int index,) {
    setState(() {
      _expandedTileIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    mqttSensorDataProvider?.disposeSocket();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    mqttSensorDataProvider = Provider.of<MqttSensorDataProvider>(context,listen: false);

    return Scaffold(
      backgroundColor: CustomColors.appThemeColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        backgroundColor: CustomColors.appBarColor,
        elevation: 5,
        shadowColor: Colors.black54,
        title: Text(
          "${widget.systemName} - Connected Pits",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body:ListView.builder(
        key: Key(_expandedTileIndex.toString()),
        shrinkWrap: true,
        itemCount: widget.sensors.isEmpty?0:widget.sensors.length,
        itemBuilder: (context, index) {
          return Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                const SizedBox(
                  height: 14,
                ),
                ExpansionTileCard(
                  trailing: const Icon(
                      Icons.keyboard_arrow_down_sharp,
                      color: Colors.white,
                      size: 25),
                  leading: Icon(Icons.sensors,
                      color: Colors.greenAccent[200],
                      size: 25),
                  key: Key(index.toString()),
                  initiallyExpanded:
                  (index == _expandedTileIndex),
                  animateTrailing: true,
                  baseColor: CustomColors.cardColor,
                  expandedColor: CustomColors.cardColor,
                  title:Text(
                      widget.sensors[index].name!,
                      style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w400)),
                  children: [
                    pitResistance(),
                    pitVoltage(),
                    pitCurrent()
                  ],
                  onExpansionChanged: (value) {
                    debugPrint("system id: ${widget.sensors[index].name}");
                    mqttSensorDataProvider!.getPreviousResult(widget.sensors[index].name!);
                    _handleTileTap(index);
                    if(value){
                      mqttSensorDataProvider!.getWebSocketData(widget.sensors[index].id!);
                    }else{
                      mqttSensorDataProvider!.disposeSocket();
                    }
                  },
                ),
              ],
            ),
          );
        },
      )
    );
  }

  Widget pitResistance() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(left: 10),
      child: Row(
        children: [
          Text(
            "Resistance :",
            style: GoogleFonts.roboto(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.w400),
          ),
          Consumer<MqttSensorDataProvider>(
              builder: (BuildContext context, value, Widget? child) {

            return Padding(
              padding: const EdgeInsets.only(left: 20),
              child: value.isLoading
                  ? Utils().isLoading(
                      CustomColors.cardColor, CustomColors.appBarColor)
                  : Text(
                      "${value.R}",
                      style: GoogleFonts.roboto(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w400),
                    ),
            );
          }),
        ],
      ),
    );
  }

  Widget pitVoltage() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(left: 10),
      child: Row(
        children: [
          Text(
            "Voltage :",
            style: GoogleFonts.roboto(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.w400),
          ),
          Consumer<MqttSensorDataProvider>(
              builder: (BuildContext context, value, Widget? child) {
            return Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: value.isLoading
                  ? Utils().isLoading(
                      CustomColors.cardColor, CustomColors.appBarColor)
                  : Text(
                      "${value.V}",
                      style: GoogleFonts.roboto(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w400),
                    ),
            );
          }),
        ],
      ),
    );
  }

  Widget pitCurrent() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(left: 10),
      child: Row(
        children: [
          Text(
            "Current : ",
            style: GoogleFonts.roboto(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.w400),
          ),
          Consumer<MqttSensorDataProvider>(
              builder: (BuildContext context, value, Widget? child) {
            return Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: value.isLoading
                  ? Utils().isLoading(
                      CustomColors.cardColor, CustomColors.appBarColor)
                  : Text(
                "${value.I}",
                      style: GoogleFonts.roboto(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w400),
                    ),
            );
          }),
        ],
      ),
    );
  }
}

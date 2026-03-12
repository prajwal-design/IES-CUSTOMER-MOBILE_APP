import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ies_mobile/models/user_details_model.dart';
import 'package:ies_mobile/utils/constants.dart';
import 'package:ies_mobile/webservises/rest_api.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/mqtt_sensor_data_provider.dart';
import '../providers/sensor_provider.dart';
import '../res/colors.dart';
import '../utils/string_utils.dart';
import 'inc_maintainance_and_prediction.dart';

class SensorList extends StatefulWidget {
  final List<Sensors> sensors;
  final String systemName;
  const SensorList(
      {super.key, required this.sensors, required this.systemName});

  @override
  State<SensorList> createState() => _SensorListState();
}

class _SensorListState extends State<SensorList> {
  SensorProvider? sensorProvider;
  MqttSensorDataProvider? mqttSensorDataProvider;
  int _expandedTileIndex = -1;
  Map<String, Maintenance> _maintenanceMap = {};
  bool _isLoadingMaintenance = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  List<Sensors> get _filteredSensors {
    if (_searchQuery.isEmpty) return widget.sensors;
    return widget.sensors.where((sensor) {
      final name = (sensor.name ?? "").toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _handleTileTap(
    int index,
  ) {
    setState(() {
      _expandedTileIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchMaintenanceData();
  }

  Future<void> _fetchMaintenanceData() async {
    try {
      final map = await RestApi().getSensorsWithMaintenance();
      if (mounted) {
        setState(() {
          _maintenanceMap = map;
          _isLoadingMaintenance = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading maintenance: $e");
      if (mounted) {
        setState(() {
          _isLoadingMaintenance = false;
        });
      }
    }
  }

  @override
  void dispose() {
    mqttSensorDataProvider?.disposeSocket();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mqttSensorDataProvider =
        Provider.of<MqttSensorDataProvider>(context, listen: false);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: CustomColors.appThemeColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(width),
            Expanded(
              child: _filteredSensors.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _searchQuery.isNotEmpty
                                ? Icons.search_off_rounded
                                : Icons.sensors_off_rounded,
                            color: Colors.white24,
                            size: 56,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? "No earth pits match \"$_searchQuery\""
                                : "No earth pits available",
                            style: GoogleFonts.outfit(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      key: Key(_expandedTileIndex.toString()),
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredSensors.length,
                      itemBuilder: (context, index) {
                        final sensor = _filteredSensors[index];
                        // Use maintenance from the sensor model if available,
                        // otherwise look it up from the API map
                        final maintenance =
                            sensor.maintenance ?? _maintenanceMap[sensor.id];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTileCard(
                            trailing: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white70,
                                size: 24),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.sensors_rounded,
                                  color: Colors.greenAccent, size: 24),
                            ),
                            key: Key(index.toString()),
                            initiallyExpanded: (index == _expandedTileIndex),
                            animateTrailing: true,
                            baseColor: CustomColors.cardColor.withOpacity(0.4),
                            expandedColor:
                                CustomColors.cardColor.withOpacity(0.6),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            title: Text(
                              sensor.name!.toHumanReadable(),
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  children: [
                                    Divider(
                                        color: Colors.white.withOpacity(0.1)),
                                    const SizedBox(height: 12),
                                    _buildDataRow(
                                      icon: Icons.electrical_services_rounded,
                                      label: "Resistance",
                                      color: Colors.orangeAccent,
                                      child: Consumer<MqttSensorDataProvider>(
                                        builder: (context, value, child) {
                                          return value.isLoading
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                            Colors.white),
                                                  ),
                                                )
                                              : Text(
                                                  "${value.R} \u03A9",
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDataRow(
                                      icon: Icons.bolt_rounded,
                                      label: "Voltage",
                                      color: Colors.yellowAccent,
                                      child: Consumer<MqttSensorDataProvider>(
                                        builder: (context, value, child) {
                                          return value.isLoading
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                            Colors.white),
                                                  ),
                                                )
                                              : Text(
                                                  "${value.V} V",
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDataRow(
                                      icon: Icons.shutter_speed_rounded,
                                      label: "Current",
                                      color: Colors.cyanAccent,
                                      child: Consumer<MqttSensorDataProvider>(
                                        builder: (context, value, child) {
                                          return value.isLoading
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                            Colors.white),
                                                  ),
                                                )
                                              : Text(
                                                  "${value.I} A",
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                );
                                        },
                                      ),
                                    ),
                                    // Maintenance Details Section
                                    const SizedBox(height: 16),
                                    _buildMaintenanceSection(
                                        maintenance, sensor),
                                  ],
                                ),
                              ),
                            ],
                            onExpansionChanged: (value) {
                              mqttSensorDataProvider!
                                  .getPreviousResult(sensor.name!);
                              _handleTileTap(index);
                              if (value) {
                                mqttSensorDataProvider!
                                    .getWebSocketData(sensor.id!, sensor.name!);
                              } else {
                                mqttSensorDataProvider!.disposeSocket();
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceSection(Maintenance? maintenance, Sensors sensor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CustomColors.appBarColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.build_rounded,
                    color: Colors.blueAccent, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                "Maintenance Details",
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (maintenance != null) _buildStatusBadge(maintenance.status),
            ],
          ),
          const SizedBox(height: 14),
          if (_isLoadingMaintenance)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white54),
                  ),
                ),
              ),
            )
          else if (maintenance == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "No maintenance data available",
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: Colors.white38,
                  ),
                ),
              ),
            )
          else ...[
            _buildMaintenanceRow(
              icon: Icons.history_rounded,
              label: "Last Maintenance",
              value: maintenance.lastMaintenanceDate ?? "N/A",
              color: Colors.amberAccent,
            ),
            const SizedBox(height: 10),
            _buildMaintenanceRow(
              icon: Icons.schedule_rounded,
              label: "Next Maintenance",
              value: maintenance.nextMaintenanceDate ?? "N/A",
              color: Colors.lightGreenAccent,
            ),
            if (maintenance.maintainerName != null) ...[
              const SizedBox(height: 10),
              _buildMaintenanceRow(
                icon: Icons.person_outline_rounded,
                label: "Maintainer",
                value: maintenance.maintainerName!,
                color: Colors.purpleAccent,
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IncidentPredAndMain(
                        sensorName: sensor.name?.toHumanReadable() ?? "Sensor",
                        lastMaintenanceDate: maintenance.lastMaintenanceDate,
                        nextMaintenanceDate: maintenance.nextMaintenanceDate,
                        maintainerName: maintenance.maintainerName,
                        maintenanceNotes: maintenance.maintenanceNotes,
                        status: maintenance.status,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blueAccent.withOpacity(0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side:
                        BorderSide(color: Colors.blueAccent.withOpacity(0.25)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(
                  "View Full Details",
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color badgeColor;
    String label = status ?? "N/A";
    switch (status?.toUpperCase()) {
      case "COMPLETED":
        badgeColor = Colors.greenAccent;
        break;
      case "PENDING":
        badgeColor = Colors.amberAccent;
        break;
      case "OVERDUE":
        badgeColor = Colors.redAccent;
        break;
      default:
        badgeColor = Colors.white38;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: badgeColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMaintenanceRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color.withOpacity(0.7), size: 16),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: Colors.white54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(double width) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 15, 24, 20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff1A4B9F),
            CustomColors.appBarColor,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.systemName.toHumanReadable(),
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: Colors.white54,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Earth Pits",
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${widget.sensors.length} Total",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white60,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildDataRow({
    required IconData icon,
    required String label,
    required Color color,
    required Widget child,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        child,
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
        cursorColor: Colors.orangeAccent,
        decoration: InputDecoration(
          hintText: "Search earth pits...",
          hintStyle: GoogleFonts.outfit(color: Colors.white30, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded,
              color: Colors.white.withOpacity(0.3), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: Colors.white.withOpacity(0.3), size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = "");
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        ),
      ),
    );
  }
}

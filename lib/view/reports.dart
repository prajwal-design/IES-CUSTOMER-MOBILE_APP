import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ies_mobile/webservises/rest_api.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/report_provider.dart';
import '../providers/user_info_provider.dart';
import '../res/colors.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  TextEditingController? fromDateController;
  TextEditingController? toDateController;

  var fDate = "From Date";
  var tDate = "To date";
  var deviceID = "";

  bool isData = false;

  ReportProvider? reportProvider;
  UserInfoProvider? userInfoProvider;

  String formatToHHMM(String isoTime) {
    DateTime dateTime = DateTime.parse(isoTime).toLocal();
    String hh = dateTime.hour.toString().padLeft(2, '0');
    String mm = dateTime.minute.toString().padLeft(2, '0');
    return "$hh:$mm";
  }

  @override
  void initState() {
    super.initState();

    reportProvider = Provider.of<ReportProvider>(context, listen: false);
    userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      reportProvider!.reportData = null;
      reportProvider!.isLoading = false;
      reportProvider!.isError = false;
      reportProvider!.isNoData = false;
      reportProvider!.notifyListeners();
    });

    fromDateController = TextEditingController();
    toDateController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: CustomColors.appThemeColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(width),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  children: [
                    // Generate Report Card
                    _buildGenerateCard(),
                    const SizedBox(height: 16),
                    // Active filters display
                    if (isData && fDate != "From Date") _buildActiveFilters(),
                    if (isData && fDate != "From Date")
                      const SizedBox(height: 16),
                    // Report content
                    if (!isData) _buildEmptyState() else showReport(width),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer<ReportProvider>(
        builder: (context, snap, child) {
          if (snap.reportData != null &&
              snap.reportData!.content != null &&
              snap.reportData!.content!.isNotEmpty) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                backgroundColor: const Color(0xff1A4B9F),
                icon: const Icon(Icons.download_rounded,
                    color: Colors.white, size: 20),
                label: Text(
                  "Download",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onPressed: () {
                  final startDateTime = DateTime(
                    selectedFromDate.year,
                    selectedFromDate.month,
                    selectedFromDate.day,
                  ).toUtc();

                  final endDateTime = DateTime(
                    selectedToDate.year,
                    selectedToDate.month,
                    selectedToDate.day,
                    23,
                    59,
                    59,
                    999,
                    999,
                  ).toUtc();

                  final payload = {
                    "deviceId": deviceID,
                    "startTime": startDateTime.toIso8601String(),
                    "endTime": endDateTime.toIso8601String(),
                    "isCriticalReport": false,
                  };

                  debugPrint("payload : $payload");
                  RestApi().downloadReport(payload);
                },
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildGenerateCard() {
    return InkWell(
      onTap: () => showCustomDialog(),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.analytics_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Generate Report",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Select date range & sensor to view logs",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CustomColors.cardColor.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_alt_rounded,
              color: Colors.blueAccent.withOpacity(0.6), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$fDate  →  $tDate  •  $deviceID",
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.white54,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () => showCustomDialog(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Edit",
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.analytics_outlined,
                size: 56, color: Colors.white.withOpacity(0.15)),
          ),
          const SizedBox(height: 20),
          Text(
            "No Reports Yet",
            style: GoogleFonts.outfit(
              color: Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Tap the button above to configure\nand generate a new report",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white30,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget showReport(double width) {
    return Consumer<ReportProvider>(
      builder: (context, snap, child) {
        if (snap.isLoading ||
            snap.isNoData ||
            snap.isError ||
            snap.reportData?.content == null ||
            snap.reportData!.content!.isEmpty) {
          IconData stateIcon;
          String title;
          String subtitle;

          if (snap.isLoading) {
            return Container(
              margin: const EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Fetching logs...",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            );
          } else if (snap.isNoData) {
            stateIcon = Icons.inbox_rounded;
            title = "No Records Found";
            subtitle = "No data available for the selected period";
          } else if (snap.isError) {
            stateIcon = Icons.error_outline_rounded;
            title = "Unable to Load";
            subtitle = "Please check your connection and try again";
          } else {
            stateIcon = Icons.analytics_outlined;
            title = "Ready";
            subtitle = "Configure and generate your report";
          }

          return Container(
            margin: const EdgeInsets.only(top: 60),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(stateIcon,
                      size: 48, color: Colors.white.withOpacity(0.2)),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: Colors.white30,
                  ),
                ),
              ],
            ),
          );
        }

        final data = snap.reportData!.content!;
        final double totalWidth = 60 + 80 + 80 + 80 + 120 + 120;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Results",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${data.length} records",
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.blueAccent.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: BoxDecoration(
                color: CustomColors.cardColor.withOpacity(0.45),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: totalWidth,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.06),
                              Colors.white.withOpacity(0.03),
                            ],
                          ),
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.white.withOpacity(0.08)),
                          ),
                        ),
                        child: Row(
                          children: [
                            _headerCell("SL", 60),
                            _headerCell("RES (Ω)", 80),
                            _headerCell("VOL (V)", 80),
                            _headerCell("CUR (A)", 80),
                            _headerCell("DATE", 120),
                            _headerCell("TIME", 120),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: data.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final element = data[index];
                            String date = "-";
                            String time = "-";

                            if (element.timestamp != null) {
                              final utc = DateTime.parse(element.timestamp!);
                              final ist = utc.toLocal();
                              date = DateFormat('MMM dd, yyyy').format(ist);
                              time = DateFormat('hh:mm a').format(ist);
                            }

                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: Colors.white.withOpacity(0.04)),
                                ),
                                color: index % 2 == 0
                                    ? Colors.transparent
                                    : Colors.white.withOpacity(0.015),
                              ),
                              child: Row(
                                children: [
                                  _bodyCell("${index + 1}", 60, isSlNo: true),
                                  _bodyCell(
                                      element.resistance?.toStringAsFixed(2) ??
                                          "-",
                                      80),
                                  _bodyCell(
                                      element.voltage?.toStringAsFixed(2) ??
                                          "-",
                                      80),
                                  _bodyCell(
                                      element.current?.toStringAsFixed(2) ??
                                          "-",
                                      80),
                                  _bodyCell(date, 120),
                                  _bodyCell(time, 120),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(double width) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
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
          Text(
            "DATA LOGS",
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: Colors.white54,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Reports",
            style: GoogleFonts.outfit(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          color: Colors.white70,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _bodyCell(String value, double width, {bool isSlNo = false}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.03), width: 1),
        ),
      ),
      child: Text(
        value,
        style: GoogleFonts.outfit(
          color: isSlNo ? Colors.white38 : Colors.white.withOpacity(0.85),
          fontSize: 13,
          fontWeight: isSlNo ? FontWeight.w400 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget fromDate() {
    return TextField(
      controller: fromDateController,
      style: GoogleFonts.outfit(color: Colors.white),
      decoration: InputDecoration(
        labelText: "From Date",
        labelStyle: GoogleFonts.outfit(color: Colors.white54),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        suffixIcon: Container(
          margin: const EdgeInsets.only(right: 8),
          child: const Icon(Icons.calendar_today_rounded,
              color: Colors.blueAccent, size: 18),
        ),
      ),
      readOnly: true,
      onTap: () => _selectDate(context, "from"),
    );
  }

  Widget toDate() {
    return TextField(
      controller: toDateController,
      style: GoogleFonts.outfit(color: Colors.white),
      decoration: InputDecoration(
        labelText: "To Date",
        labelStyle: GoogleFonts.outfit(color: Colors.white54),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        suffixIcon: Container(
          margin: const EdgeInsets.only(right: 8),
          child: const Icon(Icons.calendar_today_rounded,
              color: Colors.blueAccent, size: 18),
        ),
      ),
      readOnly: true,
      onTap: () => _selectDate(context, "to"),
    );
  }

  DateTime selectedFromDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();

  Future _selectDate(BuildContext context, String toOrFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toOrFrom == "from" ? selectedFromDate : selectedToDate,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (toOrFrom == "from") {
          selectedFromDate = picked;
          fDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
          fromDateController!.text = fDate;
        } else {
          selectedToDate = picked;
          tDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
          toDateController!.text = tDate;
        }
      });
    }
  }

  Future callGetMethod(String fDate, String tDate) async {
    final DateTime startDateTime = DateTime(
            selectedFromDate.year, selectedFromDate.month, selectedFromDate.day)
        .toUtc();

    final DateTime endDateTime = DateTime(
      selectedToDate.year,
      selectedToDate.month,
      selectedToDate.day,
      23,
      59,
      59,
      999,
      999,
    ).toUtc();

    final payload = {
      "deviceId": deviceID,
      "startTime": startDateTime.toIso8601String(),
      "endTime": endDateTime.toIso8601String(),
      "isCriticalReport": false,
    };

    debugPrint("Calling getReports with: $payload");
    await reportProvider!.getReports(payload);
  }

  Future<void> _showSensorSearchDialog(
      BuildContext context,
      UserInfoProvider provider,
      void Function(void Function()) setStateDialog) async {
    String searchQuery = '';

    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSearch) {
            final filteredList = provider.sensors.where((s) {
              final name = s.name?.toLowerCase() ?? '';
              final id = s.id?.toLowerCase() ?? '';
              final query = searchQuery.toLowerCase();
              return name.contains(query) || id.contains(query);
            }).toList();

            return Dialog(
              backgroundColor: CustomColors.cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxHeight: 400),
                child: Column(
                  children: [
                    TextField(
                      style: GoogleFonts.outfit(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search sensor...",
                        hintStyle: GoogleFonts.outfit(color: Colors.white54),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.blueAccent),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (val) {
                        setStateSearch(() => searchQuery = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filteredList.isEmpty
                          ? Center(
                              child: Text("No sensors found",
                                  style: GoogleFonts.outfit(
                                      color: Colors.white54)))
                          : ListView.builder(
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final sensor = filteredList[index];
                                return ListTile(
                                  title: Text(sensor.name ?? 'Unnamed Sensor',
                                      style: GoogleFonts.outfit(
                                          color: Colors.white)),
                                  subtitle: Text(sensor.id ?? '',
                                      style: GoogleFonts.outfit(
                                          color: Colors.white54, fontSize: 12)),
                                  onTap: () {
                                    Navigator.pop(context, sensor.name);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      setStateDialog(() => deviceID = selected);
    }
  }

  Future showCustomDialog() {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: CustomColors.cardColor.withOpacity(0.9),
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.tune_rounded,
                            color: Colors.blueAccent, size: 28),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        "Configure Report",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Select date range and sensor",
                        style: GoogleFonts.outfit(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                      fromDate(),
                      const SizedBox(height: 14),
                      toDate(),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.white.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Consumer<UserInfoProvider>(
                            builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white)),
                            );
                          }
                          String displayText = "Select sensor";
                          if (deviceID.isNotEmpty) {
                            final matches = provider.sensors
                                .where((s) => s.name == deviceID)
                                .toList();
                            if (matches.isNotEmpty) {
                              displayText = matches.first.name ?? deviceID;
                            } else {
                              displayText = deviceID;
                            }
                          }

                          return InkWell(
                            onTap: () => _showSensorSearchDialog(
                                context, provider, setStateDialog),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.sensors_rounded,
                                      color: Colors.blueAccent, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      displayText,
                                      style: GoogleFonts.outfit(
                                          color: deviceID.isEmpty
                                              ? Colors.white54
                                              : Colors.white,
                                          fontSize: 16),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down,
                                      color: Colors.white54),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                      color: Colors.white.withOpacity(0.08)),
                                ),
                              ),
                              child: Text("Cancel",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white54,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              onPressed: () async {
                                await callGetMethod(fDate, tDate);
                                setState(() {
                                  isData = true;
                                });
                                Navigator.pop(dialogContext);
                              },
                              child: Text("Generate Report",
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 15,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

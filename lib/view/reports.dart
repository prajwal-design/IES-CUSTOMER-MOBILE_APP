import 'package:flutter/material.dart';
import 'package:ies_mobile/webservises/rest_api.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';

import '../providers/report_provider.dart';
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
  var fTime = "From Time";
  var tTime = "To Time";
  var deviceID = "";

  bool isData = false;

  ReportProvider? reportProvider;

  String formatToHHMM(String isoTime) {
    DateTime dateTime = DateTime.parse(isoTime).toLocal(); // convert to local time
    String hh = dateTime.hour.toString().padLeft(2, '0');
    String mm = dateTime.minute.toString().padLeft(2, '0');
    return "$hh:$mm";
  }

  @override
  void initState() {
    super.initState();

    reportProvider = Provider.of<ReportProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      reportProvider!.reportData = null;
      reportProvider!.isLoading = false;
      reportProvider!.isError = false;
      reportProvider!.isNoData = false;
      reportProvider!.notifyListeners();
    });

    fromDateController = TextEditingController();
    toDateController = TextEditingController();
    // add these if you want time pickers too:
    // fromTimeController = TextEditingController();
    // toTimeController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: width * 0.03),
          // showColumn(),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(CustomColors.appBarColor),
                ),
                onPressed: () {
                  showCustomDialog();
                },
                child: Text(
                  "Generate Report",
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                )),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  !isData
                      ? Text(
                          "",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        )
                      : showReport(width)
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<ReportProvider>(
        builder: (context, snap, child) {
          if (snap.reportData != null &&
              snap.reportData!.content != null &&
              snap.reportData!.content!.isNotEmpty) {
            return FloatingActionButton(
              backgroundColor: CustomColors.appBarColor,
              child: const Icon(
                Icons.arrow_downward_outlined,
                color: Colors.white70,
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
                }
            );
          } else {
            return const SizedBox.shrink(); // 🧩 Hide FAB when no data
          }
        },
      ),
    );
  }

  Widget showColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 40,
                width: MediaQuery.of(context).size.width * 0.37,
                child: fromDate()),
            const SizedBox(
              width: 15,
            ),
            SizedBox(
                height: 40,
                width: MediaQuery.of(context).size.width * 0.37,
                child: toDate()),
            const SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                callGetMethod(fDate, tDate).then((value) {
                  setState(() {
                    isData = true;
                  });
                });
              },
              child: const CircleAvatar(
                backgroundColor: CustomColors.appBarColor,
                child: Icon(
                  Icons.arrow_forward_ios_sharp,
                  size: 25,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ],
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
          String message = snap.isLoading
              ? "Loading"
              : snap.isNoData
              ? "No Data Found"
              : snap.isError
              ? "Something went wrong"
              : "Data is loading OR No Data Found...";

          return Container(
            margin: EdgeInsets.only(top: width * 0.7),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
          );
        }

        final data = snap.reportData!.content!;

        // Total width is sum of all column widths:
        final double totalWidth = 60 + 80 + 80 + 80 + 120 + 120;

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,

          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalWidth, // total table width
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Container(
                    color: Colors.blueGrey.shade50,
                    child: Row(
                      children: [
                        _headerCell("SL.NO", 60),
                        _headerCell("R", 80),
                        _headerCell("V", 80),
                        _headerCell("I", 80),
                        _headerCell("Date", 120),
                        _headerCell("Time", 120),
                      ],
                    ),
                  ),

                  // TABLE BODY (vertical scroll)
                  Expanded(
                    child: ListView.builder(
                      itemCount: data.length,
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final element = data[index];
                        String date = "-";
                        String time = "-";

                        if (element.timestamp != null) {
                          final utc = DateTime.parse(element.timestamp!);
                          final ist = utc.toLocal();
                          date = DateFormat('yyyy-MM-dd').format(ist);
                          time = DateFormat('HH:mm').format(ist);
                          debugPrint("Time coming from server is : "+ time);
                        }

                        return Row(
                          children: [
                            _bodyCell("${index + 1}", 60),
                            _bodyCell(element.resistance?.toStringAsFixed(2) ?? "-", 80),
                            _bodyCell(element.voltage?.toStringAsFixed(2) ?? "-", 80),
                            _bodyCell(element.current?.toStringAsFixed(2) ?? "-", 80),
                            _bodyCell(date, 120),
                            _bodyCell(time, 120),
                          ],
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );

      },
    );
  }

  Widget _headerCell(String label, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _bodyCell(String value, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      alignment: Alignment.centerLeft,
      child: Text(value),
    );
  }


  Widget fromDate() {
    return TextField(
      controller: fromDateController,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(10),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
        ),
        hintText: "From Date",
        // keep static hint
        suffixIcon: Icon(
          Icons.calendar_today,
          color: Colors.black.withOpacity(0.5),
        ),
      ),
      readOnly: true,
      onTap: () => _selectDate(context, "from"),
    );
  }

  Widget toDate() {
    return TextField(
      controller: toDateController,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(10),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
        ),
        hintText: "To Date",
        suffixIcon: Icon(
          Icons.calendar_today,
          color: Colors.black.withOpacity(0.5),
        ),
      ),
      readOnly: true,
      onTap: () => _selectDate(context, "to"),
    );
  }

  Widget fromTime() {
    return TextField(
      controller: fromDateController,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(10),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
        ),
        hintText: fTime,
        hintStyle: TextStyle(
          color: Colors.black.withOpacity(0.5),
          fontWeight: FontWeight.w500,
        ),
        suffixIcon: Icon(
          Icons.arrow_drop_down_circle_outlined,
          color: Colors.black.withOpacity(0.5),
        ),
      ),
      obscureText: false,
      readOnly: true,
      onTap: () {
        _selectTime(context, 'from');
      },
    );
  }

  DateTime selectedFromDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();

  TimeOfDay selectedFromTime = TimeOfDay.now();
  TimeOfDay selectedToTime = TimeOfDay.now();

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
          fromDateController!.text = fDate; // ✅ update controller
        } else {
          selectedToDate = picked;
          tDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
          toDateController!.text = tDate; // ✅ update controller
        }
      });
    }
  }

  Future _selectTime(BuildContext context, String toOrFrom) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: toOrFrom == 'from' ? selectedFromTime : selectedToTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        if (toOrFrom == 'from') {
          selectedFromTime = pickedTime;
          fTime = "${pickedTime.format(context)}:00";
          debugPrint("Selected From Time $fTime");
        } else {
          selectedToTime = pickedTime;
          tTime = "${pickedTime.format(context)}:00";
          debugPrint("Selected To Time $tTime");
        }
      });
    }
  }

  Future callGetMethod(String fDate, String tDate) async {
    final DateTime startDateTime = DateTime(
        selectedFromDate.year, selectedFromDate.month, selectedFromDate.day).toUtc();

    final DateTime endDateTime = DateTime(
      selectedToDate.year,
      selectedToDate.month,
      selectedToDate.day,
      23,
      // hour
      59,
      // minute
      59,
      // second
      999,
      // millisecond
      999, // microsecond (optional, ensures very end of the day)
    ).toUtc();

    final payload = {
      "deviceId": deviceID, // Use dynamic deviceId if needed
      "startTime": startDateTime.toIso8601String(),
      "endTime": endDateTime.toIso8601String(),
      "isCriticalReport": false,
    };

    debugPrint("Calling getReports with: $payload");

    await reportProvider!.getReports(payload);
  }

  Future showCustomDialog() {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return AlertDialog(
              alignment: Alignment.center,
              title: Center(child: const Text("Generate report")),
              content: Column(
                mainAxisSize: MainAxisSize.min, // shrink to fit content
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    child: fromDate(),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    child: toDate(),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      hint: const Text("Select sensor"),
                      underline: const SizedBox(),
                      value: deviceID.isEmpty ? null : deviceID,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: "IES-0001",
                          child: Text("IES-0001"),
                        ),
                        DropdownMenuItem(
                          value: "IES-0002",
                          child: Text("IES-0002"),
                        ),
                      ],
                      onChanged: (item) {
                        setStateDialog(() => deviceID = item!);
                      },
                    ),
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => {Navigator.pop(context)},
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await callGetMethod(fDate, tDate);
                    setState(() {
                      isData = true;
                    });
                    Navigator.pop(dialogContext);
                  },
                  child: const Text("Generate"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

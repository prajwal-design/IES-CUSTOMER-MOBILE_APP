import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ies_mobile/models/user_details_model.dart';
import 'package:ies_mobile/view/sensor_list.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/user_info_provider.dart';
import '../res/colors.dart';
import '../utils/string_utils.dart';

class SystemList extends StatefulWidget {
  final List<Systems> systemList;

  const SystemList({super.key, required this.systemList});

  @override
  State<SystemList> createState() => _SystemListState();
}

class _SystemListState extends State<SystemList> {
  UserInfoProvider? userInfoProvider;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
    getUidNCallGetSystems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future getUidNCallGetSystems() async {
    var sp = await SharedPreferences.getInstance();
    var uid = sp.get("UserId");
    userInfoProvider?.getUserInfo(uid);
  }

  List<Systems> get _filteredSystems {
    if (_searchQuery.isEmpty) return widget.systemList;
    return widget.systemList.where((system) {
      final name = (system.name ?? "").toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final systems = _filteredSystems;

    return Scaffold(
      backgroundColor: CustomColors.appThemeColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(width),
            Expanded(
              child: systems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _searchQuery.isNotEmpty
                                ? Icons.search_off_rounded
                                : Icons.settings_suggest_rounded,
                            color: Colors.white24,
                            size: 56,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? "No systems match \"$_searchQuery\""
                                : "No systems available",
                            style: GoogleFonts.outfit(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: systems.length,
                      itemBuilder: (context, index) {
                        final system = systems[index];
                        final sensorCount = system.sensors?.length ?? 0;
                        // Determine system health based on sensor count
                        final bool hasData = sensorCount > 0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                final sensors = system.sensors;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SensorList(
                                      sensors: sensors!,
                                      systemName: system.name!,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(22),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color:
                                      CustomColors.cardColor.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: Colors.greenAccent.withOpacity(0.1),
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
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(11),
                                          decoration: BoxDecoration(
                                            color: Colors.greenAccent
                                                .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: const Icon(
                                            Icons.settings_suggest_rounded,
                                            color: Colors.greenAccent,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                (system.name ??
                                                        "Unnamed System")
                                                    .toHumanReadable(),
                                                style: GoogleFonts.outfit(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                system.description ??
                                                    "Earthing system",
                                                style: GoogleFonts.outfit(
                                                  color: Colors.white38,
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Colors.white.withOpacity(0.2),
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.04),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        children: [
                                          _buildStatChip(
                                            icon: Icons.sensors_rounded,
                                            label: "$sensorCount Earth Pits",
                                            color: Colors.orangeAccent,
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: (hasData
                                                      ? Colors.greenAccent
                                                      : Colors.white38)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: (hasData
                                                        ? Colors.greenAccent
                                                        : Colors.white38)
                                                    .withOpacity(0.2),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: hasData
                                                        ? Colors.greenAccent
                                                        : Colors.white38,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  hasData
                                                      ? "Connected"
                                                      : "No Pits",
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: hasData
                                                        ? Colors.greenAccent
                                                        : Colors.white38,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color.withOpacity(0.7), size: 14),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SYSTEMS",
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: Colors.white54,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    "System Inventory",
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${widget.systemList.length} Total",
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
        cursorColor: Colors.greenAccent,
        decoration: InputDecoration(
          hintText: "Search systems...",
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

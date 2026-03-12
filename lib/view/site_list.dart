import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ies_mobile/providers/user_info_provider.dart';
import 'package:ies_mobile/res/colors.dart';
import 'package:ies_mobile/utils/string_utils.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
    getUserInfo();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future getUserInfo() async {
    final sp = await SharedPreferences.getInstance();
    var id = sp.get("UserId");
    userInfoProvider!.getUserInfo(id);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: CustomColors.appThemeColor,
      body: Column(
        children: [
          _buildHeader(width),
          Expanded(
            child: Consumer<UserInfoProvider>(
              builder: (context, value, child) {
                if (value.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white54),
                    ),
                  );
                }

                final allSites = value.userDetails?.sites ?? [];
                final sites = allSites.where((site) {
                  if (_searchQuery.isEmpty) return true;
                  final name = (site.name ?? "").toLowerCase();
                  return name.contains(_searchQuery.toLowerCase());
                }).toList();

                if (sites.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off_rounded
                              : Icons.location_off_rounded,
                          color: Colors.white24,
                          size: 56,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? "No sites match \"$_searchQuery\""
                              : "No sites available",
                          style: GoogleFonts.outfit(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: sites.length,
                  itemBuilder: (context, index) {
                    final site = sites[index];
                    final systemCount = site.systems?.length ?? 0;
                    final sensorCount = site.systems?.fold<int>(0,
                            (sum, sys) => sum + (sys.sensors?.length ?? 0)) ??
                        0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final systems = site.systems;
                            if (systems != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SystemList(systemList: systems),
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(22),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: CustomColors.cardColor.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.blueAccent.withOpacity(0.1),
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
                                        color:
                                            Colors.blueAccent.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.location_on_rounded,
                                        color: Colors.blueAccent,
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
                                            (site.name ?? "Unnamed Site")
                                                .toHumanReadable(),
                                            style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            site.description ??
                                                "Managed location",
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
                                        icon: Icons.settings_suggest_rounded,
                                        label: "$systemCount Systems",
                                        color: Colors.greenAccent,
                                      ),
                                      const SizedBox(width: 16),
                                      _buildStatChip(
                                        icon: Icons.sensors_rounded,
                                        label: "$sensorCount Earth Pits",
                                        color: Colors.orangeAccent,
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
                );
              },
            ),
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
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
            "Sites",
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.white54,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Managed Locations",
            style: GoogleFonts.outfit(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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
        cursorColor: Colors.blueAccent,
        decoration: InputDecoration(
          hintText: "Search sites...",
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

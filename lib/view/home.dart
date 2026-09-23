import "dart:io";
import "dart:async";

import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:ies_mobile/providers/user_info_provider.dart";
import "package:ies_mobile/services/secure_storage_service.dart";
import "package:ies_mobile/view/login_screen.dart";
import "package:ies_mobile/view/reports.dart";
import "package:ies_mobile/view/site_list.dart";
import "package:jwt_decoder/jwt_decoder.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../providers/loin_logout.dart";
import "../providers/pit_status_provider.dart";
import "../res/colors.dart";
import "../config/app_config.dart";
import "dashboard_items.dart";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _index = 0;
  String? name;
  SharedPreferences? sharedPreferences;
  LoginLogout? log;
  PitStatusProvider? pitStatusProvider;
  UserInfoProvider? userInfoProvider;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
    pitStatusProvider = Provider.of<PitStatusProvider>(context, listen: false);

    log = Provider.of<LoginLogout>(context, listen: false);
    getUserInfo().then((val) => {
          setState(() {}),
        });

    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: AppConfig.dashboardRefreshIntervalSeconds),
      (timer) {
        if (_index == 0) {
          _refreshDashboardData();
        }
      },
    );
  }

  void _refreshDashboardData() async {
    var id = await SecureStorageService.getUserId();
    if (id != null) {
      if (userInfoProvider != null) {
        userInfoProvider!.getUserInfo(id);
      }
      if (pitStatusProvider != null) {
        pitStatusProvider!.getPitStatusFromProvider(id);
      }
    }
  }

  Future<String?> getUserInfo() async {
    name = await SecureStorageService.getUserName();
    var accessToken = await SecureStorageService.getAccessToken();

    if (accessToken == null || accessToken.isEmpty || JwtDecoder.isExpired(accessToken)) {
      debugPrint("Token is expired or missing ❌");
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ));
      }
      return null;
    } else {
      DateTime expirationDate = JwtDecoder.getExpirationDate(accessToken);
      debugPrint("Token is still valid ✅");
      debugPrint("Expires at: $expirationDate");
    }
    var id = await SecureStorageService.getUserId();
    if (id != null) {
      if (userInfoProvider != null) {
        userInfoProvider!.getUserInfo(id);
      }
      if (pitStatusProvider != null) {
        pitStatusProvider!.getPitStatusFromProvider(id);
      }
    }
    return null;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: CustomColors.appThemeColor,
      body: SafeArea(
        child: _index == 0
            ? userDashBoard(width)
            : _index == 1
                ? const SiteList()
                : _index == 2
                    ? const Reports()
                    : const SizedBox(),
      ),
      bottomNavigationBar: bottomNavBar(),
    );
  }

  Widget bottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff0C1B3A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.dashboard_rounded, "Dashboard", 0),
              _buildNavItem(Icons.location_on_rounded, "Sites", 1),
              _buildNavItem(Icons.analytics_rounded, "Reports", 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _index == index;
    return InkWell(
      onTap: () => setState(() => _index = index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blueAccent.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blueAccent : Colors.white38,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: Colors.blueAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget userDashBoard(width) {
    return Consumer<UserInfoProvider>(
      builder: (context, userInfo, child) {
        return Column(
          children: [
            _buildHeader(width),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Stats Row
                    _buildQuickStatsRow(userInfo),
                    const SizedBox(height: 24),
                    // Status Overview Title
                    Text(
                      "Status Overview",
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Dashboard Cards Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      children: [
                        DashboardItem(
                          customerID: "",
                          displayTitle: "Total Pits",
                          filter: "All",
                        ),
                        DashboardItem(
                          customerID: "",
                          displayTitle: "Active Pits",
                          filter: "Active",
                        ),
                        DashboardItem(
                          customerID: "",
                          displayTitle: "Critical Pits",
                          filter: "Critical",
                        ),
                        DashboardItem(
                          customerID: "",
                          displayTitle: "Inactive Pits",
                          filter: "Inactive",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Quick Actions
                    Text(
                      "Quick Actions",
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.location_on_rounded,
                            label: "View Sites",
                            color: Colors.blueAccent,
                            onTap: () => setState(() => _index = 1),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.analytics_rounded,
                            label: "Reports",
                            color: Colors.purpleAccent,
                            onTap: () => setState(() => _index = 2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickStatsRow(UserInfoProvider userInfo) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xff1A3A6C).withOpacity(0.7),
            const Color(0xff0F2548).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          _buildMiniStat(
            icon: Icons.location_on_rounded,
            label: "Sites",
            value: "${userInfo.userDetails?.sites?.length ?? 0}",
            color: Colors.blueAccent,
          ),
          _buildStatDivider(),
          _buildMiniStat(
            icon: Icons.settings_suggest_rounded,
            label: "Systems",
            value: "${userInfo.systemsList.length}",
            color: Colors.greenAccent,
          ),
          _buildStatDivider(),
          _buildMiniStat(
            icon: Icons.sensors_rounded,
            label: "Earth Pits",
            value: "${userInfo.sensors.length}",
            color: Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: Colors.white54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white.withOpacity(0.08),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: CustomColors.cardColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.25),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double width) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.withOpacity(0.4),
                          Colors.cyanAccent.withOpacity(0.2),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.2), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        (name ?? "U")[0].toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back,",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        name ?? "User",
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () => log!.onBackPressed(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    color: Colors.white54, size: 16),
                const SizedBox(width: 10),
                Text(
                  _getFormattedDate(),
                  style: GoogleFonts.outfit(
                    color: Colors.white60,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "System Online",
                  style: GoogleFonts.outfit(
                    color: Colors.greenAccent.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} ${now.year}";
  }
}

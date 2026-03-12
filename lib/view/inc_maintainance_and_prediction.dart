import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../res/colors.dart';

class IncidentPredAndMain extends StatefulWidget {
  final String sensorName;
  final String? lastMaintenanceDate;
  final String? nextMaintenanceDate;
  final String? maintainerName;
  final String? maintenanceNotes;
  final String? status;

  const IncidentPredAndMain({
    super.key,
    required this.sensorName,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    this.maintainerName,
    this.maintenanceNotes,
    this.status,
  });

  @override
  State<IncidentPredAndMain> createState() => _IncidentPredAndMainState();
}

class _IncidentPredAndMainState extends State<IncidentPredAndMain> {
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
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04, vertical: 20),
                child: Column(
                  children: [
                    // Overview Card
                    _buildGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(
                              Icons.info_outline_rounded, "Overview"),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            icon: Icons.sensors_rounded,
                            label: "Earth Pit",
                            value: widget.sensorName,
                            color: Colors.greenAccent,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.flag_rounded,
                            label: "Status",
                            value: widget.status ?? "N/A",
                            color: _getStatusColor(widget.status),
                            isBadge: true,
                          ),
                          if (widget.maintainerName != null) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              icon: Icons.person_outline_rounded,
                              label: "Maintainer",
                              value: widget.maintainerName!,
                              color: Colors.purpleAccent,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Schedule Card
                    _buildGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(
                              Icons.calendar_month_rounded, "Schedule"),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            icon: Icons.history_rounded,
                            label: "Last Service Date",
                            value: widget.lastMaintenanceDate ?? "N/A",
                            color: Colors.amberAccent,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.schedule_rounded,
                            label: "Next Service Date",
                            value: widget.nextMaintenanceDate ?? "N/A",
                            color: Colors.lightGreenAccent,
                          ),
                        ],
                      ),
                    ),
                    if (widget.maintenanceNotes != null &&
                        widget.maintenanceNotes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      // Notes Card
                      _buildGlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(Icons.notes_rounded, "Notes"),
                            const SizedBox(height: 12),
                            Text(
                              widget.maintenanceNotes!,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.sensorName,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              "Maintenance Details",
              style: GoogleFonts.outfit(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CustomColors.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blueAccent, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isBadge = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: color.withOpacity(0.7), size: 18),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: Colors.white54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        if (isBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          )
        else
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case "COMPLETED":
        return Colors.greenAccent;
      case "PENDING":
        return Colors.amberAccent;
      case "OVERDUE":
        return Colors.redAccent;
      default:
        return Colors.white38;
    }
  }
}

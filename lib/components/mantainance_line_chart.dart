import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../res/colors.dart';

class LineChartSample3 extends StatefulWidget {
  LineChartSample3({
    super.key,
    Color? lineColor,
    Color? indicatorLineColor,
    Color? indicatorTouchedLineColor,
    Color? indicatorSpotStrokeColor,
    Color? indicatorTouchedSpotStrokeColor,
    Color? bottomTextColor,
    Color? bottomTouchedTextColor,
    Color? averageLineColor,
    Color? tooltipBgColor,
    Color? tooltipTextColor,
  })  : lineColor = lineColor ?? AppColors.contentColorRed,
        indicatorLineColor =
            indicatorLineColor ?? AppColors.contentColorYellow.withOpacity(0.2),
        indicatorTouchedLineColor =
            indicatorTouchedLineColor ?? AppColors.contentColorYellow,
        indicatorSpotStrokeColor = indicatorSpotStrokeColor ??
            AppColors.contentColorYellow.withOpacity(0.5),
        indicatorTouchedSpotStrokeColor =
            indicatorTouchedSpotStrokeColor ?? AppColors.contentColorYellow,
        bottomTextColor =
            bottomTextColor ?? AppColors.contentColorYellow.withOpacity(0.2),
        bottomTouchedTextColor =
            bottomTouchedTextColor ?? AppColors.contentColorYellow,
        averageLineColor =
            averageLineColor ?? AppColors.contentColorGreen.withOpacity(0.8),
        tooltipBgColor = tooltipBgColor ?? AppColors.contentColorGreen,
        tooltipTextColor = tooltipTextColor ?? Colors.black;

  final Color lineColor;
  final Color indicatorLineColor;
  final Color indicatorTouchedLineColor;
  final Color indicatorSpotStrokeColor;
  final Color indicatorTouchedSpotStrokeColor;
  final Color bottomTextColor;
  final Color bottomTouchedTextColor;
  final Color averageLineColor;
  final Color tooltipBgColor;
  final Color tooltipTextColor;

  final List<String> weekDays = [
    '2/2/19',
    '2/2/20',
    '2/2/21',
    '2/2/22',
    '2/2/23',
    '2/2/24',
    '2/2/25'
  ];

  final List<double> yValues = [1.3, 1, 1.8, 1.5, 2.2, 1.8, 3];

  @override
  State createState() => _LineChartSample3State();
}

class _LineChartSample3State extends State<LineChartSample3> {
  late double touchedValue;

  @override
  void initState() {
    touchedValue = -1;
    super.initState();
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    if (value % 1 != 0) {
      return Container();
    }
    final style = TextStyle(
      color: AppColors.mainTextColor1.withOpacity(0.5),
      fontSize: 10,
    );
    final Map<int, String> labels = {1: '1 ohms', 2: '2 ohms', 3: '3 ohms'};

    return labels.containsKey(value.toInt())
        ? Text(labels[value.toInt()]!, style: style, textAlign: TextAlign.center)
        : Container();
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    if (value % 1 != 0 || value.toInt() >= widget.weekDays.length) {
      return Container();
    }
    return Text(
      widget.weekDays[value.toInt()],
      style: TextStyle(
        color: value == touchedValue ? widget.bottomTouchedTextColor : Colors.white54,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 30),
        AspectRatio(
          aspectRatio: 1.4,
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 12),
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  getTouchedSpotIndicator: (barData, spotIndexes) {
                    return spotIndexes
                        .where((index) => index > 0 && index < widget.yValues.length - 1)
                        .map((spotIndex) {
                      return TouchedSpotIndicatorData(
                        FlLine(color: widget.indicatorTouchedLineColor, strokeWidth: 4),
                        FlDotData(
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 8,
                              color: Colors.white,
                              strokeWidth: 5,
                              strokeColor: widget.indicatorTouchedSpotStrokeColor,
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (LineBarSpot spot) => widget.tooltipBgColor, // Make sure widget.tooltipBgColor is passed correctly
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots
                          .where((barSpot) => barSpot.x > 0 && barSpot.x < widget.yValues.length - 1)
                          .map((barSpot) {
                        return LineTooltipItem(
                          '${widget.weekDays[barSpot.x.toInt()]}\n',
                          TextStyle(color: widget.tooltipTextColor, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: '${barSpot.y.toString()} ohms\n',
                              style: TextStyle(color: widget.tooltipTextColor, fontWeight: FontWeight.w900),
                            ),
                            const TextSpan(
                              text: 'Completed',
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                  touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    if (!event.isInterestedForInteractions ||
                        touchResponse?.lineBarSpots == null ||
                        touchResponse!.lineBarSpots!.isEmpty) {
                      setState(() => touchedValue = -1);
                      return;
                    }
                    final value = touchResponse.lineBarSpots![0].x;
                    if (value == 0 || value == widget.yValues.length - 1) {
                      setState(() => touchedValue = -1);
                      return;
                    }
                    setState(() => touchedValue = value);
                  },
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(y: 1.8, color: widget.averageLineColor, strokeWidth: 3, dashArray: [20, 10]),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    isStepLineChart: true,
                    spots: List.generate(widget.yValues.length, (i) => FlSpot(i.toDouble(), widget.yValues[i])),
                    isCurved: false,
                    barWidth: 4,
                    color: widget.lineColor,
                    belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [
                      widget.lineColor.withOpacity(0.5),
                      widget.lineColor.withOpacity(0),
                    ])),
                  ),
                ],
                minY: 0,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: leftTitleWidgets)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: bottomTitleWidgets)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

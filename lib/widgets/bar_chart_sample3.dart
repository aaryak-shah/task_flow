import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartSample3 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BarChartSample3State();
}

class BarChartSample3State extends State<BarChartSample3> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: Container(
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceEvenly,
            maxY: 20,
            barTouchData: BarTouchData(
              enabled: false,
              touchTooltipData: BarTouchTooltipData(
                tooltipRoundedRadius: 4,
                tooltipBgColor: Colors.transparent,
                tooltipBottomMargin: 4,
                getTooltipItem: (
                  BarChartGroupData group,
                  int groupIndex,
                  BarChartRodData rod,
                  int rodIndex,
                ) {
                  return BarTooltipItem(
                    rod.y.round().toString(),
                    TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: SideTitles(
                rotateAngle: -45,
                showTitles: true,
                textStyle: TextStyle(
                    color: const Color(0xff7589a2), fontWeight: FontWeight.bold, fontSize: 13),
                margin: 20,
                getTitles: (double value) {
                  switch (value.toInt()) {
                    case 0:
                      return 'Label1';
                    case 1:
                      return 'Label2';
                    case 2:
                      return 'Label3';
                    case 3:
                      return 'Label4';
                    case 4:
                      return 'Label5';
                    case 5:
                      return 'Label6';
                    case 6:
                      return 'Other';
                    default:
                      return '';
                  }
                },
              ),
              leftTitles: SideTitles(showTitles: false),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            barGroups: [
              BarChartGroupData(
                  x: 0,
                  barRods: [BarChartRodData(y: 8, color: Colors.lightBlueAccent,width:30,borderRadius: BorderRadius.circular(5))],
                  showingTooltipIndicators: [0]),
              BarChartGroupData(
                  x: 1,
                  barRods: [BarChartRodData(y: 10, color: Colors.lightBlueAccent,width:30,borderRadius: BorderRadius.circular(5))],
                  showingTooltipIndicators: [0]),
              BarChartGroupData(
                  x: 2,
                  barRods: [BarChartRodData(y: 14, color: Colors.lightBlueAccent,width:30,borderRadius: BorderRadius.circular(5))],
                  showingTooltipIndicators: [0]),
              BarChartGroupData(
                  x: 3,
                  barRods: [BarChartRodData(y: 15, color: Colors.lightBlueAccent,width:30,borderRadius: BorderRadius.circular(5))],
                  showingTooltipIndicators: [0]),
              BarChartGroupData(
                  x: 4,
                  barRods: [BarChartRodData(y: 13, color: Colors.lightBlueAccent,width:30,borderRadius: BorderRadius.circular(5))],
                  showingTooltipIndicators: [0]),
              BarChartGroupData(
                  x: 5,
                  barRods: [BarChartRodData(y: 10, color: Colors.lightBlueAccent,width:30,borderRadius: BorderRadius.circular(5))],
                  showingTooltipIndicators: [0]),
            ],
          ),
        ),
      ),
    );
  }
}

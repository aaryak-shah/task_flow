import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/tasks.dart';

class Chart extends StatefulWidget {
  // Arguments => selectedDay: the day on the chart selected by the user, to be highlighted in the accent colour
  //
  // Creates a chart widget showing the fraction of time spent working on tasks on a particular day
  // in the past week compared to the total time spent working in the week

  final int selectedDay;
  Chart(this.selectedDay);

  @override
  State<StatefulWidget> createState() => ChartState();
}

class ChartState extends State<Chart> {
  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<Tasks>(context);

    final weekTasks = tasks.weekTasks;

    final Duration totalTime = tasks.totalTime;

    return AspectRatio(
      aspectRatio: 2.5,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Card(
          elevation: 0,
          // shape:
          //     RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: SideTitles(
                    showTitles: true,
                    getTextStyles: (_) => TextStyle(
                      color: Theme.of(context).unselectedWidgetColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    margin: 20,
                    getTitles: (value) {
                      return DateFormat.E().format(
                        DateTime.now().subtract(
                          Duration(
                            days: value.toInt(),
                          ),
                        ),
                      )[0];
                    },
                  ),
                  leftTitles: SideTitles(showTitles: false),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: weekTasks.map((t) {
                  return BarChartGroupData(
                    x: t['day'] as int,
                    barRods: [
                      BarChartRodData(
                        y: totalTime != Duration()
                            ? (t['time'] as Duration).inSeconds /
                                totalTime.inSeconds
                            : 0,
                        colors: [
                          (t['day'] != 6 - widget.selectedDay
                              ? Theme.of(context).unselectedWidgetColor
                              : Theme.of(context).accentColor),
                        ],
                      )
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

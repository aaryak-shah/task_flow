import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/tasks.dart';

class Chart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChartState();
}

class ChartState extends State<Chart> {
  @override
  Widget build(BuildContext context) {
    final recentTasks = Provider.of<Tasks>(context).recentTasks;

    final weekTasks = List.generate(7, (index) {
      final weekDay = DateTime.now().subtract(Duration(days: index));
      Duration total = Duration();

      for (int i = 0; i < recentTasks.length; i++) {
        if (recentTasks[i].latestPause.day == weekDay.day &&
            recentTasks[i].latestPause.month == weekDay.month &&
            recentTasks[i].latestPause.year == weekDay.year) {
          total += (recentTasks[i].getRunningTime());
        }
      }

      return {'day': index, 'time': total};
    }).reversed.toList();

    final Duration totalTime = weekTasks.fold(
        Duration(), (previousSum, day) => previousSum + day['time']);

    return AspectRatio(
      aspectRatio: 2.5,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: Theme.of(context).primaryColor,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 1,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: SideTitles(
                showTitles: true,
                textStyle: TextStyle(
                    // color: const Color(0xff7589a2),
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
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
                x: t['day'],
                barRods: [
                  BarChartRodData(
                    y: totalTime != Duration()
                        ? (t['time'] as Duration).inSeconds /
                            totalTime.inSeconds
                        : 0,
                    color: t['day'] != 0
                        ? Colors.white
                        : Theme.of(context).accentColor,
                  )
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

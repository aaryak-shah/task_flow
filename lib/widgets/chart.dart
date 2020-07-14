import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tasks.dart';
import '../providers/task.dart';

class Chart extends StatefulWidget {
  final List<Task> recentTasks;

  Chart(this.recentTasks);

  List<Map<String, Object>> get weekTasks {
    return List.generate(7, (index) {
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
    }).toList();
  }

  Duration get totalTime {
    return weekTasks.fold(
        Duration(), (previousSum, day) => previousSum + day['time']);
  }

  @override
  State<StatefulWidget> createState() => ChartState();
}

class ChartState extends State<Chart> {
  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<Tasks>(context).tasks;

    return AspectRatio(
      aspectRatio: 2.5,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: Theme.of(context).primaryColor,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 24,
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
                getTitles: (double value) {
                  switch (value.toInt()) {
                    case 0:
                      return 'M';
                    case 1:
                      return 'T';
                    case 2:
                      return 'W';
                    case 3:
                      return 'T';
                    case 4:
                      return 'F';
                    case 5:
                      return 'S';
                    case 6:
                      return 'S';
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
                barRods: [BarChartRodData(y: 8, color: Colors.white)],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [BarChartRodData(y: 10, color: Colors.white)],
              ),
              BarChartGroupData(
                x: 2,
                barRods: [BarChartRodData(y: 14, color: Colors.white)],
              ),
              BarChartGroupData(
                x: 3,
                barRods: [BarChartRodData(y: 15, color: Colors.white)],
              ),
              BarChartGroupData(
                x: 4,
                barRods: [BarChartRodData(y: 18, color: Colors.white)],
              ),
              BarChartGroupData(
                x: 5,
                barRods: [BarChartRodData(y: 10, color: Colors.white)],
              ),
              BarChartGroupData(
                x: 6,
                barRods: [
                  BarChartRodData(y: 11, color: Theme.of(context).accentColor)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

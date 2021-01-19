import 'package:flutter/material.dart';
import 'package:task_flow/widgets/floating_action_button.dart';
import '../widgets/app_bar.dart';
import '../widgets/pie_chart.dart';
import '../widgets/bar_chart_sample3.dart';
import '../widgets/bar_chart_sample1.dart';
import '../widgets/scatter_chart_sample2.dart';
import '../widgets/line_chart_sample2.dart';
// Screen to display statistics from the Flask API
class StatsScreen extends StatefulWidget {
  static const routeName = '/stats-screen';
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar(context),
      backgroundColor: Theme.of(context).primaryColor,
      body:  ListView(
          
          children:<Widget>[
            Container(
              height:200,
              color:Colors.grey[700],
              alignment: Alignment.center,
              child:Container(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                mytile('Total Duration','26Hrs'),
                mytile('Total Projects','8'),
                mytile('Total Clients','3'),
                mytile('Total Revenue','Rs.1200'),
                mytile('Your Efficiency','84%'),    
              ],)
              ),
            ),
            Container(
              color:Colors.blue,
              child: Card(
                elevation: 2,
                color: Colors.red[900],
                child : Column(
                  children:[
                    Align(
                      alignment: Alignment.centerLeft,
                      child:Text('TASKS',style:TextStyle(fontSize: 20)),
                    ),
                    Text('Categories by time chart:'),
                    SizedBox(height: 10,),
                    PieChartSample2(),
                    SizedBox(height: 20,),
                    Text('Categories by time chart:'),
                    BarChartSample3(),
                    SizedBox(height: 20,)
                    ])
                ),
            ),
            Container(
              color:Colors.blue[900],
              child : Card(
                child: 
                  Column(
                    children: [
                       Align(
                          alignment: Alignment.centerLeft,
                          child:Text('PROJECTS',style:TextStyle(fontSize: 20)),
                        ),
                      Container(
                        height:400,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                          Column(children: [
                            Text('Projects by time chart:'),
                          Expanded(child: ScatterChartSample2()),
                          ],),
                          Column(children:[
                            Text('Clients by time chart:'),
                          Expanded(child: LineChartSample2()),
                          ]
                          ),
                          Column(children: [
                            Text('Projects by revenue chart:'),
                          Expanded(child: BarChartSample1()),
                          ],),
                          
                        ],),
                      ),
                    ],
                  ),
              ),
            ),
            ]),
      floatingActionButton: Container(child:Row(children:[SizedBox(width:290),FancyFab()])),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
Widget mytile(String title,String quantity){
  return Card(
                  child: Container(
                  width: 150,
                  height: 100,
                  child: Center(
                    child:Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        Text(title),
                        Text(quantity),
                        ],)
                            )
                          )
                    );
}

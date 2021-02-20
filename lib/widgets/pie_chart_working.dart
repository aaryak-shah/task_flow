import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'indicator.dart';

class PieChartSample2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State {
  int touchedIndex;
  String url =
      "https://taskflowrestapi.herokuapp.com/stats/DvAfpHSHWFcqt53gSWiIXuSGEIo1/20000";
  var data = {};
  var categories;
  
  String myjsonresponse = "Extracting data...";
  List<Color> colorslist = [Color.fromRGBO(0, 0, 232, 0.7),Color.fromRGBO(232, 0, 0, 0.7),Color.fromRGBO(0, 232, 0, 0.7),Color.fromRGBO(232, 232, 0, 0.7),Color.fromRGBO(0, 232, 232, 0.7),Color.fromRGBO(232, 0, 232, 0.7),];
  Future<String> makeRequest() async {
  var response = await http
      .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
  


  setState(() {
    myjsonresponse = response.body;
    print(response.body);
    var extractdata = jsonDecode(response.body);
    data = extractdata["category"]["duration"];
    // data = {"Chores":3.0,"Miscellaneous":4.0,"Education":7.0,"Personal Development":9.0,"Wellness":12.0,"Recreational":15.0};
    categories = data.keys;
    print(data);
  });
  

  }
  @override
  void initState() {
    this.makeRequest();
    print(myjsonresponse);
  }    

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.6,
      child: categories == null? Center(child: CircularProgressIndicator( valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]),)):
      Column(
        children: <Widget>[
          
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const SizedBox(
                            height: 18,
                          ),
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: PieChart(
                                PieChartData(
                                    pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
                                      setState(() {
                                        if (pieTouchResponse.touchInput is FlLongPressEnd ||
                                            pieTouchResponse.touchInput is FlPanEnd) {
                                          touchedIndex = -1; 
                                        } else {
                                          touchedIndex = pieTouchResponse.touchedSectionIndex;
                                        }
                                      });
                                    }),
                                    borderData: FlBorderData(
                                      show: false,
                                    ),
                                    sectionsSpace: 0,
                                    centerSpaceRadius: 40,
                                    sections: showingSections()),
                              ),
                            ),
                          ),
                          

                        ],
                      ),
                      Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              for(var i=0;i<data.length;i++)

                                Indicator(
                                color: colorslist[i],
                                text: categories.elementAt(i),
                                isSquare: true,
                                ),
                                SizedBox(
                                  height: 4,
                                ),

                            ],
                          ),
                          SizedBox(height: 28,)
                    ],
                  ),
                  
                ],
              ),
            ),
          ),

        ],
      ),
      
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(categories.length, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 25 : 16;
      final double radius = isTouched ? 70 : 50;

      return PieChartSectionData(
          color: colorslist[i],
          value: data[categories.elementAt(i)],
          title: '',
          radius: radius,
          titleStyle: TextStyle(
              fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
      );
  });
  }
}

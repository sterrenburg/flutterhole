import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyLineChart extends StatefulWidget {
  final List<FlSpot> greenSpots;
  final List<FlSpot> redSpots;
  final double maxY;
  final String tooltipPrefix;

  const MyLineChart(
      {Key key,
      @required this.greenSpots,
      @required this.redSpots,
      @required this.maxY,
      this.tooltipPrefix = ''})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => MyLineChartState();
}

class MyLineChartState extends State<MyLineChart> {
  static final _colors = [
    Colors.green,
    Colors.red,
  ];

  final DateTime now = DateTime.now();

  StreamController<LineTouchResponse> controller;

  @override
  void initState() {
    super.initState();
    controller = StreamController();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.23,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SafeArea(
              minimum: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Queries over last 24 hours",
                    style: Theme.of(context).textTheme.title,
                  ),
                  Divider(),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 6.0),
                child: FlChart(
                  chart: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalGrid: true,
                        horizontalInterval: 200.0,
                        // TODO add vertical legend
                        verticalInterval: 50
//                        (widget.maxY + (widget.maxY % 50)) /
//                            _verticalInterval
                        ,
                      ),
                      lineTouchData: LineTouchData(
                          touchResponseSink: controller.sink,
                          touchTooltipData: TouchTooltipData(
                              tooltipBgColor: Theme.of(context).cardColor,
                              getTooltipItems:
                                  (List<TouchedSpot> touchedSpots) {
                                if (touchedSpots == null) {
                                  return null;
                                }

                                return touchedSpots
                                    .map((TouchedSpot touchedSpot) {
                                  if (touchedSpots == null ||
                                      touchedSpot.spot == null) {
                                    return null;
                                  }

                                  String text =
                                      touchedSpot.spot.y.toInt().toString();

                                  final color = touchedSpot.getColor();

                                  if (color == _colors.first)
                                    text = 'Total: $text';
                                  if (color == _colors.last)
                                    text = 'Blocked: $text';

                                  return TooltipItem(
                                      text,
                                      Theme.of(context)
                                          .textTheme
                                          .caption
                                          .copyWith(
                                              color: color,
                                              fontWeight: FontWeight.bold));
                                }).toList();
                              })),
                      titlesData: FlTitlesData(
                        bottomTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          textStyle: Theme.of(context).textTheme.caption,
                          margin: 10,
                          getTitles: (value) {
                            final index = value / 100;
                            return (index).toInt().toString();
                          },
                        ),
                        leftTitles: SideTitles(
                          showTitles: true,
                          textStyle: TextStyle(
                            color: Color(0xff75729e),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          getTitles: (value) {
                            return value.toInt().toString();
                          },
                          margin: 8,
                          reservedSize: 30,
                        ),
                      ),
                      borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xff4e4965),
                              width: 4,
                            ),
                            left: BorderSide(
                              color: Colors.transparent,
                            ),
                            right: BorderSide(
                              color: Colors.transparent,
                            ),
                            top: BorderSide(
                              color: Colors.transparent,
                            ),
                          )),
                      minX: 0.0,
                      minY: 0.0,
                      maxY: widget.maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: widget.greenSpots,
                          isCurved: true,
                          colors: [
                            Colors.green,
                          ],
                          belowBarData: BelowBarData(
                            show: true,
                            colors: [Colors.green.withOpacity(0.2)],
                          ),
                          barWidth: 4.0,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: false,
                          ),
                        ),
                        LineChartBarData(
                          spots: widget.redSpots,
                          isCurved: true,
                          colors: [
                            Colors.red,
                          ],
                          belowBarData: BelowBarData(
                            show: true,
                            colors: [Colors.red.withOpacity(0.2)],
                          ),
                          barWidth: 4.0,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.close();
  }
}

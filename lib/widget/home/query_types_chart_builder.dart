import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/base/pihole/query_types.dart';
import 'package:flutterhole/model/query.dart';
import 'package:flutterhole/widget/home/indicator.dart';
import 'package:flutterhole/widget/home/pi_chart.dart';

class QueryTypesChartBuilder extends StatelessWidget {
  static final _colors = [
    Colors.lightBlue,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.indigo
  ];

  MaterialColor _color(int index) => _colors[index % (_colors.length - 1)];

  List<PieChartSectionData> _sectionsFromQueryTypes(
      QueryTypes queryTypes, double width) {
    List<PieChartSectionData> items = [];

    int index = 0;
    queryTypes.queryTypes.forEach((String title, double percent) {
      double value = percent;

      items.add(PieChartSectionData(
          title: value > 5.0 ? '${value.floor().toString()}%' : '',
          value: value,
          color: _color(index),
          radius: width));
      index++;
    });

    return items;
  }

  List<Indicator> _indicatorsFromQueryTypes(
      BuildContext context, QueryTypes queryTypes) {
    List<Indicator> indicators = [];
    int index = 0;
    queryTypes.queryTypes.forEach((String title, double percent) {
      indicators.add(Indicator(
        title: Row(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.0),
                child: Text(title)),
            Text(
              '${percent.toString()}%',
              style: Theme.of(context).textTheme.caption,
            )
          ],
        ),
        color: _color(index),
      ));
      index++;
    });

    return indicators;
  }

  @override
  Widget build(BuildContext context) {
    final QueryTypesBloc queryTypesBloc =
        BlocProvider.of<QueryTypesBloc>(context);
    return BlocBuilder(
      bloc: queryTypesBloc,
      builder: (context, state) {
        if (state is BlocStateSuccess<QueryTypes>) {
          final screenWidth = MediaQuery.of(context).size.width;
          return PiChart(
            title: 'Query Types',
            centerSpaceRadius: screenWidth / 8,
            sections: _sectionsFromQueryTypes(state.data, 50),
            indicators: _indicatorsFromQueryTypes(context, state.data),
          );
        }
        if (state is BlocStateError<QueryTypes>) {
          return Card(
              child: ListTile(
                leading: Icon(Icons.warning),
                title: Text('Cannot load query types: ${state.e.message}'),
              ));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

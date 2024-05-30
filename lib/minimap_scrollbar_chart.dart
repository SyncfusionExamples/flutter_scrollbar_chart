import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide LabelPlacement;
import 'package:syncfusion_flutter_core/core.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart'
    hide EdgeLabelPlacement;

import 'chart_data.dart';

class MinimapScrollbarChart extends StatefulWidget {
  const MinimapScrollbarChart({super.key});

  @override
  State<MinimapScrollbarChart> createState() => _MinimapScrollbarChartState();
}

class _MinimapScrollbarChartState extends State<MinimapScrollbarChart> {
  late List<ChartData> _chartData;
  late DateTime _startRange;
  late DateTime _endRange;
  late ZoomPanBehavior _zoomPanBehavior;

  final Random _random = Random();
  final int _dataCount = daysInYear(2020);

  RangeController? _rangeController;
  double _baseValue = 75;

  static int daysInYear(int year) {
    if (isLeapYear(year)) {
      return 366;
    } else {
      return 365;
    }
  }

  static bool isLeapYear(int year) {
    if (year % 4 == 0) {
      if (year % 100 == 0) {
        return year % 400 == 0;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  num _yValue() {
    if (_random.nextDouble() > 0.5) {
      _baseValue += _random.nextDouble();
      return _baseValue;
    } else {
      _baseValue -= _random.nextDouble();
      return _baseValue;
    }
  }

  @override
  void initState() {
    _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      zoomMode: ZoomMode.x,
      enablePinching: true,
      enableMouseWheelZooming: true,
    );
    DateTime date = DateTime(2020);
    _chartData = List.generate(_dataCount + 1, (int index) {
      final List<num> values = [_yValue(), _yValue(), _yValue(), _yValue()];
      values.sort();
      return ChartData(
        x: date.add(Duration(days: index)),
        high: values[0],
        low: values[3],
        open: values[1],
        close: values[2],
      );
    });
    _startRange = _chartData[0].x;
    _endRange = _chartData[_dataCount].x;
    _rangeController = RangeController(
      start: _startRange,
      end: _endRange,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      appBar: AppBar(title: const Text('Minimap Scrollbar Chart')),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: SfCartesianChart(
                margin: EdgeInsets.zero,
                primaryXAxis: DateTimeAxis(
                  rangeController: _rangeController,
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                ),
                primaryYAxis: const NumericAxis(
                  opposedPosition: true,
                  rangePadding: ChartRangePadding.round,
                ),
                series: <CartesianSeries<ChartData, DateTime>>[
                  CandleSeries(
                    dataSource: _chartData,
                    xValueMapper: (ChartData data, int index) => data.x,
                    highValueMapper: (ChartData data, int index) => data.high,
                    lowValueMapper: (ChartData data, int index) => data.low,
                    openValueMapper: (ChartData data, int index) => data.open,
                    closeValueMapper: (ChartData data, int index) => data.close,
                  ),
                ],
                zoomPanBehavior: _zoomPanBehavior,
              ),
            ),
            const SizedBox(height: 25),
            Container(
              height: 150,
              padding: const EdgeInsets.only(bottom: 10),
              child: SfRangeSelectorTheme(
                data: SfRangeSelectorThemeData(
                  thumbRadius: 0,
                  overlayRadius: 0,
                  activeRegionColor: colorScheme.primary.withOpacity(0.12),
                  inactiveRegionColor: Colors.transparent,
                ),
                child: SfRangeSelector(
                  min: _startRange,
                  max: _endRange,
                  controller: _rangeController,
                  showTicks: true,
                  showLabels: true,
                  interval: 1,
                  dateIntervalType: DateIntervalType.months,
                  dateFormat: DateFormat.MMM(),
                  labelPlacement: LabelPlacement.betweenTicks,
                  labelFormatterCallback:
                      (dynamic actualValue, String formattedText) {
                    if (formattedText.contains('Jan')) {
                      final year = DateFormat('yyyy').format(actualValue);
                      return ' $year $formattedText';
                    }
                    return formattedText;
                  },
                  child: SfCartesianChart(
                    margin: const EdgeInsets.all(0),
                    primaryXAxis: const DateTimeAxis(isVisible: false),
                    primaryYAxis: const NumericAxis(
                      isVisible: false,
                      rangePadding: ChartRangePadding.round,
                    ),
                    series: <CartesianSeries<ChartData, DateTime>>[
                      CandleSeries(
                        dataSource: _chartData,
                        xValueMapper: (ChartData data, int index) => data.x,
                        highValueMapper: (ChartData data, int index) =>
                            data.high,
                        lowValueMapper: (ChartData data, int index) => data.low,
                        openValueMapper: (ChartData data, int index) =>
                            data.open,
                        closeValueMapper: (ChartData data, int index) =>
                            data.close,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

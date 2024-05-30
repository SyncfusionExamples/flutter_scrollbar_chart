import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide LabelPlacement;
import 'package:syncfusion_flutter_core/core.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart'
    hide EdgeLabelPlacement;

import 'chart_data.dart';

class ScrollbarAxesChart extends StatefulWidget {
  const ScrollbarAxesChart({super.key});

  @override
  State<ScrollbarAxesChart> createState() => _ScrollbarAxesChartState();
}

class _ScrollbarAxesChartState extends State<ScrollbarAxesChart> {
  late List<ChartData> _chartData;
  late DateTime _xScrollbarStartRange;
  late DateTime _xScrollbarEndRange;
  late NumericAxisController _yAxisController;
  late num _yAxisActualMin;
  late num _yAxisActualMax;
  final ValueNotifier<SfRangeValues> _yScrollbarSelectedValues =
      ValueNotifier(const SfRangeValues(0, 1));

  final Random _random = Random();
  final int _dataCount = daysInYear(2020);
  final ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior(
    enablePanning: true,
    enablePinching: true,
    enableMouseWheelZooming: true,
    enableSelectionZooming: true,
  );

  RangeController? _xScrollbarController;
  double _baseValue = 75;
  Size _scrollbarSize = Size.zero;

  Offset _horizontalScrollbarStart = Offset.zero;
  Offset _verticalScrollbarStart = Offset.zero;

  void _updateScrollBarSize(Size size) {
    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      if (size != _scrollbarSize) {
        setState(() {
          _scrollbarSize = size;
          _horizontalScrollbarStart = Offset(0, size.height);
          _verticalScrollbarStart = Offset(size.width, size.height);
        });
      }
    });
  }

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
    _xScrollbarStartRange = _chartData[0].x;
    _xScrollbarEndRange = _chartData[_dataCount].x;
    _xScrollbarController = RangeController(
      start: _xScrollbarStartRange,
      end: _xScrollbarEndRange,
    );
    super.initState();
  }

  @override
  void dispose() {
    _yScrollbarSelectedValues.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(title: const Text('Scrollbar On Chart Axes')),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SfCartesianChart(
          margin: EdgeInsets.zero,
          primaryXAxis: DateTimeAxis(
            rangeController: _xScrollbarController,
            edgeLabelPlacement: EdgeLabelPlacement.shift,
          ),
          primaryYAxis: NumericAxis(
            opposedPosition: true,
            rangePadding: ChartRangePadding.round,
            onRendererCreated: (NumericAxisController controller) {
              _yAxisController = controller;
            },
          ),
          series: <CartesianSeries<ChartData, DateTime>>[
            HiloOpenCloseSeries(
              dataSource: _chartData,
              xValueMapper: (ChartData data, int index) => data.x,
              highValueMapper: (ChartData data, int index) => data.high,
              lowValueMapper: (ChartData data, int index) => data.low,
              openValueMapper: (ChartData data, int index) => data.open,
              closeValueMapper: (ChartData data, int index) => data.close,
              onCreateRenderer: (ChartSeries<ChartData, DateTime> series) {
                return _HiloOpenCloseSeriesRenderer(this);
              },
            ),
          ],
          zoomPanBehavior: _zoomPanBehavior,
          onActualRangeChanged: (ActualRangeChangedArgs args) {
            if (args.axisName == 'primaryYAxis') {
              _yAxisActualMin = args.actualMin;
              _yAxisActualMax = args.actualMax;
              SchedulerBinding.instance
                  .addPostFrameCallback((Duration timeStamp) {
                final num actualRange = args.actualMax - args.actualMin;
                double visibleMinNormalized =
                    (args.visibleMin - args.actualMin) / actualRange;
                double visibleMaxNormalized =
                    (args.visibleMax - args.actualMin) / actualRange;
                _yScrollbarSelectedValues.value =
                    SfRangeValues(visibleMinNormalized, visibleMaxNormalized);
              });
            }
          },
          annotations: [
            CartesianChartAnnotation(
              x: _horizontalScrollbarStart.dx,
              y: _horizontalScrollbarStart.dy,
              coordinateUnit: CoordinateUnit.logicalPixel,
              horizontalAlignment: ChartAlignment.near,
              widget: SizedBox(
                width: _scrollbarSize.width,
                child: SfRangeSelectorTheme(
                  data: const SfRangeSelectorThemeData(
                    thumbRadius: 0,
                    overlayRadius: 0,
                  ),
                  child: SfRangeSelector(
                    min: _xScrollbarStartRange,
                    max: _xScrollbarEndRange,
                    controller: _xScrollbarController,
                    child: const SizedBox(height: 0),
                  ),
                ),
              ),
            ),
            CartesianChartAnnotation(
              x: _verticalScrollbarStart.dx,
              y: _verticalScrollbarStart.dy,
              coordinateUnit: CoordinateUnit.logicalPixel,
              verticalAlignment: ChartAlignment.far,
              widget: SizedBox(
                width: 6,
                height: _scrollbarSize.height,
                child: ValueListenableBuilder<SfRangeValues>(
                  valueListenable: _yScrollbarSelectedValues,
                  builder: (BuildContext context, SfRangeValues values,
                      Widget? child) {
                    return SfRangeSliderTheme(
                      data: const SfRangeSliderThemeData(
                        thumbRadius: 0,
                        overlayRadius: 0,
                      ),
                      child: SfRangeSlider.vertical(
                        min: 0,
                        max: 1,
                        values: values,
                        onChanged: (SfRangeValues newValues) {
                          _yAxisController.visibleMinimum = lerpDouble(
                              _yAxisActualMin,
                              _yAxisActualMax,
                              newValues.start);
                          _yAxisController.visibleMaximum = lerpDouble(
                              _yAxisActualMin, _yAxisActualMax, newValues.end);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HiloOpenCloseSeriesRenderer
    extends HiloOpenCloseSeriesRenderer<ChartData, DateTime> {
  _HiloOpenCloseSeriesRenderer(this._state);

  final _ScrollbarAxesChartState _state;

  @override
  void performLayout() {
    super.performLayout();
    _state._updateScrollBarSize(size);
  }
}

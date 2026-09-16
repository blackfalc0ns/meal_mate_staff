import 'dispatcher_metric_type.dart';

class DispatcherMetricEntity {
  const DispatcherMetricEntity({required this.type, required this.count});

  final DispatcherMetricType type;
  final int count;
}

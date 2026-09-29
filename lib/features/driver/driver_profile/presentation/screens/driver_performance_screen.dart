import 'package:flutter/material.dart';

import '../../domain/entities/driver_performance_entity.dart';

class DriverPerformanceScreen extends StatelessWidget {
  const DriverPerformanceScreen({
    super.key,
    this.performance,
  });

  final DriverPerformanceEntity? performance;

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

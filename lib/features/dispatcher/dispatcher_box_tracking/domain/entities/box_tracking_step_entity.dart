import 'package:flutter/widgets.dart';

class BoxTrackingStepEntity {
  const BoxTrackingStepEntity({
    required this.title,
    this.description,
    this.time,
    this.icon,
    this.isCompleted = false,
    this.isActive = false,
  });

  final String title;
  final String? description;
  final String? time;
  final IconData? icon;
  final bool isCompleted;
  final bool isActive;
}

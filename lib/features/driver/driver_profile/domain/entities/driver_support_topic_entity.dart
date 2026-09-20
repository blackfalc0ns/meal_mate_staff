import 'package:flutter/material.dart';

class DriverSupportTopicEntity {
  const DriverSupportTopicEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}
